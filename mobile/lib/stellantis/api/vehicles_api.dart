import 'package:dart_mappable/dart_mappable.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/core/logging/logger.dart';
import 'package:stellantis_mobile/core/perf/json_isolate.dart';
import 'package:stellantis_mobile/stellantis/models/alert.dart';
import 'package:stellantis_mobile/stellantis/models/maintenance.dart';
import 'package:stellantis_mobile/stellantis/models/vehicle.dart';
import 'package:stellantis_mobile/stellantis/models/vehicle_status.dart';
import 'package:stellantis_mobile/stellantis/network/psa_http_client.dart';

const _log = AppLogger('VehiclesApi');

/// Query-parameter extension sets used when fetching vehicle lists.
/// Each variant is tried in order; the first 200 response wins.
const _vehicleExtensions = [
  [
    ('extension', 'branding'),
    ('extension', 'pictures'),
    ('extension', 'onboardCapabilities'),
  ],
  [
    ('extension', 'pictures'),
    ('extension', 'branding'),
  ],
  [('extension', 'pictures')],
  [('extension', 'branding')],
  <(String, String)>[],
];

final vehiclesApiProvider = Provider<VehiclesApi>(
  (ref) => VehiclesApi(ref.watch(psaHttpClientProvider)),
);

class VehiclesApi {
  VehiclesApi(this._dio);

  final Dio _dio;

  /// Returns all vehicles for the authenticated user.
  ///
  /// Tries progressively simpler extension sets until one succeeds,
  /// mirroring the Python fallback strategy.
  Future<List<VehicleModel>> getVehicles({
    required String clientId,
    required String realm,
  }) async {
    final headers = _authHeaders(clientId, realm);

    for (final extensions in _vehicleExtensions) {
      try {
        final queryParams = <String, dynamic>{
          'client_id': clientId,
        };
        for (final (k, v) in extensions) {
          queryParams[k] = v;
        }

        final response = await _dio.get<Map<String, dynamic>>(
          '/user/vehicles',
          queryParameters: queryParams,
          options: Options(headers: headers),
        );

        final data = response.data;
        if (data == null) continue;

        final parsed = VehiclesResponseMapper.fromMap(data);
        final vehicles = parsed.vehicles?.vehicles ?? [];
        _log.i('Loaded ${vehicles.length} vehicle(s)');
        return vehicles;
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 401 || status == 403) rethrow;
        _log.w('getVehicles failed (status=$status), trying next variant');
      } on MapperException catch (e) {
        _log.e('getVehicles parse error', e);
        rethrow;
      }
    }

    _log.w('getVehicles: all variants exhausted, returning empty list');
    return [];
  }

  /// Returns the current status of the vehicle identified by [vehicleId].
  Future<VehicleStatusModel?> getVehicleStatus({
    required String vehicleId,
    required String clientId,
    required String realm,
  }) async {
    final headers = _authHeaders(clientId, realm);

    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        // Fetch as plain text so we can hand large bodies off to an
        // isolate before paying the dart_mappable parse cost.
        final response = await _dio.get<String>(
          '/user/vehicles/$vehicleId/status',
          queryParameters: {'client_id': clientId},
          options: Options(
            headers: headers,
            responseType: ResponseType.plain,
          ),
        );

        final body = response.data;
        if (body == null || body.isEmpty) return null;

        final decoded = await parseJsonAsync(body);
        if (decoded is! Map<String, dynamic>) {
          _log.w('getVehicleStatus: unexpected JSON shape');
          return null;
        }
        return VehicleStatusModelMapper.fromMap(decoded);
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        if (status == 401 || status == 403) rethrow;
        _log.e('getVehicleStatus attempt ${attempt + 1} failed', e);
        if (attempt == 1) return null;
      } on MapperException catch (e) {
        _log.e('getVehicleStatus parse error', e);
        return null;
      }
    }

    return null;
  }

  /// Returns the latest active alerts for the vehicle identified by
  /// [vehicleId]. Returns an empty list when none are present or on failure.
  Future<List<AlertModel>> getVehicleAlerts({
    required String vehicleId,
    required String clientId,
    required String realm,
  }) async {
    final headers = _authHeaders(clientId, realm);

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/user/vehicles/$vehicleId/alerts',
        queryParameters: {'client_id': clientId},
        options: Options(headers: headers),
      );

      final data = response.data;
      if (data == null) return [];

      final parsed = AlertsResponseMapper.fromMap(data);
      final alerts = parsed.alerts?.alerts ?? [];
      _log.i('Loaded ${alerts.length} alert(s) for $vehicleId');
      return alerts;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) rethrow;
      _log.w('getVehicleAlerts failed (status=$status)');
      return [];
    } on MapperException catch (e) {
      _log.e('getVehicleAlerts parse error', e);
      return [];
    }
  }

  /// Returns the next-maintenance details for the vehicle identified by
  /// [vehicleId], or null when unavailable.
  Future<MaintenanceModel?> getVehicleMaintenance({
    required String vehicleId,
    required String clientId,
    required String realm,
  }) async {
    final headers = _authHeaders(clientId, realm);

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/user/vehicles/$vehicleId/maintenance',
        queryParameters: {'client_id': clientId},
        options: Options(headers: headers),
      );

      final data = response.data;
      if (data == null) return null;

      return MaintenanceModelMapper.fromMap(data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) rethrow;
      _log.w('getVehicleMaintenance failed (status=$status)');
      return null;
    } on MapperException catch (e) {
      _log.e('getVehicleMaintenance parse error', e);
      return null;
    }
  }

  static Map<String, String> _authHeaders(String clientId, String realm) => {
        'client_id': clientId,
        'x-introspect-realm': realm,
      };
}
