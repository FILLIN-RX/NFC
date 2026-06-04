import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/result.dart';
import '../../domain/models/token.dart';
import '../../domain/models/token_type.dart';
import '../providers/repository_provider.dart';

part 'token_creation_vm.g.dart';

class TokenCreationState {
  final TokenType tokenType;
  final String valeurText;
  final String proprietaire;
  final bool isSubmitting;
  final String? error;
  final bool isSuccess;

  const TokenCreationState({
    this.tokenType = TokenType.payment,
    this.valeurText = '',
    this.proprietaire = '',
    this.isSubmitting = false,
    this.error,
    this.isSuccess = false,
  });

  TokenCreationState copyWith({
    TokenType? tokenType,
    String? valeurText,
    String? proprietaire,
    bool? isSubmitting,
    String? error,
    bool? isSuccess,
  }) {
    return TokenCreationState(
      tokenType: tokenType ?? this.tokenType,
      valeurText: valeurText ?? this.valeurText,
      proprietaire: proprietaire ?? this.proprietaire,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

@riverpod
class TokenCreationViewModel extends _$TokenCreationViewModel {
  @override
  TokenCreationState build() {
    return const TokenCreationState();
  }

  void setTokenType(TokenType value) => state = state.copyWith(tokenType: value, error: null);
  void setValeur(String value) => state = state.copyWith(valeurText: value, error: null);
  void setProprietaire(String value) => state = state.copyWith(proprietaire: value, error: null);

  String? _validate() {
    final valeur = double.tryParse(state.valeurText.replaceAll(',', '.'));
    if (valeur == null || valeur <= 0) return 'La valeur doit être un nombre positif.';
    if (state.proprietaire.trim().isEmpty) return 'Le propriétaire est requis.';
    return null;
  }

  Future<void> createToken() async {
    final validationError = _validate();
    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final valeur = double.parse(state.valeurText.replaceAll(',', '.'));
      final now = DateTime.now();
      final tokenId = const Uuid().v4();
      final type = state.tokenType;

      final rawData = '$tokenId|${type.code}|$valeur|${state.proprietaire}|$now';
      final hash = sha256.convert(utf8.encode(rawData)).toString();
      final key = utf8.encode('narco-secret-key');
      final signature = Hmac(sha256, key).convert(utf8.encode(rawData)).toString();

      final token = Token(
        tokenId: tokenId,
        type: type,
        valeur: valeur,
        valeurUnite: type.defaultUnite,
        dateCreation: now,
        dateExpiration: now.add(const Duration(days: 30)),
        proprietaire: state.proprietaire.trim(),
        hash: hash,
        signature: signature,
        statut: 'actif',
      );

      final repository = ref.read(tokenRepositoryProvider);
      final result = await repository.saveToken(token);

      switch (result) {
        case Success():
          AppLogger.info('CREATE_VM', 'Jeton $tokenId créé avec succès.');
          state = state.copyWith(isSubmitting: false, isSuccess: true);
        case Failure(:final message):
          state = state.copyWith(isSubmitting: false, error: message);
      }
    } catch (e) {
      AppLogger.error('CREATE_VM', 'Erreur inattendue', e);
      state = state.copyWith(isSubmitting: false, error: 'Erreur inattendue: $e');
    }
  }

  void reset() {
    state = const TokenCreationState();
  }
}
