import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/appTheme.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        'label': 'Créer',
        'icon': Icons.add_circle_outline,
        'route': '/create-token',
      },
      {
        'label': 'Envoyer',
        'icon': Icons.north_east,
        'route': '/transfer',
      },
      {
        'label': 'Recevoir',
        'icon': Icons.south_west,
      },
      {
        'label': 'Stats',
        'icon': Icons.query_stats_outlined,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((action) {
          return Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E2B24),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    final route = action['route'] as String?;
                    if (route != null) {
                      if (route.startsWith('/')) {
                        context.go(route);
                      } else {
                        context.goNamed(route);
                      }
                    }
                  },
                  icon: Icon(
                    action['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                action['label'] as String,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
