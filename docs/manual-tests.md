# 수동 테스트

OS별 동작 검증을 위한 스모크/수동 시나리오입니다.

## 공통 (모든 OS)

1. 테스트 워크스페이스에 Flutter 프로젝트 2개를 준비합니다.
2. `build/`, `.dart_tool/` 아래 더미 파일을 넣어 용량이 0이 아니게 합니다.
3. CLI/GUI에서 `SAFE` 스캔 실행 후 확인:
   - `pubspec.yaml` + (`.metadata` 또는 `ios/` 또는 `android/`) 조건으로 프로젝트 탐지
   - allowlist 대상만 표시
   - 기본값에서 심볼릭 링크 미추적
4. Plan 생성 후 경로/용량이 명시적으로 포함되는지 확인
5. Trash 모드 적용 후 영구삭제가 아닌 휴지통/리사이클빈 이동인지 확인
6. CLI 스모크:
   - `dart run bin/fluttrim.dart scan --root <path>`
   - `dart run bin/fluttrim.dart plan --root <path>`
   - `dart run bin/fluttrim.dart apply --root <path> --yes`
   - `dart run bin/fluttrim.dart doctor`
7. JSON 로그가 사용자 로그 경로(`~/.fluttrim/logs` 등)에 생성되는지 확인

## Desktop UI (Milestone 3)

1. `Projects` 탭에서 `Scan Now` 클릭
2. 프로젝트 목록이 채워지고 검색/정렬 가능한지 확인
3. 프로젝트 상세에서 대상 선택 -> `Preview Plan` -> `Apply`
4. 적용 시 확인 모달과 결과/로그 갱신 확인
5. 릴리즈 앱(Finder/Explorer 실행)에서 기본 스캔 루트 확인:
   - 앱 번들 경로가 아닌 사용자 홈 기반 루트(`~/Developer`, `~/dev`, `~/Projects` 등)로 초기화되는지
   - 필요 시 `Settings -> Scan Roots`에서 추가/삭제 후 즉시 반영되는지

## Xcode DerivedData (macOS)

1. `Xcode` 탭에서 `Refresh` 클릭
2. 각 DerivedData 항목의 귀속 상태 확인:
   - `Attributed` / `Unknown`
   - 가능한 경우 confidence/evidence 표시
3. `Allow unknown attribution cleanup`가 꺼져 있을 때 Unknown 항목 비활성 확인
4. Danger Zone 활성화 후 `Preview Plan` -> `Apply`
5. 선택/허용된 항목만 삭제되고 로그가 남는지 확인

## Flutter SDK (FVM)

1. `Flutter SDK` 탭에서 `Refresh` 클릭
2. FVM 사용 가능 여부와 실행 경로 표시 확인
3. 설치된 SDK 목록 확인
4. 스캔 후 프로젝트 pinned-version 매핑 확인
5. `Unused SDK cleanup`에서 미사용 SDK 제거 시 확인:
   - 확인 모달 표시
   - 성공/실패 배너 표시
   - SDK 목록 자동 새로고침

## History (v1)

1. 스캔 1회, 정리 1회 이상 실행
2. `History` 탭에서 최신순 기록 표시 확인
3. 지표 확인:
   - 전체 실행 수
   - 누적 회수 용량
   - 최근 스캔 증감량
4. 항목의 열기 버튼으로 JSON 로그 접근 확인
5. 필터 동작 확인:
   - 유형 칩(`Scan` / `Cleanup`)
   - 프로파일(`safe/medium/aggressive/all`)
   - 기간(`7/30/90일/전체`)

## macOS

- Trash 동작 검증
- Xcode DerivedData 귀속/Unknown 기본 차단 검증

## Windows 10/11

- Recycle Bin 동작 검증

## Ubuntu (Linux)

- freedesktop.org trash 동작 또는 폴백 규칙 검증
