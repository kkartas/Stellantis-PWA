import 'package:dart_mappable/dart_mappable.dart';

part 'vehicle.mapper.dart';

@MappableClass()
class VehicleModel with VehicleModelMappable {
  const VehicleModel({
    required this.vin,
    required this.vehicleId,
    this.label,
    this.brand,
    this.pictureUrl,
  });

  final String vin;

  @MappableField(key: 'id')
  final String vehicleId;

  final String? label;
  final String? brand;

  @MappableField(key: 'pictures')
  final List<String>? pictureUrl;

  String? get primaryPicture =>
      (pictureUrl?.isNotEmpty ?? false) ? pictureUrl!.first : null;
}

/// Top-level response from `GET /user/vehicles`.
@MappableClass()
class VehiclesResponse with VehiclesResponseMappable {
  const VehiclesResponse({this.vehicles});

  @MappableField(key: '_embedded')
  final VehiclesEmbedded? vehicles;
}

@MappableClass()
class VehiclesEmbedded with VehiclesEmbeddedMappable {
  const VehiclesEmbedded({this.vehicles});

  final List<VehicleModel>? vehicles;
}
