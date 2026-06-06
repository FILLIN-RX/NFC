import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/appTheme.dart';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transactions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<TransactionRecord>>(
            future: HistoryService.instance.getTransactions(limit: 5),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final transactions = snapshot.data ?? [];
              
              if (transactions.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('Aucune transaction récente', style: TextStyle(color: Colors.grey)),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final isOutgoing = tx.type == TransactionType.outgoing;
                  
                  return _buildTransactionItem(
                    icon: isOutgoing ? Icons.north_east : Icons.south_west,
                    iconBg: isOutgoing ? const Color(0xFFFBE9E7) : const Color(0xFFE8F5E9),
                    iconColor: isOutgoing ? AppTheme.error : AppTheme.success,
                    title: tx.peerName ?? (isOutgoing ? 'Envoi Jeton' : 'Réception Jeton'),
                    subtitle: '${DateFormat('dd MMM, HH:mm').format(tx.date)} • ${tx.method.name.toUpperCase()}',
                    amount: '${isOutgoing ? "-" : "+"} ${tx.amount.toInt()} ${tx.currency}',
                    amountColor: isOutgoing ? AppTheme.textPrimary : AppTheme.success,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    Color? amountColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            amount,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: amountColor ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
