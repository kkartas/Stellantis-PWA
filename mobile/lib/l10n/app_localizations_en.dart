// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Stellantis';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navTrips => 'Trips';

  @override
  String get navCharging => 'Charging';

  @override
  String get navStats => 'Stats';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionLock => 'Lock';

  @override
  String get actionUnlock => 'Unlock';

  @override
  String get actionClimate => 'Climate';

  @override
  String get actionCharge => 'Charge';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get actionLogout => 'Log out';

  @override
  String get statusCharging => 'Charging';

  @override
  String get statusRange => 'Range';

  @override
  String get statusMileage => 'Mileage';

  @override
  String rangeKm(int value) {
    return '$value km';
  }

  @override
  String batteryPercent(int value) {
    return '$value%';
  }

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorOfflineTitle => 'You\'re offline';

  @override
  String get errorOfflineMessage =>
      'We\'re showing the last known state. Reconnect to refresh from the cloud.';

  @override
  String get emptyTrips => 'No trips recorded yet.';

  @override
  String get emptyCharging => 'No charging sessions yet.';

  @override
  String lastRefreshed(String time) {
    return 'Last refreshed $time';
  }

  @override
  String tripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trips',
      one: '1 trip',
      zero: 'No trips',
    );
    return '$_temp0';
  }
}
