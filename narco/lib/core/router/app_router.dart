import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/token_creation/presentation/screens/create_token_screen.dart';
import '../../features/token_creation/presentation/screens/token_confirmation_screen.dart';
import '../../features/token_transfer/presentation/screens/transfer_screen.dart';
import '../../features/token_history/presentation/screens/history_screen.dart';
import '../widgets/main_shell.dart';

class AppRouter {
  static const String home = 'home';
  static const String createToken = 'create-token';
  static const String tokenConfirmation = 'token-confirmation';
  static const String transfer = 'transfer';
  static const String history = 'history';

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create-token',
                name: createToken,
                builder: (context, state) => const CreateTokenScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transfer',
                name: transfer,
                builder: (context, state) => const TransferScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                name: history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/token-confirmation',
        name: tokenConfirmation,
        builder: (context, state) => const TokenConfirmationScreen(),
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(child: Text('Page introuvable')),
    ),
  );
}
