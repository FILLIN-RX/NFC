import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/appTheme.dart';
import '../providers/token_list_provider.dart';
import '../widgets/action_buttons.dart';
import '../widgets/home_header.dart';
import '../widgets/stats_badges.dart';
import '../widgets/token_balance_card.dart';
import '../widgets/transaction_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenListAsync = ref.watch(tokenListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.dark,
          backgroundColor: Colors.white,
          strokeWidth: 2.5,
          onRefresh: () async {
            // Rafraîchir à la fois les tokens ET les transactions
            ref.invalidate(tokenListProvider);
            await ref.read(tokenListProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── En-tête avec salutation ─────────────────────────────
                const HomeHeader(),

                const SizedBox(height: 24),

                // ── Carte(s) de solde en plein width ──────────────────
                tokenListAsync.when(
                  data: (tokens) => TokenBalanceCard(tokens: tokens),
                  loading: () => const _CardSkeleton(),
                  error: (e, _) => _ErrorCard(message: e.toString()),
                ),

                const SizedBox(height: 4),

                // ── Stats (envoyés / reçus) ────────────────────────────
                const StatsBadges(),

                // ── Boutons d'action ───────────────────────────────────
                const ActionButtons(),

                // ── Liste des transactions récentes ───────────────────
                const TransactionList(),

                // Espace bas (la bottom nav est dans MainShell)
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Skeleton de chargement ───────────────────────────────────────────────────

class _CardSkeleton extends StatefulWidget {
  const _CardSkeleton();

  @override
  State<_CardSkeleton> createState() => _CardSkeletonState();
}

class _CardSkeletonState extends State<_CardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimmer = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (context, child) => Container(
          width: screenW - 48,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                (_shimmer.value - 0.3).clamp(0.0, 1.0),
                _shimmer.value.clamp(0.0, 1.0),
                (_shimmer.value + 0.3).clamp(0.0, 1.0),
              ],
              colors: const [
                Color(0xFFE5E7EB),
                Color(0xFFF3F4F6),
                Color(0xFFE5E7EB),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Erreur ───────────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppTheme.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Erreur : $message',
                style:
                    const TextStyle(color: AppTheme.error, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
