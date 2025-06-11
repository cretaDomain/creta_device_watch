import 'package:shared_preferences/shared_preferences.dart';

abstract class FontLocalDataSource {
  Future<int> getFontIndex();
  Future<void> saveFontIndex(int index);
}

class FontLocalDataSourceImpl implements FontLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _fontIndexKey = 'font_index';

  FontLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<int> getFontIndex() async {
    return sharedPreferences.getInt(_fontIndexKey) ?? 0;
  }

  @override
  Future<void> saveFontIndex(int index) async {
    await sharedPreferences.setInt(_fontIndexKey, index);
  }
}
