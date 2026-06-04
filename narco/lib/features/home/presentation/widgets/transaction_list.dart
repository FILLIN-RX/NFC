import 'package:flutter/material.dart';
import '../../../../core/appTheme.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title and View All
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Date Separator
          Text(
            'April 26, 2023',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 12),
          // Transaction Items
          _buildTransactionItem(
            context,
            icon: Icons.credit_card,
            iconBgColor: const Color(0xFFF9EED4),
            iconColor: const Color(0xFF8B6B23),
            title: 'From Mastercard *0025\ncard',
            subtitleWidget: Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            amount: '1,000\n€',
            amountColor: const Color(0xFF8B6B23),
          ),
          const SizedBox(height: 12),
          _buildTransactionItem(
            context,
            icon: Icons.shopping_bag_outlined,
            iconBgColor: const Color(0xFFFCE6DB),
            iconColor: const Color(0xFFD36A3E),
            title: 'Amazon\nMarketplace',
            subtitle: 'Shopping • 12:45 PM',
            amount: '- 42.50\n€',
            amountColor: AppTheme.textPrimary,
          ),
          const SizedBox(height: 12),
          _buildTransactionItem(
            context,
            icon: Icons.restaurant_outlined,
            iconBgColor: const Color(0xFFDEE5F8),
            iconColor: const Color(0xFF4F70D6),
            title: 'Le Bistrot\nGourmand',
            subtitle: 'Dining • 8:20 PM',
            amount: '- 85.00\n€',
            amountColor: AppTheme.textPrimary,
          ),
          const SizedBox(height: 80), // Padding at the bottom for navigation bar
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? subtitleWidget,
    required String amount,
    required Color amountColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Icon Circular Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Middle Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1.2,
                        color: AppTheme.textPrimary,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                  ),
                ],
                ?subtitleWidget,
              ],
            ),
          ),
          // Right Amount
          Text(
            amount,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  height: 1.1,
                  color: amountColor,
                ),
          ),
        ],
      ),
    );
  }
}
