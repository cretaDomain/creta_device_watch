class HistoricalEventsResponseDto {
  final List<HistoricalEventDto> events;

  HistoricalEventsResponseDto({required this.events});

  factory HistoricalEventsResponseDto.fromJson(Map<String, dynamic> json) {
    final eventsList = json['events'] as List<dynamic>? ?? [];
    final events = eventsList
        .map((eventJson) => HistoricalEventDto.fromJson(eventJson as Map<String, dynamic>))
        .toList();
    return HistoricalEventsResponseDto(events: events);
  }
}

class HistoricalEventDto {
  final String text;
  final int year;
  final List<EventPageDto> pages;

  HistoricalEventDto({
    required this.text,
    required this.year,
    required this.pages,
  });

  factory HistoricalEventDto.fromJson(Map<String, dynamic> json) {
    final pageList = json['pages'] as List<dynamic>? ?? [];
    final pages = pageList
        .map((pageJson) => EventPageDto.fromJson(pageJson as Map<String, dynamic>))
        .toList();
    return HistoricalEventDto(
      text: json['text'] as String? ?? '',
      year: json['year'] as int? ?? 0,
      pages: pages,
    );
  }

  String? get imageUrl =>
      pages.isNotEmpty && pages.first.thumbnail != null ? pages.first.thumbnail!.source : null;
}

class EventPageDto {
  final PageThumbnailDto? thumbnail;

  EventPageDto({this.thumbnail});

  factory EventPageDto.fromJson(Map<String, dynamic> json) {
    return EventPageDto(
      thumbnail: json['thumbnail'] != null
          ? PageThumbnailDto.fromJson(json['thumbnail'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PageThumbnailDto {
  final String source;

  PageThumbnailDto({required this.source});

  factory PageThumbnailDto.fromJson(Map<String, dynamic> json) {
    return PageThumbnailDto(
      source: json['source'] as String? ?? '',
    );
  }
}
