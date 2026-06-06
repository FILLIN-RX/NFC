import 'package:flutter/material.dart';
import '../../../../core/appTheme.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 8),
          const Text(
            'April 26, 2023',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          _buildTransactionItem(
            icon: Icons.credit_card,
            iconBg: const Color(0xFFFFF8E1),
            iconColor: const Color(0xFFB88E2F),
            title: 'From Mastercard *0025\ncard',
            amount: '1,000\n€',
            isNew: true,
          ),
          const SizedBox(height: 12),
          _buildTransactionItem(
            icon: Icons.shopping_bag_outlined,
            iconBg: const Color(0xFFFBE9E7),
            iconColor: const Color(0xFFD84315),
            title: 'Amazon\nMarketplace',
            subtitle: 'Shopping • 12:45 PM',
            amount: '- 42.50\n€',
          ),
          const SizedBox(height: 12),
          _buildTransactionItem(
            icon: Icons.restaurant_menu_outlined,
            iconBg: const Color(0xFFE8EAF6),
            iconColor: const Color(0xFF3F51B5),
            title: 'Le Bistrot\nGourmand',
            subtitle: 'Dining • 8:20 PM',
            amount: '- 85.00\n€',
          ),
          const SizedBox(height: 100), // Spacing for bottom bar
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    required String amount,
    bool isNew = false,
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
                    height: 1.2,
                  ),
                ),
                if (isNew) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ] else if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          Text(
            amount,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}