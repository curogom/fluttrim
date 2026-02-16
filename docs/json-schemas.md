# JSON 스키마

이 프로젝트는 스캔/플랜/정리 결과를 기계 처리 가능한 JSON으로 출력합니다.

## ScanResult

`packages/core` 모델: `ScanResult.toJson()`

```json
{
  "startedAt": "2026-02-16T01:43:12.123Z",
  "finishedAt": "2026-02-16T01:43:20.456Z",
  "profile": "safe",
  "cancelled": false,
  "projects": [
    {
      "name": "my_app",
      "rootPath": "/Users/me/Projects/my_app",
      "totalBytes": 123456,
      "targets": [
        {
          "targetId": "project.build",
          "category": "project",
          "risk": "low",
          "path": "/Users/me/Projects/my_app/build",
          "exists": true,
          "sizeBytes": 123456,
          "error": null
        }
      ]
    }
  ],
  "xcodeTargets": [
    {
      "targetId": "xcode.derived_data",
      "category": "xcode",
      "risk": "high",
      "path": "/Users/me/Library/Developer/Xcode/DerivedData/MyApp-abc",
      "exists": true,
      "sizeBytes": 987654321,
      "attributionStatus": "attributed",
      "attributedProjectRootPath": "/Users/me/Projects/my_app",
      "attributionConfidence": 0.95,
      "attributionEvidencePath": "/Users/me/Projects/my_app/ios/Runner.xcworkspace",
      "error": null
    }
  ],
  "totalsByCategory": {
    "project": 123456,
    "xcode": 987654321,
    "fvm": 0,
    "global": 0
  },
  "totalBytes": 987777777
}
```

설명:

- `profile`: `safe|medium|aggressive`
- `category`: `project|xcode|fvm|global`
- `risk`: `low|medium|high`
- `attributionStatus`: `none|attributed|unknown`

## CleanupPlan

`packages/core` 모델: `CleanupPlan.toJson()`

```json
{
  "createdAt": "2026-02-16T01:44:00.000Z",
  "profile": "safe",
  "deleteMode": "trash",
  "warnings": [],
  "items": [
    {
      "targetId": "project.build",
      "category": "project",
      "risk": "low",
      "path": "/Users/me/Projects/my_app/build",
      "sizeBytes": 123456,
      "attributionStatus": "none",
      "attributedProjectRootPath": null,
      "attributionConfidence": null,
      "attributionEvidencePath": null,
      "projectRootPath": "/Users/me/Projects/my_app"
    }
  ],
  "totalBytes": 123456
}
```

설명:

- `deleteMode`: `trash|permanent`

## CleanupResult

`packages/core` 모델: `CleanupResult.toJson()`

```json
{
  "startedAt": "2026-02-16T01:45:00.000Z",
  "finishedAt": "2026-02-16T01:45:05.000Z",
  "profile": "safe",
  "deleteMode": "trash",
  "allowUnknown": false,
  "items": [
    {
      "targetId": "project.build",
      "path": "/Users/me/Projects/my_app/build",
      "status": "success",
      "reclaimedBytes": 123456,
      "error": null
    },
    {
      "targetId": "project.dart_tool",
      "path": "/Users/me/Projects/my_app/.dart_tool",
      "status": "failed",
      "reclaimedBytes": 0,
      "error": "TrashOperationException: ..."
    }
  ],
  "reclaimedBytes": 123456,
  "successCount": 1,
  "failureCount": 1,
  "skippedCount": 0
}
```

설명:

- `status`: `success|failed|skipped`

CLI/GUI 일관성을 위해 스키마 호환성을 유지해야 합니다.
