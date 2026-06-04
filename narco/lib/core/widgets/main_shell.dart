import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/widgets/bottom_nav_bar.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: navigationShell,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              selectedIndex: navigationShell.currentIndex,
              onItemTapped: (index) => navigationShell.goBranch(index),
            ),
          ),
        ],
      ),
    );
  }
}
