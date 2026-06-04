import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../token_creation/domain/models/token.dart';
import '../../../token_creation/presentation/providers/repository_provider.dart';

final tokenListProvider = FutureProvider<List<Token>>((ref) async {
  final repo = ref.read(tokenRepositoryProvider);
  final result = await repo.getAllTokens();
  return result.when(
    success: (tokens) => tokens,
    failure: (_) => [],
  );
});
