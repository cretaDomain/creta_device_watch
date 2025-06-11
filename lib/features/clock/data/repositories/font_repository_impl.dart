import 'package:creta_device_watch/features/clock/data/datasources/font_local_data_source.dart';
import 'package:creta_device_watch/features/clock/domain/repositories/font_repository.dart';

class FontRepositoryImpl implements FontRepository {
  final FontLocalDataSource localDataSource;

  FontRepositoryImpl(this.localDataSource);

  @override
  Future<int> getFontIndex() {
    return localDataSource.getFontIndex();
  }

  @override
  Future<void> saveFontIndex(int index) {
    return localDataSource.saveFontIndex(index);
  }
}
