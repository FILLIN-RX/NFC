import 'package:flutter/material.dart';
import '../../../../../core/appTheme.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'actif':
        backgroundColor = AppTheme.success;
        break;
      case 'transféré':
      case 'transfere':
        backgroundColor = AppTheme.warning;
        break;
      case 'expiré':
      case 'expire':
        backgroundColor = AppTheme.textSecondary;
        break;
      default:
        backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: backgroundColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
