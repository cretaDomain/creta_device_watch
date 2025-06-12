# 포춘 쿠키 기능 개발 체크리스트 (AI 기반)

이 문서는 AI API를 사용하여 오늘의 포춘 쿠키 메시지를 가져와 팝업으로 보여주는 기능 개발을 위한 체크리스트입니다.

## 1. 프로젝트 설정 및 의존성 추가

-   [ ] `google_generative_ai` 또는 `http` 패키지 추가: AI API 연동을 위해 `pubspec.yaml` 파일에 추가합니다.
    ```shell
    flutter pub add google_generative_ai
    flutter pub add http
    ```

## 2. API 키 관리

-   [ ] Gemini 또는 Copilot API 키 발급
-   [ ] API 키 및 기타 설정을 코드에 직접 하드코딩하지 않고, 환경 변수를 사용하여 안전하게 주입합니다.
    -   **Gemini 사용 시:**
        ```shell
        flutter run --dart-define=AI=Gemini --dart-define=GEMINI_API_KEY=YOUR_GEMINI_KEY
        ```
    -   **Copilot (Azure AI) 사용 시:**
        ```shell
        flutter run --dart-define=AI=Copilot --dart-define=COPILOT_API_KEY=YOUR_AZURE_KEY --dart-define=COPILOT_ENDPOINT=YOUR_AZURE_ENDPOINT
        ```

## 3. 기능 구현 (클린 아키텍처)

### Domain Layer

-   [ ] `FortuneCookie` 엔티티 생성: AI API로부터 받은 포춘 쿠키 메시지를 담을 데이터 모델을 정의합니다. (예: `message`)
-   [ ] `FortuneCookieRepository` 인터페이스 정의: 포춘 쿠키 데이터 소스를 추상화하는 리포지토리 인터페이스를 생성합니다.
-   [ ] `GetFortuneCookieUseCase` 유즈케이스 생성: Presentation 레이어에서 포춘 쿠키 메시지를 요청할 때 사용할 유즈케이스를 구현합니다.

### Data Layer

-   [ ] `FortuneCookieRemoteDataSource` 구현:
    -   AI API에 보낼 프롬프트를 생성합니다. (예: "오늘의 포춘 쿠키 메시지를 알려줘.")
    -   선택된 AI(`google_generative_ai` 또는 `http`) 패키지를 사용하여 AI API를 호출하고 응답을 받습니다.
-   [ ] `FortuneCookieRepositoryImpl` 구현: `FortuneCookieRepository` 인터페이스를 구현하며, `FortuneCookieRemoteDataSource`를 호출하여 데이터를 가공하고 `FortuneCookie` 엔티티로 변환합니다.

### Presentation Layer

-   [ ] `FortuneCookieNotifier` 구현 (Riverpod):
    -   `GetFortuneCookieUseCase`를 호출하여 포춘 쿠키 메시지를 가져옵니다.
    -   로딩, 데이터, 에러 상태를 관리하는 StateNotifier를 생성합니다.
-   [ ] `FortuneCookieDialog` 위젯 생성:
    -   포춘 쿠키 메시지를 표시할 팝업 다이얼로그 UI를 구현합니다.
    -   `FortuneCookieNotifier`의 상태에 따라 로딩 인디케이터, 포춘 쿠키 메시지, 또는 에러 메시지를 표시합니다.
-   [ ] 포춘 쿠키 버튼 연동 (`SettingsControls`):
    -   `SettingsControls`에 있는 버튼의 `onPressed` 콜백에서 `FortuneCookieNotifier`를 호출합니다.
    -   `showDialog`를 사용하여 `FortuneCookieDialog`를 표시합니다.