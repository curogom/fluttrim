# Fluttrim Promo Web

Fluttrim 홍보용 정적 랜딩 페이지입니다.

## 로컬 실행

```bash
cd apps/promo_web
python3 -m http.server 8080
```

브라우저에서 `http://localhost:8080` 접속.

## 참고

- 기본 언어 EN, KO 토글 제공
- 순수 정적 HTML/CSS/JS (프레임워크 의존성 없음)
- Cloudflare Pages 등 정적 호스팅에 바로 배포 가능
- 문서 경로: `/docs/` 및 `/docs/<slug>/` 제공 (`docs/viewer.html` 기반)
- 문서 다국어: EN/KO 토글 지원 (`?lang=en|ko`, localStorage 유지)
- 문서 콘텐츠 경로:
  - KO: `apps/promo_web/docs/content/*.md`
  - EN: `apps/promo_web/docs/content/en/*.md`
- 랜딩 내 `Open source operations kit` 섹션에서 문서 경로로 직접 연결
- 문서 원본 변경 시 `apps/promo_web/docs/content/` 사본도 함께 동기화 필요
- 로고 원본: `assets/logo.png` (원본), 서비스 적용본: `assets/logo-cropped.png`
