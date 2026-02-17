# 기여 가이드

Fluttrim에 기여해 주셔서 감사합니다.

## 시작 전 확인

- 버그/회귀/기능 제안은 먼저 이슈로 공유해 주세요.
- 변경 범위는 Flutter 관련 캐시/아티팩트에 집중해 주세요.
- 큰 구조 변경은 구현 전에 합의가 필요합니다.

## 개발 환경

- Core: `cd packages/core && dart test`
- CLI: `cd apps/cli && dart run bin/fluttrim.dart --help`
- Desktop: `cd apps/desktop && flutter run`
- Promo web: `cd apps/promo_web && python3 -m http.server 8080`

## PR 규칙

- PR 하나당 기능/수정 하나를 원칙으로 합니다.
- 코드 변경 시 테스트/문서 업데이트를 함께 포함해 주세요.
- CLI/GUI는 얇게 유지하고, 비즈니스 로직은 `packages/core`에 둡니다.
- 안전 규칙(allowlist + containment + preview-before-apply)을 깨지 않아야 합니다.
- 파괴적 동작은 반드시 명시적 확인 흐름을 유지해야 합니다.

## 커밋 메시지 예시

- `feat(core): scan 필터 추가`
- `fix(desktop): unknown attribution 정리 차단 보강`
- `docs: 수동 테스트 문서 갱신`

## 리뷰 체크리스트

- [ ] `dart analyze` / `flutter analyze` 통과
- [ ] 변경 범위의 테스트 통과
- [ ] Flutter 캐시 범위를 벗어난 스코프 확장 없음
- [ ] UI 문자열 변경 시 EN/KO i18n 반영
- [ ] 내부 전용 문서/자산이 PR에 포함되지 않음
