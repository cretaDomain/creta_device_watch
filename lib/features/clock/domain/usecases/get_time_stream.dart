import 'package:creta_device_watch/features/clock/domain/repositories/time_repository.dart';

class GetTimeStream {
  final TimeRepository repository;

  GetTimeStream(this.repository);

  Stream<DateTime> call() {
    return repository.getTimeStream().asBroadcastStream();
  }
}
