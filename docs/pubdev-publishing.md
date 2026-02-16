# pub.dev 공개 전략

이 문서는 Fluttrim 모노레포에서 pub.dev에 공개할 패키지 범위와 절차를 정의합니다.

## 공개 대상(1차)

- 1순위: `packages/core` (`fluttrim_core`)
- 보류: `apps/cli` (`fluttrim_cli`)
  - 현재 `path` 의존성(`../../packages/core`) 구조라 pub.dev 공개 대상이 아님
  - 향후 CLI를 공개하려면 `fluttrim_core`의 hosted dependency 전환 + executable 패키지 정책 정리 필요

## 원칙

- 비즈니스 로직은 `fluttrim_core`에서만 공개
- Desktop 앱/내부 운영 문서는 pub.dev 범위에서 제외
- 토큰/자격 증명은 로컬 환경에서만 사용하고 저장소에는 저장하지 않음

## `fluttrim_core` 배포 체크리스트

1. 버전/체인지로그 갱신
   - `packages/core/pubspec.yaml`
   - `packages/core/CHANGELOG.md`
2. 정적 검증
   - `cd packages/core`
   - `dart format --output=none --set-exit-if-changed .`
   - `dart analyze`
   - `dart test`
3. 공개 검증
   - `dart pub publish --dry-run`
4. 실제 배포(로컬에서만 실행)
   - `dart pub publish`

## CI 보증

- `.github/workflows/ci.yml`의 `core-pub-dry-run` 잡이 항상 `dart pub publish --dry-run`을 검증
- 메타데이터/라이선스 누락 시 PR 단계에서 실패하도록 구성

## 권장 릴리즈 순서

1. `fluttrim_core`를 먼저 pub.dev에 공개
2. CLI는 `fluttrim_core` 공개 안정화 후 별도 패키지로 재구성해 공개 여부 결정
