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
                const SizedBox(height: 20),
                
                tokenListAsync.when(
                  data: (tokens) => TokenBalanceCard(tokens: tokens),
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
