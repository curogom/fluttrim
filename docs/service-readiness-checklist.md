# 서비스 공개 체크업 (MVP)

기준일: 2026-02-17

## 완료

- 커스텀 도메인 서빙: `https://fluttrim.curogom.dev`
- 웹 메타데이터 기본 세트
  - canonical
  - Open Graph / Twitter 카드 이미지
  - favicon (`ico/png`)
  - `site.webmanifest`
  - `robots.txt`, `sitemap.xml`
- 브랜드 로고 반영
  - Promo 웹 로고/파비콘
  - macOS/Windows 데스크톱 앱 아이콘
- 오픈소스 운영 문서 세트
  - `LICENSE`, `CONTRIBUTING`, `CODE_OF_CONDUCT`, `SECURITY`
  - `SUPPORT`, `GOVERNANCE`, `MAINTAINERS`, `ROADMAP`
- CI 기본 검증
  - core/cli/analyze/test/build/dry-run

## 보완 권장

- Linux 앱 아이콘(창 아이콘/데스크톱 엔트리) 명시 반영
- 다운로드 배포 동선 확정
  - GitHub Releases / GitHub Packages 중 기준 결정
  - Promo 웹 다운로드 링크 연결
- 실제 문의 수집을 시작할 경우 개인정보 처리방침 문서 추가
- 릴리즈 노트 템플릿(버전별 변경 내역)을 운영 루틴에 고정
