import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:narco/core/utils/ndef_encoder.dart';
import 'package:narco/features/token_creation/domain/models/token.dart';
import 'package:narco/features/token_creation/domain/models/token_type.dart';

Token _buildToken({String proprietaire = 'Awa', double valeur = 1500.0}) {
  return Token(
    tokenId: 'token-123',
    type: TokenType.payment,
    valeur: valeur,
    dateCreation: DateTime(2024, 1, 1, 12),
    dateExpiration: DateTime(2024, 2, 1, 12),
    proprietaire: proprietaire,
    hash: 'hash',
    signature: 'sig',
    statut: 'actif',
  );
}

void main() {
  group('NdefEncoder', () {
    test('encode → decode (round-trip) restitue le jeton', () {
      final token = _buildToken();
      final bytes = NdefEncoder.encode(token);
      final decoded = NdefEncoder.decode(bytes);
      expect(decoded, token);
    });

    test('produit un enregistrement MIME de type narco', () {
      final message = NdefEncoder.buildMessage(_buildToken());
      expect(message.records, hasLength(1));
      final record = message.records.first;
      expect(utf8.decode(record.type), NdefEncoder.mimeType);
    });

    test('gère un payload long (> 255 octets, record non court)', () {
      // Un long propriétaire force un payload > 255 octets.
      final token = _buildToken(proprietaire: 'A' * 400);
      final bytes = NdefEncoder.encode(token);

      // Le bit SR (0x10) doit être absent pour un long record.
      expect(bytes[0] & 0x10, 0);

      final decoded = NdefEncoder.decode(bytes);
      expect(decoded.proprietaire.length, 400);
    });

    test('lève FormatException sur des octets vides', () {
      expect(
        () => NdefEncoder.decode(Uint8List(0)),
        throwsA(isA<FormatException>()),
      );
    });

    test('lève FormatException sur des données tronquées', () {
      final bytes = NdefEncoder.encode(_buildToken());
      final truncated = bytes.sublist(0, bytes.length - 10);
      expect(
        () => NdefEncoder.decode(truncated),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
