import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_record.freezed.dart';
part 'transaction_record.g.dart';

enum TransactionType { outgoing, incoming }
enum TransferMethod { nfc, bluetooth }

@freezed
class TransactionRecord with _$TransactionRecord {
  const factory TransactionRecord({
    required String id,
    required String tokenId,
    required TransactionType type,
    required DateTime date,
    required String status,
    required TransferMethod method,
    required double amount,
    required String currency,
    String? peerName, // Nom de l'expéditeur ou destinataire
  }) = _TransactionRecord;

  factory TransactionRecord.fromJson(Map<String, dynamic> json) => 
      _$TransactionRecordFromJson(json);
}