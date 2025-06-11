# '역사 속 오늘' 기능 개발 체크리스트

- [ ] **1. API 연동 및 모델링**
    - [ ] `http` 또는 `dio` 패키지를 `pubspec.yaml`에 추가합니다.
    - [ ] Wikimedia API 응답 구조를 분석하고 `HistoricalEventDto`를 정의합니다.
- [ ] **2. Domain Layer 구현**
    - [ ] `HistoricalEvent` 엔티티와 `HistoryRepository` 인터페이스를 정의합니다.
    - [ ] `GetHistoricalEventsUseCase`를 작성합니다.
- [ ] **3. Data Layer 구현**
    - [ ] `HistoryRemoteDataSource`를 작성하여 API 호출 로직을 구현합니다.
    - [ ] `HistoryRepositoryImpl`을 작성하여 데이터 소스와 도메인 계층을 연결합니다.
- [ ] **4. 의존성 주입 (DI) 설정**
    - [ ] `core/di/provider.dart`에 새로운 DataSource, Repository, UseCase를 위한 프로바이더를 추가합니다.
- [ ] **5. Presentation Layer 구현**
    - [ ] `HistoryNotifier`를 Riverpod의 `Notifier` 또는 `AsyncNotifier`로 작성하여 상태 관리를 구현합니다.
    - [ ] `HistoryEventsDialog` 위젯을 만들어 UI를 구성합니다.
- [ ] **6. 기능 통합 및 테스트**
    - [ ] `ClockPage`의 버튼 클릭 시 `HistoryEventsDialog`가 나타나도록 연결합니다.
    - [ ] 각 계층별 단위 테스트 및 위젯 테스트를 작성하여 기능의 안정성을 검증합니다. 