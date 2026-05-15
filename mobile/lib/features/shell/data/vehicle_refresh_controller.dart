import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/core/logging/logger.dart';
import 'package:stellantis_mobile/features/auth/data/brand_session.dart';
import 'package:stellantis_mobile/features/vehicles/data/selected_vehicle.dart';
import 'package:stellantis_mobile/stellantis/api/vehicles_api.dart';
import 'package:stellantis_mobile/stellantis/brands/brand_constants.dart';
import 'package:stellantis_mobile/stellantis/brands/secrets_template.dart';
import 'package:stellantis_mobile/stellantis/models/vehicle_status.dart';
import 'package:stellantis_mobile/stellantis/mqtt/mqtt_client_service.dart';
import 'package:stellantis_mobile/stellantis/mqtt/remote_command.dart';
import 'package:stellantis_mobile/stellantis/storage/repositories.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/status_snapshot.dart';

const _log = AppLogger('VehicleRefresh');

final vehicleRefreshControllerProvider = Provider<VehicleRefreshController>(
  VehicleRefreshController.new,
);

/// Coordinates the pull-to-refresh contract for vehicle screens:
///
/// 1. Send a WakeupCommand over MQTT so the car publishes fresh telemetry.
/// 2. Re-fetch /user/vehicles/{id}/status from the REST API.
/// 3. Persist the result into Isar so SWR widgets repaint immediately.
///
/// Cached reads remain the default elsewhere — only this method talks to
/// the network.
class VehicleRefreshController {
  VehicleRefreshController(this._ref);

  final Ref _ref;

  Future<void> wakeAndRefresh() async {
    final vin = _ref.read(selectedVinProvider);
    final session = _ref.read(selectedBrandSessionProvider);
    if (vin == null || session == null) {
      _log.w('wakeAndRefresh skipped — no active vehicle or brand session');
      return;
    }

    try {
      await _ref
          .read(mqttClientServiceProvider)
          .sendCommand(WakeupCommand(vin: vin));
    } catch (e, st) {
      // Wakeup is best-effort: a failure here shouldn't block the network
      // refresh below, which still returns the last server-known state.
      _log.w('Wakeup MQTT publish failed; proceeding with REST fetch: $e');
      _log.d(st.toString());
    }

    final clientId = BrandSecrets.clientId[session.cacheKey] ?? '';
    final realm = BrandConstants.realm[session.brand] ?? '';
    final status = await _ref.read(vehiclesApiProvider).getVehicleStatus(
          vehicleId: vin,
          clientId: clientId,
          realm: realm,
        );

    if (status == null) {
      _log.w('Status refresh returned null for VIN $vin');
      return;
    }

    final repo = await _ref.read(statusRepoProvider.future);
    await repo.save(_toSnapshot(vin, status));
    _log.i('Refreshed status snapshot for VIN $vin');
  }

  StatusSnapshot _toSnapshot(String vin, VehicleStatusModel status) {
    final snapshot = StatusSnapshot()
      ..vin = vin
      ..timestamp = DateTime.now().toUtc()
      ..mileage = status.timedOdometer?.mileage
      ..latitude = status.lastPosition?.geometry?.latitude
      ..longitude = status.lastPosition?.geometry?.longitude
      ..speed = status.kinetic?.speed;

    final electric = status.electricEnergy;
    if (electric != null) {
      snapshot
        ..batteryLevel = electric.level?.toInt()
        ..chargingStatus = electric.charging?.status?.name
        ..chargingMode = electric.charging?.chargingMode
        ..batteryResistance = electric.battery?.health?.resistance;
    }

    final fuel = status.fuelEnergy;
    if (fuel != null) {
      snapshot.fuelLevel = fuel.level?.toInt();
    }

    return snapshot;
  }
}
