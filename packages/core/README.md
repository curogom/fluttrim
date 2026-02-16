# fluttrim_core

Fluttrim의 순수 Dart 코어 라이브러리입니다.  
CLI/GUI 프런트엔드는 이 패키지를 호출해 동일한 정리 규칙을 사용합니다.

## 주요 역할

- 스캔 루트에서 Flutter 프로젝트 탐지
- 프로파일별 allowlist 캐시 대상 용량 계산
- allowlist + containment 가드 기반 정리 플랜 생성
- trash/permanent 모드 정리 실행 및 항목별 결과 보고
- doctor 진단(OS/도구/캐시 경로)
- JSON 실행 로그 기록

## 공개 API

- `ScanService.scan(ScanRequest) -> Stream<ScanEvent>`
- `CleanupPlanner.createPlan(...) -> CleanupPlan`
- `CleanupExecutor.execute(...) -> Stream<CleanupEvent>`
- `DoctorService.run() -> Future<DoctorResult>`
- `RunLogWriter.writeScanResult(...)`
- `RunLogWriter.writeCleanupResult(...)`

## 사용 예시

```dart
import 'package:fluttrim_core/fluttrim_core.dart';

Future<void> main() async {
  const request = ScanRequest(
    roots: ['/Users/you/dev'],
    profile: Profile.safe,
    includeGlobal: false,
  );

  final scanService = ScanService();
  await for (final event in scanService.scan(request)) {
    if (event.isDone) {
      final result = event.result!;
      print('projects: ${result.projects.length}');
      print('reclaimable: ${result.totalBytes} bytes');
    }
  }
}
```

## 개발 검증

```bash
dart format --output=none --set-exit-if-changed .
dart analyze
dart test
dart pub publish --dry-run
```
