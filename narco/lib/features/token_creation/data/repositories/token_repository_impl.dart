import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/result.dart';
import '../../domain/models/token.dart';
import '../../domain/repositories/token_repository.dart';
import '../datasources/database_helper.dart';

class TokenRepositoryImpl implements TokenRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Box get _cacheBox => Hive.box('token_cache');

  @override
  Future<Result<void>> saveToken(Token token) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'tokens',
        token.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await _cacheBox.put(token.tokenId, token.toJson());
      AppLogger.info('REPOSITORY', 'Jeton ${token.tokenId} sauvegardé (SQLite + Hive).');
      return const Success(null);
    } catch (e) {
      AppLogger.error('REPOSITORY', 'Échec de sauvegarde', e);
      return Failure('Impossible de sauvegarder le jeton.', error: e);
    }
  }

  @override
  Future<Result<Token?>> getTokenById(String tokenId) async {
    try {
      if (_cacheBox.containsKey(tokenId)) {
        final data = Map<String, dynamic>.from(_cacheBox.get(tokenId));
        AppLogger.info('REPOSITORY', 'Jeton $tokenId récupéré depuis Hive.');
        return Success(Token.fromJson(data));
      }

      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'tokens',
        where: 'tokenId = ?',
        whereArgs: [tokenId],
      );

      if (maps.isNotEmpty) {
        final token = Token.fromJson(maps.first);
        await _cacheBox.put(tokenId, token.toJson());
        return Success(token);
      }
      return const Success(null);
    } catch (e) {
      AppLogger.error('REPOSITORY', 'Erreur de lecture', e);
      return Failure('Erreur lors de la récupération du jeton.', error: e);
    }
  }

  @override
  Future<Result<List<Token>>> getAllTokens() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('tokens', orderBy: 'dateCreation DESC');
      final tokens = maps.map((json) => Token.fromJson(json)).toList();
      return Success(tokens);
    } catch (e) {
      AppLogger.error('REPOSITORY', 'Erreur de liste', e);
      return Failure('Impossible de charger les jetons.', error: e);
    }
  }

  @override
  Future<Result<void>> updateTokenStatus(String tokenId, String newStatus) async {
    try {
      final db = await _dbHelper.database;

      await db.update(
        'tokens',
        {'statut': newStatus},
        where: 'tokenId = ?',
        whereArgs: [tokenId],
      );

      if (_cacheBox.containsKey(tokenId)) {
        final data = Map<String, dynamic>.from(_cacheBox.get(tokenId));
        data['statut'] = newStatus;
        await _cacheBox.put(tokenId, data);
      }

      AppLogger.info('REPOSITORY', 'Statut du jeton $tokenId mis à jour vers: $newStatus');
      return const Success(null);
    } catch (e) {
      AppLogger.error('REPOSITORY', 'Erreur de mise à jour du statut', e);
      return Failure('Échec de la mise à jour du statut.', error: e);
    }
  }

  @override
  Future<Result<void>> deleteToken(String tokenId) async {
    try {
      final db = await _dbHelper.database;

      await db.delete(
        'tokens',
        where: 'tokenId = ?',
        whereArgs: [tokenId],
      );

      await _cacheBox.delete(tokenId);

      AppLogger.info('REPOSITORY', 'Jeton $tokenId supprimé définitivement.');
      return const Success(null);
    } catch (e) {
      AppLogger.error('REPOSITORY', 'Erreur de suppression', e);
      return Failure('Échec de la suppression du jeton.', error: e);
    }
  }
}
