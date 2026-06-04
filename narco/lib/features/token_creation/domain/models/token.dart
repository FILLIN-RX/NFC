import 'package:json_annotation/json_annotation.dart';

import 'token_type.dart';

part 'token.g.dart';

@JsonSerializable()
class Token {
  final String tokenId;
  final TokenType type;
  final double valeur;
  final String valeurUnite;
  final DateTime dateCreation;
  final DateTime dateExpiration;
  final String proprietaire;
  final String hash;
  final String signature;
  final String statut;

  const Token({
    required this.tokenId,
    required this.type,
    required this.valeur,
    this.valeurUnite = 'FCFA',
    required this.dateCreation,
    required this.dateExpiration,
    required this.proprietaire,
    required this.hash,
    required this.signature,
    required this.statut,
  });

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  Map<String, dynamic> toJson() => _$TokenToJson(this);

  Token copyWith({
    String? tokenId,
    TokenType? type,
    double? valeur,
    String? valeurUnite,
    DateTime? dateCreation,
    DateTime? dateExpiration,
    String? proprietaire,
    String? hash,
    String? signature,
    String? statut,
  }) {
    return Token(
      tokenId: tokenId ?? this.tokenId,
      type: type ?? this.type,
      valeur: valeur ?? this.valeur,
      valeurUnite: valeurUnite ?? this.valeurUnite,
      dateCreation: dateCreation ?? this.dateCreation,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      proprietaire: proprietaire ?? this.proprietaire,
      hash: hash ?? this.hash,
      signature: signature ?? this.signature,
      statut: statut ?? this.statut,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Token &&
          runtimeType == other.runtimeType &&
          tokenId == other.tokenId &&
          type == other.type &&
          valeur == other.valeur &&
          valeurUnite == other.valeurUnite &&
          dateCreation == other.dateCreation &&
          dateExpiration == other.dateExpiration &&
          proprietaire == other.proprietaire &&
          hash == other.hash &&
          signature == other.signature &&
          statut == other.statut;

  @override
  int get hashCode => Object.hash(
        tokenId,
        type,
        valeur,
        valeurUnite,
        dateCreation,
        dateExpiration,
        proprietaire,
        hash,
        signature,
        statut,
      );

  @override
  String toString() {
    return 'Token(tokenId: $tokenId, type: ${type.code}, valeur: $valeur $valeurUnite, '
        'dateCreation: $dateCreation, dateExpiration: $dateExpiration, '
        'proprietaire: $proprietaire, hash: $hash, signature: $signature, '
        'statut: $statut)';
  }
}
