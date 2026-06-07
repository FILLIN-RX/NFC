import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/token_history/presentation/screens/history_screen.dart';
import '../../features/token_creation/presentation/screens/create_token_screen.dart';
import '../../features/token_creation/presentation/screens/token_confirmation_screen.dart';
import '../../features/token_transfer/presentation/screens/transfer_screen.dart';
import '../../features/token_transfer/presentation/screens/transfer_selection_screen.dart';
import '../../features/splash/presentation/screens/login_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/create-token',
        name: 'create-token',
        builder: (context, state) => const CreateTokenScreen(),
      ),
      GoRoute(
        path: '/token-confirmation',
        name: 'token-confirmation',
        builder: (context, state) => const TokenConfirmationScreen(),
      ),
      GoRoute(
        path: '/transfer-selection',
        name: 'transfer-selection',
        builder: (context, state) => const TransferSelectionScreen(),
      ),
      GoRoute(
        path: '/transfer',
        name: 'transfer',
        builder: (context, state) {
          final method = state.uri.queryParameters['method'];
          final tokenId = state.uri.queryParameters['tokenId'];
          return TransferScreen(method: method, tokenId: tokenId);
        },
      ),
    ],
  );
}