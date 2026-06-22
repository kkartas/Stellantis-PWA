// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Stellantis';

  @override
  String get navDashboard => 'Übersicht';

  @override
  String get navTrips => 'Fahrten';

  @override
  String get navCharging => 'Laden';

  @override
  String get navStats => 'Statistik';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get actionLock => 'Verriegeln';

  @override
  String get actionUnlock => 'Entriegeln';

  @override
  String get actionClimate => 'Klima';

  @override
  String get actionCharge => 'Laden';

  @override
  String get actionRetry => 'Erneut versuchen';

  @override
  String get actionRefresh => 'Aktualisieren';

  @override
  String get actionLogout => 'Abmelden';

  @override
  String get statusCharging => 'Lädt';

  @override
  String get statusRange => 'Reichweite';

  @override
  String get statusMileage => 'Kilometerstand';

  @override
  String rangeKm(int value) {
    return '$value km';
  }

  @override
  String batteryPercent(int value) {
    return '$value %';
  }

  @override
  String get errorTitle => 'Etwas ist schiefgelaufen';

  @override
  String get errorOfflineTitle => 'Sie sind offline';

  @override
  String get errorOfflineMessage =>
      'Wir zeigen den zuletzt bekannten Stand. Stellen Sie die Verbindung wieder her, um aus der Cloud zu aktualisieren.';

  @override
  String get emptyTrips => 'Noch keine Fahrten aufgezeichnet.';

  @override
  String get emptyCharging => 'Noch keine Ladevorgänge.';

  @override
  String lastRefreshed(String time) {
    return 'Zuletzt aktualisiert $time';
  }

  @override
  String tripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fahrten',
      one: '1 Fahrt',
      zero: 'Keine Fahrten',
    );
    return '$_temp0';
  }
}
