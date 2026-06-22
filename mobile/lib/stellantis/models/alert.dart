import 'package:dart_mappable/dart_mappable.dart';
import 'package:stellantis_mobile/stellantis/models/position.dart';

part 'alert.mapper.dart';

/// Severity of a vehicle alert.
///
/// - [information]: better to fix but the vehicle operates accurately.
/// - [warning]: should be fixed as soon as possible.
/// - [critical]: starting prohibited without repair.
@MappableEnum(defaultValue: AlertSeverity.unknown)
enum AlertSeverity {
  @MappableValue('Information')
  information,
  @MappableValue('Warning')
  warning,
  @MappableValue('Critical')
  critical,
  unknown,
}

/// A single alert message returned by `GET /user/vehicles/{id}/alerts`.
///
/// The `type` field is one of the (very large) `AlertMsgEnum` values from the
/// B2C API; it is kept as a raw string rather than an enum because the set is
/// brand-dependent and changes over time.
@MappableClass()
class AlertModel with AlertModelMappable {
  const AlertModel({
    required this.id,
    required this.type,
    this.active,
    this.severity,
    this.startedAt,
    this.endAt,
    this.startPosition,
    this.endPosition,
    this.createdAt,
    this.updatedAt,
  });

  final String id;

  /// Raw `AlertMsgEnum` value (e.g. `TyrePressureLow`).
  final String type;

  final bool? active;
  final AlertSeverity? severity;

  @MappableField(key: 'startedAt')
  final DateTime? startedAt;

  @MappableField(key: 'endAt')
  final DateTime? endAt;

  @MappableField(key: 'startPosition')
  final PositionModel? startPosition;

  @MappableField(key: 'endPosition')
  final PositionModel? endPosition;

  @MappableField(key: 'createdAt')
  final DateTime? createdAt;

  @MappableField(key: 'updatedAt')
  final DateTime? updatedAt;
}

/// Top-level response from `GET /user/vehicles/{id}/alerts`.
@MappableClass()
class AlertsResponse with AlertsResponseMappable {
  const AlertsResponse({this.alerts});

  @MappableField(key: '_embedded')
  final AlertsEmbedded? alerts;
}

@MappableClass()
class AlertsEmbedded with AlertsEmbeddedMappable {
  const AlertsEmbedded({this.alerts});

  final List<AlertModel>? alerts;
}
