import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/features/dashboard/data/latest_status.dart';
import 'package:stellantis_mobile/features/vehicles/data/selected_vehicle.dart';
import 'package:stellantis_mobile/stellantis/storage/app_database.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/alert_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/charge_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/maintenance_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/soh_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/status_snapshot.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/trip_record.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/vehicle_record.dart';

const _kAppVersion = '1.0.0-dev';
const _kBuildChannel = 'beta';

class _CacheStats {
  const _CacheStats({
    required this.vehicles,
    required this.statusSnapshots,
    required this.trips,
    required this.charges,
    required this.soh,
    required this.alerts,
    required this.maintenance,
  });

  final int vehicles;
  final int statusSnapshots;
  final int trips;
  final int charges;
  final int soh;
  final int alerts;
  final int maintenance;

  int get total =>
      vehicles + statusSnapshots + trips + charges + soh + alerts + maintenance;
}

final _cacheStatsProvider =
    FutureProvider.autoDispose<_CacheStats>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  final counts = await Future.wait([
    isar.vehicleRecords.count(),
    isar.statusSnapshots.count(),
    isar.tripRecords.count(),
    isar.chargeRecords.count(),
    isar.sohRecords.count(),
    isar.alertRecords.count(),
    isar.maintenanceRecords.count(),
  ]);
  return _CacheStats(
    vehicles: counts[0],
    statusSnapshots: counts[1],
    trips: counts[2],
    charges: counts[3],
    soh: counts[4],
    alerts: counts[5],
    maintenance: counts[6],
  );
});

class AboutSettingsPage extends ConsumerWidget {
  const AboutSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheAsync = ref.watch(_cacheStatsProvider);
    final latest = ref.watch(latestStatusProvider).valueOrNull;
    final vin = ref.watch(selectedVinProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('About & diagnostics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stellantis Mobile',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text('Version $_kAppVersion ($_kBuildChannel)',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Last refresh',
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                latest?.timestamp == null
                    ? 'Never'
                    : _formatTimestamp(latest!.timestamp),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Local cache',
            child: cacheAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('$e'),
              ),
              data: (stats) => Column(
                children: [
                  _CacheRow('Vehicles', stats.vehicles),
                  _CacheRow('Status snapshots', stats.statusSnapshots),
                  _CacheRow('Trips', stats.trips),
                  _CacheRow('Charge sessions', stats.charges),
                  _CacheRow('SOH samples', stats.soh),
                  _CacheRow('Alerts', stats.alerts),
                  _CacheRow('Maintenance', stats.maintenance),
                  const Divider(),
                  _CacheRow('Total rows', stats.total),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: () => _copyDiagnostics(
              context: context,
              cache: cacheAsync.valueOrNull,
              lastRefresh: latest?.timestamp,
              activeVin: vin,
            ),
            icon: const Icon(Icons.copy_all),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Copy diagnostics to clipboard'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyDiagnostics({
    required BuildContext context,
    required _CacheStats? cache,
    required DateTime? lastRefresh,
    required String? activeVin,
  }) async {
    final buf = StringBuffer()
      ..writeln('Stellantis Mobile diagnostics')
      ..writeln('Version: $_kAppVersion ($_kBuildChannel)')
      ..writeln('Generated: ${DateTime.now().toUtc().toIso8601String()}')
      ..writeln('Active VIN: ${activeVin ?? "(none)"}')
      ..writeln('Last refresh: ${lastRefresh?.toIso8601String() ?? "never"}')
      ..writeln()
      ..writeln('Cache rows:');
    if (cache != null) {
      buf
        ..writeln('  vehicles: ${cache.vehicles}')
        ..writeln('  status:   ${cache.statusSnapshots}')
        ..writeln('  trips:    ${cache.trips}')
        ..writeln('  charges:  ${cache.charges}')
        ..writeln('  soh:      ${cache.soh}')
        ..writeln('  alerts:   ${cache.alerts}')
        ..writeln('  maint:    ${cache.maintenance}')
        ..writeln('  total:    ${cache.total}');
    } else {
      buf.writeln('  (still loading)');
    }
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnostics copied to clipboard')),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          child,
        ],
      ),
    );
  }
}

class _CacheRow extends StatelessWidget {
  const _CacheRow(this.label, this.count);
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label),
      trailing: Text(count.toString()),
    );
  }
}

String _formatTimestamp(DateTime t) {
  final diff = DateTime.now().toUtc().difference(t);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) return '${diff.inHours} h ago';
  return '${diff.inDays} d ago (${t.toIso8601String()})';
}
