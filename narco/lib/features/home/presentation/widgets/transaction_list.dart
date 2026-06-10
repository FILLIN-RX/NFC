import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/appTheme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../token_history/data/services/history_service.dart';
import '../../../token_history/domain/models/transaction_record.dart';

class TransactionList extends ConsumerWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête section ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.recentTransactions,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () => StatefulNavigationShell.of(context).goBranch(3),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.dark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    AppStrings.viewAll,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Liste ──────────────────────────────────────────────────
          FutureBuilder<List<TransactionRecord>>(
            future: HistoryService.instance.getTransactions(limit: 5),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final transactions = snapshot.data ?? [];

              if (transactions.isEmpty) {
                return _EmptyTransactionsState();
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _TransactionItem(tx: transactions[index]);
                },
              );
            },
          ),

          // Espace pour la bottom nav bar (via MainShell)
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Transaction Item ─────────────────────────────────────────────────────────

class _TransactionItem extends StatelessWidget {
  final TransactionRecord tx;
  const _TransactionItem({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isOutgoing = tx.type == TransactionType.outgoing;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Icône ──────────────────────────────────────────────────
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isOutgoing
                  ? const Color(0xFFFBE9E7)
                  : const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOutgoing ? Icons.north_east_rounded : Icons.south_west_rounded,
              color:
                  isOutgoing ? AppTheme.error : AppTheme.success,
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          // ── Titre + sous-titre ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.peerName ?? (isOutgoing ? 'Envoi Jeton' : 'Réception Jeton'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${DateFormat('dd MMM, HH:mm').format(tx.date)} · ${tx.method.name.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // ── Montant ────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isOutgoing ? "−" : "+"} ${tx.amount.toInt()} ${tx.currency}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color:
                      isOutgoing ? AppTheme.textPrimary : AppTheme.success,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyTransactionsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Illustration placeholder — remplace par une vraie image
          // quand assets/images/empty_transactions.png sera ajouté
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              size: 40,
              color: AppTheme.textSecondary,
            ),
          ),
          // TODO: Remplacer le Container ci-dessus par :
          // Image.asset(AppAssets.emptyTransactions, height: 90)

          const SizedBox(height: 16),
          const Text(
            AppStrings.noTransactions,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            AppStrings.noTransactionsSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
