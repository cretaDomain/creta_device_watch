# 날씨 기능 요구사항

## 1. 개발 환경
- 날씨 기능은 `feature/weather` 라는 새로운 브랜치에서 작업해야 합니다.

## 2. 코드 구조
- 날씨 기능은 기존 소스 코드에 미치는 영향을 최소화해야 합니다.
- 새로운 클래스는 새로운 파일에 작성하는 것을 원칙으로 합니다.
- Clean Architecture를 준수하여 `lib/features/weather` 경로 하위에 `data`, `domain`, `presentation` 레이어로 구현합니다.

## 3. 날씨 API
- 무료 날씨 API를 사용해야 합니다.
- API 키는 소스 코드에 직접 포함하지 않고 별도의 파일로 관리해야 합니다.

## 4. 위치 정보
- 날씨 정보를 가져오기 위한 위치는 사용자가 직접 도시 이름을 영어로 입력합니다. (예: Tokyo, New York)
- 앱 초기 실행 시 또는 설정 메뉴를 통해 도시를 입력받는 UI가 필요합니다.
- 만약 사용자가 도시를 지정하지 않으면, 기본값으로 'Seoul'을 사용합니다.

## 5. 데이터 갱신
- 날씨 정보는 앱이 처음 시작될 때 한 번 가져옵니다.
- 이후 매 1시간마다 자동으로 갱신되어야 합니다.
- 데이터 갱신 시, 1분 동안 전체 화면으로 날씨 정보가 표시된 후 다시 시계 화면으로 돌아갑니다.

## 6. 표시 정보
- 현재 온도 (℃)
- 기상 상태 (예: 맑음, 흐림, 비, 눈 등)
- 오늘 최고/최저 기온
- 강수량
- 풍향 및 풍속

## 7. UI/UX
- 평상시에는 현재 시계 화면의 배경으로 날씨 상태에 맞는 동영상이 재생됩니다.
- 동영상 위에 현재 온도, 풍향, 풍속이 작게 표시됩니다.
- 날씨 갱신 시(매시 정각), 시계 화면이 사라지고 1분 동안 날씨 정보(전체 화면)가 표시됩니다.

## 8. 날씨 상태에 따른 배경 동영상
- 아래의 기상 상태에 맞는 동영상 파일이 `assets/videos/` 폴더에 준비되어야 합니다. 파일명은 영문 소문자로 통일합니다.
  - `clear.mp4` (맑음)
  - `clouds.mp4` (구름)
  - `rain.mp4` (비)
  - `snow.mp4` (눈)
  - `drizzle.mp4` (이슬비)
  - `thunderstorm.mp4` (뇌우)
  - `mist.mp4` (안개/옅은 안개)
  - `atmosphere.mp4` (황사, 화산재 등)

## 9. 인포그래픽
- 날씨 정보는 최대한 인포그래픽 형태로 표시해야 합니다.
- 예:
  - 풍향: 텍스트(NW, SE) 대신 풍향계 아이콘으로 표시
  - 강수량: 숫자와 함께 물방울 아이콘의 크기를 조절하여 시각적으로 표현
  - 기상 상태: 텍스트(Clear, Rain)와 함께 의미에 맞는 아이콘(☀️, 🌧️)을 표시 