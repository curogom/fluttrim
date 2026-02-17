# fluttrim_core API Reference

`fluttrim_core`는 Fluttrim의 공용 비즈니스 로직 패키지입니다.

## 핵심 흐름

1. `ScanRequest` 생성
2. `ScanService.scan(...)` 실행
3. `CleanupPlanner.createPlan(...)`으로 계획 생성
4. `CleanupExecutor.execute(...)` 실행
5. `RunLogWriter`로 JSON 로그 저장

## 주요 서비스 API

### Scan

- `ScanService`
  - `scan(ScanRequest request, {CancellationToken? cancellationToken})`
  - 결과: `Stream<ScanEvent>`

핵심 모델:

- `ScanRequest`
- `ScanEvent`
- `ScanResult`
- `ProjectScanResult`
- `TargetScanResult`

### Plan

- `CleanupPlanner`
  - `createPlan({required ScanResult scan, DeleteMode deleteMode, Set<String>? targetIds, bool allowUnknown})`
  - 결과: `CleanupPlan`

핵심 모델:

- `CleanupPlan`
- `CleanupPlanItem`
- `InvalidPlanException`

### Apply

- `CleanupExecutor`
  - `execute(CleanupPlan plan, {bool allowUnknown = false, CancellationToken? cancellationToken})`
  - 결과: `Stream<CleanupEvent>`

핵심 모델:

- `CleanupEvent`
- `CleanupResult`
- `CleanupItemResult`

### Doctor

- `DoctorService`
  - `run()`
  - 결과: `Future<DoctorResult>`

핵심 모델:

- `DoctorResult`
- `CachePathStatus`
- `ToolStatus`

### FVM

- `FvmService`
  - `inspect({List<String> projectRoots = const []})`
  - `removeSdk(String sdkName, {bool force = false})`

핵심 모델:

- `FvmResult`
- `FvmInstalledSdk`
- `FvmProjectUsage`
- `FvmRemovalResult`

### Run Logs / History

- `RunLogWriter`
  - `writeScanResult(ScanResult result)`
  - `writeCleanupResult(CleanupResult result)`
- `RunHistoryService`
  - `listRuns({int limit = 100})`

핵심 모델:

- `RunHistoryEntry`
- `RunHistoryKind`

## 보조 API

- `TargetRegistry`: 타겟 정의 조회/필터
- `GlobalCachePath`, `resolveGlobalCachePaths(...)`
- `resolveXcodeDerivedDataPath(...)`
- `DerivedDataAttribution`, `attributeDerivedDataDirectory(...)`
- `CancellationToken`, `CancelledException`

## JSON 직렬화 원칙

공개 모델은 `toJson()` 또는 `toJsonValue()`를 제공하며 CLI/GUI 양쪽에서 동일한 스키마를 사용합니다.
