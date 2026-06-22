import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/stellantis/api/vehicles_api.dart';
import 'package:stellantis_mobile/stellantis/models/alert.dart';
import 'package:stellantis_mobile/stellantis/models/energy.dart';
import 'package:stellantis_mobile/stellantis/models/maintenance.dart';
import 'package:stellantis_mobile/stellantis/models/vehicle.dart';
import 'package:stellantis_mobile/stellantis/models/vehicle_status.dart';

String _fixtureString(String name) =>
    File('test/fixtures/stellantis/$name').readAsStringSync();

Map<String, dynamic> _fixtureMap(String name) =>
    jsonDecode(_fixtureString(name)) as Map<String, dynamic>;

/// A Dio adapter that replays the captured fixtures by endpoint. Records the
/// last request so tests can assert headers and query parameters.
class _ReplayAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    final path = options.uri.path;

    final String fixture;
    if (path.endsWith('/status')) {
      fixture = 'status.json';
    } else if (path.endsWith('/alerts')) {
      fixture = 'alerts.json';
    } else if (path.endsWith('/maintenance')) {
      fixture = 'maintenance.json';
    } else if (path.endsWith('/user/vehicles')) {
      fixture = 'vehicles.json';
    } else {
      return ResponseBody.fromString('{}', 404);
    }

    return ResponseBody.fromString(
      _fixtureString(fixture),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

VehiclesApi _apiWith(HttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test/v4'))
    ..httpClientAdapter = adapter;
  return VehiclesApi(dio);
}

void main() {
  group('Model parsing from captured fixtures', () {
    test('vehicles.json → two typed vehicles with brand and pictures', () {
      final parsed =
          VehiclesResponseMapper.fromMap(_fixtureMap('vehicles.json'));
      final vehicles = parsed.vehicles?.vehicles ?? [];

      expect(vehicles, hasLength(2));
      final first = vehicles.first;
      expect(first.vehicleId, '1234567890abcdef');
      expect(first.vin, 'VR3UHZKXZNT000001');
      expect(first.label, 'e-208');
      expect(first.brand, 'Peugeot');
      expect(first.primaryPicture,
          'https://cdn.example.test/peugeot-e208-front.png');
      expect(vehicles[1].brand, 'Citroen');
    });

    test('status.json → energy, charging, doors, position, odometer', () {
      final status =
          VehicleStatusModelMapper.fromMap(_fixtureMap('status.json'));

      final electric = status.electricEnergy;
      expect(electric, isNotNull);
      expect(electric!.level, 72.0);
      expect(electric.autonomy, 210.0);
      expect(electric.charging?.status, ChargingStatus.inProgress);
      expect(electric.charging?.plugged, isTrue);
      expect(electric.charging?.chargingRate, 12);
      expect(electric.battery?.health?.state, 'Good');

      expect(status.fuelEnergy?.type, EnergyType.fuel);
      expect(status.doorsState?.lockedStates, DoorLockStatus.locked);
      expect(status.ignition?.type, IgnitionType.stop);
      expect(status.kinetic?.moving, isFalse);
      expect(status.lastPosition?.geometry?.latitude, 45.764043);
      expect(status.lastPosition?.geometry?.longitude, 4.835659);
      expect(status.timedOdometer?.mileage, closeTo(12345.6, 1e-9));
      expect(status.preconditioning?.airConditioning?.status,
          AirConditioningStatus.disabled);
    });

    test('alerts.json → two alerts with severity enums', () {
      final parsed = AlertsResponseMapper.fromMap(_fixtureMap('alerts.json'));
      final alerts = parsed.alerts?.alerts ?? [];

      expect(alerts, hasLength(2));
      expect(alerts.first.severity, AlertSeverity.warning);
      expect(alerts.first.active, isTrue);
      expect(alerts[1].severity, AlertSeverity.critical);
      expect(alerts[1].active, isFalse);
    });

    test('maintenance.json → days and mileage before service', () {
      final m =
          MaintenanceModelMapper.fromMap(_fixtureMap('maintenance.json'));

      expect(m.daysBeforeMaintenance, 45);
      expect(m.mileageBeforeMaintenance, closeTo(1239.6, 1e-9));
      expect(m.isOverdue, isFalse);
    });
  });

  group('VehiclesApi replay (fake Dio adapter)', () {
    late _ReplayAdapter adapter;
    late VehiclesApi api;

    setUp(() {
      adapter = _ReplayAdapter();
      api = _apiWith(adapter);
    });

    test('getVehicles parses the list and sends auth headers', () async {
      final vehicles = await api.getVehicles(
        clientId: 'test-client',
        realm: 'clientsB2CPeugeot',
      );

      expect(vehicles, hasLength(2));
      expect(adapter.lastRequest?.headers['client_id'], 'test-client');
      expect(adapter.lastRequest?.headers['x-introspect-realm'],
          'clientsB2CPeugeot');
      expect(adapter.lastRequest?.queryParameters['client_id'], 'test-client');
    });

    test('getVehicleStatus parses the status payload', () async {
      final status = await api.getVehicleStatus(
        vehicleId: '1234567890abcdef',
        clientId: 'test-client',
        realm: 'clientsB2CPeugeot',
      );

      expect(status, isNotNull);
      expect(status!.electricEnergy?.level, 72.0);
      expect(adapter.lastRequest?.uri.path, endsWith('/status'));
    });

    test('getVehicleAlerts parses the alert list', () async {
      final alerts = await api.getVehicleAlerts(
        vehicleId: '1234567890abcdef',
        clientId: 'test-client',
        realm: 'clientsB2CPeugeot',
      );

      expect(alerts, hasLength(2));
      expect(alerts.first.type, 'TyrePressureLow');
    });

    test('getVehicleMaintenance parses the maintenance payload', () async {
      final m = await api.getVehicleMaintenance(
        vehicleId: '1234567890abcdef',
        clientId: 'test-client',
        realm: 'clientsB2CPeugeot',
      );

      expect(m, isNotNull);
      expect(m!.daysBeforeMaintenance, 45);
    });

    test('non-2xx on every variant yields an empty vehicle list', () async {
      final notFoundApi = _apiWith(_NotFoundAdapter());
      final vehicles = await notFoundApi.getVehicles(
        clientId: 'c',
        realm: 'r',
      );
      expect(vehicles, isEmpty);
    });
  });
}

class _NotFoundAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString('{}', 404);

  @override
  void close({bool force = false}) {}
}
