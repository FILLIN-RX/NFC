enum TokenType {
  payment('PAYMENT', 'Paiement', 'FCFA'),
  ticket('TICKET', 'Ticket', 'entrée(s)'),
  loyalty('LOYALTY', 'Fidélité', 'points'),
  access('ACCESS', 'Accès', 'pass'),
  voucher('VOUCHER', 'Bon', '%'),
  other('OTHER', 'Autre', 'unité(s)');

  final String code;
  final String label;
  final String defaultUnite;

  const TokenType(this.code, this.label, this.defaultUnite);

  static TokenType fromCode(String code) =>
      TokenType.values.firstWhere((e) => e.code == code, orElse: () => other);
}
