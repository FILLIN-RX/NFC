import 'package:flutter/material.dart';

import '../../../../core/appTheme.dart';

/// Animation de scan NFC : cercles concentriques pulsants autour d'une icône.
class NfcAnimationOverlay extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  const NfcAnimationOverlay({
    super.key,
    this.icon = Icons.nfc,
    this.color = AppTheme.primary,
    this.size = 220,
  });

  @override
  State<NfcAnimationOverlay> createState() => _NfcAnimationOverlayState();
}

class _NfcAnimationOverlayState extends State<NfcAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const int _waveCount = 3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < _waveCount; i++) _buildWave(i),
              Container(
                width: widget.size * 0.32,
                height: widget.size * 0.32,
                decoration: const BoxDecoration(
                  color: AppTheme.tertiary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: widget.size * 0.16,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWave(int index) {
    final progress = (_controller.value + index / _waveCount) % 1.0;
    final scale = 0.35 + progress * 0.65;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity * 0.6,
      child: Container(
        width: widget.size * scale,
        height: widget.size * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: widget.color, width: 3),
        ),
      ),
    );
  }
}
