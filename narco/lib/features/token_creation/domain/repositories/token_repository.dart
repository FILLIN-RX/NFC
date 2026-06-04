import '../../../../core/utils/result.dart';
import '../models/token.dart';

abstract class TokenRepository {
  Future<Result<void>> saveToken(Token token);
  Future<Result<Token?>> getTokenById(String tokenId);
  Future<Result<List<Token>>> getAllTokens();
  Future<Result<void>> updateTokenStatus(String tokenId, String newStatus);
  Future<Result<void>> deleteToken(String tokenId);
}
