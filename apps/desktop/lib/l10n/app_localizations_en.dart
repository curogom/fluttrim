// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fluttrim';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navProjects => 'Projects';

  @override
  String get navXcode => 'Xcode';

  @override
  String get navFlutterSdk => 'Flutter SDK';

  @override
  String get navGlobalCaches => 'Global Caches';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get xcodeMacMilestoneMessage =>
      'Xcode DerivedData attribution module is planned in the next milestone.';

  @override
  String get historyMilestoneMessage =>
      'History persistence is planned for v1.';

  @override
  String get scanNow => 'Scan Now';

  @override
  String get cancel => 'Cancel';

  @override
  String get working => 'Working...';

  @override
  String get totalReclaimable => 'Total reclaimable';

  @override
  String get projectsCount => 'Projects found';

  @override
  String get profileLabel => 'Profile';

  @override
  String get profileSafe => 'Safe';

  @override
  String get profileMedium => 'Medium';

  @override
  String get profileAggressive => 'Aggressive';

  @override
  String get lastScanLabel => 'Last scan';

  @override
  String get notScannedYet => 'Not scanned yet';

  @override
  String get latestScanLog => 'Latest scan log';

  @override
  String get latestCleanupLog => 'Latest cleanup log';

  @override
  String get searchProjects => 'Search projects';

  @override
  String get scanToDiscoverProjects => 'Run scan to discover projects.';

  @override
  String get noMatchingProjects => 'No matching projects.';

  @override
  String get selectProjectForDetails => 'Select a project to view details.';

  @override
  String get projectDetail => 'Project detail';

  @override
  String get targetNotFound => 'Target not found';

  @override
  String get previewPlan => 'Preview Plan';

  @override
  String get applyPlan => 'Apply';

  @override
  String get planPreview => 'Plan preview';

  @override
  String get confirmApplyTitle => 'Apply Cleanup?';

  @override
  String confirmApplyBody(int itemCount, Object size, Object mode) {
    return 'This will clean $itemCount item(s), reclaim about $size, and use delete mode: $mode.';
  }

  @override
  String get cleanupSummary => 'Cleanup summary';

  @override
  String get cleanupSuccess => 'Success';

  @override
  String get cleanupFailed => 'Failed';

  @override
  String get cleanupSkipped => 'Skipped';

  @override
  String get reclaimed => 'Reclaimed';

  @override
  String get refresh => 'Refresh';

  @override
  String get loadingXcodeCaches => 'Loading Xcode DerivedData...';

  @override
  String get xcodeTotalDetected => 'DerivedData total';

  @override
  String get xcodeCacheItems => 'DerivedData entries';

  @override
  String get xcodeAttributed => 'Attributed';

  @override
  String get xcodeUnknown => 'Unknown';

  @override
  String get xcodeDerivedDataTargets => 'DerivedData targets';

  @override
  String get noXcodeCachesDetected =>
      'No Xcode DerivedData entries were detected.';

  @override
  String get attributionNotApplicable => 'Attribution: N/A';

  @override
  String get attributionAttributed => 'Attribution: Attributed';

  @override
  String get attributionUnknown => 'Attribution: Unknown';

  @override
  String get confidence => 'Confidence';

  @override
  String get evidence => 'Evidence';

  @override
  String get xcodeUnknownBlockedHint =>
      'Unknown attribution is blocked unless \'Allow unknown attribution cleanup\' is enabled.';

  @override
  String get xcodeDangerDescription =>
      'Deleting DerivedData can significantly increase next Xcode build time.';

  @override
  String get xcodeDangerAcknowledge =>
      'I understand rebuild costs and want to enable Xcode cleanup.';

  @override
  String get loadingGlobalCaches => 'Loading global caches...';

  @override
  String get globalTotalDetected => 'Global total';

  @override
  String get globalCacheItems => 'Global cache items';

  @override
  String get globalCachesDetected => 'Detected global caches';

  @override
  String get noGlobalCachesDetected =>
      'No global cache paths were detected on this OS.';

  @override
  String get loadingHistory => 'Loading history...';

  @override
  String get historyTotalRuns => 'Total runs';

  @override
  String get historyLatestScanDelta => 'Latest scan delta';

  @override
  String get historyRecentRuns => 'Recent runs';

  @override
  String get historyNoRunsYet => 'No runs recorded yet.';

  @override
  String get historyFilters => 'Filters';

  @override
  String get historyFilterProfile => 'Profile';

  @override
  String get historyFilterPeriod => 'Period';

  @override
  String get historyProfileAll => 'All profiles';

  @override
  String get historyPeriodAll => 'All time';

  @override
  String get historyPeriod7d => 'Last 7 days';

  @override
  String get historyPeriod30d => 'Last 30 days';

  @override
  String get historyPeriod90d => 'Last 90 days';

  @override
  String get historyTypeScan => 'Scan';

  @override
  String get historyTypeCleanup => 'Cleanup';

  @override
  String get historyTimestamp => 'Time';

  @override
  String get dangerZoneTitle => 'Danger Zone';

  @override
  String get dangerZoneDescription =>
      'Deleting global caches can significantly increase rebuild/re-download time across all projects.';

  @override
  String get dangerZoneAcknowledge =>
      'I understand rebuild costs and want to enable global cleanup.';

  @override
  String get confirmGlobalApplyTitle => 'Apply Global Cleanup?';

  @override
  String get openFolder => 'Open folder';

  @override
  String get globalPubCache => 'Pub cache';

  @override
  String get globalGradleCache => 'Gradle user home cache';

  @override
  String get globalCocoaPodsCache => 'CocoaPods cache';

  @override
  String get globalCocoaPodsHome => 'CocoaPods home';

  @override
  String get loadingFvmStatus => 'Loading FVM status...';

  @override
  String get noFvmDataYet => 'No FVM data yet. Click refresh.';

  @override
  String get fvmStatus => 'FVM status';

  @override
  String get fvmAvailable => 'FVM available';

  @override
  String get fvmUnavailable => 'FVM not available';

  @override
  String get version => 'Version';

  @override
  String get path => 'Path';

  @override
  String get installedSdks => 'Installed SDKs';

  @override
  String get state => 'State';

  @override
  String get usedByProjects => 'Used by projects';

  @override
  String get ready => 'Ready';

  @override
  String get notReady => 'Not ready';

  @override
  String get projectUsage => 'Project usage';

  @override
  String get scanToLoadProjectUsage =>
      'Run scan to load project usage mapping.';

  @override
  String get fvmUnusedSdkCleanup => 'Unused SDK cleanup';

  @override
  String get fvmNoUnusedSdks => 'No unused SDKs detected.';

  @override
  String get removeSdk => 'Remove SDK';

  @override
  String get removeInProgress => 'Removing...';

  @override
  String get removeSdkConfirmTitle => 'Remove Flutter SDK?';

  @override
  String removeSdkConfirmBody(Object sdkName) {
    return 'This removes FVM SDK \'$sdkName\'. Continue?';
  }

  @override
  String fvmRemovalSuccess(Object sdkName) {
    return 'Removed SDK: $sdkName';
  }

  @override
  String fvmRemovalFailed(Object sdkName) {
    return 'Failed to remove SDK: $sdkName';
  }

  @override
  String get sdkUsed => 'In use';

  @override
  String get sdkUnused => 'Unused';

  @override
  String get project => 'Project';

  @override
  String get pinnedVersion => 'Pinned version';

  @override
  String get installedLocally => 'Installed locally';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get noData => 'No data';

  @override
  String get scanRoots => 'Scan roots';

  @override
  String get addRoot => 'Add root';

  @override
  String get rootPathHint => '/path/to/projects';

  @override
  String get add => 'Add';

  @override
  String get deleteModeLabel => 'Delete mode';

  @override
  String get deleteModeTrash => 'Trash (default)';

  @override
  String get deleteModePermanent => 'Permanent';

  @override
  String get allowUnknown => 'Allow unknown attribution cleanup';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKorean => 'Korean';
}
