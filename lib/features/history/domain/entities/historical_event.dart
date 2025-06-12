import 'package:equatable/equatable.dart';

class HistoricalEvent extends Equatable {
  final int year;
  final String text;
  final String? imageUrl;
  final String? translatedText;

  const HistoricalEvent({
    required this.year,
    required this.text,
    this.imageUrl,
    this.translatedText,
  });

  HistoricalEvent copyWith({
    int? year,
    String? text,
    String? imageUrl,
    String? translatedText,
  }) {
    return HistoricalEvent(
      year: year ?? this.year,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      translatedText: translatedText ?? this.translatedText,
    );
  }

  @override
  List<Object?> get props => [year, text, imageUrl, translatedText];
}
