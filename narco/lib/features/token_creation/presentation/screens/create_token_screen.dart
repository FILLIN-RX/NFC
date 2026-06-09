import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/appTheme.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/widgets/premium_step_indicator.dart';
import '../providers/token_creation_vm.dart';
import '../widgets/token_type_config.dart';

class CreateTokenScreen extends ConsumerStatefulWidget {
  const CreateTokenScreen({super.key});

  @override
  ConsumerState<CreateTokenScreen> createState() => _CreateTokenScreenState();
}

const _sliderValues = [500, 1000, 2500, 5000, 10000, 25000, 50000, 100000];

class _CreateTokenScreenState extends ConsumerState<CreateTokenScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final name = ref.read(userServiceProvider).getUserName();
      if (name != null && mounted) {
        ref.read(tokenCreationViewModelProvider.notifier).setProprietaire(name);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    FeedbackService.instance.triggerLight();
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    } else {
      ref.read(tokenCreationViewModelProvider.notifier).createToken();
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      FeedbackService.instance.triggerLight();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  String get _buttonLabel {
    switch (_currentStep) {
      case 0:
        return 'Continuer';
      case 1:
        return 'Continuer';
      case 2:
        return 'Générer le jeton ⚡';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(tokenCreationViewModelProvider);

    ref.listen<TokenCreationState>(tokenCreationViewModelProvider, (prev, next) {
      if (next.isSuccess && (prev == null || !prev.isSuccess)) {
        FeedbackService.instance.triggerSuccess();
        context.pushReplacement('/token-confirmation');
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Custom header ───────────────────────────────────────────
            _Header(
              step: _currentStep,
              onBack: _currentStep > 0 ? _goBack : () => context.pop(),
            ),

            const SizedBox(height: 4),

            // ── Animated step indicator ─────────────────────────────────
            PremiumStepIndicator(currentStep: _currentStep),

            const SizedBox(height: 8),

            // ── Error banner ────────────────────────────────────────────
            if (vm.error != null)
              _ErrorBanner(message: vm.error!),

            // ── Step pages ──────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _StepTypeSelection(vm: vm, ref: ref),
                  _StepValueInput(vm: vm, ref: ref),
                  _StepSummary(vm: vm, ref: ref),
                ],
              ),
            ),

            // ── CTA button ──────────────────────────────────────────────
            _CtaButton(
              label: _buttonLabel,
              isLoading: vm.isSubmitting,
              onPressed: vm.isSubmitting ? null : _goNext,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int step;
  final VoidCallback onBack;
  const _Header({required this.step, required this.onBack});

  static const _titles = ['Type de jeton', 'Valeur', 'Aperçu'];

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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _titles[step],
              key: ValueKey(step),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CTA Button ──────────────────────────────────────────────────────────────

class _CtaButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  const _CtaButton({required this.label, required this.isLoading, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.black,
            disabledBackgroundColor: const Color(0xFFE5E7EB),
            disabledForegroundColor: const Color(0xFF9CA3AF),
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.black,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Step 1: Type Selection ───────────────────────────────────────────────────

class _StepTypeSelection extends StatelessWidget {
  final TokenCreationState vm;
  final WidgetRef ref;
  const _StepTypeSelection({required this.vm, required this.ref});

  @override
  Widget build(BuildContext context) {
    final configs = TokenTypeConfig.all;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisissez une catégorie',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: configs
                  .map((c) => _TypeCard(
                        config: c,
                        isSelected: vm.tokenType == c.type,
                        ref: ref,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeCard extends StatefulWidget {
  final TokenTypeConfig config;
  final bool isSelected;
  final WidgetRef ref;
  const _TypeCard({
    required this.config,
    required this.isSelected,
    required this.ref,
  });

  @override
  State<_TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<_TypeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scale = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    if (widget.isSelected) _animController.value = 1;
  }

  @override
  void didUpdateWidget(_TypeCard old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _animController.forward(from: 0);
    } else if (!widget.isSelected && old.isSelected) {
      _animController.reverse();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(
        scale: 0.93 + _scale.value * 0.07,
        child: child,
      ),
      child: GestureDetector(
        onTap: () {
          FeedbackService.instance.triggerLight();
          widget.ref.read(tokenCreationViewModelProvider.notifier).setTokenType(c.type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? c.color.withValues(alpha: 0.10)
                : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.isSelected ? c.color : const Color(0xFFE5E7EB),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: c.color.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? c.color.withValues(alpha: 0.15)
                      : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Icon(c.icon, color: c.color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                c.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: widget.isSelected ? c.color : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: widget.isSelected
                    ? Container(
                        key: const ValueKey('active'),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: c.color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          c.unit,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : Text(
                        c.unit,
                        key: const ValueKey('inactive'),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Step 2: Value Input ──────────────────────────────────────────────────────

class _StepValueInput extends StatelessWidget {
  final TokenCreationState vm;
  final WidgetRef ref;
  const _StepValueInput({required this.vm, required this.ref});

  @override
  Widget build(BuildContext context) {
    final config = TokenTypeConfig.fromType(vm.tokenType);
    final valeur = double.tryParse(vm.valeurText.replaceAll(',', '.'));
    final sliderIndex = valeur != null
        ? (() {
            final i = _sliderValues.indexWhere((v) => v >= valeur);
            return i == -1 ? _sliderValues.length - 1 : i;
          })()
        : -1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Montant en ${config.unit}',
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const Spacer(),

          // ── Big value display ──────────────────────────────────────────
          Center(
            child: Column(
              children: [
                // Value container with subtle background
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: config.color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: config.color.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: TextField(
                          controller: TextEditingController(text: vm.valeurText)
                            ..selection = TextSelection.fromPosition(
                              TextPosition(offset: vm.valeurText.length),
                            ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: config.color,
                            height: 1.0,
                            letterSpacing: -2,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: '0',
                          ),
                          onChanged: (v) =>
                              ref.read(tokenCreationViewModelProvider.notifier).setValeur(v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          config.unit,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: config.color.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // ── Slider ────────────────────────────────────────────────────
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: config.color,
                  thumbColor: config.color,
                  overlayColor: config.color.withValues(alpha: 0.12),
                  inactiveTrackColor: const Color(0xFFE5E7EB),
                  trackHeight: 5,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
                ),
                child: Slider(
                  value: sliderIndex >= 0 ? sliderIndex.toDouble() : 0,
                  min: 0,
                  max: (_sliderValues.length - 1).toDouble(),
                  divisions: _sliderValues.length - 1,
                  onChanged: (v) {
                    final val = _sliderValues[v.round()].toString();
                    ref.read(tokenCreationViewModelProvider.notifier).setValeur(val);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _sliderValues
                      .where((v) => v <= 10000 || v == _sliderValues.last)
                      .map((v) {
                    final isSelected = valeur != null &&
                        valeur >= v &&
                        (v >= _sliderValues.last ||
                            valeur < _sliderValues[_sliderValues.indexOf(v) + 1]);
                    return Text(
                      _formatLabel(v),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                        color: isSelected ? config.color : AppTheme.textSecondary,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatLabel(int v) {
    if (v >= 1000) return '${v ~/ 1000}k';
    return v.toString();
  }
}

// ─── Step 3: Summary / Preview ────────────────────────────────────────────────

class _StepSummary extends ConsumerWidget {
  final TokenCreationState vm;
  final WidgetRef ref;
  const _StepSummary({required this.vm, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = TokenTypeConfig.fromType(vm.tokenType);
    final valeur = double.tryParse(vm.valeurText.replaceAll(',', '.')) ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Vérifiez avant de générer',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          // ── Premium card preview ─────────────────────────────────────
          _PreviewCard(config: config, valeur: valeur, proprietaire: vm.proprietaire),

          const SizedBox(height: 24),

          // ── Summary details card ─────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Type',
                  value: config.label,
                  icon: config.icon,
                  iconColor: config.color,
                ),
                const _Divider(),
                _SummaryRow(
                  label: 'Valeur',
                  value: '$valeur ${config.unit}',
                  icon: Icons.attach_money_rounded,
                  iconColor: AppTheme.dark,
                ),
                const _Divider(),
                _SummaryRow(
                  label: 'Propriétaire',
                  value: vm.proprietaire.isNotEmpty ? vm.proprietaire : '—',
                  icon: Icons.person_outline_rounded,
                  iconColor: AppTheme.dark,
                ),
                const _Divider(),
                _SummaryRow(
                  label: 'Expiration',
                  value: '30 jours',
                  icon: Icons.schedule_rounded,
                  iconColor: AppTheme.dark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatefulWidget {
  final TokenTypeConfig config;
  final double valeur;
  final String proprietaire;
  const _PreviewCard({
    required this.config,
    required this.valeur,
    required this.proprietaire,
  });

  @override
  State<_PreviewCard> createState() => _PreviewCardState();
}

class _PreviewCardState extends State<_PreviewCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_PreviewCard old) {
    super.didUpdateWidget(old);
    if (old.config.type != widget.config.type || old.valeur != widget.valeur) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    final screenW = MediaQuery.of(context).size.width;
    final cardW = screenW - 48.0;
    final cardH = cardW * 0.60;

    return FadeTransition(
      opacity: _anim,
      child: SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
                .animate(_anim),
        child: _buildCard(c, cardW, cardH),
      ),
    );
  }

  Widget _buildCard(TokenTypeConfig c, double cardW, double cardH) {
    return Container(
      width: cardW,
      height: cardH,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.55, 1.0],
          colors: c.gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: c.gradientColors[1].withValues(alpha: 0.50),
            blurRadius: 36,
            spreadRadius: -6,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative circle top-right
            Positioned(
              top: -cardH * 0.5,
              right: -cardH * 0.4,
              child: Opacity(
                opacity: 0.08,
                child: Container(
                  width: cardH * 1.6,
                  height: cardH * 1.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.accentColor,
                  ),
                ),
              ),
            ),
            // Gloss top edge
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.5),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Gloss top half
            Positioned(
              top: 0, left: 0, right: 0,
              height: cardH * 0.5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.11),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.nfc_rounded,
                          color: Colors.white.withValues(alpha: 0.75), size: 26),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(c.icon, color: Colors.white, size: 12),
                            const SizedBox(width: 5),
                            Text(
                              c.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.valeur.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          c.unit,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.70),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CardInfo(
                        label: 'PROPRIÉTAIRE',
                        value: widget.proprietaire.isNotEmpty
                            ? widget.proprietaire
                            : '—',
                      ),
                      _CardInfo(
                        label: 'EXPIRATION',
                        value: '30 jours',
                        alignRight: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardInfo extends StatelessWidget {
  final String label;
  final String value;
  final bool alignRight;
  const _CardInfo({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6));
  }
}
