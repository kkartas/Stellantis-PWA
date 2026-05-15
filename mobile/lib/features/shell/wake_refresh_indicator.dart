import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/features/shell/data/vehicle_refresh_controller.dart';

/// Pull-to-refresh affordance that wakes the car (MQTT) and re-fetches its
/// status from the network. Wraps any scrollable list, sliver, or column.
///
/// Default reads should keep using the cached Isar stream — only an explicit
/// pull triggers the wake. The plan calls this "pull-to-refresh = wake".
class WakeRefreshIndicator extends ConsumerWidget {
  const WakeRefreshIndicator({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref
          .read(vehicleRefreshControllerProvider)
          .wakeAndRefresh(),
      child: child,
    );
  }
}
