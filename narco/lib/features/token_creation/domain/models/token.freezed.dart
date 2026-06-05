// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Token {

 String get tokenId;@_TokenTypeConverter() TokenType get type; double get valeur; String get valeurUnite; DateTime get dateCreation; DateTime get dateExpiration; String get proprietaire; String get hash; String get signature; String get statut; String get direction;
/// Create a copy of Token
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenCopyWith<Token> get copyWith => _$TokenCopyWithImpl<Token>(this as Token, _$identity);

  /// Serializes this Token to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Token&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId)&&(identical(other.type, type) || other.type == type)&&(identical(other.valeur, valeur) || other.valeur == valeur)&&(identical(other.valeurUnite, valeurUnite) || other.valeurUnite == valeurUnite)&&(identical(other.dateCreation, dateCreation) || other.dateCreation == dateCreation)&&(identical(other.dateExpiration, dateExpiration) || other.dateExpiration == dateExpiration)&&(identical(other.proprietaire, proprietaire) || other.proprietaire == proprietaire)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.signature, signature) || other.signature == signature)&&(identical(other.statut, statut) || other.statut == statut)&&(identical(other.direction, direction) || other.direction == direction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tokenId,type,valeur,valeurUnite,dateCreation,dateExpiration,proprietaire,hash,signature,statut,direction);

@override
String toString() {
  return 'Token(tokenId: $tokenId, type: $type, valeur: $valeur, valeurUnite: $valeurUnite, dateCreation: $dateCreation, dateExpiration: $dateExpiration, proprietaire: $proprietaire, hash: $hash, signature: $signature, statut: $statut, direction: $direction)';
}


}

/// @nodoc
abstract mixin class $TokenCopyWith<$Res>  {
  factory $TokenCopyWith(Token value, $Res Function(Token) _then) = _$TokenCopyWithImpl;
@useResult
$Res call({
 String tokenId,@_TokenTypeConverter() TokenType type, double valeur, String valeurUnite, DateTime dateCreation, DateTime dateExpiration, String proprietaire, String hash, String signature, String statut, String direction
});




}
/// @nodoc
class _$TokenCopyWithImpl<$Res>
    implements $TokenCopyWith<$Res> {
  _$TokenCopyWithImpl(this._self, this._then);

  final Token _self;
  final $Res Function(Token) _then;

/// Create a copy of Token
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tokenId = null,Object? type = null,Object? valeur = null,Object? valeurUnite = null,Object? dateCreation = null,Object? dateExpiration = null,Object? proprietaire = null,Object? hash = null,Object? signature = null,Object? statut = null,Object? direction = null,}) {
  return _then(_self.copyWith(
tokenId: null == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TokenType,valeur: null == valeur ? _self.valeur : valeur // ignore: cast_nullable_to_non_nullable
as double,valeurUnite: null == valeurUnite ? _self.valeurUnite : valeurUnite // ignore: cast_nullable_to_non_nullable
as String,dateCreation: null == dateCreation ? _self.dateCreation : dateCreation // ignore: cast_nullable_to_non_nullable
as DateTime,dateExpiration: null == dateExpiration ? _self.dateExpiration : dateExpiration // ignore: cast_nullable_to_non_nullable
as DateTime,proprietaire: null == proprietaire ? _self.proprietaire : proprietaire // ignore: cast_nullable_to_non_nullable
as String,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,signature: null == signature ? _self.signature : signature // ignore: cast_nullable_to_non_nullable
as String,statut: null == statut ? _self.statut : statut // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Token].
extension TokenPatterns on Token {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Token value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Token() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Token value)  $default,){
final _that = this;
switch (_that) {
case _Token():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Token value)?  $default,){
final _that = this;
switch (_that) {
case _Token() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String tokenId, @_TokenTypeConverter()  TokenType type,  double valeur,  String valeurUnite,  DateTime dateCreation,  DateTime dateExpiration,  String proprietaire,  String hash,  String signature,  String statut,  String direction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Token() when $default != null:
return $default(_that.tokenId,_that.type,_that.valeur,_that.valeurUnite,_that.dateCreation,_that.dateExpiration,_that.proprietaire,_that.hash,_that.signature,_that.statut,_that.direction);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String tokenId, @_TokenTypeConverter()  TokenType type,  double valeur,  String valeurUnite,  DateTime dateCreation,  DateTime dateExpiration,  String proprietaire,  String hash,  String signature,  String statut,  String direction)  $default,) {final _that = this;
switch (_that) {
case _Token():
return $default(_that.tokenId,_that.type,_that.valeur,_that.valeurUnite,_that.dateCreation,_that.dateExpiration,_that.proprietaire,_that.hash,_that.signature,_that.statut,_that.direction);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String tokenId, @_TokenTypeConverter()  TokenType type,  double valeur,  String valeurUnite,  DateTime dateCreation,  DateTime dateExpiration,  String proprietaire,  String hash,  String signature,  String statut,  String direction)?  $default,) {final _that = this;
switch (_that) {
case _Token() when $default != null:
return $default(_that.tokenId,_that.type,_that.valeur,_that.valeurUnite,_that.dateCreation,_that.dateExpiration,_that.proprietaire,_that.hash,_that.signature,_that.statut,_that.direction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Token extends Token {
  const _Token({required this.tokenId, @_TokenTypeConverter() required this.type, required this.valeur, this.valeurUnite = 'FCFA', required this.dateCreation, required this.dateExpiration, required this.proprietaire, required this.hash, required this.signature, required this.statut, this.direction = 'outgoing'}): super._();
  factory _Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

@override final  String tokenId;
@override@_TokenTypeConverter() final  TokenType type;
@override final  double valeur;
@override@JsonKey() final  String valeurUnite;
@override final  DateTime dateCreation;
@override final  DateTime dateExpiration;
@override final  String proprietaire;
@override final  String hash;
@override final  String signature;
@override final  String statut;
@override@JsonKey() final  String direction;

/// Create a copy of Token
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TokenCopyWith<_Token> get copyWith => __$TokenCopyWithImpl<_Token>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Token&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId)&&(identical(other.type, type) || other.type == type)&&(identical(other.valeur, valeur) || other.valeur == valeur)&&(identical(other.valeurUnite, valeurUnite) || other.valeurUnite == valeurUnite)&&(identical(other.dateCreation, dateCreation) || other.dateCreation == dateCreation)&&(identical(other.dateExpiration, dateExpiration) || other.dateExpiration == dateExpiration)&&(identical(other.proprietaire, proprietaire) || other.proprietaire == proprietaire)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.signature, signature) || other.signature == signature)&&(identical(other.statut, statut) || other.statut == statut)&&(identical(other.direction, direction) || other.direction == direction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tokenId,type,valeur,valeurUnite,dateCreation,dateExpiration,proprietaire,hash,signature,statut,direction);

@override
String toString() {
  return 'Token(tokenId: $tokenId, type: $type, valeur: $valeur, valeurUnite: $valeurUnite, dateCreation: $dateCreation, dateExpiration: $dateExpiration, proprietaire: $proprietaire, hash: $hash, signature: $signature, statut: $statut, direction: $direction)';
}


}

/// @nodoc
abstract mixin class _$TokenCopyWith<$Res> implements $TokenCopyWith<$Res> {
  factory _$TokenCopyWith(_Token value, $Res Function(_Token) _then) = __$TokenCopyWithImpl;
@override @useResult
$Res call({
 String tokenId,@_TokenTypeConverter() TokenType type, double valeur, String valeurUnite, DateTime dateCreation, DateTime dateExpiration, String proprietaire, String hash, String signature, String statut, String direction
});




}
/// @nodoc
class __$TokenCopyWithImpl<$Res>
    implements _$TokenCopyWith<$Res> {
  __$TokenCopyWithImpl(this._self, this._then);

  final _Token _self;
  final $Res Function(_Token) _then;

/// Create a copy of Token
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tokenId = null,Object? type = null,Object? valeur = null,Object? valeurUnite = null,Object? dateCreation = null,Object? dateExpiration = null,Object? proprietaire = null,Object? hash = null,Object? signature = null,Object? statut = null,Object? direction = null,}) {
  return _then(_Token(
tokenId: null == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TokenType,valeur: null == valeur ? _self.valeur : valeur // ignore: cast_nullable_to_non_nullable
as double,valeurUnite: null == valeurUnite ? _self.valeurUnite : valeurUnite // ignore: cast_nullable_to_non_nullable
as String,dateCreation: null == dateCreation ? _self.dateCreation : dateCreation // ignore: cast_nullable_to_non_nullable
as DateTime,dateExpiration: null == dateExpiration ? _self.dateExpiration : dateExpiration // ignore: cast_nullable_to_non_nullable
as DateTime,proprietaire: null == proprietaire ? _self.proprietaire : proprietaire // ignore: cast_nullable_to_non_nullable
as String,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,signature: null == signature ? _self.signature : signature // ignore: cast_nullable_to_non_nullable
as String,statut: null == statut ? _self.statut : statut // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
