import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:narco/core/utils/result.dart';
import 'package:narco/features/token_creation/domain/models/token.dart';
import 'package:narco/features/token_creation/domain/repositories/token_repository.dart';

class MockTokenRepository extends Mock implements TokenRepository {
  @override
  Future<Result<void>> saveToken(Token? token) =>
      super.noSuchMethod(Invocation.method(#saveToken, [token]), returnValue: Future.value(const Success<void>(null)));

  @override
  Future<Result<Token?>> getTokenById(String? tokenId) =>
      super.noSuchMethod(Invocation.method(#getTokenById, [tokenId]), returnValue: Future.value(const Success<Token?>(null)));

  @override
  Future<Result<List<Token>>> getAllTokens() =>
      super.noSuchMethod(Invocation.method(#getAllTokens, []), returnValue: Future.value(const Success<List<Token>>([])));

  @override
  Future<Result<void>> updateTokenStatus(String? tokenId, String? newStatus) =>
      super.noSuchMethod(Invocation.method(#updateTokenStatus, [tokenId, newStatus]), returnValue: Future.value(const Success<void>(null)));

  @override
  Future<Result<void>> deleteToken(String? tokenId) =>
      super.noSuchMethod(Invocation.method(#deleteToken, [tokenId]), returnValue: Future.value(const Success<void>(null)));
}

void main() {
  group('TokenRepository Mock Tests', () {
    late MockTokenRepository repository;

    setUp(() {
      repository = MockTokenRepository();
    });

    test('saveToken returns Success on successful save', () async {
      final token = Token(
        tokenId: '123',
        type: 'Test',
        valeur: 10.0,
        dateCreation: DateTime.now(),
        dateExpiration: DateTime.now().add(const Duration(days: 1)),
        proprietaire: 'User',
        hash: 'hash',
        signature: 'sig',
        statut: 'actif',
      );

      when(repository.saveToken(token)).thenAnswer((_) async => const Success(null));

      final result = await repository.saveToken(token);
      expect(result, isA<Success<void>>());
    });

    test('getTokenById returns token when found', () async {
      final token = Token(
        tokenId: '123',
        type: 'Test',
        valeur: 10.0,
        dateCreation: DateTime.now(),
        dateExpiration: DateTime.now().add(const Duration(days: 1)),
        proprietaire: 'User',
        hash: 'hash',
        signature: 'sig',
        statut: 'actif',
      );

      when(repository.getTokenById('123')).thenAnswer((_) async => Success(token));

      final result = await repository.getTokenById('123');
      expect(result, isA<Success<Token?>>());
      
      switch(result) {
        case Success(:final data):
          expect(data?.tokenId, '123');
        case Failure():
          fail('Expected Success');
      }
    });
  });
}
