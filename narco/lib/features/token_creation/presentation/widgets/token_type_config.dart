import 'package:flutter/material.dart';

import '../../domain/models/token_type.dart';

class TokenTypeConfig {
  final TokenType type;
  final String label;
  final String unit;
  final Color color;
  final IconData icon;

  const TokenTypeConfig({
    required this.type,
    required this.label,
    required this.unit,
    required this.color,
    required this.icon,
  });

  static const List<TokenTypeConfig> all = [
    TokenTypeConfig(
      type: TokenType.payment,
      label: 'Paiement',
      unit: 'XAF',
      color: Color(0xFF2563EB),
      icon: Icons.payments_outlined,
    ),
    TokenTypeConfig(
      type: TokenType.ticket,
      label: 'Ticket',
      unit: 'Pass',
      color: Color(0xFF7C3AED),
      icon: Icons.confirmation_number_outlined,
    ),
    TokenTypeConfig(
      type: TokenType.loyalty,
      label: 'Fidélité',
      unit: 'Pts',
      color: Color(0xFF059669),
      icon: Icons.stars_outlined,
    ),
    TokenTypeConfig(
      type: TokenType.access,
      label: 'Accès',
      unit: 'Pass',
      color: Color(0xFFEA580C),
      icon: Icons.vpn_key_outlined,
    ),
    TokenTypeConfig(
      type: TokenType.voucher,
      label: 'Bon',
      unit: '%',
      color: Color(0xFFDB2777),
      icon: Icons.local_offer_outlined,
    ),
    TokenTypeConfig(
      type: TokenType.other,
      label: 'Autre',
      unit: 'Unités',
      color: Color(0xFF4B5563),
      icon: Icons.more_horiz,
    ),
  ];

  static TokenTypeConfig fromType(TokenType type) =>
      all.firstWhere((c) => c.type == type);
}
