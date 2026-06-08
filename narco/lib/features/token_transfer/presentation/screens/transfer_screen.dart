import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/appTheme.dart';
import '../../../token_creation/presentation/widgets/token_card.dart';
import '../../data/services/bluetooth_service.dart';
import '../../data/services/nfc_service.dart';
import '../providers/transfer_vm.dart';
import '../widgets/bt_device_list.dart';
import '../widgets/nfc_animation.dart';

class TransferScreen extends ConsumerStatefulWidget {
  final String? method;
  final String? tokenId;

  const TransferScreen({super.key, this.method, this.tokenId});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  String? _selectedAddress;

  bool get _isBluetooth => widget.method == 'bluetooth';
  bool get _isReceive => widget.tokenId == null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    final vm = ref.read(transferViewModelProvider.notifier);
    if (_isBluetooth) {
      if (_isReceive) {
        vm.startBluetoothReceive();
      } else if (_selectedAddress != null) {
        vm.startBluetoothSend(widget.tokenId!, _selectedAddress!);
      }
    } else {
      if (_isReceive) {
        vm.startReceive();
      } else {
        vm.startSend(widget.tokenId!);
      }
    }
  }

  void _onDeviceSelected(BtDevice device) {
    setState(() => _selectedAddress = device.address);
    ref.read(transferViewModelProvider.notifier).startBluetoothSend(widget.tokenId!, device.address);
  }

  @override
  Widget build(BuildContext context) {
    final channel = _isBluetooth ? 'Bluetooth' : 'NFC';

    ref.listen<TransferState>(transferViewModelProvider, (previous, next) {
      if (next.status == TransferStatus.error &&
          previous?.status != TransferStatus.error) {
        _showErrorDialog(next.error ?? 'Une erreur est survenue.');
      }
      if (next.status == TransferStatus.connected &&
          previous?.status != TransferStatus.connected) {
        HapticFeedback.mediumImpact();
      }
      if (next.status == TransferStatus.success &&
          previous?.status != TransferStatus.success) {
        HapticFeedback.vibrate();
      }
    });

    final state = ref.watch(transferViewModelProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Transfert $channel'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildBody(state),
        ),
      ),
    );
  }

  Widget _buildBody(TransferState state) {
    // Envoi Bluetooth : sélection de l'appareil tant qu'aucun n'est choisi.
    if (_isBluetooth &&
        !_isReceive &&
        _selectedAddress == null &&
        state.status == TransferStatus.idle) {
      return BluetoothDeviceList(onSelected: _onDeviceSelected);
    }

    switch (state.status) {
      case TransferStatus.success:
        return _buildSuccess(state);
      case TransferStatus.error:
        return _buildError(state);
      case TransferStatus.received:
        return _buildConfirmation(state);
      case TransferStatus.idle:
      case TransferStatus.waiting:
      case TransferStatus.connected:
      case TransferStatus.transferring:
        return _buildInProgress(state);
    }
  }

  Widget _buildInProgress(TransferState state) {
    return Column(
      children: [
        const Spacer(),
        NfcAnimationOverlay(icon: _isBluetooth ? Icons.bluetooth : Icons.nfc),
        const SizedBox(height: 32),
        Text(
          _stageLabel(state),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _subtitle(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
        if (state.progress != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: state.progress,
                    minHeight: 12,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(state.progress! * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        if (state.token != null) TokenCard(token: state.token!, compact: true),
        const Spacer(),
        OutlinedButton(
          onPressed: () async {
            await ref.read(transferViewModelProvider.notifier).cancel();
            if (mounted) context.go('/');
          },
          child: const Text('Annuler'),
        ),
      ],
    );
  }

  Widget _buildConfirmation(TransferState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.pending_actions, color: AppTheme.primary, size: 80),
        const SizedBox(height: 24),
        const Text(
          'Jeton reçu',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Voulez-vous accepter ce jeton ?',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 32),
        if (state.token != null) TokenCard(token: state.token!),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => ref.read(transferViewModelProvider.notifier).rejectToken(),
                icon: const Icon(Icons.close, color: AppTheme.error),
                label: const Text('Refuser'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(color: AppTheme.error),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => ref.read(transferViewModelProvider.notifier).acceptToken(),
                icon: const Icon(Icons.check),
                label: const Text('Accepter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccess(TransferState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle, color: AppTheme.success, size: 80),
        const SizedBox(height: 24),
        Text(
          _isReceive ? 'Jeton reçu !' : 'Jeton envoyé !',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isReceive
              ? 'Le jeton a été ajouté à votre portefeuille.'
              : 'Le jeton a été transmis et marqué comme transféré.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 32),
        if (state.token != null) TokenCard(token: state.token!),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => context.go('/'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text(
            'Retour à l\'accueil',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildError(TransferState state) {
    final isNfcDisabled = state.error?.contains('NFC est désactivé') ?? false;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          isNfcDisabled ? Icons.nfc : Icons.error_outline,
          color: AppTheme.error,
          size: 80,
        ),
        const SizedBox(height: 24),
        Text(
          isNfcDisabled ? 'NFC désactivé' : 'Transfert échoué',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.error ?? 'Une erreur est survenue.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 32),
        if (isNfcDisabled)
          ElevatedButton.icon(
            onPressed: () => ref.read(nfcServiceProvider).openNfcSettings(),
            icon: const Icon(Icons.settings),
            label: const Text('Activer le NFC dans les paramètres'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        if (!isNfcDisabled)
          ElevatedButton(
            onPressed: _start,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              'Réessayer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => context.go('/'),
          child: const Text('Retour à l\'accueil'),
        ),
      ],
    );
  }

  String _stageLabel(TransferState state) {
    switch (state.status) {
      case TransferStatus.connected:
        return _isBluetooth ? 'Connexion à l\'appareil…' : 'Appareil détecté…';
      case TransferStatus.transferring:
        return 'Transfert en cours…';
      case TransferStatus.waiting:
      default:
        return _isReceive ? 'En attente de réception…' : 'En attente du récepteur…';
    }
  }

  String _subtitle() {
    if (_isBluetooth) {
      return _isReceive
          ? 'Restez à proximité de l\'émetteur.'
          : 'Connexion et envoi sécurisé en cours.';
    }
    return _isReceive
        ? 'Rapprochez l\'autre téléphone pour recevoir le jeton.'
        : 'Rapprochez les deux téléphones dos à dos.';
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Erreur de transfert'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
