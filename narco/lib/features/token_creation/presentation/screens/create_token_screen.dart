import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/appTheme.dart';
import '../../../../core/services/user_service.dart';
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
    if (_currentStep < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
    } else {
      ref.read(tokenCreationViewModelProvider.notifier).createToken();
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOutCubic);
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
        context.pushReplacement('/token-confirmation');
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Créer un jeton'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentStep > 0 ? _goBack : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _StepIndicator(step: _currentStep),
            const SizedBox(height: 8),
            if (vm.error != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(vm.error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
              ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.isSubmitting ? null : _goNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: vm.isSubmitting
                      ? const SizedBox(
                          height: 22, width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : Text(
                          _buttonLabel,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step indicator
// ---------------------------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i == step;
        final isDone = i < step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isDone ? AppTheme.primary : isActive ? AppTheme.primary : Colors.grey.shade300,
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1: Type Selection (Bento Grid)
// ---------------------------------------------------------------------------

class _StepTypeSelection extends StatelessWidget {
  final TokenCreationState vm;
  final WidgetRef ref;
  const _StepTypeSelection({required this.vm, required this.ref});

  @override
  Widget build(BuildContext context) {
    final configs = TokenTypeConfig.all;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Type de jeton',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choisissez une catégorie',
            style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              physics: const NeverScrollableScrollPhysics(),
              children: configs.map((c) => _TypeCard(config: c, isSelected: vm.tokenType == c.type, vm: vm, ref: ref)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeCard extends StatefulWidget {
  final TokenTypeConfig config;
  final bool isSelected;
  final TokenCreationState vm;
  final WidgetRef ref;
  const _TypeCard({required this.config, required this.isSelected, required this.vm, required this.ref});

  @override
  State<_TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<_TypeCard> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
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
      builder: (context, child) {
        final scale = 0.92 + _scale.value * 0.08;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          widget.ref.read(tokenCreationViewModelProvider.notifier).setTokenType(c.type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: widget.isSelected ? c.color.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isSelected ? c.color : Colors.grey.shade200,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(c.icon, color: c.color, size: 36),
              const SizedBox(height: 10),
              Text(
                c.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isSelected ? c.color : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: widget.isSelected
                    ? Container(
                        key: const ValueKey('unit'),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                        decoration: BoxDecoration(
                          color: c.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          c.unit,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      )
                    : Text(
                        c.unit,
                        key: const ValueKey('unit2'),
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2: Value Input
// ---------------------------------------------------------------------------

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
          const SizedBox(height: 16),
          const Text(
            'Valeur',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Montant en ${config.unit}',
            style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
          ),
          const Spacer(),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: TextField(
                    controller: TextEditingController(text: vm.valeurText)
                      ..selection = TextSelection.fromPosition(TextPosition(offset: vm.valeurText.length)),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: config.color,
                      height: 1,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (v) => ref.read(tokenCreationViewModelProvider.notifier).setValeur(v),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    config.unit,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: config.color.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: config.color,
                  thumbColor: config.color,
                  overlayColor: config.color.withValues(alpha: 0.12),
                  inactiveTrackColor: Colors.grey.shade200,
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _sliderValues.where((v) => v <= 10000 || v == _sliderValues.last).map((v) {
                    final isSelected = valeur != null && valeur >= v && (v >= _sliderValues.last || valeur < _sliderValues[_sliderValues.indexOf(v) + 1]);
                    return Text(
                      _formatSliderLabel(v),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  String _formatSliderLabel(int v) {
    if (v >= 1000) return '${v ~/ 1000}k';
    return v.toString();
  }
}

// ---------------------------------------------------------------------------
// Step 3: Summary Card
// ---------------------------------------------------------------------------

class _StepSummary extends ConsumerWidget {
  final TokenCreationState vm;
  final WidgetRef ref;
  const _StepSummary({required this.vm, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = TokenTypeConfig.fromType(vm.tokenType);
    final valeur = double.tryParse(vm.valeurText.replaceAll(',', '.'));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Récapitulatif',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Vérifiez les informations avant de générer',
            style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: _VirtualCard(
                config: config,
                valeur: valeur ?? 0,
                proprietaire: vm.proprietaire,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VirtualCard extends StatefulWidget {
  final TokenTypeConfig config;
  final double valeur;
  final String proprietaire;
  const _VirtualCard({required this.config, required this.valeur, required this.proprietaire});

  @override
  State<_VirtualCard> createState() => _VirtualCardState();
}

class _VirtualCardState extends State<_VirtualCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeSlide = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(_VirtualCard old) {
    super.didUpdateWidget(old);
    if (old.config.type != widget.config.type || old.valeur != widget.valeur) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    final width = MediaQuery.of(context).size.width - 64;

    return FadeTransition(
      opacity: _fadeSlide,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(_fadeSlide),
        child: Container(
          width: width,
          height: width * 0.62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c.color, c.color.withValues(alpha: 0.7)],
            ),
            boxShadow: [
              BoxShadow(
                color: c.color.withValues(alpha: 0.35),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.nfc, color: Colors.white70, size: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      c.label,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
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
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      c.unit,
                      style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CardInfo(label: 'Propriétaire', value: widget.proprietaire.isNotEmpty ? widget.proprietaire : '—'),
                  _CardInfo(label: 'ID', value: '••••${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardInfo extends StatelessWidget {
  final String label;
  final String value;
  const _CardInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
