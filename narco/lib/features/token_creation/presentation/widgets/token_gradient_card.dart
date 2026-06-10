import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/token.dart';
import 'token_type_config.dart';

/// A full-width gradient card displaying token info.
/// Used on home page carousel and transfer selection screen.
class TokenGradientCard extends StatelessWidget {
  final Token token;
  final double? width;
  final double height;

  const TokenGradientCard({
    super.key,
    required this.token,
    this.width,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final config = TokenTypeConfig.fromType(token.type);
    final cardW = width ?? MediaQuery.of(context).size.width - 48;
    final cardH = height;

    return _CardFace(
      token: token,
      config: config,
      cardW: cardW,
      cardH: cardH,
    );
  }
}

class _CardFace extends StatelessWidget {
  final Token token;
  final TokenTypeConfig config;
  final double cardW;
  final double cardH;

  const _CardFace({
    required this.token,
    required this.config,
    required this.cardW,
    required this.cardH,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardW,
      height: cardH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.55, 1.0],
          colors: config.gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: config.gradientColors[1].withValues(alpha: 0.45),
            blurRadius: 28,
            spreadRadius: -6,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              top: -cardH * 0.5,
              right: -cardH * 0.3,
              child: Opacity(
                opacity: 0.08,
                child: Container(
                  width: cardH * 1.5,
                  height: cardH * 1.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: config.accentColor,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -cardH * 0.25,
              left: -cardH * 0.1,
              child: Opacity(
                opacity: 0.06,
                child: Container(
                  width: cardH * 0.8,
                  height: cardH * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: cardH * 0.45,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          Icons.nfc_rounded,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 20,
                        ),
                      ),
                      _TypeBadge(label: config.label, icon: config.icon),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatValue(token.valeur),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          token.valeurUnite,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.70),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoColumn(
                        label: 'PROPRIÉTAIRE',
                        value: token.proprietaire.isNotEmpty
                            ? token.proprietaire
                            : '—',
                      ),
                      _InfoColumn(
                        label: 'ID',
                        value: '•••• ${_shortId(token.tokenId)}',
                        alignRight: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k';
    }
    return v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
  }

  String _shortId(String id) {
    final clean = id.replaceAll('-', '');
    return clean.substring(math.max(0, clean.length - 4)).toUpperCase();
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _TypeBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool alignRight;

  const _InfoColumn({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final align =
        alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
