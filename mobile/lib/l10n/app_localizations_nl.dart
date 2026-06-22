// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Stellantis';

  @override
  String get navDashboard => 'Overzicht';

  @override
  String get navTrips => 'Ritten';

  @override
  String get navCharging => 'Opladen';

  @override
  String get navStats => 'Statistieken';

  @override
  String get navSettings => 'Instellingen';

  @override
  String get actionLock => 'Vergrendelen';

  @override
  String get actionUnlock => 'Ontgrendelen';

  @override
  String get actionClimate => 'Klimaat';

  @override
  String get actionCharge => 'Opladen';

  @override
  String get actionRetry => 'Opnieuw';

  @override
  String get actionRefresh => 'Vernieuwen';

  @override
  String get actionLogout => 'Afmelden';

  @override
  String get statusCharging => 'Aan het laden';

  @override
  String get statusRange => 'Actieradius';

  @override
  String get statusMileage => 'Kilometerstand';

  @override
  String rangeKm(int value) {
    return '$value km';
  }

  @override
  String batteryPercent(int value) {
    return '$value%';
  }

  @override
  String get errorTitle => 'Er ging iets mis';

  @override
  String get errorOfflineTitle => 'Je bent offline';

  @override
  String get errorOfflineMessage =>
      'We tonen de laatst bekende status. Maak opnieuw verbinding om vanuit de cloud te vernieuwen.';

  @override
  String get emptyTrips => 'Nog geen ritten geregistreerd.';

  @override
  String get emptyCharging => 'Nog geen laadsessies.';

  @override
  String lastRefreshed(String time) {
    return 'Laatst vernieuwd $time';
  }

  @override
  String tripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ritten',
      one: '1 rit',
      zero: 'Geen ritten',
    );
    return '$_temp0';
  }
}
