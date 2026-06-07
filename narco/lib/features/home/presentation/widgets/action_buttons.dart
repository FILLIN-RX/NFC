import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/appTheme.dart';
import '../../../token_transfer/presentation/widgets/channel_selection_dialog.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {'label': 'Envoyer', 'icon': Icons.north_east, 'route': '/transfer-selection'},
      {'label': 'Recevoir', 'icon': Icons.south_west, 'onTap': 'receive'},
      {'label': 'Collecter', 'icon': Icons.account_balance_wallet_outlined, 'route': '/create-token'},
      {'label': 'Stats', 'icon': Icons.bar_chart_rounded, 'route': '/history'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((action) {
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (action['onTap'] == 'receive') {
                    ChannelSelectionDialog.showForReceive(context);
                  } else if (action['route'] != null) {
                    context.push(action['route']);
                  }
                },
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    color: AppTheme.dark,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(action['icon'] as IconData, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                action['label'] as String,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}