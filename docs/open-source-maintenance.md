# 오픈소스 공개 범위 관리

이 문서는 공개 저장소에 포함할 콘텐츠 기준을 정의합니다.

## 공개 포함

- 제품 코드(`packages/`, `apps/`)
- 실행/배포 문서(`README`, `docs/` 내 공개 문서)
- 오픈소스 운영 파일(`LICENSE`, `CONTRIBUTING`, `SECURITY`, `CODE_OF_CONDUCT`)

## 공개 제외

- 내부 기획 초안, 프롬프트, 시안 원본
- 외부 공개 필요가 없는 운영 메모
- 개인 식별 정보 또는 내부 인프라 상세

## 현재 정책

- `fluttrim_planning_md_set/`는 공개 저장소에서 제외합니다.
- 내부 자료는 저장소 외부 경로(예: 별도 private 폴더)에 보관합니다.

## PR 전 점검

1. `git status`로 변경 파일 확인
2. 내부 문서/자산이 포함되지 않았는지 확인
3. `.github/pull_request_template.md` 체크리스트 완료
4. CI 공개 범위 가드 통과 여부 확인
