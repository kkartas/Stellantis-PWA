import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Glassmorphism container with a backdrop blur and a subtle border.
/// Designed for hero overlays (status pills, info chips) where the layer
/// underneath is colourful enough to show through.
///
/// BackdropFilter is expensive on low-end Android; on those devices the
/// blur is skipped in favour of a solid translucent surface that hits the
/// same visual hierarchy at a fraction of the cost. The threshold is
/// conservative — the flag flips when the platform reports a software
/// renderer, when impeller is off, or on Android API levels where the
/// blur shader compiles slowly.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.blurSigma = 18,
    this.tintOpacity = 0.18,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double blurSigma;
  final double tintOpacity;

  static bool? _cachedCanBlur;

  bool _canBlur() {
    if (_cachedCanBlur != null) return _cachedCanBlur!;
    // Cheap heuristic: blur on iOS / macOS / desktop where the metal /
    // skia path is mature. On Android we only opt-in when running release
    // mode (where Impeller is more likely to be active).
    final ok = !kIsWeb &&
        (Platform.isIOS ||
            Platform.isMacOS ||
            Platform.isLinux ||
            Platform.isWindows ||
            (Platform.isAndroid && kReleaseMode));
    _cachedCanBlur = ok;
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tint = scheme.surface.withValues(alpha: tintOpacity);
    final border = scheme.outline.withValues(alpha: 0.2);
    final radius = BorderRadius.circular(borderRadius);

    final inner = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: radius,
        border: Border.all(color: border),
      ),
      child: child,
    );

    if (!_canBlur()) {
      // Solid translucent fallback — same shape, no shader cost.
      return inner;
    }

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: inner,
      ),
    );
  }
}
