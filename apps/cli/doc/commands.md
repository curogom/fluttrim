# fluttrim CLI Command Reference

이 문서는 `fluttrim_cli` 명령어 사용법을 정리합니다.

## 실행 방식

- 로컬(레포 내): `dart run bin/fluttrim.dart <command> [options]`
- 전역(pub.dev 설치 후): `fluttrim <command> [options]`

## 전역 공통 옵션

- `-h, --help`: 도움말 출력
- `--version`: CLI 버전 출력

## `scan`

Flutter 프로젝트를 탐지하고 캐시/아티팩트 용량을 계산합니다.

```bash
fluttrim scan [options]
```

주요 옵션:

- `-r, --root <path>`: 스캔 루트(반복 가능)
- `--profile <safe|medium|aggressive>`: 스캔 프로파일 (기본: `safe`)
- `--exclude <pattern>`: 제외 패턴(반복 가능)
- `--max-depth <n>`: 루트 기준 탐색 깊이 (기본: `5`)
- `--include-global`: 글로벌 캐시 포함 여부 (기본: `false`)
- `--json`: JSON 출력

예시:

```bash
fluttrim scan --root ~/dev --profile safe
fluttrim scan --root ~/dev --include-global --json
```

## `plan`

삭제 없이 정리 계획만 생성합니다.

```bash
fluttrim plan [options]
```

`scan` 옵션 + 추가 옵션:

- `--trash`: 삭제 모드를 휴지통으로 설정 (기본)
- `--permanent`: 삭제 모드를 영구 삭제로 설정
- `--allow-unknown`: 귀속 불명(unknown attribution) 대상 포함
- `--json`: JSON 출력

예시:

```bash
fluttrim plan --root ~/dev --profile medium
fluttrim plan --root ~/dev --profile safe --json
```

## `apply`

정리 계획을 실행합니다.

```bash
fluttrim apply [options]
```

주요 옵션:

- `-r, --root <path>`: 스캔 루트(반복 가능)
- `--profile <safe|medium|aggressive>`: 프로파일 (기본: `safe`)
- `--exclude <pattern>`: 제외 패턴(반복 가능)
- `--max-depth <n>`: 탐색 깊이 (기본: `5`)
- `--include-global`: 글로벌 캐시 포함 여부
- `-y, --yes`: 확인 프롬프트 생략
- `--trash`: 휴지통 모드 (기본)
- `--permanent`: 영구 삭제 모드 (`--yes` 필수)
- `--allow-unknown`: 귀속 불명 대상 허용
- `--json`: JSON 출력

주의:

- `--permanent`는 `--yes` 없이 실행할 수 없습니다.
- 기본값은 안전한 동작을 위해 `--trash` + unknown 차단입니다.

예시:

```bash
fluttrim apply --root ~/dev --profile safe --yes
fluttrim apply --root ~/dev --profile aggressive --permanent --yes
fluttrim apply --root ~/dev --profile safe --json --yes
```

## `doctor`

OS, 도구 설치 상태, 캐시 경로 존재 여부를 출력합니다.

```bash
fluttrim doctor [options]
```

옵션:

- `--json`: JSON 출력

예시:

```bash
fluttrim doctor
fluttrim doctor --json
```

## 종료 코드

- `0`: 성공
- `1`: 실행 중 예외/실패
- `64`: 잘못된 인자/형식 오류
- `130`: 사용자 취소(SIGINT 등)
