import 'package:creta_device_watch/features/history/data/datasources/history_remote_data_source.dart';
import 'package:creta_device_watch/features/history/domain/entities/historical_event.dart';
import 'package:creta_device_watch/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<HistoricalEvent>> getHistoricalEvents(int month, int day) async {
    try {
      final dtos = await remoteDataSource.getHistoricalEvents(month, day);
      return dtos
          .map((dto) => HistoricalEvent(
                year: dto.year,
                text: dto.text,
                imageUrl: dto.imageUrl,
                translatedText: null,
              ))
          .toList();
    } catch (e) {
      // Here you could handle different types of exceptions
      // and return a more specific result (e.g. using a Result type).
      rethrow;
    }
  }
}
