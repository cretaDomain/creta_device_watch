import 'package:dio/dio.dart';
import 'package:creta_device_watch/features/history/data/models/historical_event_dto.dart';

abstract class HistoryRemoteDataSource {
  Future<List<HistoricalEventDto>> getHistoricalEvents(int month, int day);
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final Dio dio;

  HistoryRemoteDataSourceImpl(this.dio);

  @override
  Future<List<HistoricalEventDto>> getHistoricalEvents(int month, int day) async {
    try {
      final response = await dio.get(
        'https://api.wikimedia.org/feed/v1/wikipedia/en/onthisday/events/$month/$day',
      );
      if (response.statusCode == 200) {
        final responseDto = HistoricalEventsResponseDto.fromJson(response.data);
        return responseDto.events;
      } else {
        throw Exception('Failed to load historical events');
      }
    } catch (e) {
      throw Exception('Failed to load historical events: $e');
    }
  }
}
