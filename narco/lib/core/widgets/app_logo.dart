import 'package:flutter/material.dart';
import '../appTheme.dart';
import '../constants/app_constants.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool circular;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 40.0,
    this.borderRadius = 12.0,
    this.circular = false,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: size * 0.4,
                  offset: Offset(0, size * 0.15),
                )
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: circular
            ? BorderRadius.circular(size)
            : BorderRadius.circular(borderRadius),
        child: Image.asset(
          AppAssets.logo,
          fit: BoxFit.cover,
          width: size,
          height: size,
          // Fallback if image fails to load
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.nfc_rounded,
            color: Colors.black,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }
}
