import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/appTheme.dart';
import '../providers/active_transfer_provider.dart';
import '../providers/token_list_provider.dart';
import '../widgets/action_buttons.dart';
import '../widgets/home_header.dart';
import '../widgets/token_balance_card.dart';
import '../widgets/transaction_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokensAsync = ref.watch(tokenListProvider);
    final isTransferActive = ref.watch(activeTransferProvider);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () => ref.refresh(tokenListProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              if (isTransferActive) _ActiveTransferBanner(),
              const SizedBox(height: 8),
              tokensAsync.when(
                data: (tokens) => TokenBalanceCard(tokens: tokens),
                loading: () => const TokenBalanceCard(tokens: []),
                error: (_, _) => const TokenBalanceCard(tokens: []),
              ),
              const SizedBox(height: 8),
              const ActionButtons(),
              const TransactionList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveTransferBanner extends StatefulWidget {
  @override
  State<_ActiveTransferBanner> createState() => _ActiveTransferBannerState();
}

class _ActiveTransferBannerState extends State<_ActiveTransferBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFF2E2B24).withValues(alpha: _opacity.value * 0.9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Transaction en cours...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
