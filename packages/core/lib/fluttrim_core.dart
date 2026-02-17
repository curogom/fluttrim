/// Shared Fluttrim business logic for scan, planning, cleanup, diagnostics,
/// and machine-readable logging.
///
/// Typical flow:
/// 1. Build a [ScanRequest].
/// 2. Run [ScanService.scan].
/// 3. Build a [CleanupPlan] with [CleanupPlanner.createPlan].
/// 4. Execute with [CleanupExecutor.execute].
/// 5. Persist outputs with [RunLogWriter].
library;

export 'src/cancellation/cancellation_token.dart';
export 'src/doctor/doctor_service.dart';
export 'src/fvm/fvm_service.dart';
export 'src/global/global_cache_paths.dart';
export 'src/history/run_history_service.dart';
export 'src/models/attribution_status.dart';
export 'src/models/cache_category.dart';
export 'src/models/cache_target.dart';
export 'src/models/cleanup_event.dart';
export 'src/models/cleanup_plan.dart';
export 'src/models/cleanup_result.dart';
export 'src/models/delete_mode.dart';
export 'src/models/doctor_result.dart';
export 'src/models/fvm_result.dart';
export 'src/models/history_entry.dart';
export 'src/models/profile.dart';
export 'src/models/risk.dart';
export 'src/models/scan_event.dart';
export 'src/models/scan_request.dart';
export 'src/models/scan_result.dart';
export 'src/execute/cleanup_executor.dart';
export 'src/logs/run_log_writer.dart';
export 'src/plan/cleanup_planner.dart';
export 'src/scan/scan_service.dart';
export 'src/targets/target_registry.dart';
export 'src/xcode/derived_data_attribution.dart';
export 'src/xcode/xcode_cache_paths.dart';
