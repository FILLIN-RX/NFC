import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/appTheme.dart';

class ChannelSelectionDialog extends StatelessWidget {
  /// Identifiant du jeton à envoyer. `null` ⇒ mode réception.
  final String? tokenId;

  const ChannelSelectionDialog({super.key, this.tokenId});

  bool get _isReceive => tokenId == null;

  /// Sélecteur de canal pour l'envoi d'un jeton.
  static Future<void> show(BuildContext context, String tokenId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChannelSelectionDialog(tokenId: tokenId),
    );
  }

  /// Sélecteur de canal pour la réception d'un jeton.
  static Future<void> showForReceive(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChannelSelectionDialog(),
    );
  }

  void _goToTransfer(BuildContext context, String method) {
    final params = <String, String>{'method': method};
    if (!_isReceive) params['tokenId'] = tokenId!;
    context.goNamed('transfer', queryParameters: params);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF2E2B24),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wifi_tethering, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            _isReceive
                ? 'Choisissez votre\ncanal de réception'
                : 'Choisissez votre\ncanal de diffusion',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isReceive
                ? 'Le jeton sera reçu de manière sécurisée'
                : 'Le jeton sera transmis de manière sécurisée',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _ChannelButton(
                  icon: Icons.nfc,
                  label: 'NFC',
                  subtitle: 'Proximité',
                  onTap: () => _goToTransfer(context, 'nfc'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ChannelButton(
                  icon: Icons.bluetooth,
                  label: 'Bluetooth',
                  subtitle: 'Distance',
                  onTap: () => _goToTransfer(context, 'bluetooth'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ChannelButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ChannelButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3EE),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: const Color(0xFF2E2B24)),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
