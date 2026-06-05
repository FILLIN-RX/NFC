import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:narco/core/utils/result.dart';
import 'package:narco/features/token_creation/domain/models/token.dart';
import 'package:narco/features/token_creation/domain/models/token_type.dart';
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

Token _buildToken({String id = '123'}) {
  return Token(
    tokenId: id,
    type: TokenType.payment,
    valeur: 10.0,
    dateCreation: DateTime(2024, 1, 1),
    dateExpiration: DateTime(2024, 2, 1),
    proprietaire: 'User',
    hash: 'hash',
    signature: 'sig',
    statut: 'actif',
  );
}

void main() {
  group('TokenRepository Mock Tests', () {
    late MockTokenRepository repository;

    setUp(() {
      repository = MockTokenRepository();
    });

    test('saveToken returns Success on successful save', () async {
      final token = _buildToken();

      when(repository.saveToken(token)).thenAnswer((_) async => const Success(null));

      final result = await repository.saveToken(token);
      expect(result, isA<Success<void>>());
    });

    test('getTokenById returns token when found', () async {
      final token = _buildToken();

      when(repository.getTokenById('123')).thenAnswer((_) async => Success(token));

      final result = await repository.getTokenById('123');
      expect(result, isA<Success<Token?>>());

      switch (result) {
        case Success(:final data):
          expect(data?.tokenId, '123');
          expect(data?.type, TokenType.payment);
        case Failure():
          fail('Expected Success');
      }
    });

    test('getAllTokens returns the stored list', () async {
      final tokens = [_buildToken(id: 'a'), _buildToken(id: 'b')];

      when(repository.getAllTokens()).thenAnswer((_) async => Success(tokens));

      final result = await repository.getAllTokens();

      switch (result) {
        case Success(:final data):
          expect(data.length, 2);
        case Failure():
          fail('Expected Success');
      }
    });
  });

  group('Token model', () {
    test('serializes and deserializes via JSON (round-trip)', () {
      final token = _buildToken();
      final json = token.toJson();

      expect(json['type'], 'PAYMENT');
      expect(json['direction'], 'outgoing');

      final restored = Token.fromJson(json);
      expect(restored, token);
    });

    test('direction getters reflect the value', () {
      final outgoing = _buildToken();
      expect(outgoing.isOutgoing, true);
      expect(outgoing.isIncoming, false);

      final incoming = outgoing.copyWith(direction: 'incoming');
      expect(incoming.isIncoming, true);
      expect(incoming.isOutgoing, false);
    });
  });
}
