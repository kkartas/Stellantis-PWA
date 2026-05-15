import 'package:flutter/services.dart';

/// Centralised haptic feedback helpers so every primary action calls the
/// same vibration pattern. Lets us tune the whole app from one place.
///
/// All calls are awaited so failures (e.g. on a device without a vibrator)
/// surface as logs rather than swallowing the future silently.
class Haptics {
  Haptics._();

  /// Tap on a primary control: lock/unlock, climate, charge, etc.
  static Future<void> tap() => HapticFeedback.selectionClick();

  /// Confirmation that a remote command succeeded.
  static Future<void> success() => HapticFeedback.lightImpact();

  /// Heavier buzz for destructive or failure paths.
  static Future<void> failure() => HapticFeedback.heavyImpact();

  /// Pull-to-refresh trigger.
  static Future<void> refresh() => HapticFeedback.mediumImpact();
}
