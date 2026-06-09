import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/appTheme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../token_creation/domain/models/token.dart';
import '../../../token_creation/presentation/widgets/token_type_config.dart';

class TokenBalanceCard extends StatefulWidget {
  final List<Token> tokens;

  const TokenBalanceCard({super.key, required this.tokens});

  @override
  State<TokenBalanceCard> createState() => _TokenBalanceCardState();
}

class _TokenBalanceCardState extends State<TokenBalanceCard> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.tokens.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % widget.tokens.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tokens.isEmpty) {
      return _EmptyTokensState();
    }

    return Column(
      children: [
        // ── Card carousel (plein width) ─────────────────────────────────
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.tokens.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) => _FullWidthTokenCard(
              token: widget.tokens[index],
            ),
          ),
        ),

        // ── Dots indicator (seulement si > 1 jeton) ─────────────────────
        if (widget.tokens.length > 1) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.tokens.length, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.dark
                      : AppTheme.dark.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ] else
          const SizedBox(height: 14),
      ],
    );
  }
}

// ─── Full Width Token Card ────────────────────────────────────────────────────

class _FullWidthTokenCard extends StatefulWidget {
  final Token token;
  const _FullWidthTokenCard({required this.token});

  @override
  State<_FullWidthTokenCard> createState() => _FullWidthTokenCardState();
}

class _FullWidthTokenCardState extends State<_FullWidthTokenCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = TokenTypeConfig.fromType(widget.token.type);
    final screenW = MediaQuery.of(context).size.width;
    final cardW = screenW - 48.0;

    return FadeTransition(
      opacity: _fade,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _CardFace(
          token: widget.token,
          config: config,
          cardW: cardW,
          cardH: 200,
        ),
      ),
    );
  }
}

// ─── Card Face ────────────────────────────────────────────────────────────────

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
            // ── Cercle décoratif haut-droite ───────────────────────────
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
            // ── Cercle décoratif bas-gauche ────────────────────────────
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
            // ── Gloss top edge ─────────────────────────────────────────
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
            // ── Gloss panel supérieur ──────────────────────────────────
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

            // ── Contenu ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1 : NFC chip icon + type badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Puce NFC stylisée
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
                      // Badge type
                      _TypeBadge(label: config.label, icon: config.icon),
                    ],
                  ),

                  const Spacer(),

                  // Row 2 : Valeur principale
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

                  // Row 3 : Propriétaire + ID masqué
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

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyTokensState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration placeholder — remplace par une vraie image
            // quand assets/images/empty_tokens.png sera ajouté
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 44,
                color: AppTheme.primary,
              ),
            ),
            // TODO: Remplacer le Container ci-dessus par :
            // Image.asset(AppAssets.emptyTokens, height: 100)

            const SizedBox(height: 20),
            const Text(
              AppStrings.noTokens,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.noTokensSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // CTA
            SizedBox(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/create-token'),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  AppStrings.createFirstToken,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.dark,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
