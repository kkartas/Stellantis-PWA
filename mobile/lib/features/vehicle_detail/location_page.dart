import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:stellantis_mobile/core/ui/glass_card.dart';
import 'package:stellantis_mobile/core/ui/state_views.dart';
import 'package:stellantis_mobile/features/dashboard/data/latest_status.dart';
import 'package:stellantis_mobile/features/shell/wake_refresh_indicator.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/status_snapshot.dart';

class VehicleLocationPage extends ConsumerWidget {
  const VehicleLocationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(latestStatusProvider);
    final status = statusAsync.valueOrNull;
    final lat = status?.latitude;
    final lng = status?.longitude;

    final hasPosition = lat != null && lng != null;
    final center =
        hasPosition ? LatLng(lat, lng) : const LatLng(48.8566, 2.3522);

    return Scaffold(
      appBar: AppBar(title: const Text('Location')),
      body: WakeRefreshIndicator(
        child: hasPosition
            ? _MapView(center: center, status: status!)
            : const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: 600,
                  child: EmptyStateView(
                    icon: Icons.location_off,
                    message:
                        'No location reported yet. Pull to refresh to fetch '
                        'the latest position from your car.',
                  ),
                ),
              ),
      ),
    );
  }
}

class _MapView extends StatelessWidget {
  const _MapView({required this.center, required this.status});

  final LatLng center;
  final StatusSnapshot status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 14,
            minZoom: 3,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.stellantis.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: center,
                  width: 48,
                  height: 48,
                  child: _PinIcon(color: scheme.primary),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: _AddressCard(status: status),
        ),
      ],
    );
  }
}

class _PinIcon extends StatelessWidget {
  const _PinIcon({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.location_on, color: color, size: 48),
        const Positioned(
          top: 8,
          child: Icon(Icons.directions_car, color: Colors.white, size: 18),
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.status});
  final StatusSnapshot status;

  @override
  Widget build(BuildContext context) {
    final lat = status.latitude;
    final lng = status.longitude;
    final ts = status.timestamp;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
            Icons.directions_car,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Last known location',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  '${lat?.toStringAsFixed(5)}, ${lng?.toStringAsFixed(5)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  _formatTimestamp(ts),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTimestamp(DateTime t) {
  final diff = DateTime.now().toUtc().difference(t);
  if (diff.inMinutes < 1) return 'Updated just now';
  if (diff.inHours < 1) return 'Updated ${diff.inMinutes} min ago';
  if (diff.inDays < 1) return 'Updated ${diff.inHours} h ago';
  return 'Updated ${diff.inDays} d ago';
}
