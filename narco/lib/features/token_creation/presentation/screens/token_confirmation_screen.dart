import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/appTheme.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../../core/widgets/premium_token_card.dart';
import '../../../home/presentation/providers/token_list_provider.dart';
import '../providers/repository_provider.dart';

class TokenConfirmationScreen extends ConsumerStatefulWidget {
  const TokenConfirmationScreen({super.key});

  @override
  ConsumerState<TokenConfirmationScreen> createState() =>
      _TokenConfirmationScreenState();
}

class _TokenConfirmationScreenState
    extends ConsumerState<TokenConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    // Trigger success feedback on screen entry
    FeedbackService.instance.triggerSuccess();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: FutureBuilder(
          future: ref.read(tokenRepositoryProvider).getAllTokens(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Text(
                  'Erreur: Impossible de charger le jeton.',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              );
            }

            return snapshot.data!.when(
              success: (tokens) {
                if (tokens.isEmpty) {
                  return const Center(child: Text('Aucun jeton trouvé.'));
                }
                final latestToken = tokens.first;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),

                      // ── Animated success icon ─────────────────────────
                      FadeTransition(
                        opacity: _fade,
                        child: ScaleTransition(
                          scale: _scale,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.success.withValues(alpha: 0.12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.success.withValues(alpha: 0.28),
                                  blurRadius: 28,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: AppTheme.success,
                              size: 52,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Title ─────────────────────────────────────────
                      FadeTransition(
                        opacity: _fade,
                        child: const Text(
                          'Félicitations !',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      FadeTransition(
                        opacity: _fade,
                        child: const Text(
                          'Votre jeton a été créé et sauvegardé avec succès.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Premium card ──────────────────────────────────
                      PremiumTokenCard(token: latestToken, animate: true),

                      const SizedBox(height: 40),

                      // ── CTA ───────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.invalidate(tokenListProvider);
                            context.go('/');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            "Retour à l'accueil",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
              failure: (message) => Center(
                child: Text(
                  'Erreur: $message',
                  style: const TextStyle(color: AppTheme.error),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
