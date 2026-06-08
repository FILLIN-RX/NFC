import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'token_type.dart';

part 'token.freezed.dart';
part 'token.g.dart';

class _TokenTypeConverter implements JsonConverter<TokenType, String> {
  const _TokenTypeConverter();

  @override
  TokenType fromJson(String json) => TokenType.fromCode(json);

  @override
  String toJson(TokenType object) => object.code;
}

@freezed
abstract class Token with _$Token {
  const Token._();

  const factory Token({
    required String tokenId,
    @_TokenTypeConverter() required TokenType type,
    required double valeur,
    @Default('FCFA') String valeurUnite,
    required DateTime dateCreation,
    required DateTime dateExpiration,
    required String proprietaire,
    required String hash,
    required String signature,
    required String statut,
    @Default('outgoing') String direction,
  }) = _Token;

  bool get isOutgoing => direction == 'outgoing';
  bool get isIncoming => direction == 'incoming';

  bool get isUsed => statut == 'transféré';

  bool verifyIntegrity() {
    final rawData = '$tokenId|${type.code}|$valeur|$proprietaire|$dateCreation';
    final expectedHash = sha256.convert(utf8.encode(rawData)).toString();
    if (expectedHash != hash) return false;
    final key = utf8.encode('narco-secret-key');
    final expectedSignature =
        Hmac(sha256, key).convert(utf8.encode(rawData)).toString();
    return expectedSignature == signature;
  }

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
}
