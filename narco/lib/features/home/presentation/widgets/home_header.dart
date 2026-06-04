import 'package:flutter/material.dart';
import '../../../../core/appTheme.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Avatar with a stylized black circle
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.tertiary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.security,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // App Name
              Text(
                'Narco',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(width: 10),
              // Hub Dropdown Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFECE5), // Slightly darker cream for contrast
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      'Orovera Hub',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Chat bubble icon button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: AppTheme.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
