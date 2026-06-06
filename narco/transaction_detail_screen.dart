import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/transaction_record.dart';
import '../../../../core/appTheme.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionRecord transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isOutgoing = transaction.type == TransactionType.outgoing;

    return Scaffold(
      appBar: AppBar(title: const Text('Détails de la Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                isOutgoing ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 80,
                color: isOutgoing ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow('ID Transaction', transaction.id),
            _buildInfoRow('ID Jeton', transaction.tokenId),
            _buildInfoRow('Montant', '${transaction.amount} ${transaction.currency}'),
            _buildInfoRow('Date', DateFormat('dd MMMM yyyy HH:mm').format(transaction.date)),
            _buildInfoRow('Méthode', transaction.method.name.toUpperCase()),
            _buildInfoRow('Statut', transaction.status),
            _buildInfoRow('Correspondant', transaction.peerName ?? 'Inconnu'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
        ],
      ),
    );
  }
}