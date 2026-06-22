import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Circular battery / fuel level indicator. Renders a thin track plus a
/// thicker filled arc, with the percentage centered. Brand-themed colors
/// come from the surrounding [Theme].
class BatteryRing extends StatelessWidget {
  const BatteryRing({
    required this.percentage,
    super.key,
    this.size = 140,
    this.label = '%',
    this.subtitle,
    this.isCharging = false,
  });

  /// 0–100. Clamped on render.
  final double? percentage;
  final double size;
  final String label;
  final String? subtitle;
  final bool isCharging;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (percentage ?? 0).clamp(0, 100).toDouble();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              progress: pct / 100,
              trackColor: theme.colorScheme.surfaceContainerHighest,
              progressColor: isCharging
                  ? theme.colorScheme.tertiary
                  : theme.colorScheme.primary,
              strokeWidth: size * 0.08,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCharging)
                Icon(
                  Icons.bolt,
                  color: theme.colorScheme.tertiary,
                  size: size * 0.18,
                ),
              Text(
                percentage == null ? '—' : pct.toStringAsFixed(0),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelMedium,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor;
}
