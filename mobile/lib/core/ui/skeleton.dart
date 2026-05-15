import 'package:flutter/material.dart';

/// Animated shimmer block used while real content is loading from the
/// network or Isar. Cheap and dependency-free — a single AnimationController
/// drives a shifting LinearGradient. Pulse-respecting: disabled when the
/// reduce-motion accessibility flag is on.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = scheme.surfaceContainer;
    final disabled = MediaQuery.disableAnimationsOf(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: disabled
            ? Container(color: base)
            : AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-1.0 - 2 * t, 0),
                        end: Alignment(1.0 - 2 * t, 0),
                        colors: [base, highlight, base],
                        stops: const [0.25, 0.5, 0.75],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// Stack a few [Skeleton] rows to mimic a list while it loads.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.rows = 6, this.rowHeight = 72});

  final int rows;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rows,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => Skeleton(height: rowHeight, borderRadius: 12),
    );
  }
}
