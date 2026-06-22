import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Schedules warm-up reads of likely-next providers after the host screen
/// has been visible for a brief idle period. The idea: while the user is
/// looking at the dashboard, the Isar streams for Trips / Charging / Stats
/// are already filling their caches so switching tabs paints from memory
/// rather than going cold.
///
/// Reads are fire-and-forget. Failures are ignored — this is a perf hint,
/// not a correctness path.
class Prefetcher extends ConsumerStatefulWidget {
  const Prefetcher({
    required this.providers,
    required this.child,
    super.key,
    this.delay = const Duration(seconds: 2),
  });

  /// Providers to warm. Use [ProviderBase] so any kind works (Future,
  /// Stream, plain Provider) — `ref.read` accepts all of them.
  final List<ProviderListenable<Object?>> providers;
  final Widget child;
  final Duration delay;

  @override
  ConsumerState<Prefetcher> createState() => _PrefetcherState();
}

class _PrefetcherState extends ConsumerState<Prefetcher> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, _prefetch);
  }

  void _prefetch() {
    if (!mounted) return;
    for (final p in widget.providers) {
      try {
        ref.read(p);
      } catch (_) {
        // Best-effort warm-up; ignore.
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
