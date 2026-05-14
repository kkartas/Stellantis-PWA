import 'package:dart_mappable/dart_mappable.dart';

part 'position.mapper.dart';

@MappableClass()
class GeoPoint with GeoPointMappable {
  const GeoPoint({this.type, this.coordinates});

  final String? type;

  /// [longitude, latitude, altitude?]
  final List<double>? coordinates;

  double? get longitude =>
      (coordinates?.isNotEmpty ?? false) ? coordinates![0] : null;

  double? get latitude =>
      (coordinates?.length ?? 0) > 1 ? coordinates![1] : null;

  double? get altitude =>
      (coordinates?.length ?? 0) > 2 ? coordinates![2] : null;
}

@MappableClass()
class PositionProperties with PositionPropertiesMappable {
  const PositionProperties({
    this.heading,
    this.moving,
    this.signalQuality,
    this.updatedAt,
  });

  final double? heading;
  final bool? moving;

  @MappableField(key: 'signalQuality')
  final int? signalQuality;

  @MappableField(key: 'updatedAt')
  final DateTime? updatedAt;
}

@MappableClass()
class PositionModel with PositionModelMappable {
  const PositionModel({this.type, this.geometry, this.properties});

  final String? type;
  final GeoPoint? geometry;
  final PositionProperties? properties;
}
