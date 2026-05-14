/// Cache TTL constants and staleness helpers for the local Isar store.
///
/// The PSA API rate-limits requests; these constants define how long a
/// cached value is considered fresh before a background refresh is warranted.
class CachePolicy {
  const CachePolicy._();

  /// A StatusSnapshot is fresh for this long after it was written.
  static const statusFresh = Duration(minutes: 5);

  /// A StatusSnapshot older than this is pruned by the background worker.
  static const statusRetention = Duration(hours: 48);

  /// Charge-session records are historical; treat them as always fresh.
  static const chargeFresh = Duration(days: 1);

  /// SOH readings change slowly; one day is fresh enough.
  static const sohFresh = Duration(days: 1);

  /// Trip records are historical; treat them as always fresh.
  static const tripFresh = Duration(days: 1);

  /// Remote-access MQTT token TTL (seconds), as issued by the PSA API.
  static const mqttTokenTtl = Duration(seconds: 890);

  /// Electricity-Maps CO₂ intensity cache window.
  static const co2SignalCache = Duration(minutes: 10);

  /// Returns whether a timestamp is older than the given TTL.
  static bool isStale(DateTime? updatedAt, Duration ttl) {
    if (updatedAt == null) return true;
    return DateTime.now().toUtc().difference(updatedAt) > ttl;
  }

  /// Returns whether a StatusSnapshot timestamp is still fresh.
  static bool isStatusFresh(DateTime? updatedAt) =>
      !isStale(updatedAt, statusFresh);
}
