import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'settings_manager.dart';

/// Plays audio + haptic feedback on scan results.
/// Reads sound/vibration preferences automatically each call so it always
/// reflects the latest Settings toggle without needing a restart.
///
/// Sound files expected at:
///   assets/sounds/success.mp3   — short upbeat beep   (valid ticket)
///   assets/sounds/warning.mp3   — double short buzz   (already used)
///   assets/sounds/error.mp3     — single long buzz    (invalid)
class FeedbackService {
  static final AudioPlayer _player = AudioPlayer();

  // ── Public API ────────────────────────────────────────────────────────────

  static Future<void> onValid() async {
    await _sound('sounds/success.mp3');
    await _vibrate([0, 80]);            // single short pulse
  }

  static Future<void> onAlreadyUsed() async {
    await _sound('sounds/warning.mp3');
    await _vibrate([0, 80, 80, 80]);    // two short pulses
  }

  static Future<void> onInvalid() async {
    await _sound('sounds/error.mp3');
    await _vibrate([0, 300]);           // single long buzz
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static Future<void> _sound(String assetPath) async {
    final enabled = await SettingsManager.getSoundEnabled();
    if (!enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (e) {
      // Silently ignore — missing asset or audio init failure shouldn't crash
      print('FeedbackService audio error: $e');
    }
  }

  static Future<void> _vibrate(List<int> pattern) async {
    final enabled = await SettingsManager.getVibrationEnabled();
    if (!enabled) return;
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (!hasVibrator) return;

      if (pattern.length == 2) {
        // Single pulse — use simple vibrate() for best compatibility
        Vibration.vibrate(duration: pattern[1]);
      } else {
        // Multi-pulse pattern
        Vibration.vibrate(pattern: pattern);
      }
    } catch (e) {
      print('FeedbackService vibration error: $e');
    }
  }
}