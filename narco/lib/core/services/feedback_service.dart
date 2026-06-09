import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Centralises all sensory feedback (haptics + audio).
///
/// Usage:
///   await FeedbackService.instance.triggerSuccess();
class FeedbackService {
  FeedbackService._();

  static final FeedbackService instance = FeedbackService._();

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;

  /// Heavy haptic + success chime (creation / transfer done).
  Future<void> triggerSuccess() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
    if (_soundEnabled) {
      try {
        await _player.play(AssetSource('sounds/success.mp3'));
      } catch (_) {
        // Asset may not exist yet — fail silently.
      }
    }
  }

  /// Light haptic only (step navigation, selection).
  Future<void> triggerLight() => HapticFeedback.lightImpact();

  /// Medium haptic (connection events, confirmations).
  Future<void> triggerMedium() => HapticFeedback.mediumImpact();

  void setSoundEnabled(bool enabled) => _soundEnabled = enabled;

  void dispose() => _player.dispose();
}
