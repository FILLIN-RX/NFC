import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/appTheme.dart';
import '../../domain/models/transaction_record.dart';
import '../../data/services/history_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TransactionRecord> _transactions = [];
  bool _isLoading = true;
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadHistory(query: query);
    });
  }

  Future<void> _loadHistory({String? query}) async {
    setState(() => _isLoading = true);
    final results = await HistoryService.instance.getTransactions(query: query);
    setState(() {
      _transactions = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Historique des Transactions'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher un jeton ou un contact...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _transactions.isEmpty
                ? const Center(child: Text('Aucune transaction trouvée'))
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
                      final isOutgoing = tx.type == TransactionType.outgoing;
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isOutgoing ? Colors.orange.shade100 : Colors.green.shade100,
                          child: Icon(
                            isOutgoing ? Icons.arrow_upward : Icons.arrow_downward,
                            color: isOutgoing ? Colors.orange : Colors.green,
                          ),
                        ),
                        title: Text(tx.peerName ?? 'Inconnu'),
                        subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(tx.date)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isOutgoing ? "-" : "+"}${tx.amount} ${tx.currency}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isOutgoing ? Colors.red : Colors.green,
                              ),
                            ),
                            Text(
                              tx.method.name.toUpperCase(),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}