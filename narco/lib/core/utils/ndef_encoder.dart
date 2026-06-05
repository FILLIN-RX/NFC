import 'dart:convert';
import 'dart:typed_data';

import 'package:nfc_manager/ndef_record.dart';

import '../../features/token_creation/domain/models/token.dart';

/// Encodage / décodage d'un [Token] vers un message NDEF (enregistrement MIME
/// `application/vnd.narco.token+json`).
///
/// Ce composant est volontairement indépendant du matériel : il manipule des
/// octets bruts conformes à la spécification NDEF. Il est donc :
///  - transmissible via HCE/ISO-DEP (Dev 2),
///  - inscriptible sur un tag NDEF,
///  - vérifiable côté sécurité (Dev 3).
class NdefEncoder {
  NdefEncoder._();

  /// Type MIME des enregistrements de jeton Narco.
  static const String mimeType = 'application/vnd.narco.token+json';

  /// Construit le message NDEF (modèle objet) correspondant au [token].
  static NdefMessage buildMessage(Token token) {
    final payload = utf8.encode(jsonEncode(token.toJson()));
    final record = NdefRecord(
      typeNameFormat: TypeNameFormat.media,
      type: Uint8List.fromList(utf8.encode(mimeType)),
      identifier: Uint8List(0),
      payload: Uint8List.fromList(payload),
    );
    return NdefMessage(records: [record]);
  }

  /// Sérialise le [token] en octets NDEF prêts à être transmis.
  static Uint8List encode(Token token) {
    final type = utf8.encode(mimeType);
    final payload = utf8.encode(jsonEncode(token.toJson()));
    final shortRecord = payload.length < 256;

    // Octet d'en-tête : MB | ME | (SR) | TNF(media = 0x02)
    int flags = 0x80 | 0x40 | TypeNameFormat.media.index;
    if (shortRecord) flags |= 0x10; // SR (short record)

    final builder = BytesBuilder();
    builder.addByte(flags);
    builder.addByte(type.length);
    if (shortRecord) {
      builder.addByte(payload.length);
    } else {
      builder.add([
        (payload.length >> 24) & 0xFF,
        (payload.length >> 16) & 0xFF,
        (payload.length >> 8) & 0xFF,
        payload.length & 0xFF,
      ]);
    }
    builder.add(type);
    builder.add(payload);
    return builder.toBytes();
  }

  /// Décode des octets NDEF en [Token].
  ///
  /// Lève [FormatException] si les données sont absentes, incomplètes ou ne
  /// correspondent pas au type MIME attendu.
  static Token decode(Uint8List bytes) {
    if (bytes.length < 3) {
      throw const FormatException('Message NDEF incomplet ou vide.');
    }

    var i = 0;
    final flags = bytes[i++];
    final tnf = flags & 0x07;
    final shortRecord = (flags & 0x10) != 0;
    final hasId = (flags & 0x08) != 0;

    if (tnf != TypeNameFormat.media.index) {
      throw const FormatException('Enregistrement NDEF non MIME inattendu.');
    }

    final typeLength = bytes[i++];

    int payloadLength;
    if (shortRecord) {
      payloadLength = bytes[i++];
    } else {
      payloadLength = (bytes[i] << 24) |
          (bytes[i + 1] << 16) |
          (bytes[i + 2] << 8) |
          bytes[i + 3];
      i += 4;
    }

    var idLength = 0;
    if (hasId) {
      idLength = bytes[i++];
    }

    if (i + typeLength + idLength + payloadLength > bytes.length) {
      throw const FormatException('Longueurs NDEF incohérentes (données tronquées).');
    }

    final type = utf8.decode(bytes.sublist(i, i + typeLength));
    i += typeLength + idLength;
    if (type != mimeType) {
      throw FormatException('Type MIME inattendu : $type');
    }

    final payload = bytes.sublist(i, i + payloadLength);
    final json = jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;
    return Token.fromJson(json);
  }
}
