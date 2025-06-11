import 'package:equatable/equatable.dart';

class HistoricalEvent extends Equatable {
  final int year;
  final String text;
  final String? imageUrl;

  const HistoricalEvent({
    required this.year,
    required this.text,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [year, text, imageUrl];
}
