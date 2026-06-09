import 'package:flutter/material.dart';

import '../../domain/models/token_type.dart';

/// Visual identity for each token type.
/// Contains colour, icon AND the premium card gradient colours.
class TokenTypeConfig {
  final TokenType type;
  final String label;
  final String unit;
  final Color color;
  final IconData icon;

  /// Three gradient stops for the premium card face.
  final List<Color> gradientColors;

  /// Subtle accent used for decorative background circles.
  final Color accentColor;

  const TokenTypeConfig({
    required this.type,
    required this.label,
    required this.unit,
    required this.color,
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
  });

  // ─── All Configurations ──────────────────────────────────────────────────

  static const List<TokenTypeConfig> all = [
    // Payment — deep royal blue → electric indigo
    TokenTypeConfig(
      type: TokenType.payment,
      label: 'Paiement',
      unit: 'XAF',
      color: Color(0xFF2563EB),
      icon: Icons.payments_outlined,
      gradientColors: [
        Color(0xFF1E40AF),
        Color(0xFF2563EB),
        Color(0xFF4F46E5),
      ],
      accentColor: Color(0xFF818CF8),
    ),

    // Ticket — deep violet → bright purple
    TokenTypeConfig(
      type: TokenType.ticket,
      label: 'Ticket',
      unit: 'Pass',
      color: Color(0xFF7C3AED),
      icon: Icons.confirmation_number_outlined,
      gradientColors: [
        Color(0xFF4C1D95),
        Color(0xFF7C3AED),
        Color(0xFFA855F7),
      ],
      accentColor: Color(0xFFD8B4FE),
    ),

    // Loyalty — deep emerald → teal
    TokenTypeConfig(
      type: TokenType.loyalty,
      label: 'Fidélité',
      unit: 'Pts',
      color: Color(0xFF059669),
      icon: Icons.stars_outlined,
      gradientColors: [
        Color(0xFF064E3B),
        Color(0xFF059669),
        Color(0xFF0D9488),
      ],
      accentColor: Color(0xFF6EE7B7),
    ),

    // Access — deep burnt orange → amber
    TokenTypeConfig(
      type: TokenType.access,
      label: 'Accès',
      unit: 'Pass',
      color: Color(0xFFEA580C),
      icon: Icons.vpn_key_outlined,
      gradientColors: [
        Color(0xFF7C2D12),
        Color(0xFFEA580C),
        Color(0xFFF59E0B),
      ],
      accentColor: Color(0xFFFCD34D),
    ),

    // Voucher — deep rose → hot pink
    TokenTypeConfig(
      type: TokenType.voucher,
      label: 'Bon',
      unit: '%',
      color: Color(0xFFDB2777),
      icon: Icons.local_offer_outlined,
      gradientColors: [
        Color(0xFF831843),
        Color(0xFFDB2777),
        Color(0xFFEC4899),
      ],
      accentColor: Color(0xFFF9A8D4),
    ),

    // Other — deep slate → zinc
    TokenTypeConfig(
      type: TokenType.other,
      label: 'Autre',
      unit: 'Unités',
      color: Color(0xFF4B5563),
      icon: Icons.more_horiz,
      gradientColors: [
        Color(0xFF111827),
        Color(0xFF374151),
        Color(0xFF6B7280),
      ],
      accentColor: Color(0xFF9CA3AF),
    ),
  ];

  static TokenTypeConfig fromType(TokenType type) =>
      all.firstWhere((c) => c.type == type);
}
