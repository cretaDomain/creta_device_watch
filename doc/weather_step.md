# 날씨 기능 개발 단계

## 1단계: 개발 환경 설정 및 의존성 추가
1.  `feature/weather` Git 브랜치를 생성합니다.
2.  `pubspec.yaml` 파일에 날씨 API 통신을 위한 `http` 패키지와 동영상 배경 재생을 위한 `video_player` 패키지를 추가합니다.
3.  `lib/features/weather` 경로에 `data`, `domain`, `presentation` 디렉토리를 생성하여 날씨 기능의 기본 구조를 설정합니다.

## 2단계: 도메인 계층(Domain Layer) 구현 및 테스트
1.  날씨 데이터 구조를 정의하는 `Weather` 엔티티를 생성합니다.
2.  데이터 소스와 도메인을 분리하는 `WeatherRepository` 추상 클래스(인터페이스)를 정의합니다.
3.  도시 이름을 받아 날씨 정보를 가져오는 `GetWeather` 유스케이스를 구현합니다.
4.  `GetWeather` 유스케이스에 대한 단위 테스트를 작성하고 실행합니다.

## 3단계: 데이터 계층(Data Layer) 구현 - Part 1 (Remote Source) 및 테스트
1.  무료 날씨 API (OpenWeatherMap)를 사용하여 `WeatherRemoteDataSource`를 구현합니다. 이 부분에서 API 통신을 직접 담당합니다.
2.  API 응답(JSON)을 Dart 객체로 변환하는 `WeatherModel`을 생성합니다.
3.  `WeatherRemoteDataSource`에 대한 단위 테스트를 작성하고 실행합니다. (API 키가 필요하며, 안전한 곳에 보관하도록 안내해 드리겠습니다.)

## 4단계: 데이터 계층(Data Layer) 구현 - Part 2 (Repository) 및 테스트
1.  2단계에서 정의한 `WeatherRepository` 인터페이스의 구현체인 `WeatherRepositoryImpl`을 생성합니다. 이 클래스는 `WeatherRemoteDataSource`를 사용하여 실제 데이터를 가져옵니다.
2.  `WeatherRepositoryImpl`에 대한 단위 테스트를 작성하고 실행합니다.

## 5단계: 프레젠테이션 계층(Presentation Layer) 구현 - Part 1 (상태 관리)
1.  Riverpod를 사용하여 `WeatherNotifier`를 구현합니다. 이 Notifier는 UI 상태를 관리하고, `GetWeather` 유스케이스를 호출하여 날씨 정보를 가져옵니다.
2.  앱 시작 시 및 1시간마다 날씨를 갱신하는 로직을 `WeatherNotifier`에 포함시킵니다.
3.  도시 이름을 입력받고 저장하는 로직을 추가합니다.

## 6단계: 프레젠테이션 계층(Presentation Layer) 구현 - Part 2 (UI)
1.  사용자가 도시 이름을 입력할 수 있는 다이얼로그 UI를 구현합니다.
2.  날씨 상태에 따라 적절한 배경 동영상을 재생하고, 그 위에 현재 온도, 풍향, 풍속을 표시하는 `WeatherWidget`을 구현합니다.
3.  기존 `ClockPage`에 `WeatherWidget`을 통합하여 시계 화면 배경으로 날씨 영상이 보이도록 수정합니다.

## 7단계: 전체 기능 통합 및 최종 테스트
1.  매시간 날씨가 갱신될 때, 1분간 전체 화면으로 날씨 정보가 표시되는 기능을 구현합니다.
2.  `assets/videos/` 폴더를 생성하고 `pubspec.yaml`에 비디오 애셋을 등록합니다.
3.  전체 기능에 대한 통합 테스트 및 UI 테스트를 진행하여 요구사항대로 잘 동작하는지 최종 확인합니다. 