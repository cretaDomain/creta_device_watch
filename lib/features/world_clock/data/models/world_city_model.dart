import 'dart:convert';
import 'package:creta_device_watch/features/world_clock/domain/entities/world_city.dart';

class WorldCityModel extends WorldCity {
  const WorldCityModel({
    required super.id,
    required super.city,
    required super.timezone,
  });

  factory WorldCityModel.fromEntity(WorldCity entity) {
    return WorldCityModel(
      id: entity.id,
      city: entity.city,
      timezone: entity.timezone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'city': city,
      'timezone': timezone,
    };
  }

  factory WorldCityModel.fromMap(Map<String, dynamic> map) {
    return WorldCityModel(
      id: map['id'] as String,
      city: map['city'] as String,
      timezone: map['timezone'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory WorldCityModel.fromJson(String source) =>
      WorldCityModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
