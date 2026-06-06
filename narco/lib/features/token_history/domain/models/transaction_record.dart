enum TransactionType { outgoing, incoming }
enum TransferMethod { nfc, bluetooth }

class TransactionRecord {
  final String id;
  final String tokenId;
  final TransactionType type;
  final DateTime date;
  final String status;
  final TransferMethod method;
  final double amount;
  final String currency;
  final String? peerName;

  const TransactionRecord({
    required this.id,
    required this.tokenId,
    required this.type,
    required this.date,
    required this.status,
    required this.method,
    required this.amount,
    required this.currency,
    this.peerName,
  });

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      id: json['id'] as String,
      tokenId: json['tokenId'] as String,
      type: TransactionType.values.firstWhere((e) => e.name == json['type']),
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      method: TransferMethod.values.firstWhere((e) => e.name == json['method']),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      peerName: json['peerName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tokenId': tokenId,
      'type': type.name,
      'date': date.toIso8601String(),
      'status': status,
      'method': method.name,
      'amount': amount,
      'currency': currency,
      'peerName': peerName,
    };
  }
}