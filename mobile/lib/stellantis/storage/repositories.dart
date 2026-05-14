import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/stellantis/storage/app_database.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories/alert_repository.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories/charge_repository.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories/soh_repository.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories/status_repository.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories/trip_repository.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories/vehicle_repository.dart';

final alertRepoProvider = FutureProvider<AlertRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return AlertRepository(isar);
});

final chargeRepoProvider = FutureProvider<ChargeRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return ChargeRepository(isar);
});

final sohRepoProvider = FutureProvider<SohRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return SohRepository(isar);
});

final statusRepoProvider = FutureProvider<StatusRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return StatusRepository(isar);
});

final tripRepoProvider = FutureProvider<TripRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return TripRepository(isar);
});

final vehicleRepoProvider = FutureProvider<VehicleRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return VehicleRepository(isar);
});
