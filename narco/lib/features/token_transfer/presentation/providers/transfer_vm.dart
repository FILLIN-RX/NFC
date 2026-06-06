import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

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

enum TransferStatus {
  idle,
  waiting,
  connected,
  transferring,
  success,
  error,
}

class TransferState {
  final TransferStatus status;
  final Token? token;
  final String? error;
  final bool isReceiveMode;
  final String method;

  const TransferState({
    this.status = TransferStatus.idle,
    this.token,
    this.error,
    this.isReceiveMode = false,
    this.method = 'nfc',
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
  }) {
    return TransferState(
      status: status ?? this.status,
      token: token ?? this.token,
      error: identical(error, _keep) ? this.error : error as String?,
      isReceiveMode: isReceiveMode ?? this.isReceiveMode,
      method: method ?? this.method,
    );
  }
}

@riverpod
class TransferViewModel extends _$TransferViewModel {
  @override
  TransferState build() => const TransferState();

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

    state = state.copyWith(
      token: token,
      isReceiveMode: false,
      status: TransferStatus.waiting,
      error: null,
    );
    ref.read(activeTransferProvider.notifier).start();

    final result = await ref.read(nfcServiceProvider).sendToken(token, onStage: _onStage);
    ref.read(activeTransferProvider.notifier).stop();

    switch (result) {
      case Success():
        await repository.updateTokenStatus(token.tokenId, 'transféré');
        await HistoryService.instance.recordTransaction(TransactionRecord(
          id: const Uuid().v4(),
          tokenId: token.tokenId,
          type: TransactionType.outgoing,
          date: DateTime.now(),
          status: 'Complété',
          method: TransferMethod.nfc,
          amount: token.valeur,
          currency: token.valeurUnite,
          peerName: 'Transfert NFC',
        ));
        _refreshWallet();
        state = state.copyWith(status: TransferStatus.success, error: null);
      case Failure(:final message):
        state = state.copyWith(status: TransferStatus.error, error: message);
    }
  }

  Future<void> startReceive() async {
    state = state.copyWith(isReceiveMode: true, status: TransferStatus.waiting, error: null);
    ref.read(activeTransferProvider.notifier).start();
    final result = await ref.read(nfcServiceProvider).receiveToken(onStage: _onStage);
    ref.read(activeTransferProvider.notifier).stop();

    switch (result) {
      case Success(:final data):
        final received = data.copyWith(direction: 'incoming', statut: 'actif');
        final saveResult = await ref.read(tokenRepositoryProvider).saveToken(received);
        if (saveResult is Success) {
          await HistoryService.instance.recordTransaction(TransactionRecord(
            id: const Uuid().v4(),
            tokenId: received.tokenId,
            type: TransactionType.incoming,
            date: DateTime.now(),
            status: 'Reçu',
            method: TransferMethod.nfc,
            amount: received.valeur,
            currency: received.valeurUnite,
            peerName: received.proprietaire,
          ));
          _refreshWallet();
          state = state.copyWith(status: TransferStatus.success, token: received, error: null);
        }
      case Failure(:final message):
        state = state.copyWith(status: TransferStatus.error, error: message);
    }
  }

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

    state = state.copyWith(token: token, isReceiveMode: false, method: 'bluetooth', status: TransferStatus.connected, error: null);
    ref.read(activeTransferProvider.notifier).start();
    final result = await ref.read(bluetoothServiceProvider).sendToken(token, address, onStage: _onBtStage);
    ref.read(activeTransferProvider.notifier).stop();

    if (result is Success) {
      await repository.updateTokenStatus(token.tokenId, 'transféré');
      await HistoryService.instance.recordTransaction(TransactionRecord(
        id: const Uuid().v4(),
        tokenId: token.tokenId,
        type: TransactionType.outgoing,
        date: DateTime.now(),
        status: 'Complété',
        method: TransferMethod.bluetooth,
        amount: token.valeur,
        currency: token.valeurUnite,
        peerName: 'Transfert Bluetooth',
      ));
      _refreshWallet();
      state = state.copyWith(status: TransferStatus.success, error: null);
    }
  }

  Future<void> startBluetoothReceive() async {
    state = state.copyWith(isReceiveMode: true, method: 'bluetooth', status: TransferStatus.waiting, error: null);
    ref.read(activeTransferProvider.notifier).start();
    final result = await ref.read(bluetoothServiceProvider).receiveToken(onStage: _onBtStage);
    ref.read(activeTransferProvider.notifier).stop();

    if (result is Success) {
      final data = (result as Success<Token>).data;
      final received = data.copyWith(direction: 'incoming', statut: 'actif');
      await ref.read(tokenRepositoryProvider).saveToken(received);
      await HistoryService.instance.recordTransaction(TransactionRecord(
        id: const Uuid().v4(),
        tokenId: received.tokenId,
        type: TransactionType.incoming,
        date: DateTime.now(),
        status: 'Reçu',
        method: TransferMethod.bluetooth,
        amount: received.valeur,
        currency: received.valeurUnite,
        peerName: received.proprietaire,
      ));
      _refreshWallet();
      state = state.copyWith(status: TransferStatus.success, token: received, error: null);
    }
  }

  Future<void> cancel() async {
    await ref.read(nfcServiceProvider).cancelSending();
    await ref.read(bluetoothServiceProvider).cancel();
    ref.read(activeTransferProvider.notifier).stop();
    state = state.copyWith(status: TransferStatus.idle, error: null);
  }

  void _refreshWallet() {
    ref.invalidate(tokenListProvider);
    ref.invalidate(transferableTokensProvider);
  }

  void _onBtStage(BtTransferStage stage) {
    final mapped = switch (stage) {
      BtTransferStage.waiting => TransferStatus.waiting,
      BtTransferStage.connecting => TransferStatus.connected,
      BtTransferStage.transferring => TransferStatus.transferring,
      BtTransferStage.completed => TransferStatus.transferring,
    };
    if (state.status == TransferStatus.success || state.status == TransferStatus.error) return;
    state = state.copyWith(status: mapped);
  }

  void _onStage(NfcTransferStage stage) {
    final mapped = switch (stage) {
      NfcTransferStage.waiting => TransferStatus.waiting,
      NfcTransferStage.connected => TransferStatus.connected,
      NfcTransferStage.transferring => TransferStatus.transferring,
      NfcTransferStage.completed => TransferStatus.transferring,
    };
    if (state.status == TransferStatus.success || state.status == TransferStatus.error) return;
    state = state.copyWith(status: mapped);
  }
}