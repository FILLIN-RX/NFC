import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../features/token_creation/domain/models/token.dart';
import '../../features/token_creation/presentation/widgets/token_type_config.dart';

/// A premium, credit-card-style widget with 3D depth, glassmorphism
/// overlays, per-type gradients, and decorative background shapes.
///
/// Pass [compact] = true for in-list usage (slightly smaller).
class PremiumTokenCard extends StatefulWidget {
  final Token token;
  final bool compact;
  final bool animate;

  const PremiumTokenCard({
    super.key,
    required this.token,
    this.compact = false,
    this.animate = true,
  });

  @override
  State<PremiumTokenCard> createState() => _PremiumTokenCardState();
}

class _PremiumTokenCardState extends State<PremiumTokenCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeSlide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    if (widget.animate) _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = TokenTypeConfig.fromType(widget.token.type);
    final card = _CardFace(token: widget.token, config: cfg, compact: widget.compact);
    if (!widget.animate) return card;
    return FadeTransition(
      opacity: _fadeSlide,
      child: SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
                .animate(_fadeSlide),
        child: card,
      ),
    );
  }
}

// ─── Card Face ──────────────────────────────────────────────────────────────

class _CardFace extends StatelessWidget {
  final Token token;
  final TokenTypeConfig config;
  final bool compact;

  const _CardFace({
    required this.token,
    required this.config,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final cardW = compact ? screenW - 64.0 : screenW - 48.0;
    final cardH = cardW * 0.60;
    final pad = compact ? 18.0 : 22.0;

    return Container(
      width: cardW,
      height: cardH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 20 : 24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.55, 1.0],
          colors: config.gradientColors,
        ),
        boxShadow: [
          // Coloured glow below the card
          BoxShadow(
            color: config.gradientColors[1].withValues(alpha: 0.45),
            blurRadius: compact ? 20 : 32,
            spreadRadius: compact ? -4 : -6,
            offset: Offset(0, compact ? 10 : 16),
          ),
          // Soft ambient shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: compact ? 12 : 20,
            offset: Offset(0, compact ? 4 : 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(compact ? 20 : 24),
        child: Stack(
          children: [
            // ── Decorative circles (depth / texture) ─────────────────────
            _DecorativeCircle(
              size: cardH * 1.6,
              color: config.accentColor,
              opacity: 0.07,
              top: -cardH * 0.5,
              right: -cardH * 0.4,
            ),
            _DecorativeCircle(
              size: cardH * 0.9,
              color: Colors.white,
              opacity: 0.05,
              bottom: -cardH * 0.3,
              left: -cardH * 0.1,
            ),

            // ── Top-edge gloss highlight ──────────────────────────────────
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
                      Colors.white.withValues(alpha: 0.45),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Semi-transparent inner gloss panel ───────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: cardH * 0.5,
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

            // ── Card Content ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: NFC icon + type badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.nfc_rounded,
                        color: Colors.white.withValues(alpha: 0.75),
                        size: compact ? 22 : 26,
                      ),
                      _TypeBadge(label: config.label, icon: config.icon),
                    ],
                  ),

                  const Spacer(),

                  // Row 2: Value + unit
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatValue(token.valeur),
                        style: TextStyle(
                          fontSize: compact ? 28 : 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          token.valeurUnite,
                          style: TextStyle(
                            fontSize: compact ? 14 : 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.70),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: compact ? 10 : 14),

                  // Row 3: Owner + masked ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CardInfoColumn(
                        label: 'Propriétaire',
                        value: token.proprietaire.isNotEmpty
                            ? token.proprietaire
                            : '—',
                        compact: compact,
                      ),
                      _CardInfoColumn(
                        label: 'ID',
                        value: '•••• ${_shortId(token.tokenId)}',
                        compact: compact,
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
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k';
    return v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
  }

  String _shortId(String id) {
    final clean = id.replaceAll('-', '');
    return clean.substring(math.max(0, clean.length - 4)).toUpperCase();
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

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

class _CardInfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool compact;
  final bool alignRight;

  const _CardInfoColumn({
    required this.label,
    required this.value,
    required this.compact,
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
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: compact ? 9 : 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const _DecorativeCircle({
    required this.size,
    required this.color,
    required this.opacity,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}
