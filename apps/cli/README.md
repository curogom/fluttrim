# fluttrim_cli

`fluttrim_core`를 호출하는 얇은 CLI 래퍼입니다.

## 사용법

```bash
dart run bin/fluttrim.dart --help
```

명령어:

- `scan` : Flutter 프로젝트 탐지 및 캐시 용량 계산
- `plan` : 정리 계획 생성(미리보기)
- `apply` : 정리 계획 실행
- `doctor` : OS/도구/캐시 경로 진단 출력

예시:

```bash
dart run bin/fluttrim.dart scan --root ~/Projects --profile safe
dart run bin/fluttrim.dart plan --root ~/Projects --profile medium
dart run bin/fluttrim.dart apply --root ~/Projects --profile safe --yes
dart run bin/fluttrim.dart doctor
```
