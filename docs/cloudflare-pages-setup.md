# Cloudflare Pages 설정 가이드 (Promo Web)

이 문서는 `apps/promo_web`를 GitHub Actions 워크플로로 배포하는 절차를 설명합니다.

- 워크플로 파일: `.github/workflows/promo-web-pages.yml`

## 1) Cloudflare Pages 프로젝트 생성

Cloudflare 대시보드에서:

1. **Workers & Pages** 이동
2. **Create application** -> **Pages** -> **Direct Upload** 선택
3. 프로젝트 이름 생성 (예: `fluttrim-site`)
4. 생성만 완료하면 되고, 초기 수동 업로드는 선택 사항

이 프로젝트 이름을 GitHub 변수 `CLOUDFLARE_PAGES_PROJECT`에 사용합니다.

## 2) API 토큰 생성

Cloudflare 대시보드에서:

1. **My Profile** -> **API Tokens** -> **Create Token**
2. 템플릿 **Edit Cloudflare Workers**(또는 커스텀 토큰) 선택
3. 최소 필요 권한
   - Account: `Cloudflare Pages:Edit`
4. Pages 프로젝트가 속한 계정 범위로 제한
5. 토큰 생성 후 값 복사

## 3) Account ID 확인

- Cloudflare 계정 홈에서 **Account ID** 복사

## 4) GitHub 저장소 시크릿/변수 설정

저장소: `curogom/fluttrim`

**Settings -> Secrets and variables -> Actions**에서 설정:

Secrets:

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

Variable:

- `CLOUDFLARE_PAGES_PROJECT`

## 5) 배포 실행

### 방법 A: 수동 실행

- GitHub -> **Actions** -> **Promo Web Cloudflare Pages** -> **Run workflow**

### 방법 B: 자동 실행

아래 경로 변경이 `main`에 푸시되면 자동 배포됩니다.

- `apps/promo_web/**`
- `.github/workflows/promo-web-pages.yml`

## 6) 검증

- 워크플로 로그에서 deployment URL 확인
- URL 접속 후 EN 기본/KO 토글 동작 확인
- 필요 시 Cloudflare Pages의 **Custom domains**에서 커스텀 도메인 연결

## 문제 해결

- `Missing repository variable CLOUDFLARE_PAGES_PROJECT`
  - 저장소 변수 이름을 정확히 설정
- 인증 오류
  - 토큰 권한/계정 범위 점검
  - `CLOUDFLARE_ACCOUNT_ID`와 실제 Pages 프로젝트 계정 일치 여부 점검
- 배포 성공 후 구버전 노출
  - 강력 새로고침 및 CDN 전파 시간 확인
