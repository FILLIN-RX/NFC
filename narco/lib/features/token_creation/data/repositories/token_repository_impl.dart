import 'package:hive_flutter/hive_flutter.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/result.dart';
import '../../domain/models/token.dart';
import '../../domain/repositories/token_repository.dart';
import '../datasources/database_helper.dart';
import '../../../../core/services/security_service.dart';

class TokenRepositoryImpl implements TokenRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Box get _cacheBox => Hive.box(AppConstants.hiveBoxName);

  @override
  Future<Result<void>> saveToken(Token token) async {
    try {
      final securedToken = SecurityService.secureToken(token);
      final db = await _dbHelper.database;
      
      if (db != null) {
        await db.insert(
          'tokens',
          securedToken.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await _cacheBox.put(securedToken.tokenId, securedToken.toJson());
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
        return Success(Token.fromJson(data));
      }

      final db = await _dbHelper.database;
      if (db != null) {
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
      }
      return const Success(null);
    } catch (e) {
      return Failure('Erreur lors de la récupération du jeton.', error: e);
    }
  }

  @override
  Future<Result<List<Token>>> getAllTokens() async {
    try {
      final db = await _dbHelper.database;
      if (db != null) {
        final List<Map<String, dynamic>> maps = await db.query('tokens', orderBy: 'dateCreation DESC');
        return Success(maps.map((json) => Token.fromJson(json)).toList());
      }
      return const Success([]);
    } catch (e) {
      return Failure('Impossible de charger les jetons.', error: e);
    }
  }

  @override
  Future<Result<void>> updateTokenStatus(String tokenId, String newStatus) async {
    try {
      final db = await _dbHelper.database;
      if (db != null) {
        await db.update('tokens', {'statut': newStatus}, where: 'tokenId = ?', whereArgs: [tokenId]);
      }
      if (_cacheBox.containsKey(tokenId)) {
        final data = Map<String, dynamic>.from(_cacheBox.get(tokenId));
        data['statut'] = newStatus;
        await _cacheBox.put(tokenId, data);
      }
      return const Success(null);
    } catch (e) {
      return Failure('Échec de la mise à jour.', error: e);
    }
  }

  @override
  Future<Result<void>> deleteToken(String tokenId) async {
    try {
      final db = await _dbHelper.database;
      if (db != null) {
        await db.delete('tokens', where: 'tokenId = ?', whereArgs: [tokenId]);
      }
      await _cacheBox.delete(tokenId);
      return const Success(null);
    } catch (e) {
      return Failure('Échec de la suppression.', error: e);
    }
  }

  @override
  Future<Result<bool>> exists(String tokenId) async {
    try {
      final db = await _dbHelper.database;
      if (db != null) {
        final maps = await db.query('tokens', where: 'tokenId = ?', whereArgs: [tokenId], limit: 1);
        return Success(maps.isNotEmpty);
      }
      return const Success(false);
    } catch (e) {
      return Failure('Erreur de vérification.', error: e);
    }
  }
}