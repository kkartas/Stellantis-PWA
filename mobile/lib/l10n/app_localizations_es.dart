// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Stellantis';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navTrips => 'Viajes';

  @override
  String get navCharging => 'Carga';

  @override
  String get navStats => 'Estadísticas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get actionLock => 'Bloquear';

  @override
  String get actionUnlock => 'Desbloquear';

  @override
  String get actionClimate => 'Climatización';

  @override
  String get actionCharge => 'Cargar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionRefresh => 'Actualizar';

  @override
  String get actionLogout => 'Cerrar sesión';

  @override
  String get statusCharging => 'Cargando';

  @override
  String get statusRange => 'Autonomía';

  @override
  String get statusMileage => 'Kilometraje';

  @override
  String rangeKm(int value) {
    return '$value km';
  }

  @override
  String batteryPercent(int value) {
    return '$value %';
  }

  @override
  String get errorTitle => 'Algo salió mal';

  @override
  String get errorOfflineTitle => 'Estás sin conexión';

  @override
  String get errorOfflineMessage =>
      'Mostramos el último estado conocido. Vuelve a conectarte para actualizar desde la nube.';

  @override
  String get emptyTrips => 'Aún no hay viajes registrados.';

  @override
  String get emptyCharging => 'Aún no hay sesiones de carga.';

  @override
  String lastRefreshed(String time) {
    return 'Última actualización $time';
  }

  @override
  String tripsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count viajes',
      one: '1 viaje',
      zero: 'Sin viajes',
    );
    return '$_temp0';
  }
}
