import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:narco/core/utils/result.dart';
import 'package:narco/features/token_creation/domain/models/token.dart';
import 'package:narco/features/token_creation/domain/repositories/token_repository.dart';
import 'package:narco/features/token_creation/presentation/providers/repository_provider.dart';
import 'package:narco/features/token_creation/presentation/providers/token_creation_vm.dart';

class MockTokenRepository extends Mock implements TokenRepository {
  @override
  Future<Result<void>> saveToken(Token? token) =>
      super.noSuchMethod(Invocation.method(#saveToken, [token]), returnValue: Future.value(const Success<void>(null)));

  @override
  Future<Result<Token?>> getTokenById(String? tokenId) =>
      super.noSuchMethod(Invocation.method(#getTokenById, [tokenId]), returnValue: Future.value(const Success<Token?>(null)));
}

void main() {
  group('TokenCreationViewModel Tests', () {
    late MockTokenRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockTokenRepository();
      container = ProviderContainer(
        overrides: [
          tokenRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is empty', () {
      final state = container.read(tokenCreationViewModelProvider);
      expect(state.type, '');
      expect(state.valeurText, '');
      expect(state.proprietaire, '');
      expect(state.isSubmitting, false);
      expect(state.error, isNull);
      expect(state.isSuccess, false);
    });

    test('Validation fails on empty type', () async {
      container.read(tokenCreationViewModelProvider.notifier).setValeur('10');
      container.read(tokenCreationViewModelProvider.notifier).setProprietaire('User');
      
      await container.read(tokenCreationViewModelProvider.notifier).createToken();
      
      final state = container.read(tokenCreationViewModelProvider);
      expect(state.error, 'Le type est requis.');
    });

    test('Validation fails on invalid valeur', () async {
      container.read(tokenCreationViewModelProvider.notifier).setType('Test');
      container.read(tokenCreationViewModelProvider.notifier).setValeur('invalid');
      container.read(tokenCreationViewModelProvider.notifier).setProprietaire('User');
      
      await container.read(tokenCreationViewModelProvider.notifier).createToken();
      
      final state = container.read(tokenCreationViewModelProvider);
      expect(state.error, 'La valeur doit être un nombre positif.');
    });

    test('Validation fails on empty proprietaire', () async {
      container.read(tokenCreationViewModelProvider.notifier).setType('Test');
      container.read(tokenCreationViewModelProvider.notifier).setValeur('10');
      
      await container.read(tokenCreationViewModelProvider.notifier).createToken();
      
      final state = container.read(tokenCreationViewModelProvider);
      expect(state.error, 'Le propriétaire est requis.');
    });

    test('Successfully creates a token', () async {
      container.read(tokenCreationViewModelProvider.notifier).setType('Test');
      container.read(tokenCreationViewModelProvider.notifier).setValeur('10');
      container.read(tokenCreationViewModelProvider.notifier).setProprietaire('User');
      
      when(mockRepository.getTokenById(any)).thenAnswer((_) async => const Success(null));
      when(mockRepository.saveToken(any)).thenAnswer((_) async => const Success(null));

      await container.read(tokenCreationViewModelProvider.notifier).createToken();
      
      final state = container.read(tokenCreationViewModelProvider);
      expect(state.error, isNull);
      expect(state.isSubmitting, false);
      expect(state.isSuccess, true);
    });

    test('Fails when UUID already exists', () async {
      container.read(tokenCreationViewModelProvider.notifier).setType('Test');
      container.read(tokenCreationViewModelProvider.notifier).setValeur('10');
      container.read(tokenCreationViewModelProvider.notifier).setProprietaire('User');
      
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

      when(mockRepository.getTokenById(any)).thenAnswer((_) async => Success(token));

      await container.read(tokenCreationViewModelProvider.notifier).createToken();
      
      final state = container.read(tokenCreationViewModelProvider);
      expect(state.error, 'Un jeton avec cet identifiant existe déjà (UUID existant).');
      expect(state.isSuccess, false);
    });
  });
}
