// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
  tokenId: json['tokenId'] as String,
  type: const _TokenTypeConverter().fromJson(json['type'] as String),
  valeur: (json['valeur'] as num).toDouble(),
  valeurUnite: json['valeurUnite'] as String? ?? 'FCFA',
  dateCreation: DateTime.parse(json['dateCreation'] as String),
  dateExpiration: DateTime.parse(json['dateExpiration'] as String),
  proprietaire: json['proprietaire'] as String,
  hash: json['hash'] as String,
  signature: json['signature'] as String,
  statut: json['statut'] as String,
  direction: json['direction'] as String? ?? 'outgoing',
);

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
  'tokenId': instance.tokenId,
  'type': const _TokenTypeConverter().toJson(instance.type),
  'valeur': instance.valeur,
  'valeurUnite': instance.valeurUnite,
  'dateCreation': instance.dateCreation.toIso8601String(),
  'dateExpiration': instance.dateExpiration.toIso8601String(),
  'proprietaire': instance.proprietaire,
  'hash': instance.hash,
  'signature': instance.signature,
  'statut': instance.statut,
  'direction': instance.direction,
};
