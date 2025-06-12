import 'package:creta_device_watch/features/fortune_cookie/domain/entities/fortune_cookie.dart';
import 'package:creta_device_watch/features/fortune_cookie/domain/repositories/fortune_cookie_repository.dart';

class GetFortuneCookieUseCase {
  final FortuneCookieRepository repository;

  GetFortuneCookieUseCase(this.repository);

  Future<FortuneCookie> call() {
    return repository.getFortuneCookie();
  }
}
