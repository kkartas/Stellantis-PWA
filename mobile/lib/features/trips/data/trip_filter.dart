import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellantis_mobile/stellantis/storage/schemas/trip_record.dart';

/// Immutable filter state applied client-side over the cached trip list.
class TripFilter {
  const TripFilter({
    this.query = '',
    this.startAfter,
    this.minDistanceKm = 0,
  });

  final String query;
  final DateTime? startAfter;
  final double minDistanceKm;

  bool get isActive =>
      query.isNotEmpty || startAfter != null || minDistanceKm > 0;

  TripFilter copyWith({
    String? query,
    DateTime? startAfter,
    double? minDistanceKm,
  }) {
    return TripFilter(
      query: query ?? this.query,
      startAfter: startAfter ?? this.startAfter,
      minDistanceKm: minDistanceKm ?? this.minDistanceKm,
    );
  }

  List<TripRecord> apply(List<TripRecord> trips) {
    return trips.where((t) {
      if (startAfter != null && t.startAt.isBefore(startAfter!)) return false;
      if (t.distance < minDistanceKm) return false;
      if (query.isEmpty) return true;
      final haystack = '${t.startAt.toIso8601String()} '
          '${t.distance.toStringAsFixed(1)} '
          '${t.consumption?.toStringAsFixed(1) ?? ''}';
      return haystack.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}

final tripFilterProvider = StateProvider<TripFilter>((_) => const TripFilter());
