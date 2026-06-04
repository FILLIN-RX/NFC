import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.account_balance_wallet, 'Accueil'),
      (Icons.add_circle_outline, 'Créer'),
      (Icons.swap_horiz, 'Transfert'),
      (Icons.history, 'Historique'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFF2E2B24),
        borderRadius: BorderRadius.circular(38),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(items.length, (i) {
            final isSelected = i == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onItemTapped(i),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: isSelected
                      ? Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            items[i].$1,
                            color: const Color(0xFF755C22),
                            size: 24,
                          ),
                        )
                      : Icon(
                          items[i].$1,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 24,
                        ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
