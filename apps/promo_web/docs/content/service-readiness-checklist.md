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
- GitHub Packages 배포 정책/범위 확정(필요 시)
- 대기자 이메일 수집 기능은 현재 비활성화(TODO)
  - 개인정보 처리방침 + 수집/보관 백엔드 준비 후 재개
- 릴리즈 노트 템플릿(버전별 변경 내역)을 운영 루틴에 고정
