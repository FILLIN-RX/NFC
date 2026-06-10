import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/user_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/result.dart';
import '../../../home/presentation/providers/active_transfer_provider.dart';
import '../../../home/presentation/providers/token_list_provider.dart';
import '../../../token_creation/domain/models/token.dart';
import '../../../token_creation/presentation/providers/repository_provider.dart';
import '../../../token_history/data/services/history_service.dart';
import '../../../token_history/domain/models/transaction_record.dart';
import '../../data/services/bluetooth_service.dart';
import '../../data/services/nfc_service.dart';
import '../screens/transfer_selection_screen.dart';

part 'transfer_vm.g.dart';

/// Statut global d'un transfert, exposé à l'UI.
enum TransferStatus {
  idle,
  waiting,
  connected,
  transferring,
  received,
  success,
  error,
}

class TransferState {
  final TransferStatus status;
  final Token? token;
  final String? error;
  final bool isReceiveMode;
  final String method;
  final double? progress;

  const TransferState({
    this.status = TransferStatus.idle,
    this.token,
    this.error,
    this.isReceiveMode = false,
    this.method = 'nfc',
    this.progress,
  });

  bool get isBusy =>
      status == TransferStatus.waiting ||
      status == TransferStatus.connected ||
      status == TransferStatus.transferring;

  static const Object _keep = Object();

  TransferState copyWith({
    TransferStatus? status,
    Token? token,
    Object? error = _keep,
    bool? isReceiveMode,
    String? method,
    Object? progress = _keep,
  }) {
    return TransferState(
      status: status ?? this.status,
      token: token ?? this.token,
      error: identical(error, _keep) ? this.error : error as String?,
      isReceiveMode: isReceiveMode ?? this.isReceiveMode,
      method: method ?? this.method,
      progress: identical(progress, _keep) ? this.progress : progress as double?,
    );
  }
}

@riverpod
class TransferViewModel extends _$TransferViewModel {
  @override
  TransferState build() => const TransferState();

  /// Envoie un jeton existant via NFC (rôle émetteur / HCE).
  Future<void> startSend(String tokenId) async {
    final repository = ref.read(tokenRepositoryProvider);

    final tokenResult = await repository.getTokenById(tokenId);
    final token = switch (tokenResult) {
      Success(:final data) => data,
      Failure() => null,
    };

    if (token == null) {
      state = state.copyWith(status: TransferStatus.error, error: 'Jeton introuvable.');
      return;
    }

    if (token.isUsed) {
      state = state.copyWith(
        status: TransferStatus.error,
        error: 'Ce jeton a déjà été transféré. Il ne peut pas être réutilisé.',
      );
      return;
    }

    state = state.copyWith(
      token: token,
      isReceiveMode: false,
      status: TransferStatus.waiting,
      error: null,
      progress: 0.0,
    );
    ref.read(activeTransferProvider.notifier).start();

    final result = await ref.read(nfcServiceProvider).sendToken(token, onStage: _onStage);

    ref.read(activeTransferProvider.notifier).stop();

    switch (result) {
      case Success():
        await repository.updateTokenStatus(token.tokenId, 'transféré');
        _recordTransfer(token, TransactionType.outgoing, 'nfc');
        _refreshWallet();
        state = state.copyWith(status: TransferStatus.success, error: null, progress: 1.0);
      case Failure(:final message):
        state = state.copyWith(status: TransferStatus.error, error: message, progress: null);
    }
  }

  Future<String?> _checkReceivedToken(Token token) async {
    if (!token.verifyIntegrity()) {
      return 'Jeton invalide ou falsifié : l\'empreinte numérique ne correspond pas.';
    }
    final alreadyReceived = await ref.read(userServiceProvider).isTokenAlreadyReceived(token.tokenId);
    if (alreadyReceived) {
      return 'Ce jeton a déjà été reçu. Opération annulée pour éviter la duplication.';
    }
    return null;
  }

  /// Reçoit un jeton via NFC (rôle lecteur ISO-DEP).
  Future<void> startReceive() async {
    state = state.copyWith(
      isReceiveMode: true,
      status: TransferStatus.waiting,
      error: null,
      progress: 0.0,
    );
    ref.read(activeTransferProvider.notifier).start();

    final result = await ref.read(nfcServiceProvider).receiveToken(onStage: _onStage);

    switch (result) {
      case Success(:final data):
        final error = await _checkReceivedToken(data);
        if (error != null) {
          ref.read(activeTransferProvider.notifier).stop();
          state = state.copyWith(status: TransferStatus.error, error: error, progress: null);
        } else {
          state = state.copyWith(
            status: TransferStatus.received,
            token: data.copyWith(direction: 'incoming', statut: 'actif'),
            error: null,
            progress: 1.0,
          );
        }
      case Failure(:final message):
        ref.read(activeTransferProvider.notifier).stop();
        state = state.copyWith(status: TransferStatus.error, error: message, progress: null);
    }
  }

  Future<void> acceptToken() async {
    final token = state.token;
    if (token == null) return;

    ref.read(activeTransferProvider.notifier).start();
    final saveResult = await ref.read(tokenRepositoryProvider).saveToken(token);
    if (saveResult is Success) {
      ref.read(userServiceProvider).markTokenReceived(token.tokenId);
      _recordTransfer(token, TransactionType.incoming, state.method);
      _refreshWallet();
      if (state.method == 'bluetooth') {
        await ref.read(bluetoothServiceProvider).respondToTransfer(true);
      }
      ref.read(activeTransferProvider.notifier).stop();
      state = state.copyWith(status: TransferStatus.success, progress: 1.0);
    } else {
      ref.read(activeTransferProvider.notifier).stop();
      state = state.copyWith(
        status: TransferStatus.error,
        error: (saveResult as Failure).message,
        progress: null,
      );
    }
  }

  Future<void> rejectToken() async {
    if (state.method == 'bluetooth') {
      await ref.read(bluetoothServiceProvider).respondToTransfer(false);
    }
    ref.read(activeTransferProvider.notifier).stop();
    state = state.copyWith(
      status: TransferStatus.error,
      error: 'Transfert refusé.',
      progress: null,
    );
  }

  /// Envoie un jeton vers un appareil Bluetooth choisi (rôle client RFCOMM).
  Future<void> startBluetoothSend(String tokenId, String address) async {
    final repository = ref.read(tokenRepositoryProvider);

    final tokenResult = await repository.getTokenById(tokenId);
    final token = switch (tokenResult) {
      Success(:final data) => data,
      Failure() => null,
    };

    if (token == null) {
      state = state.copyWith(status: TransferStatus.error, error: 'Jeton introuvable.');
      return;
    }

    if (token.isUsed) {
      state = state.copyWith(
        status: TransferStatus.error,
        error: 'Ce jeton a déjà été transféré. Il ne peut pas être réutilisé.',
      );
      return;
    }

    state = state.copyWith(
      token: token,
      isReceiveMode: false,
      method: 'bluetooth',
      status: TransferStatus.connected,
      error: null,
      progress: 0.0,
    );
    ref.read(activeTransferProvider.notifier).start();

    final result =
        await ref.read(bluetoothServiceProvider).sendToken(token, address, onStage: _onBtStage);

    ref.read(activeTransferProvider.notifier).stop();

    switch (result) {
      case Success():
        await repository.updateTokenStatus(token.tokenId, 'transféré');
        _recordTransfer(token, TransactionType.outgoing, 'bluetooth');
        _refreshWallet();
        state = state.copyWith(status: TransferStatus.success, error: null, progress: 1.0);
      case Failure(:final message):
        state = state.copyWith(status: TransferStatus.error, error: message, progress: null);
    }
  }

  void _recordTransfer(Token token, TransactionType type, String method) {
    final uuid = const Uuid();
    HistoryService.instance.recordTransaction(
      TransactionRecord(
        id: uuid.v4(),
        tokenId: token.tokenId,
        type: type,
        date: DateTime.now(),
        status: 'Validé',
        method: method == 'bluetooth' ? TransferMethod.bluetooth : TransferMethod.nfc,
        amount: token.valeur,
        currency: token.valeurUnite,
      ),
    );
  }

  /// Reçoit un jeton via Bluetooth (rôle serveur RFCOMM).
  Future<void> startBluetoothReceive() async {
    state = state.copyWith(
      isReceiveMode: true,
      method: 'bluetooth',
      status: TransferStatus.waiting,
      error: null,
      progress: 0.0,
    );
    ref.read(activeTransferProvider.notifier).start();

    final result = await ref.read(bluetoothServiceProvider).receiveToken(onStage: _onBtStage);

    switch (result) {
      case Success(:final data):
        final error = await _checkReceivedToken(data);
        if (error != null) {
          ref.read(activeTransferProvider.notifier).stop();
          await ref.read(bluetoothServiceProvider).respondToTransfer(false);
          state = state.copyWith(status: TransferStatus.error, error: error, progress: null);
        } else {
          state = state.copyWith(
            status: TransferStatus.received,
            token: data.copyWith(direction: 'incoming', statut: 'actif'),
            error: null,
            progress: 1.0,
          );
        }
      case Failure(:final message):
        ref.read(activeTransferProvider.notifier).stop();
        state = state.copyWith(status: TransferStatus.error, error: message, progress: null);
    }
  }

  /// Annule un transfert en cours.
  Future<void> cancel() async {
    await ref.read(nfcServiceProvider).cancelSending();
    await ref.read(bluetoothServiceProvider).cancel();
    ref.read(activeTransferProvider.notifier).stop();
    state = state.copyWith(status: TransferStatus.idle, error: null, progress: null);
  }

  /// Rafraîchit le portefeuille (accueil + liste transférable) après un transfert.
  void _refreshWallet() {
    ref.invalidate(tokenListProvider);
    ref.invalidate(transferableTokensProvider);
  }

  void _onBtStage(BtTransferStage stage, {double? progress}) {
    final mapped = switch (stage) {
      BtTransferStage.waiting => TransferStatus.waiting,
      BtTransferStage.connecting => TransferStatus.connected,
      BtTransferStage.transferring => TransferStatus.transferring,
      BtTransferStage.completed => TransferStatus.transferring,
    };
    if (state.status == TransferStatus.success || state.status == TransferStatus.error) {
      return;
    }
    AppLogger.bluetooth('Étape transfert : ${stage.name} ($progress)');
    state = state.copyWith(status: mapped, progress: progress);
  }

  void _onStage(NfcTransferStage stage, {double? progress}) {
    final mapped = switch (stage) {
      NfcTransferStage.waiting => TransferStatus.waiting,
      NfcTransferStage.connected => TransferStatus.connected,
      NfcTransferStage.transferring => TransferStatus.transferring,
      NfcTransferStage.completed => TransferStatus.transferring,
    };
    // On ne dégrade jamais un état terminal (success/error).
    if (state.status == TransferStatus.success || state.status == TransferStatus.error) {
      return;
    }
    AppLogger.nfc('Étape transfert : ${stage.name} ($progress)');
    state = state.copyWith(status: mapped, progress: progress);
  }
}
