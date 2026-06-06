import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/appTheme.dart';
import '../providers/repository_provider.dart';
import '../widgets/token_card.dart';

class TokenConfirmationScreen extends ConsumerWidget {
  const TokenConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureTokens = ref.watch(tokenRepositoryProvider).getAllTokens();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Jeton Créé'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
        future: futureTokens,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Erreur: Impossible de charger le jeton.'));
          }

          final result = snapshot.data!;
          return result.when(
            success: (tokens) {
              if (tokens.isEmpty) {
                return const Center(child: Text('Aucun jeton trouvé.'));
              }

              final latestToken = tokens.first;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.success,
                        size: 80,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Félicitations !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Votre jeton a été créé et sauvegardé avec succès.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      TokenCard(token: latestToken),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          context.go('/');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Retour à l\'accueil',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
            failure: (message) => Center(child: Text('Erreur: $message')),
          );
        },
      ),
    );
  }
}
