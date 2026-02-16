import 'package:fluttrim_core/fluttrim_core.dart';
import 'package:test/test.dart';

void main() {
  group('CleanupPlanner', () {
    test('creates a plan from scan results (existing targets only)', () {
      final scan = ScanResult(
        startedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        finishedAt: DateTime.fromMillisecondsSinceEpoch(1, isUtc: true),
        profile: Profile.safe,
        cancelled: false,
        projects: [
          ProjectScanResult(
            name: 'p',
            rootPath: '/tmp/p',
            targets: [
              TargetScanResult(
                targetId: 'project.build',
                category: CacheCategory.project,
                risk: Risk.low,
                path: '/tmp/p/build',
                exists: true,
                sizeBytes: 10,
              ),
              TargetScanResult(
                targetId: 'project.dart_tool',
                category: CacheCategory.project,
                risk: Risk.low,
                path: '/tmp/p/.dart_tool',
                exists: false,
                sizeBytes: 0,
              ),
            ],
          ),
        ],
      );

      final planner = CleanupPlanner();
      final plan = planner.createPlan(scan: scan);
      expect(plan.items.length, 1);
      expect(plan.items.single.targetId, 'project.build');
      expect(plan.items.single.sizeBytes, 10);
      expect(plan.deleteMode, DeleteMode.trash);
    });

    test('rejects unknown targetId', () {
      final scan = ScanResult(
        startedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        finishedAt: DateTime.fromMillisecondsSinceEpoch(1, isUtc: true),
        profile: Profile.safe,
        cancelled: false,
        projects: [
          ProjectScanResult(
            name: 'p',
            rootPath: '/tmp/p',
            targets: [
              TargetScanResult(
                targetId: 'nope',
                category: CacheCategory.project,
                risk: Risk.low,
                path: '/tmp/p/build',
                exists: true,
                sizeBytes: 10,
              ),
            ],
          ),
        ],
      );

      final planner = CleanupPlanner();
      expect(
        () => planner.createPlan(scan: scan),
        throwsA(isA<InvalidPlanException>()),
      );
    });

    test('rejects project target paths outside project root', () {
      final scan = ScanResult(
        startedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        finishedAt: DateTime.fromMillisecondsSinceEpoch(1, isUtc: true),
        profile: Profile.safe,
        cancelled: false,
        projects: [
          ProjectScanResult(
            name: 'p',
            rootPath: '/tmp/p',
            targets: [
              TargetScanResult(
                targetId: 'project.build',
                category: CacheCategory.project,
                risk: Risk.low,
                path: '/tmp/elsewhere/build',
                exists: true,
                sizeBytes: 10,
              ),
            ],
          ),
        ],
      );

      final planner = CleanupPlanner();
      expect(
        () => planner.createPlan(scan: scan),
        throwsA(isA<InvalidPlanException>()),
      );
    });

    test('skips unknown-attribution xcode targets by default', () {
      final scan = ScanResult(
        startedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        finishedAt: DateTime.fromMillisecondsSinceEpoch(1, isUtc: true),
        profile: Profile.aggressive,
        cancelled: false,
        projects: const <ProjectScanResult>[],
        xcodeTargets: [
          TargetScanResult(
            targetId: xcodeDerivedDataTargetId,
            category: CacheCategory.xcode,
            risk: Risk.high,
            path: '/tmp/DerivedData/foo',
            exists: true,
            sizeBytes: 42,
            attributionStatus: AttributionStatus.unknown,
          ),
        ],
      );

      final planner = CleanupPlanner();
      final plan = planner.createPlan(scan: scan);
      expect(plan.items, isEmpty);
      expect(plan.warnings, isNotEmpty);
    });

    test('includes unknown-attribution xcode targets when allowed', () {
      final scan = ScanResult(
        startedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        finishedAt: DateTime.fromMillisecondsSinceEpoch(1, isUtc: true),
        profile: Profile.aggressive,
        cancelled: false,
        projects: const <ProjectScanResult>[],
        xcodeTargets: [
          TargetScanResult(
            targetId: xcodeDerivedDataTargetId,
            category: CacheCategory.xcode,
            risk: Risk.high,
            path: '/tmp/DerivedData/foo',
            exists: true,
            sizeBytes: 42,
            attributionStatus: AttributionStatus.unknown,
          ),
        ],
      );

      final planner = CleanupPlanner();
      final plan = planner.createPlan(scan: scan, allowUnknown: true);
      expect(plan.items.length, 1);
      expect(plan.warnings, isEmpty);
    });
  });
}
