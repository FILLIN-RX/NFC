import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/appTheme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../token_creation/domain/models/token.dart';
import '../../../token_creation/presentation/widgets/token_gradient_card.dart';

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
    return FadeTransition(
      opacity: _fade,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: TokenGradientCard(token: widget.token, height: 200),
      ),
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
                onPressed: () => StatefulNavigationShell.of(context).goBranch(1),
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
