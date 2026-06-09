import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../token_history/data/services/history_service.dart';
import '../../../token_history/domain/models/transaction_record.dart';

class StatsBadges extends StatelessWidget {
  const StatsBadges({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TransactionRecord>>(
      future: HistoryService.instance.getTransactions(limit: 100),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final txs = snapshot.data!;
        final sent = txs.where((t) => t.type == TransactionType.outgoing).length;
        final received = txs.where((t) => t.type == TransactionType.incoming).length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _buildBadge(AppStrings.filterOutgoing, sent.toString(), Colors.orange),
              const SizedBox(width: 12),
              _buildBadge(AppStrings.filterIncoming, received.toString(), Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Text(count, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}