import 'package:flutter/material.dart';
import '../../../../core/appTheme.dart';
import '../../../token_creation/domain/models/token.dart';

class TokenBalanceCard extends StatelessWidget {
  final List<Token> tokens;

  const TokenBalanceCard({super.key, required this.tokens});

  @override
  Widget build(BuildContext context) {
    if (tokens.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(36),
        ),
        child: const Center(
          child: Text(
            'Aucun jeton',
            style: TextStyle(fontSize: 18, color: AppTheme.textPrimary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: PageView.builder(
        padEnds: false,
        controller: PageController(viewportFraction: 0.8),
        itemCount: tokens.length,
        itemBuilder: (context, index) {
          final token = tokens[index];
          return _TokenSlide(token: token);
        },
      ),
    );
  }
}

class _TokenSlide extends StatelessWidget {
  final Token token;

  const _TokenSlide({required this.token});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 8, 16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 12,
            top: 12,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Image.asset(
                'assets/images/robot_mascot.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    token.type.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      token.valeur.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      token.valeurUnite,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  token.proprietaire,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
