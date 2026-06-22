import 'package:flutter_test/flutter_test.dart';
import 'package:stellantis_mobile/stellantis/models/alert.dart';
import 'package:stellantis_mobile/stellantis/models/maintenance.dart';

void main() {
  group('AlertsResponse parsing', () {
    // Fixture shaped after the B2C `Alerts` schema (CollectionResult +
    // _embedded.alerts), with values from the api-b2c.yaml examples.
    final fixture = <String, dynamic>{
      'total': 2,
      '_embedded': {
        'alerts': [
          {
            'id': '0a9de72cc3803b12a74418acd20dcd66',
            'active': true,
            'type': 'TyrePressureLow',
            'severity': 'Warning',
            'createdAt': '2026-06-20T08:15:00Z',
            'updatedAt': '2026-06-20T08:15:00Z',
            'startedAt': '2026-06-20T08:14:30Z',
            'startPosition': {
              'type': 'Feature',
              'geometry': {
                'type': 'Point',
                'coordinates': [4.835659, 45.764043, 180.0],
              },
              'properties': {'updatedAt': '2026-06-20T08:14:30Z'},
            },
          },
          {
            'id': 'b1c2d3e4f5',
            'active': false,
            'type': 'EngineOilPressureFailure',
            'severity': 'Critical',
            'startedAt': '2026-06-18T10:00:00Z',
            'endAt': '2026-06-18T11:00:00Z',
          },
        ],
      },
    };

    test('parses the embedded alert list', () {
      final parsed = AlertsResponseMapper.fromMap(fixture);
      final alerts = parsed.alerts?.alerts ?? [];

      expect(alerts, hasLength(2));
    });

    test('maps fields and severity enum on the first alert', () {
      final alert = AlertsResponseMapper.fromMap(fixture).alerts!.alerts!.first;

      expect(alert.id, '0a9de72cc3803b12a74418acd20dcd66');
      expect(alert.type, 'TyrePressureLow');
      expect(alert.active, isTrue);
      expect(alert.severity, AlertSeverity.warning);
      expect(alert.startedAt, DateTime.utc(2026, 6, 20, 8, 14, 30));
      expect(alert.startPosition?.geometry?.latitude, 45.764043);
    });

    test('maps Critical severity and endAt on a resolved alert', () {
      final alert = AlertsResponseMapper.fromMap(fixture).alerts!.alerts![1];

      expect(alert.severity, AlertSeverity.critical);
      expect(alert.active, isFalse);
      expect(alert.endAt, DateTime.utc(2026, 6, 18, 11));
      expect(alert.startPosition, isNull);
    });

    test('falls back to AlertSeverity.unknown for unrecognised values', () {
      final alert = AlertModelMapper.fromMap({
        'id': 'x',
        'type': 'SomethingNew',
        'severity': 'Catastrophic',
      });

      expect(alert.severity, AlertSeverity.unknown);
    });

    test('tolerates a missing _embedded block', () {
      final parsed = AlertsResponseMapper.fromMap({'total': 0});
      expect(parsed.alerts?.alerts ?? [], isEmpty);
    });
  });

  group('MaintenanceModel parsing', () {
    test('parses days and mileage before maintenance', () {
      final m = MaintenanceModelMapper.fromMap({
        'createdAt': '2026-06-01T00:00:00Z',
        'daysBeforeMaintenance': 45,
        'mileageBeforeMaintenance': 1239.6,
      });

      expect(m.daysBeforeMaintenance, 45);
      expect(m.mileageBeforeMaintenance, closeTo(1239.6, 1e-9));
      expect(m.createdAt, DateTime.utc(2026, 6));
      expect(m.isOverdue, isFalse);
    });

    test('flags overdue when a figure is negative', () {
      final m = MaintenanceModelMapper.fromMap({
        'daysBeforeMaintenance': -10,
        'mileageBeforeMaintenance': 500.0,
      });

      expect(m.isOverdue, isTrue);
    });

    test('handles a payload with only one figure present', () {
      final m = MaintenanceModelMapper.fromMap({
        'mileageBeforeMaintenance': 2000.0,
      });

      expect(m.daysBeforeMaintenance, isNull);
      expect(m.mileageBeforeMaintenance, 2000.0);
      expect(m.isOverdue, isFalse);
    });
  });
}
