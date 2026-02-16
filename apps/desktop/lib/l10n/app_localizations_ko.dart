// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Fluttrim';

  @override
  String get navDashboard => '대시보드';

  @override
  String get navProjects => '프로젝트';

  @override
  String get navXcode => 'Xcode';

  @override
  String get navFlutterSdk => 'Flutter SDK';

  @override
  String get navGlobalCaches => '전역 캐시';

  @override
  String get navHistory => '히스토리';

  @override
  String get navSettings => '설정';

  @override
  String get xcodeMacMilestoneMessage =>
      'Xcode DerivedData 귀속 모듈은 다음 마일스톤에서 구현 예정입니다.';

  @override
  String get historyMilestoneMessage => '히스토리 저장은 v1에서 구현 예정입니다.';

  @override
  String get scanNow => '지금 스캔';

  @override
  String get cancel => '취소';

  @override
  String get working => '작업 중...';

  @override
  String get totalReclaimable => '정리 가능 총 용량';

  @override
  String get projectsCount => '탐지된 프로젝트';

  @override
  String get profileLabel => '프로파일';

  @override
  String get profileSafe => 'Safe';

  @override
  String get profileMedium => 'Medium';

  @override
  String get profileAggressive => 'Aggressive';

  @override
  String get lastScanLabel => '마지막 스캔';

  @override
  String get notScannedYet => '아직 스캔하지 않았습니다';

  @override
  String get latestScanLog => '최근 스캔 로그';

  @override
  String get latestCleanupLog => '최근 정리 로그';

  @override
  String get searchProjects => '프로젝트 검색';

  @override
  String get scanToDiscoverProjects => '프로젝트를 찾으려면 스캔을 실행하세요.';

  @override
  String get noMatchingProjects => '검색 결과가 없습니다.';

  @override
  String get selectProjectForDetails => '상세 보기를 위해 프로젝트를 선택하세요.';

  @override
  String get projectDetail => '프로젝트 상세';

  @override
  String get targetNotFound => '대상이 없습니다';

  @override
  String get previewPlan => '플랜 미리보기';

  @override
  String get applyPlan => '적용';

  @override
  String get planPreview => '플랜 미리보기';

  @override
  String get confirmApplyTitle => '정리를 적용할까요?';

  @override
  String confirmApplyBody(int itemCount, Object size, Object mode) {
    return '$itemCount개 항목을 정리하고 약 $size를 회수합니다. 삭제 모드는 $mode 입니다.';
  }

  @override
  String get cleanupSummary => '정리 결과';

  @override
  String get cleanupSuccess => '성공';

  @override
  String get cleanupFailed => '실패';

  @override
  String get cleanupSkipped => '건너뜀';

  @override
  String get reclaimed => '회수 용량';

  @override
  String get refresh => '새로고침';

  @override
  String get loadingXcodeCaches => 'Xcode DerivedData 로딩 중...';

  @override
  String get xcodeTotalDetected => 'DerivedData 총 용량';

  @override
  String get xcodeCacheItems => 'DerivedData 항목 수';

  @override
  String get xcodeAttributed => '연결됨';

  @override
  String get xcodeUnknown => '알 수 없음';

  @override
  String get xcodeDerivedDataTargets => 'DerivedData 대상';

  @override
  String get noXcodeCachesDetected => '탐지된 Xcode DerivedData 항목이 없습니다.';

  @override
  String get attributionNotApplicable => '연결 정보: 해당 없음';

  @override
  String get attributionAttributed => '연결 정보: 프로젝트 연결됨';

  @override
  String get attributionUnknown => '연결 정보: 알 수 없음';

  @override
  String get confidence => '신뢰도';

  @override
  String get evidence => '근거';

  @override
  String get xcodeUnknownBlockedHint =>
      '\'Unknown 귀속 항목 정리 허용\'을 켜기 전에는 이 항목을 정리할 수 없습니다.';

  @override
  String get xcodeDangerDescription =>
      'DerivedData 삭제 시 다음 Xcode 빌드 시간이 크게 증가할 수 있습니다.';

  @override
  String get xcodeDangerAcknowledge => '재빌드 비용을 이해했으며 Xcode 정리를 활성화합니다.';

  @override
  String get loadingGlobalCaches => '전역 캐시를 불러오는 중...';

  @override
  String get globalTotalDetected => '전역 캐시 총량';

  @override
  String get globalCacheItems => '전역 캐시 항목 수';

  @override
  String get globalCachesDetected => '탐지된 전역 캐시';

  @override
  String get noGlobalCachesDetected => '현재 OS에서 탐지된 전역 캐시 경로가 없습니다.';

  @override
  String get loadingHistory => '히스토리 로딩 중...';

  @override
  String get historyTotalRuns => '전체 실행 횟수';

  @override
  String get historyLatestScanDelta => '최근 스캔 증감';

  @override
  String get historyRecentRuns => '최근 실행 기록';

  @override
  String get historyNoRunsYet => '아직 기록된 실행이 없습니다.';

  @override
  String get historyFilters => '필터';

  @override
  String get historyFilterProfile => '프로파일';

  @override
  String get historyFilterPeriod => '기간';

  @override
  String get historyProfileAll => '전체 프로파일';

  @override
  String get historyPeriodAll => '전체 기간';

  @override
  String get historyPeriod7d => '최근 7일';

  @override
  String get historyPeriod30d => '최근 30일';

  @override
  String get historyPeriod90d => '최근 90일';

  @override
  String get historyTypeScan => '스캔';

  @override
  String get historyTypeCleanup => '정리';

  @override
  String get historyTimestamp => '시각';

  @override
  String get dangerZoneTitle => 'Danger Zone';

  @override
  String get dangerZoneDescription =>
      '전역 캐시 삭제 시 모든 프로젝트에서 재빌드/재다운로드 시간이 크게 증가할 수 있습니다.';

  @override
  String get dangerZoneAcknowledge => '재빌드 비용을 이해했으며 전역 캐시 정리를 활성화합니다.';

  @override
  String get confirmGlobalApplyTitle => '전역 캐시 정리를 적용할까요?';

  @override
  String get openFolder => '폴더 열기';

  @override
  String get globalPubCache => 'Pub 캐시';

  @override
  String get globalGradleCache => 'Gradle 사용자 홈 캐시';

  @override
  String get globalCocoaPodsCache => 'CocoaPods 캐시';

  @override
  String get globalCocoaPodsHome => 'CocoaPods 홈';

  @override
  String get loadingFvmStatus => 'FVM 상태 로딩 중...';

  @override
  String get noFvmDataYet => '아직 FVM 데이터가 없습니다. 새로고침을 눌러주세요.';

  @override
  String get fvmStatus => 'FVM 상태';

  @override
  String get fvmAvailable => 'FVM 사용 가능';

  @override
  String get fvmUnavailable => 'FVM을 찾을 수 없음';

  @override
  String get version => '버전';

  @override
  String get path => '경로';

  @override
  String get installedSdks => '설치된 SDK';

  @override
  String get state => '상태';

  @override
  String get usedByProjects => '사용 프로젝트 수';

  @override
  String get ready => '준비됨';

  @override
  String get notReady => '준비 안됨';

  @override
  String get projectUsage => '프로젝트 사용 현황';

  @override
  String get scanToLoadProjectUsage => '프로젝트 매핑을 보려면 스캔을 먼저 실행하세요.';

  @override
  String get fvmUnusedSdkCleanup => '미사용 SDK 정리';

  @override
  String get fvmNoUnusedSdks => '미사용 SDK가 없습니다.';

  @override
  String get removeSdk => 'SDK 제거';

  @override
  String get removeInProgress => '제거 중...';

  @override
  String get removeSdkConfirmTitle => 'Flutter SDK를 제거할까요?';

  @override
  String removeSdkConfirmBody(Object sdkName) {
    return 'FVM SDK \'$sdkName\'를 제거합니다. 계속할까요?';
  }

  @override
  String fvmRemovalSuccess(Object sdkName) {
    return 'SDK 제거 완료: $sdkName';
  }

  @override
  String fvmRemovalFailed(Object sdkName) {
    return 'SDK 제거 실패: $sdkName';
  }

  @override
  String get sdkUsed => '사용 중';

  @override
  String get sdkUnused => '미사용';

  @override
  String get project => '프로젝트';

  @override
  String get pinnedVersion => '고정 버전';

  @override
  String get installedLocally => '로컬 설치 여부';

  @override
  String get yes => '예';

  @override
  String get no => '아니오';

  @override
  String get noData => '데이터 없음';

  @override
  String get scanRoots => '스캔 루트';

  @override
  String get addRoot => '루트 추가';

  @override
  String get rootPathHint => '/path/to/projects';

  @override
  String get add => '추가';

  @override
  String get deleteModeLabel => '삭제 모드';

  @override
  String get deleteModeTrash => '휴지통(기본)';

  @override
  String get deleteModePermanent => '영구 삭제';

  @override
  String get allowUnknown => 'Unknown 귀속 항목 정리 허용';

  @override
  String get settingsLanguage => '언어';

  @override
  String get languageEnglish => '영어';

  @override
  String get languageKorean => '한국어';
}
