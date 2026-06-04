import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/token_creation/presentation/screens/create_token_screen.dart';
import '../../features/token_creation/presentation/screens/token_confirmation_screen.dart';
import '../../features/token_transfer/presentation/screens/transfer_screen.dart';
import '../../features/token_transfer/presentation/screens/transfer_selection_screen.dart';
import '../../features/token_history/presentation/screens/history_screen.dart';
import '../widgets/main_shell.dart';

class AppRouter {
  static const String splash = 'splash';
  static const String home = 'home';
  static const String createToken = 'create-token';
  static const String tokenConfirmation = 'token-confirmation';
  static const String transfer = 'transfer';
  static const String transferSelection = 'transfer-selection';
  static const String history = 'history';

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: splash,
        builder: (context, state) => const SplashScreen(),
      ),
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
                name: transferSelection,
                builder: (context, state) => const TransferSelectionScreen(),
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
      GoRoute(
        path: '/transfer/nfc',
        name: transfer,
        builder: (context, state) {
          final method = state.uri.queryParameters['method'];
          final tokenId = state.uri.queryParameters['tokenId'];
          return TransferScreen(method: method, tokenId: tokenId);
        },
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(child: Text('Page introuvable')),
    ),
  );
}
