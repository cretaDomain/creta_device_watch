import 'package:creta_device_watch/features/fortune_cookie/data/datasources/fortune_cookie_remote_data_source.dart';
import 'package:creta_device_watch/features/fortune_cookie/domain/entities/fortune_cookie.dart';
import 'package:creta_device_watch/features/fortune_cookie/domain/repositories/fortune_cookie_repository.dart';

class FortuneCookieRepositoryImpl implements FortuneCookieRepository {
  final FortuneCookieRemoteDataSource remoteDataSource;

  FortuneCookieRepositoryImpl({required this.remoteDataSource});

  @override
  Future<FortuneCookie> getFortuneCookie() async {
    try {
      final message = await remoteDataSource.getFortuneCookieMessage();
      return FortuneCookie(message: message);
    } catch (e) {
      // It's good practice to catch specific exceptions and re-throw
      // them as domain-specific exceptions, but for now, we'll re-throw.
      rethrow;
    }
  }
}
