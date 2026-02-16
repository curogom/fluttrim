# Cloudflare Pages 설정 가이드 (토큰 없이 기본 운영)

이 문서는 `apps/promo_web`를 **Cloudflare 대시보드 Git 연동**으로 배포하는 기준을 설명합니다.

기본 원칙:

- 기본 배포는 Cloudflare Pages가 GitHub를 직접 빌드하도록 구성
- 이 방식은 GitHub 저장소에 Cloudflare API 토큰을 저장하지 않아도 됨

## 1) Cloudflare Pages 프로젝트 생성

Cloudflare 대시보드:

1. **Workers & Pages** 이동
2. **Create application** -> **Pages** -> GitHub 저장소 연결
3. 저장소 `curogom/fluttrim` 선택
4. 다음 값으로 빌드 설정

- 프로젝트 이름: `fluttrim` (원하는 이름 가능)
- 프로덕션 브랜치: `main`
- 프레임워크 사전 설정: `없음`
- 빌드 명령: 비워둠 (필요 시 `echo "no build"`)
- 빌드 출력 디렉터리: `apps/promo_web`
- 루트 디렉터리(고급): `/` (기본값이면 비워둬도 됨)
- 환경 변수: 없음

5. **저장 및 배포**

## 2) 배포 확인

- 초기 배포 URL 예시: `https://fluttrim.pages.dev`
- `main` 브랜치에 `apps/promo_web/**` 변경 푸시 시 Cloudflare에서 자동 재배포

## 3) GitHub Actions 워크플로와의 관계

저장소에는 선택적으로 사용할 수 있는 워크플로가 있습니다.

- 파일: `.github/workflows/promo-web-pages.yml`
- 현재: 수동 실행(`workflow_dispatch`) + 토큰/변수 설정 시에만 실제 배포

즉, 토큰을 설정하지 않으면 이 워크플로는 안내 메시지만 출력하고 배포를 수행하지 않습니다.

## 4) 선택 옵션: GitHub Actions로 배포하고 싶을 때만

아래 값은 **선택 사항**입니다. 토큰 없는 운영을 유지하려면 설정하지 않아도 됩니다.

- Secrets:
  - `CLOUDFLARE_API_TOKEN`
  - `CLOUDFLARE_ACCOUNT_ID`
- Variable:
  - `CLOUDFLARE_PAGES_PROJECT`

## 문제 해결

- 배포가 안 뜨는 경우:
  - Cloudflare Pages 프로젝트의 Git 연결 저장소/브랜치가 `curogom/fluttrim` / `main`인지 확인
  - 빌드 출력 디렉터리가 `apps/promo_web`인지 확인
- 구버전이 보이는 경우:
  - 강력 새로고침
  - Cloudflare 배포 로그에서 최신 커밋 반영 여부 확인
