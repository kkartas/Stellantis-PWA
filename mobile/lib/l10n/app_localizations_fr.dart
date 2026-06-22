// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Stellantis';

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navTrips => 'Trajets';

  @override
  String get navCharging => 'Recharge';

  @override
  String get navStats => 'Statistiques';

  @override
  String get navSettings => 'Réglages';

  @override
  String get actionLock => 'Verrouiller';

  @override
  String get actionUnlock => 'Déverrouiller';

  @override
  String get actionClimate => 'Climatisation';

  @override
  String get actionCharge => 'Recharger';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionRefresh => 'Actualiser';

  @override
  String get actionLogout => 'Se déconnecter';

  @override
  String get statusCharging => 'En charge';

  @override
  String get statusRange => 'Autonomie';

  @override
  String get statusMileage => 'Kilométrage';

  @override
  String rangeKm(int value) {
    return '$value km';
  }

  @override
  String batteryPercent(int value) {
    return '$value %';
  }

  @override
  String get errorTitle => 'Une erreur s\'est produite';

  @override
  String get errorOfflineTitle => 'Vous êtes hors ligne';

  @override
  String get errorOfflineMessage =>
      'Nous affichons le dernier état connu. Reconnectez-vous pour actualiser depuis le cloud.';

  @override
  String get emptyTrips => 'Aucun trajet enregistré pour le moment.';

  @override
  String get emptyCharging => 'Aucune session de recharge pour le moment.';

  @override
  String lastRefreshed(String time) {
    return 'Dernière actualisation $time';
  }

  @override
  String tripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trajets',
      one: '1 trajet',
      zero: 'Aucun trajet',
    );
    return '$_temp0';
  }
}
