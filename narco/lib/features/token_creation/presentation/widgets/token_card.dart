import 'package:flutter/material.dart';
import '../../../../core/appTheme.dart';
import '../../domain/models/token.dart';
import '../widgets/status_badge.dart';
import '../widgets/token_type_config.dart';

/// Compact list-item card for token history and wallet screens.
/// Uses the token-type gradient as a left accent + icon background.
class TokenCard extends StatelessWidget {
  final Token token;
  final bool compact;

  const TokenCard({super.key, required this.token, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final cfg = TokenTypeConfig.fromType(token.type);
    final isOut = token.isOutgoing;
    final directionColor =
        isOut ? const Color(0xFFEA580C) : const Color(0xFF059669);
    final directionIcon =
        isOut ? Icons.north_east_rounded : Icons.south_west_rounded;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: compact ? 4 : 6,
        horizontal: compact ? 8 : 0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            // ── Gradient accent bar ─────────────────────────────────────
            Container(
              width: 5,
              height: compact ? 60 : 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [cfg.gradientColors[0], cfg.gradientColors[2]],
                ),
              ),
            ),

            const SizedBox(width: 14),

            // ── Type icon ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: cfg.color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(cfg.icon, color: cfg.color, size: compact ? 20 : 22),
            ),

            const SizedBox(width: 14),

            // ── Text info ───────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      token.type.label,
                      style: TextStyle(
                        fontSize: compact ? 14 : 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      token.proprietaire,
                      style: TextStyle(
                        fontSize: compact ? 11 : 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // ── Value + direction ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(directionIcon, color: directionColor, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        '${_fmt(token.valeur)} ${token.valeurUnite}',
                        style: TextStyle(
                          fontSize: compact ? 13 : 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  StatusBadge(status: token.statut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k';
    return v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
  }
}
