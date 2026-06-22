import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:stellantis_mobile/core/ui/state_views.dart';
import 'package:stellantis_mobile/features/vehicles/data/selected_vehicle.dart';
import 'package:stellantis_mobile/stellantis/storage/app_database.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/maintenance_record.dart';

final _maintenanceProvider =
    StreamProvider.autoDispose<List<MaintenanceRecord>>((ref) async* {
  final vin = ref.watch(selectedVinProvider);
  if (vin == null) {
    yield const [];
    return;
  }
  final isar = await ref.watch(isarProvider.future);
  yield* isar.maintenanceRecords
      .where()
      .vinEqualTo(vin)
      .watch(fireImmediately: true);
});

class MaintenancePage extends ConsumerWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_maintenanceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance')),
      body: async.when(
        loading: () => const LoadingStateView(),
        error: (e, _) => mapErrorToStateView(e),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyStateView(
              icon: Icons.build_outlined,
              message:
                  'No scheduled maintenance yet. Reminders will appear here '
                  'once service intervals are configured.',
            );
          }
          final pending = records.where((r) => !r.completed).toList()
            ..sort(_byDueOrMileage);
          final completed = records.where((r) => r.completed).toList()
            ..sort((a, b) => (b.completedAt ?? b.dueDate ?? DateTime(0))
                .compareTo(a.completedAt ?? a.dueDate ?? DateTime(0)));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                Text('Due', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final r in pending)
                  _ReminderTile(record: r, isDone: false, ref: ref),
              ],
              if (completed.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Completed',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final r in completed)
                  _ReminderTile(record: r, isDone: true, ref: ref),
              ],
            ],
          );
        },
      ),
    );
  }
}

int _byDueOrMileage(MaintenanceRecord a, MaintenanceRecord b) {
  final ad = a.dueDate;
  final bd = b.dueDate;
  if (ad != null && bd != null) return ad.compareTo(bd);
  if (ad != null) return -1;
  if (bd != null) return 1;
  return (a.dueMileage ?? 0).compareTo(b.dueMileage ?? 0);
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.record,
    required this.isDone,
    required this.ref,
  });

  final MaintenanceRecord record;
  final bool isDone;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final due = record.dueDate;
    final overdue = due != null && due.isBefore(DateTime.now()) && !isDone;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDone
              ? theme.colorScheme.surfaceContainerHighest
              : (overdue
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.primaryContainer),
          child: Icon(
            _iconFor(record.serviceType),
            color: isDone
                ? theme.colorScheme.onSurface
                : (overdue
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onPrimaryContainer),
          ),
        ),
        title: Text(
          record.serviceType,
          style: TextStyle(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? theme.colorScheme.outline : null,
          ),
        ),
        subtitle: Text(_subtitleFor(record, isDone)),
        trailing: isDone
            ? const Icon(Icons.check_circle, color: Colors.green)
            : IconButton(
                icon: const Icon(Icons.check),
                tooltip: 'Mark complete',
                onPressed: _markComplete,
              ),
      ),
    );
  }

  IconData _iconFor(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('oil')) return Icons.oil_barrel;
    if (lower.contains('brake')) return Icons.disc_full;
    if (lower.contains('tire') || lower.contains('tyre')) {
      return Icons.donut_large;
    }
    if (lower.contains('inspection') || lower.contains('service')) {
      return Icons.build;
    }
    return Icons.warning_amber;
  }

  String _subtitleFor(MaintenanceRecord r, bool isDone) {
    if (isDone) {
      return r.completedAt == null
          ? 'Completed'
          : 'Completed ${_formatDate(r.completedAt!)}';
    }
    final parts = <String>[];
    if (r.dueDate != null) parts.add('Due ${_formatDate(r.dueDate!)}');
    if (r.dueMileage != null) {
      parts.add('At ${r.dueMileage!.toStringAsFixed(0)} km');
    }
    return parts.isEmpty ? 'No due date set' : parts.join(' · ');
  }

  Future<void> _markComplete() async {
    final isar = await ref.read(isarProvider.future);
    await isar.writeTxn(() async {
      record
        ..completed = true
        ..completedAt = DateTime.now();
      await isar.maintenanceRecords.put(record);
    });
  }
}

String _formatDate(DateTime t) {
  final l = t.toLocal();
  return '${l.year}-${l.month.toString().padLeft(2, '0')}'
      '-${l.day.toString().padLeft(2, '0')}';
}
