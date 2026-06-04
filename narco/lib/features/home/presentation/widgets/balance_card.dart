import 'package:flutter/material.dart';
import '../../../../core/appTheme.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
              // Mascot Image in the top-right corner
              Positioned(
                right: 12,
                top: 12,
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Image.asset(
                    'assets/images/robot_mascot.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Card Contents
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppTheme.tertiary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.done,
                              size: 14,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Getting funds',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Amount Label
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '2,783',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        Text(
                          '.00 €',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Expected Subtitle
                    Text(
                      'Expected to receive this week',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 28),
                    // Pending Transactions Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Pending transactions',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_right,
                            color: AppTheme.textPrimary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF6B5835), // Dark brown active dot
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
