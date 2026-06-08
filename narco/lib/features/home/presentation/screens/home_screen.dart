import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/appTheme.dart';
import '../../../token_creation/domain/models/token.dart';
import '../../../token_creation/presentation/widgets/token_type_config.dart';
import '../providers/token_list_provider.dart';
import '../widgets/action_buttons.dart';
import '../widgets/home_header.dart';
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
          onRefresh: () => ref.refresh(tokenListProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
                const SizedBox(height: 20),
                
                tokenListAsync.when(
                  data: (tokens) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TokenBalanceCard(tokens: tokens),
                      if (tokens.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.only(left: 24),
                          child: Text(
                            'Mes jetons',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: tokens.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 12),
                            itemBuilder: (context, index) => _TokenMiniCard(token: tokens[index]),
                          ),
                        ),
                      ],
                    ],
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(color: AppTheme.dark),
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Erreur: $e')),
                ),
                
                const ActionButtons(),
                const TransactionList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TokenMiniCard extends StatelessWidget {
  final Token token;
  const _TokenMiniCard({required this.token});

  @override
  Widget build(BuildContext context) {
    final config = TokenTypeConfig.fromType(token.type);
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(config.icon, color: config.color, size: 20),
              const SizedBox(width: 6),
              Text(
                config.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: config.color,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            token.valeur.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            config.unit,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
