import 'package:flutter/material.dart';

import '../appTheme.dart';

/// A premium animated step indicator with numbered circles,
/// connecting lines, and descriptive labels.
///
/// Replaces the basic dot indicator in [CreateTokenScreen].
class PremiumStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<_StepMeta> steps;

  static const List<_StepMeta> tokenCreationSteps = [
    _StepMeta(number: 1, label: 'Type'),
    _StepMeta(number: 2, label: 'Valeur'),
    _StepMeta(number: 3, label: 'Aperçu'),
  ];

  const PremiumStepIndicator({
    super.key,
    required this.currentStep,
    this.steps = tokenCreationSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _StepCircle(
              step: steps[i],
              state: _stepState(i),
            ),
            if (i < steps.length - 1)
              Expanded(
                child: _ConnectorLine(filled: i < currentStep),
              ),
          ],
        ],
      ),
    );
  }

  _CircleState _stepState(int index) {
    if (index < currentStep) return _CircleState.done;
    if (index == currentStep) return _CircleState.active;
    return _CircleState.future;
  }
}

enum _CircleState { done, active, future }

class _StepMeta {
  final int number;
  final String label;
  const _StepMeta({required this.number, required this.label});
}

// ─── Circle ──────────────────────────────────────────────────────────────────

class _StepCircle extends StatelessWidget {
  final _StepMeta step;
  final _CircleState state;

  const _StepCircle({required this.step, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDone = state == _CircleState.done;
    final isActive = state == _CircleState.active;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? AppTheme.dark
                : isActive
                    ? AppTheme.primary
                    : Colors.transparent,
            border: Border.all(
              color: isDone
                  ? AppTheme.dark
                  : isActive
                      ? AppTheme.primary
                      : const Color(0xFFD1D5DB),
              width: isActive ? 2.5 : 1.5,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.40),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isDone
                ? const Icon(
                    Icons.check_rounded,
                    key: ValueKey('done'),
                    color: Colors.white,
                    size: 18,
                  )
                : Text(
                    step.number.toString(),
                    key: ValueKey(step.number),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? Colors.black
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 350),
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isDone
                ? AppTheme.dark
                : isActive
                    ? AppTheme.dark
                    : const Color(0xFF9CA3AF),
            letterSpacing: 0.2,
          ),
          child: Text(step.label),
        ),
      ],
    );
  }
}

// ─── Connector ───────────────────────────────────────────────────────────────

class _ConnectorLine extends StatelessWidget {
  final bool filled;
  const _ConnectorLine({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        height: 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: filled ? AppTheme.dark : const Color(0xFFE5E7EB),
        ),
      ),
    );
  }
}
