import 'package:equatable/equatable.dart';

class WorldCity extends Equatable {
  final String id;
  final String city;
  final String timezone;

  const WorldCity({
    required this.id,
    required this.city,
    required this.timezone,
  });

  @override
  List<Object?> get props => [id, city, timezone];
}
