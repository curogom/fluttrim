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
- Promo 웹(Cloudflare Pages): GitHub Actions `Promo Web Cloudflare Pages`
  - `.github/workflows/promo-web-pages.yml`

## Cloudflare Pages 설정

워크플로 실행 전 저장소 설정이 필요합니다.

- Secrets
  - `CLOUDFLARE_API_TOKEN`
  - `CLOUDFLARE_ACCOUNT_ID`
- Variable
  - `CLOUDFLARE_PAGES_PROJECT`

상세 가이드: `docs/cloudflare-pages-setup.md`

## 공개 범위 원칙

- 외부 공개가 불필요한 내부 기획/시안 문서는 공개 저장소에 포함하지 않습니다.
- PR 전 공개 범위 점검 기준은 `docs/open-source-maintenance.md`를 따릅니다.
