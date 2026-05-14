import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

const _co2SignalBaseUrl = 'https://api.electricitymaps.com';
const _reqIntervalSeconds = 600;
const _timeoutSeconds = 10;

typedef _Co2Entry = ({DateTime timestamp, double value});

/// CO₂ intensity estimator for EV charging sessions.
///
/// Port of Python `Ecomix` (psacc/application/ecomix.py). Fetches grid
/// carbon intensity from either the Electricity Maps API or the French
/// RTE eco2mix feed, caching results per country code.
///
/// The caller is responsible for supplying the ISO 3166-1 alpha-2
/// country code — this class does not perform reverse geocoding.
class EmissionsEstimator {
  EmissionsEstimator({required this.dio, this.co2SignalKey});

  final Dio dio;

  /// Electricity Maps API key. When null, France-only fallback is used.
  String? co2SignalKey;

  final _cache = <String, List<_Co2Entry>>{};

  /// Evicts cache entries older than 24 hours.
  void cleanCache() {
    final cutoff = DateTime.now()
        .toUtc()
        .subtract(const Duration(days: 1));
    for (final entries in _cache.values) {
      entries.removeWhere((e) => !e.timestamp.isAfter(cutoff));
    }
  }

  /// Returns the mean CO₂ (gCO₂/kWh) from cache for [countryCode]
  /// with timestamps falling strictly between [start] and [end].
  ///
  /// Returns null when no cached samples exist for the window.
  double? getCo2FromSignalCache(
    DateTime start,
    DateTime end,
    String countryCode,
  ) {
    cleanCache();
    final entries = _cache[countryCode] ?? [];
    final values = [
      for (final e in entries)
        if (e.timestamp.isAfter(start) && e.timestamp.isBefore(end))
          e.value,
    ];
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Fetches live carbon intensity for [countryCode] from Electricity Maps
  /// and stores the result in the local cache.
  ///
  /// Returns true when a fresh sample was added, false on error or when
  /// the cached value is still within the rate-limit window.
  Future<bool> fetchCo2Signal(String countryCode) async {
    final key = co2SignalKey;
    if (key == null) return false;
    try {
      final now = DateTime.now().toUtc();
      final cached = _cache[countryCode] ?? [];
      if (cached.isNotEmpty) {
        final elapsed =
            now.difference(cached.last.timestamp).inSeconds;
        if (elapsed < _reqIntervalSeconds) return false;
      }
      final resp = await dio.get<Map<String, dynamic>>(
        '$_co2SignalBaseUrl/v3/carbon-intensity/latest',
        queryParameters: {'zone': countryCode},
        options: Options(
          headers: {'auth-token': key},
          sendTimeout: const Duration(seconds: _timeoutSeconds),
          receiveTimeout: const Duration(seconds: _timeoutSeconds),
        ),
      );
      if (resp.statusCode != 200) return false;
      final raw = resp.data?['carbonIntensity'];
      final value = raw is num ? raw.toDouble() : null;
      if (value == null) return false;
      _cache.putIfAbsent(countryCode, () => []).add(
        (timestamp: now, value: value),
      );
      return true;
    } on DioException {
      return false;
    }
  }

  /// Fetches CO₂ intensity from the French RTE eco2mix XML feed.
  ///
  /// Returns the mean gCO₂/kWh over [start]→[end], or null on error.
  Future<double?> getDataFrance(DateTime start, DateTime end) async {
    try {
      final resp = await dio.get<String>(
        'https://eco2mix.rte-france.com/curves/eco2mixWeb',
        queryParameters: {
          'type': 'co2',
          'dateDeb': _frDate(start),
          'dateFin': _frDate(end),
          'mode': 'NORM',
        },
        options: Options(
          headers: {
            'Origin': 'https://www.rte-france.com',
            'Referer': 'https://www.rte-france.com/eco2mix/'
                'les-emissions-de-co2-par-kwh-produit-en-france',
          },
          responseType: ResponseType.plain,
          sendTimeout: const Duration(seconds: _timeoutSeconds),
          receiveTimeout: const Duration(seconds: _timeoutSeconds),
        ),
      );
      final body = resp.data;
      if (body == null) return null;
      return _parseFranceXml(body, start, end);
    } on DioException {
      return null;
    }
  }

  double? _parseFranceXml(String xml, DateTime start, DateTime end) {
    try {
      final doc = XmlDocument.parse(xml);
      final periodStart = (start.hour + start.minute ~/ 30) * 4;
      final periodEnd = (end.hour + end.minute ~/ 30) * 4;
      final values = <double>[];
      var inRange = false;
      for (final el in doc.findAllElements('valeur')) {
        final periode =
            int.tryParse(el.getAttribute('periode') ?? '');
        if (periode == null) continue;
        if (periode == periodStart) inRange = true;
        if (periode == periodEnd) break;
        if (inRange) {
          final v = double.tryParse(el.innerText.trim());
          if (v != null) values.add(v);
        }
      }
      if (values.isEmpty) return null;
      return values.reduce((a, b) => a + b) / values.length;
    } on XmlException {
      return null;
    }
  }

  /// Returns mean CO₂ intensity (gCO₂/kWh) for a charge between
  /// [start] and [end], choosing the best available source for
  /// [countryCode].
  ///
  /// Prefers the Electricity Maps cache when a key is configured,
  /// falls back to the RTE eco2mix feed for France, otherwise null.
  Future<double?> getCo2PerKw(
    DateTime start,
    DateTime end,
    String countryCode,
  ) async {
    if (co2SignalKey != null) {
      return getCo2FromSignalCache(start, end, countryCode);
    }
    if (countryCode == 'FR') {
      return getDataFrance(start, end);
    }
    return null;
  }

  static String _frDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }
}
