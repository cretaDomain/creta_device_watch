import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsDataSource {
  Future<String?> getTimeFormat();
  Future<void> setTimeFormat(String timeFormat);
  Future<String?> getThemeMode();
  Future<void> setThemeMode(String themeMode);
}

class SettingsDataSourceImpl implements SettingsDataSource {
  final SharedPreferences sharedPreferences;

  SettingsDataSourceImpl(this.sharedPreferences);

  static const _timeFormatKey = 'time_format';
  static const _themeModeKey = 'theme_mode';

  @override
  Future<String?> getTimeFormat() async {
    return sharedPreferences.getString(_timeFormatKey);
  }

  @override
  Future<void> setTimeFormat(String timeFormat) async {
    await sharedPreferences.setString(_timeFormatKey, timeFormat);
  }

  @override
  Future<String?> getThemeMode() async {
    return sharedPreferences.getString(_themeModeKey);
  }

  @override
  Future<void> setThemeMode(String themeMode) async {
    await sharedPreferences.setString(_themeModeKey, themeMode);
  }
}
