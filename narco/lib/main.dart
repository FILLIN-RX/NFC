import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/appTheme.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/utils/app_logger.dart';
import 'features/token_creation/data/datasources/database_helper.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();
    await Hive.openBox(AppConstants.hiveBoxName);
    await Hive.openBox('user_profile');
    AppLogger.info('HIVE', 'Hive initialisé avec succès.');

    await DatabaseHelper.instance.database;
    AppLogger.info('DATABASE', 'SQLite initialisé avec succès.');
  } catch (e) {
    AppLogger.error('INIT', 'Échec de l\'initialisation des bases de données', e, null);
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Narco',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}