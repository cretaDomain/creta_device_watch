import 'package:creta_device_watch/features/fortune_cookie/domain/entities/fortune_cookie.dart';

abstract class FortuneCookieRepository {
  Future<FortuneCookie> getFortuneCookie();
}
