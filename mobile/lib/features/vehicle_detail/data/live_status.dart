import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/stellantis/models/vehicle_status.dart';

/// In-memory cache of the most recent full VehicleStatusModel payload per
/// VIN. The Isar StatusSnapshot collection holds the numeric subset used
/// by lists and the dashboard, but the vehicle-detail screen needs the
/// richer object (door positions, AC state, etc.) the API returns.
///
/// This provider intentionally does not persist: cold-starting the detail
/// screen with no live status simply prompts the user to pull-to-refresh.
final liveVehicleStatusProvider =
    StateProvider<Map<String, VehicleStatusModel>>((_) => const {});
