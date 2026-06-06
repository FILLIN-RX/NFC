import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/appTheme.dart';
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
                const SizedBox(height: 10),
                
                tokenListAsync.when(
                  data: (tokens) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Solde Total Dynamique
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Solde total',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${tokens.fold(0.0, (sum, t) => sum + t.valeur).toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Affichage des cartes de jetons (Design Premium)
                      TokenBalanceCard(tokens: tokens),
                    ],
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Erreur: $e')),
                ),
                
                const ActionButtons(),
                const SizedBox(height: 20),
                const TransactionList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
