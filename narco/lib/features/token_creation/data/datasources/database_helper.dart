import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    AppLogger.info('DATABASE', 'Initialisation de la base SQLite à : $path');
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    AppLogger.info('DATABASE', 'Création de la table tokens...');
    await db.execute('''
      CREATE TABLE tokens (
        tokenId TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        valeur REAL NOT NULL,
        valeurUnite TEXT NOT NULL DEFAULT 'FCFA',
        dateCreation TEXT NOT NULL,
        dateExpiration TEXT NOT NULL,
        proprietaire TEXT NOT NULL,
        hash TEXT NOT NULL,
        signature TEXT NOT NULL,
        statut TEXT NOT NULL,
        direction TEXT NOT NULL DEFAULT 'outgoing'
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        AppLogger.info('DATABASE', 'Migration v1 → v2 : ajout valeurUnite');
        await db.execute('ALTER TABLE tokens ADD COLUMN valeurUnite TEXT NOT NULL DEFAULT "FCFA"');
      } catch (e) {
        AppLogger.warning('DATABASE', 'Migration v1→v2 ignorée (colonne existe probablement)');
      }
    }
    if (oldVersion < 3) {
      try {
        AppLogger.info('DATABASE', 'Migration v2 → v3 : ajout direction');
        await db.execute('ALTER TABLE tokens ADD COLUMN direction TEXT NOT NULL DEFAULT "outgoing"');
      } catch (e) {
        AppLogger.warning('DATABASE', 'Migration v2→v3 ignorée (colonne existe probablement)');
      }
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) await db.close();
  }
}