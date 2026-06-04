import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/token_repository_impl.dart';
import '../../domain/repositories/token_repository.dart';

part 'repository_provider.g.dart';

@riverpod
TokenRepository tokenRepository(Ref ref) {
  return TokenRepositoryImpl();
}
