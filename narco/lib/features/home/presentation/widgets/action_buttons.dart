import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/appTheme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../token_transfer/presentation/widgets/channel_selection_dialog.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_ActionItem> actions = [
      _ActionItem(
        label: AppStrings.actionSend,
        icon: Icons.north_east_rounded,
        color: AppTheme.dark,
        onTap: () => context.push('/transfer'),
      ),
      _ActionItem(
        label: AppStrings.actionReceive,
        icon: Icons.south_west_rounded,
        color: AppTheme.dark,
        onTap: () => ChannelSelectionDialog.showForReceive(context),
      ),
      _ActionItem(
        label: AppStrings.actionCollect,
        icon: Icons.account_balance_wallet_outlined,
        color: AppTheme.dark,
        onTap: () => context.push('/create-token'),
      ),
      _ActionItem(
        label: AppStrings.actionStats,
        icon: Icons.bar_chart_rounded,
        color: AppTheme.dark,
        onTap: () => context.push('/history'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions
            .map((action) => _AnimatedActionButton(item: action))
            .toList(),
      ),
    );
  }
}

// ─── Action Item Model ────────────────────────────────────────────────────────

class _ActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

// ─── Animated Button ──────────────────────────────────────────────────────────

class _AnimatedActionButton extends StatefulWidget {
  final _ActionItem item;
  const _AnimatedActionButton({required this.item});

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();
  void _onTapUp(TapUpDetails _) => _ctrl.reverse();
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.item.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Column(
          children: [
            // ── Bouton cercle ──────────────────────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: widget.item.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.dark.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                widget.item.icon,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.item.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}