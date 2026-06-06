import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../../domain/models/transaction_record.dart';
import '../../../../core/utils/app_logger.dart';

class HistoryService {
  static final HistoryService instance = HistoryService._init();
  static Database? _database;

  HistoryService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      return openReadOnlyDatabase(':memory:');
    }
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        tokenId TEXT NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        method TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        peerName TEXT
      )
    ''');
  }

  Future<void> recordTransaction(TransactionRecord record) async {
    final db = await database;
    await db.insert('transactions', record.toJson(), 
        conflictAlgorithm: ConflictAlgorithm.replace);
    AppLogger.info('HISTORY', 'Transaction enregistrée: ${record.id}');
  }

  Future<List<TransactionRecord>> getTransactions({
    String? query,
    TransactionType? type,
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (type != null) {
      whereClause = 'type = ?';
      whereArgs = [type.name];
    }

    if (query != null && query.isNotEmpty) {
      whereClause = (whereClause == null) ? 'peerName LIKE ?' : '$whereClause AND peerName LIKE ?';
      whereArgs = (whereArgs ?? [])..add('%$query%');
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((json) => TransactionRecord.fromJson(json)).toList();
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    AppLogger.info('HISTORY', 'Transaction $id supprimée.');
  }
}