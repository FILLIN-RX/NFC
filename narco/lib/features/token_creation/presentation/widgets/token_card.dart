import 'package:flutter/material.dart';
import '../../../../core/appTheme.dart';
import '../../domain/models/token.dart';
import 'status_badge.dart';

class TokenCard extends StatelessWidget {
  final Token token;
  final bool compact;

  const TokenCard({super.key, required this.token, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final arrow = token.isOutgoing
        ? Icons.north_east
        : Icons.south_west;
    final arrowColor = token.isOutgoing
        ? const Color(0xFFD36A3E)
        : const Color(0xFF4CAF50);

    return Container(
      margin: EdgeInsets.symmetric(vertical: compact ? 4 : 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Token ID: \u2022\u2022\u2022${token.tokenId.substring(token.tokenId.length > 6 ? token.tokenId.length - 6 : 0)}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(arrow, color: arrowColor, size: 18),
                  const SizedBox(width: 6),
                  StatusBadge(status: token.statut),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.token_outlined,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      token.type.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Propriétaire: ${token.proprietaire}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${token.valeur.toStringAsFixed(2)} ${token.valeurUnite}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
