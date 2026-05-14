import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const _channelId = 'stellantis_alerts';
const _channelName = 'Vehicle Alerts';

const _details = NotificationDetails(
  android: AndroidNotificationDetails(_channelId, _channelName),
  iOS: DarwinNotificationDetails(),
);

class NotificationService {
  const NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() => _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );

  static Future<void> showChargingComplete(String vin, int level) =>
      _plugin.show(
        _id(vin, 0),
        'Charging Complete',
        'Battery at $level% — ready to go.',
        _details,
      );

  static Future<void> showLowBattery(String vin, int level) =>
      _plugin.show(
        _id(vin, 1),
        'Low Battery',
        'Battery at $level% — consider charging soon.',
        _details,
      );

  static int _id(String vin, int type) =>
      (vin.hashCode & 0x0FFFFFFF) + type;
}
