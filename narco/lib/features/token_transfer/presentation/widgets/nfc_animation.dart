import 'package:flutter/material.dart';

import '../../../../core/appTheme.dart';

/// Pulsating concentric-wave NFC/Bluetooth animation.
///
/// Pass [tokenColor] to dynamically colour the rings to match the active token.
class NfcAnimationOverlay extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color? tokenColor;
  final double size;

  const NfcAnimationOverlay({
    super.key,
    this.icon = Icons.nfc_rounded,
    this.color = AppTheme.primary,
    this.tokenColor,
    this.size = 220,
  });

  @override
  State<NfcAnimationOverlay> createState() => _NfcAnimationOverlayState();
}

class _NfcAnimationOverlayState extends State<NfcAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const int _waveCount = 4;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringColor = widget.tokenColor ?? widget.color;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < _waveCount; i++)
                _buildWave(i, ringColor),
              child!,
            ],
          );
        },
        child: Container(
          width: widget.size * 0.30,
          height: widget.size * 0.30,
          decoration: BoxDecoration(
            color: AppTheme.dark,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (widget.tokenColor ?? AppTheme.primary)
                    .withValues(alpha: 0.35),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: widget.size * 0.14,
          ),
        ),
      ),
    );
  }

  Widget _buildWave(int index, Color color) {
    // Staggered progress calculation using offset and modulo for a smooth loop.
    // This avoids using Interval and its strict 0.0-1.0 constraints.
    final waveValue = (_controller.value - (index / _waveCount)) % 1.0;
    final progress = Curves.easeOut.transform(waveValue);

    final scale = 0.30 + progress * 0.70;
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity * 0.55,
      child: Container(
        width: widget.size * scale,
        height: widget.size * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
        ),
      ),
    );
  }
}
