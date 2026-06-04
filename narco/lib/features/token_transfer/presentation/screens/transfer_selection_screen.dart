import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/appTheme.dart';
import '../../../token_creation/domain/models/token.dart';
import '../../../token_creation/presentation/providers/repository_provider.dart';
import '../../../token_creation/presentation/widgets/token_card.dart';
import '../widgets/channel_selection_dialog.dart';

class TransferSelectionScreen extends ConsumerWidget {
  const TransferSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokensAsync = ref.watch(transferableTokensProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Transférer un jeton'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: tokensAsync.when(
        data: (tokens) {
          if (tokens.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucun jeton disponible',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            itemCount: tokens.length,
            itemBuilder: (context, index) {
              final token = tokens[index];
              return GestureDetector(
                onTap: () => _onTokenSelected(context, token),
                child: TokenCard(token: token),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }

  void _onTokenSelected(BuildContext context, Token token) {
    ChannelSelectionDialog.show(context, token.tokenId);
  }
}

final transferableTokensProvider = FutureProvider<List<Token>>((ref) async {
  final repo = ref.read(tokenRepositoryProvider);
  final result = await repo.getAllTokens();
  return result.when(
    success: (tokens) => tokens.where((t) => t.statut == 'actif').toList(),
    failure: (_) => [],
  );
});
