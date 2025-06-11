import 'dart:async';

abstract class TimeDataSource {
  Stream<DateTime> getTimeStream();
}

class TimeDataSourceImpl implements TimeDataSource {
  @override
  Stream<DateTime> getTimeStream() {
    return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }
}
