# GUI 사용자 가이드

Fluttrim 데스크톱 GUI에서 실제 정리 작업까지 빠르게 도달하기 위한 안내입니다.

## 1. 온보딩

처음 실행 시 아래를 설정합니다.

- 언어 선택(English/Korean)
- 기본 스캔 루트 선택
- 홈 폴더 바로가기 버튼으로 즉시 루트 추가 가능

## 2. Dashboard

핵심 지표와 최근 실행 상태를 확인합니다.

- `Total reclaimable`: 정리 가능 총 용량
- `Projects found`: 현재 프로파일 기준으로 감지된 프로젝트 수
- `Profile`: 현재 스캔 프로파일

권장 흐름:

1. `Scan Now`
2. 에러 배너가 있으면 권한/경로부터 확인

## 3. Projects

프로젝트 단위 정리의 메인 화면입니다.

- 검색창으로 프로젝트 필터링
- 다중 선택(일괄 정리)
- 프로젝트 상세에서 대상 체크
- `Preview Plan`으로 삭제 예정 경로/용량 확인
- `Apply`로 실제 적용

참고:

- 0B 대상은 기본 카운트/선택에서 제외됩니다.
- `packages` 하위 프로젝트는 스캔 대상에서 제외됩니다.

## 4. Xcode (macOS)

DerivedData 정리 화면입니다.

- 귀속 상태: `Attributed` / `Unknown`
- Unknown은 기본 차단
- `Allow unknown attribution cleanup`를 켜야 선택 가능
- Danger Zone 확인 후에만 Apply 가능

## 5. Flutter SDK (FVM)

FVM 상태와 버전 사용 현황을 봅니다.

- 설치 SDK 목록(최신 버전 우선 정렬)
- `Used by projects`는 명시적 FVM 설정이 있는 프로젝트 기준
- 불확실한 추정값은 사용 카운트에 포함하지 않음

## 6. Global Caches

전역 캐시 정리 화면입니다.

- 기본은 탐지/미리보기 중심
- Danger Zone 확인 없이 적용 불가
- 경로가 allowlist 범위를 벗어나면 계획 단계에서 차단

## 7. History

스캔/정리 실행 기록을 확인합니다.

- 실행 시각, 프로파일, 회수 용량
- 최근 스캔 증감
- 로그 파일 열기

## 8. Settings

기본 동작 정책을 관리합니다.

- 스캔 루트 추가/삭제
- 기본 프로파일(SAFE/MEDIUM/AGGRESSIVE)
- 삭제 모드(Trash/영구삭제)
- Unknown 귀속 허용 여부
- 언어 변경

## 권장 사용자 흐름

1. `Settings`에서 루트/프로파일 확인
2. `Scan Now`
3. `Projects`에서 다중 선택
4. `Preview Plan`
5. 경로/용량 확인 후 `Apply`
6. `History`에서 결과 로그 확인
