// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Stellantis';

  @override
  String get navDashboard => 'Cruscotto';

  @override
  String get navTrips => 'Viaggi';

  @override
  String get navCharging => 'Ricarica';

  @override
  String get navStats => 'Statistiche';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get actionLock => 'Blocca';

  @override
  String get actionUnlock => 'Sblocca';

  @override
  String get actionClimate => 'Clima';

  @override
  String get actionCharge => 'Ricarica';

  @override
  String get actionRetry => 'Riprova';

  @override
  String get actionRefresh => 'Aggiorna';

  @override
  String get actionLogout => 'Esci';

  @override
  String get statusCharging => 'In carica';

  @override
  String get statusRange => 'Autonomia';

  @override
  String get statusMileage => 'Chilometraggio';

  @override
  String rangeKm(int value) {
    return '$value km';
  }

  @override
  String batteryPercent(int value) {
    return '$value%';
  }

  @override
  String get errorTitle => 'Qualcosa è andato storto';

  @override
  String get errorOfflineTitle => 'Sei offline';

  @override
  String get errorOfflineMessage =>
      'Stiamo mostrando l\'ultimo stato noto. Riconnettiti per aggiornare dal cloud.';

  @override
  String get emptyTrips => 'Nessun viaggio registrato.';

  @override
  String get emptyCharging => 'Nessuna sessione di ricarica.';

  @override
  String lastRefreshed(String time) {
    return 'Ultimo aggiornamento $time';
  }

  @override
  String tripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count viaggi',
      one: '1 viaggio',
      zero: 'Nessun viaggio',
    );
    return '$_temp0';
  }
}
