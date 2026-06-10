import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../../domain/models/transaction_record.dart';

class HistoryService {
  static final HistoryService instance = HistoryService._init();
  static Database? _database;

  HistoryService._init();

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('history.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
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

  Future<List<TransactionRecord>> getTransactions({
    String? query,
    TransactionType? type,
    int limit = 20,
    int offset = 0,
  }) async {
    if (kIsWeb) {
      // Données de test uniquement pour Chrome
      return [
        TransactionRecord(
          id: '1',
          tokenId: 'tok_1',
          type: TransactionType.outgoing,
          date: DateTime.now().subtract(const Duration(hours: 2)),
          status: 'Validé',
          method: TransferMethod.nfc,
          amount: 5000,
          currency: 'FCFA',
          peerName: 'Jean Dupont',
        ),
        TransactionRecord(
          id: '2',
          tokenId: 'tok_2',
          type: TransactionType.incoming,
          date: DateTime.now().subtract(const Duration(days: 1)),
          status: 'Validé',
          method: TransferMethod.bluetooth,
          amount: 12500,
          currency: 'FCFA',
          peerName: 'Marie Louise',
        ),
      ];
    }

    final db = await database;
    if (db == null) return [];

    final whereClause = <String>[];
    final whereArgs = <dynamic>[];

    if (query != null && query.isNotEmpty) {
      whereClause.add('(peerName LIKE ? OR currency LIKE ?)');
      final q = '%$query%';
      whereArgs.addAll([q, q]);
    }

    if (type != null) {
      whereClause.add('type = ?');
      whereArgs.add(type.name);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: whereClause.isNotEmpty ? whereClause.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((json) => TransactionRecord.fromJson(json)).toList();
  }

  Future<void> recordTransaction(TransactionRecord record) async {
    if (kIsWeb) return;
    final db = await database;
    if (db != null) {
      await db.insert('transactions', record.toJson(), 
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}