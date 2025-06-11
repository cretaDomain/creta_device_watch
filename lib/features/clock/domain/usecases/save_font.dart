import 'package:creta_device_watch/features/clock/domain/repositories/font_repository.dart';

class SaveFont {
  final FontRepository repository;

  SaveFont(this.repository);

  Future<void> call(int index) {
    return repository.saveFontIndex(index);
  }
}
