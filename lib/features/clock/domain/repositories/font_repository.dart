abstract class FontRepository {
  Future<int> getFontIndex();
  Future<void> saveFontIndex(int index);
}
