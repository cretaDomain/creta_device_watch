# '오늘, 역사 속 오늘' 기능 요구사항 정의

## 1. 기능 개요
- **목표**: 디지털 시계 앱 사용자에게 현재 날짜를 기준으로 과거에 발생했던 주요 역사적 사건 정보를 이미지와 함께 제공하여 교육적 가치와 재미를 더합니다.
- **트리거**: 메인 시계 화면의 날짜 표시 옆에 있는 '역사(history)' 아이콘 버튼을 클릭하면 기능이 활성화됩니다.

## 2. 사용자 인터페이스 (UI/UX)
- **화면 형태**: 모달 다이얼로그(Modal Dialog) 형태로 현재 화면 위에 표시되어 사용자가 쉽고 빠르게 정보를 확인하고 원래 화면으로 돌아갈 수 있도록 합니다.
- **콘텐츠 구성**:
    - **제목**: "O월 O일, 역사 속 오늘"과 같이 현재 날짜를 명확히 표시합니다.
    - **사건 목록**:
        - 해당 날짜에 발생한 역사적 사건들을 시간 순(오래된 순)으로 나열합니다.
        - 각 항목은 `발생 연도`, `사건 설명`, `관련 이미지`로 구성됩니다.
        - 목록은 수직으로 스크롤이 가능해야 합니다.
    - **이미지 처리**:
        - 이미지가 없는 사건의 경우, 기본 아이콘(예: `history_edu`)을 표시합니다.
        - 이미지를 불러오는 동안에는 로딩 인디케이터(placeholder)를 보여줍니다.
- **상태 처리**:
    - **로딩**: API로부터 데이터를 불러오는 동안 로딩 스피너를 표시합니다.
    - **오류**: 데이터 로딩에 실패할 경우, "정보를 불러오는 데 실패했습니다. 다시 시도해주세요."와 같은 오류 메시지와 '다시 시도' 버튼을 제공합니다.
    - **데이터 없음**: 해당 날짜에 대한 데이터가 없을 경우, "해당 날짜의 역사적 사건 정보가 없습니다."라는 메시지를 표시합니다.
- **상호작용**:
    - 다이얼로그 외부를 클릭하거나 '닫기' 버튼을 누르면 다이얼로그가 닫힙니다.

## 3. 데이터 소스 (API)
- **API**: Wikimedia의 "On this day" 피드 API를 사용합니다.
- **Endpoint**: `https://api.wikimedia.org/feed/v1/wikipedia/{language}/onthisday/all/{MM}/{DD}`
    - `language`: `ko` (한국어)를 사용하여 한국 중심의 데이터를 우선적으로 가져옵니다.
    - `MM`: 월 (01-12)
    - `DD`: 일 (01-31)
- **주요 응답 데이터**:
    - `events`: 역사적 사건 목록
        - `text`: 사건 설명 (예: "1950년 - 한국 전쟁 발발")
        - `year`: 발생 연도
        - `pages`: 관련 위키피디아 페이지 정보
            - `thumbnail.source`: 대표 이미지 URL

## 4. 기술 구현 계획 (Clean Architecture 기반)
- ### Domain Layer
    - **Entity**: `HistoricalEvent`
        - `year` (int): 발생 연도
        - `text` (String): 사건 설명
        - `imageUrl` (String?): 관련 이미지 URL (nullable)
    - **Repository**: `HistoryRepository` (Interface)
        - `Future<List<HistoricalEvent>> getHistoricalEvents(int month, int day);`
    - **UseCase**: `GetHistoricalEventsUseCase`
        - `HistoryRepository`를 사용하여 데이터를 가져오는 비즈니스 로직을 캡슐화합니다.

- ### Data Layer
    - **DataSource**: `HistoryRemoteDataSource`
        - `dio` 또는 `http` 패키지를 사용하여 Wikimedia API를 호출하고 JSON 데이터를 받아옵니다.
    - **Repository Impl**: `HistoryRepositoryImpl`
        - `HistoryRepository` 인터페이스의 구현체입니다.
        - API로부터 받은 데이터를 `HistoricalEvent` 엔티티 객체로 변환(mapping)하는 역할을 담당합니다.
        - API 호출 중 발생할 수 있는 예외(네트워크 오류 등)를 처리합니다.
    - **Model**: `HistoricalEventDto`
        - API의 JSON 응답 구조에 맞춰 데이터를 파싱하기 위한 DTO(Data Transfer Object) 클래스입니다. `copyWith`, `fromJson`, `toJson` 메서드를 포함합니다.

- ### Presentation Layer (MVVM with Riverpod)
    - **Notifier/Provider**: `HistoryNotifier` (Riverpod)
        - `GetHistoricalEventsUseCase`를 사용하여 데이터를 비동기적으로 가져옵니다.
        - UI에 필요한 상태(로딩, 데이터, 오류)를 관리하고 노출합니다. (예: `AsyncValue<List<HistoricalEvent>>`)
        - 날짜가 변경되거나 '다시 시도' 시 데이터를 다시 불러오는 로직을 포함합니다.
    - **View**: `HistoryEventsDialog`
        - `ConsumerWidget` 또는 `ConsumerStatefulWidget`으로 구현합니다.
        - `HistoryNotifier`를 `watch`하여 상태 변화에 따라 UI를 갱신합니다.
        - 로딩, 오류, 데이터 표시 등 각 상태에 맞는 UI를 렌더링합니다.
    - **통합**: `ClockPage`
        - 'history' `IconButton`의 `onPressed` 콜백에서 `showDialog`를 호출하여 `HistoryEventsDialog`를 띄웁니다.

## 5. 개발 단계 (Task Breakdown)
1. **API 연동 및 모델링**:
    - `http` 또는 `dio` 패키지를 `pubspec.yaml`에 추가합니다.
    - Wikimedia API 응답 구조를 분석하고 `HistoricalEventDto`를 정의합니다.
2. **Data Layer 구현**:
    - `HistoryRemoteDataSource`를 작성하여 API 호출 로직을 구현합니다.
    - `HistoryRepositoryImpl`을 작성하여 데이터 소스와 도메인 계층을 연결합니다.
3. **Domain Layer 구현**:
    - `HistoricalEvent` 엔티티와 `HistoryRepository` 인터페이스를 정의합니다.
    - `GetHistoricalEventsUseCase`를 작성합니다.
4. **DI 설정**:
    - `core/di/provider.dart`에 새로운 DataSource, Repository, UseCase를 위한 프로바이더를 추가합니다.
5. **Presentation Layer 구현**:
    - `HistoryNotifier`를 Riverpod의 `Notifier` 또는 `AsyncNotifier`로 작성하여 상태 관리를 구현합니다.
    - `HistoryEventsDialog` 위젯을 만들어 UI를 구성합니다.
6. **기능 통합 및 테스트**:
    - `ClockPage`의 버튼 클릭 시 `HistoryEventsDialog`가 나타나도록 연결합니다.
    - 각 계층별 단위 테스트 및 위젯 테스트를 작성하여 기능의 안정성을 검증합니다. 