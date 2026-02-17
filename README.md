# fluttrim

Fluttrim은 Flutter 개발 환경에서 발생하는 캐시/아티팩트를 안전하게 점검하고 정리하는 크로스플랫폼 도구입니다.

## 구성

- `packages/core`: 순수 Dart 비즈니스 로직(스캔/플랜/적용/안전 규칙)
- `apps/cli`: `packages/core`를 호출하는 CLI
- `apps/desktop`: `packages/core`를 호출하는 Flutter 데스크톱 GUI
- `apps/promo_web`: 홍보용 정적 랜딩 페이지(기본 EN + KO 토글)

범위는 Flutter 관련 캐시/아티팩트로 한정하며, 범용 시스템 클리너 기능은 포함하지 않습니다.

## 라이선스

MIT (`LICENSE`)

## 개발 실행

- Core: `cd packages/core && dart test`
- CLI: `cd apps/cli && dart run bin/fluttrim.dart --help`
- Desktop: `cd apps/desktop && flutter run`
- Promo web: `cd apps/promo_web && python3 -m http.server 8080`

## 배포

- 데스크톱 아티팩트(macOS/Windows/Linux): GitHub Actions `Desktop Release`
  - `.github/workflows/desktop-release.yml`
- Promo 웹(Cloudflare Pages): **Cloudflare 대시보드 Git 연동 배포(기본, 토큰 불필요)**
  - Cloudflare Pages 프로젝트에서 `curogom/fluttrim` 저장소를 연결하고 `apps/promo_web`를 정적 출력 디렉터리로 사용

## Cloudflare Pages 설정

Cloudflare 대시보드 Git 연동 방식으로 운영합니다. GitHub Secrets/토큰 설정은 필요하지 않습니다.

상세 가이드: `docs/cloudflare-pages-setup.md`

## 공개 준비 체크

- 서비스 공개 체크업: `docs/service-readiness-checklist.md`

## pub.dev 공개 계획

- 1차 공개 대상은 `fluttrim_core` 패키지입니다.
- 공개 절차/체크리스트: `docs/pubdev-publishing.md`

## 오픈소스 운영 문서

- 기여 가이드: `CONTRIBUTING.md`
- 행동 강령: `CODE_OF_CONDUCT.md`
- 보안 제보 정책: `SECURITY.md`
- 지원 정책: `SUPPORT.md`
- 거버넌스: `GOVERNANCE.md`
- 메인테이너 정보: `MAINTAINERS.md`
- 공개 로드맵: `ROADMAP.md`

## 공개 범위 원칙

- 외부 공개가 불필요한 내부 기획/시안 문서는 공개 저장소에 포함하지 않습니다.
- PR 전 공개 범위 점검 기준은 `docs/open-source-maintenance.md`를 따릅니다.
