# pub.dev 공개 전략

이 문서는 Fluttrim 모노레포에서 pub.dev에 공개할 패키지 범위와 절차를 정의합니다.

## 공개 대상

- `packages/core` (`fluttrim_core`)
- `apps/cli` (`fluttrim_cli`)

## 원칙

- 비즈니스 로직은 `fluttrim_core`에서만 유지
- Desktop 앱/내부 운영 문서는 pub.dev 범위에서 제외
- 토큰/자격 증명은 로컬 환경에서만 사용하고 저장소에는 저장하지 않음

## `fluttrim_core` 배포 체크리스트

1. 버전/체인지로그 갱신
   - `packages/core/pubspec.yaml`
   - `packages/core/CHANGELOG.md`
   - 메타데이터 확인: `homepage=https://fluttrim.curogom.dev`
   - API 문서 확인: `packages/core/doc/api-reference.md`, public API dartdoc
2. 정적 검증
   - `cd packages/core`
   - `dart format --output=none --set-exit-if-changed .`
   - `dart analyze`
   - `dart test`
3. 공개 검증
   - `dart pub publish --dry-run`
4. 실제 배포(로컬에서만 실행)
   - `dart pub publish`

## `fluttrim_cli` 배포 체크리스트

1. 버전/체인지로그 갱신
   - `apps/cli/pubspec.yaml`
   - `apps/cli/CHANGELOG.md`
   - `executables.fluttrim` 설정 확인
   - 명령어 문서 확인: `apps/cli/doc/commands.md`
2. 의존성 확인
   - `fluttrim_core`를 hosted dependency로 지정
3. 정적 검증
   - `cd apps/cli`
   - `dart format --output=none --set-exit-if-changed .`
   - `dart analyze`
4. 공개 검증
   - `dart pub publish --dry-run`
5. 실제 배포(로컬에서만 실행)
   - `dart pub publish`

## CI 보증

- `.github/workflows/ci.yml`의 `core-pub-dry-run`, `cli-pub-dry-run` 잡이 `dart pub publish --dry-run`을 검증
- 메타데이터/라이선스 누락 시 PR 단계에서 실패하도록 구성

## 권장 릴리즈 순서

1. `fluttrim_core`를 먼저 pub.dev에 공개
2. `fluttrim_cli`를 공개하고 설치 안내(`dart pub global activate fluttrim_cli`)를 릴리즈 노트에 포함
