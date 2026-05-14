import 'package:stellantis_mobile/stellantis/notifications/notification_service.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/status_snapshot.dart';

class StateChangeDetector {
  const StateChangeDetector._();

  static const _lowBatteryThreshold = 20;

  static Future<void> checkTransition(
    StatusSnapshot? previous,
    StatusSnapshot current,
  ) async {
    if (previous == null) return;
    await Future.wait([
      _checkChargingComplete(previous, current),
      _checkLowBattery(previous, current),
    ]);
  }

  static Future<void> _checkChargingComplete(
    StatusSnapshot previous,
    StatusSnapshot current,
  ) async {
    if (previous.chargingStatus == 'InProgress' &&
        current.chargingStatus != 'InProgress') {
      await NotificationService.showChargingComplete(
        current.vin,
        current.batteryLevel ?? 0,
      );
    }
  }

  static Future<void> _checkLowBattery(
    StatusSnapshot previous,
    StatusSnapshot current,
  ) async {
    final prev = previous.batteryLevel;
    final curr = current.batteryLevel;
    if (prev != null &&
        curr != null &&
        prev >= _lowBatteryThreshold &&
        curr < _lowBatteryThreshold) {
      await NotificationService.showLowBattery(current.vin, curr);
    }
  }
}
