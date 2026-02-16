# fluttrim_core

Fluttrim의 순수 Dart 코어 라이브러리입니다.

## 역할

- 스캔 루트에서 Flutter 프로젝트 탐지
- 프로파일별 allowlist 캐시 대상 용량 계산
- allowlist + containment 가드 기반 정리 플랜 생성
- trash/permanent 모드 정리 실행 및 항목별 결과 보고
- doctor 진단(OS/도구/캐시 경로)
- JSON 실행 로그 기록

## 공개 API(현재)

- `ScanService.scan(ScanRequest) -> Stream<ScanEvent>`
- `CleanupPlanner.createPlan(...) -> CleanupPlan`
- `CleanupExecutor.execute(...) -> Stream<CleanupEvent>`
- `DoctorService.run() -> Future<DoctorResult>`
- `RunLogWriter.writeScanResult(...)`
- `RunLogWriter.writeCleanupResult(...)`

## 테스트

```bash
dart test
```
