import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/appTheme.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../../core/widgets/premium_token_card.dart';
import '../../../token_creation/presentation/widgets/token_type_config.dart';
import '../../data/services/bluetooth_service.dart';
import '../../data/services/nfc_service.dart';
import '../providers/transfer_vm.dart';
import '../widgets/bt_device_list.dart';
import '../widgets/nfc_animation.dart';

class TransferScreen extends ConsumerStatefulWidget {
  final String? method;
  final String? tokenId;

  const TransferScreen({super.key, this.method, this.tokenId});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  String? _selectedAddress;

  bool get _isBluetooth => widget.method == 'bluetooth';
  bool get _isReceive => widget.tokenId == null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    final vm = ref.read(transferViewModelProvider.notifier);
    if (_isBluetooth) {
      if (_isReceive) {
        vm.startBluetoothReceive();
      } else if (_selectedAddress != null) {
        vm.startBluetoothSend(widget.tokenId!, _selectedAddress!);
      }
    } else {
      if (_isReceive) {
        vm.startReceive();
      } else {
        vm.startSend(widget.tokenId!);
      }
    }
  }

  void _onDeviceSelected(BtDevice device) {
    setState(() => _selectedAddress = device.address);
    ref
        .read(transferViewModelProvider.notifier)
        .startBluetoothSend(widget.tokenId!, device.address);
  }

  @override
  Widget build(BuildContext context) {
    final channel = _isBluetooth ? 'Bluetooth' : 'NFC';

    ref.listen<TransferState>(transferViewModelProvider, (previous, next) {
      if (next.status == TransferStatus.error &&
          previous?.status != TransferStatus.error) {
        _showErrorDialog(next.error ?? 'Une erreur est survenue.');
      }
      if (next.status == TransferStatus.connected &&
          previous?.status != TransferStatus.connected) {
        HapticFeedback.mediumImpact();
      }
      if (next.status == TransferStatus.success &&
          previous?.status != TransferStatus.success) {
        FeedbackService.instance.triggerSuccess();
      }
    });

    final state = ref.watch(transferViewModelProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Custom header ─────────────────────────────────────────
            _TransferHeader(
              channel: channel,
              isReceive: _isReceive,
              onBack: () => context.go('/'),
            ),
            // ── Body ─────────────────────────────────────────────────
            Expanded(
              child: _buildBody(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TransferState state) {
    if (_isBluetooth &&
        !_isReceive &&
        _selectedAddress == null &&
        state.status == TransferStatus.idle) {
      return BluetoothDeviceList(onSelected: _onDeviceSelected);
    }

    return switch (state.status) {
      TransferStatus.success => _buildSuccess(state),
      TransferStatus.error => _buildError(state),
      TransferStatus.received => _buildConfirmation(state),
      _ => _buildInProgress(state),
    };
  }

  // ─── In Progress ────────────────────────────────────────────────────────────

  Widget _buildInProgress(TransferState state) {
    final tokenColor = state.token != null
        ? TokenTypeConfig.fromType(state.token!.type).gradientColors[1]
        : AppTheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),

          NfcAnimationOverlay(
            icon: _isBluetooth ? Icons.bluetooth_rounded : Icons.nfc_rounded,
            tokenColor: state.token != null ? tokenColor : null,
          ),

          const SizedBox(height: 32),

          Text(
            _stageLabel(state),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _subtitle(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),

          if (state.progress != null) ...[
            const SizedBox(height: 28),
            _ProgressSection(progress: state.progress!, color: tokenColor),
          ],

          if (state.token != null) ...[
            const SizedBox(height: 28),
            PremiumTokenCard(token: state.token!, compact: true),
          ],

          const SizedBox(height: 36),

          _OutlineBtn(
            label: 'Annuler',
            onPressed: () async {
              await ref.read(transferViewModelProvider.notifier).cancel();
              if (mounted) context.go('/');
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Confirmation ────────────────────────────────────────────────────────────

  Widget _buildConfirmation(TransferState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Status icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              color: AppTheme.warning,
              size: 40,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Jeton reçu',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Voulez-vous accepter ce jeton dans votre portefeuille ?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.5),
          ),

          const SizedBox(height: 28),

          if (state.token != null)
            PremiumTokenCard(token: state.token!, animate: true),

          const SizedBox(height: 32),

          // Accept / Reject row
          Row(
            children: [
              Expanded(
                child: _OutlineBtn(
                  label: 'Refuser',
                  icon: Icons.close_rounded,
                  color: AppTheme.error,
                  onPressed: () =>
                      ref.read(transferViewModelProvider.notifier).rejectToken(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _PrimaryBtn(
                  label: 'Accepter',
                  icon: Icons.check_rounded,
                  onPressed: () =>
                      ref.read(transferViewModelProvider.notifier).acceptToken(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Success ─────────────────────────────────────────────────────────────────

  Widget _buildSuccess(TransferState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          _AnimatedSuccessIcon(),

          const SizedBox(height: 24),

          Text(
            _isReceive ? 'Jeton reçu !' : 'Jeton envoyé !',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _isReceive
                ? 'Le jeton a été ajouté à votre portefeuille.'
                : 'Le jeton a été transmis et marqué comme transféré.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          if (state.token != null)
            PremiumTokenCard(token: state.token!, animate: true),

          const SizedBox(height: 32),

          _PrimaryBtn(
            label: "Retour à l'accueil",
            onPressed: () => context.go('/'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Error ───────────────────────────────────────────────────────────────────

  Widget _buildError(TransferState state) {
    final isNfcDisabled = state.error?.contains('NFC est désactivé') ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 48),

          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isNfcDisabled ? Icons.nfc_rounded : Icons.error_outline_rounded,
              color: AppTheme.error,
              size: 44,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            isNfcDisabled ? 'NFC désactivé' : 'Transfert échoué',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            state.error ?? 'Une erreur est survenue.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 36),

          if (isNfcDisabled)
            _PrimaryBtn(
              label: 'Activer le NFC',
              icon: Icons.settings_rounded,
              onPressed: () =>
                  ref.read(nfcServiceProvider).openNfcSettings(),
            )
          else
            _PrimaryBtn(
              label: 'Réessayer',
              onPressed: _start,
            ),

          const SizedBox(height: 14),

          _OutlineBtn(
            label: "Retour à l'accueil",
            onPressed: () => context.go('/'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  String _stageLabel(TransferState state) {
    return switch (state.status) {
      TransferStatus.connected =>
        _isBluetooth ? "Connexion à l'appareil…" : 'Appareil détecté…',
      TransferStatus.transferring => 'Transfert en cours…',
      _ => _isReceive ? 'En attente de réception…' : 'En attente du récepteur…',
    };
  }

  String _subtitle() {
    if (_isBluetooth) {
      return _isReceive
          ? "Restez à proximité de l'émetteur."
          : 'Connexion et envoi sécurisé en cours.';
    }
    return _isReceive
        ? "Rapprochez l'autre téléphone pour recevoir le jeton."
        : 'Rapprochez les deux téléphones dos à dos.';
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Erreur de transfert'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Section ─────────────────────────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  final double progress;
  final Color color;
  const _ProgressSection({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─── Transfer Header ──────────────────────────────────────────────────────────

class _TransferHeader extends StatelessWidget {
  final String channel;
  final bool isReceive;
  final VoidCallback onBack;
  const _TransferHeader({
    required this.channel,
    required this.isReceive,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppTheme.textPrimary,
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isReceive ? 'Recevoir' : 'Envoyer',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'via $channel',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Animated Success Icon ────────────────────────────────────────────────────

class _AnimatedSuccessIcon extends StatefulWidget {
  const _AnimatedSuccessIcon();

  @override
  State<_AnimatedSuccessIcon> createState() => _AnimatedSuccessIconState();
}

class _AnimatedSuccessIconState extends State<_AnimatedSuccessIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppTheme.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.success.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppTheme.success,
            size: 46,
          ),
        ),
      ),
    );
  }
}

// ─── Button helpers ───────────────────────────────────────────────────────────

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  const _PrimaryBtn({required this.label, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.black,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback? onPressed;
  const _OutlineBtn({
    required this.label,
    this.icon,
    this.color = AppTheme.textPrimary,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 20, color: color) : const SizedBox.shrink(),
        label: Text(
          label,
          style:
              TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.35), width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}
