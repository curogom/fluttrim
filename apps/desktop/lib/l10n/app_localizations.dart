import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Fluttrim'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get navProjects;

  /// No description provided for @navXcode.
  ///
  /// In en, this message translates to:
  /// **'Xcode'**
  String get navXcode;

  /// No description provided for @navFlutterSdk.
  ///
  /// In en, this message translates to:
  /// **'Flutter SDK'**
  String get navFlutterSdk;

  /// No description provided for @navGlobalCaches.
  ///
  /// In en, this message translates to:
  /// **'Global Caches'**
  String get navGlobalCaches;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @xcodeMacMilestoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Xcode DerivedData attribution module is planned in the next milestone.'**
  String get xcodeMacMilestoneMessage;

  /// No description provided for @historyMilestoneMessage.
  ///
  /// In en, this message translates to:
  /// **'History persistence is planned for v1.'**
  String get historyMilestoneMessage;

  /// No description provided for @scanNow.
  ///
  /// In en, this message translates to:
  /// **'Scan Now'**
  String get scanNow;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @working.
  ///
  /// In en, this message translates to:
  /// **'Working...'**
  String get working;

  /// No description provided for @totalReclaimable.
  ///
  /// In en, this message translates to:
  /// **'Total reclaimable'**
  String get totalReclaimable;

  /// No description provided for @projectsCount.
  ///
  /// In en, this message translates to:
  /// **'Projects found'**
  String get projectsCount;

  /// No description provided for @profileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileLabel;

  /// No description provided for @profileSafe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get profileSafe;

  /// No description provided for @profileMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get profileMedium;

  /// No description provided for @profileAggressive.
  ///
  /// In en, this message translates to:
  /// **'Aggressive'**
  String get profileAggressive;

  /// No description provided for @lastScanLabel.
  ///
  /// In en, this message translates to:
  /// **'Last scan'**
  String get lastScanLabel;

  /// No description provided for @notScannedYet.
  ///
  /// In en, this message translates to:
  /// **'Not scanned yet'**
  String get notScannedYet;

  /// No description provided for @latestScanLog.
  ///
  /// In en, this message translates to:
  /// **'Latest scan log'**
  String get latestScanLog;

  /// No description provided for @latestCleanupLog.
  ///
  /// In en, this message translates to:
  /// **'Latest cleanup log'**
  String get latestCleanupLog;

  /// No description provided for @searchProjects.
  ///
  /// In en, this message translates to:
  /// **'Search projects'**
  String get searchProjects;

  /// No description provided for @scanToDiscoverProjects.
  ///
  /// In en, this message translates to:
  /// **'Run scan to discover projects.'**
  String get scanToDiscoverProjects;

  /// No description provided for @noMatchingProjects.
  ///
  /// In en, this message translates to:
  /// **'No matching projects.'**
  String get noMatchingProjects;

  /// No description provided for @selectedProjectsLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected projects'**
  String get selectedProjectsLabel;

  /// No description provided for @selectAllVisible.
  ///
  /// In en, this message translates to:
  /// **'Select all visible'**
  String get selectAllVisible;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelection;

  /// No description provided for @includeInBatchCleanup.
  ///
  /// In en, this message translates to:
  /// **'Include in batch cleanup'**
  String get includeInBatchCleanup;

  /// No description provided for @batchCleanupHint.
  ///
  /// In en, this message translates to:
  /// **'Plan and apply will run across {count} selected project(s).'**
  String batchCleanupHint(int count);

  /// No description provided for @selectProjectForDetails.
  ///
  /// In en, this message translates to:
  /// **'Select a project to view details.'**
  String get selectProjectForDetails;

  /// No description provided for @projectDetail.
  ///
  /// In en, this message translates to:
  /// **'Project detail'**
  String get projectDetail;

  /// No description provided for @targetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Target not found'**
  String get targetNotFound;

  /// No description provided for @previewPlan.
  ///
  /// In en, this message translates to:
  /// **'Preview Plan'**
  String get previewPlan;

  /// No description provided for @applyPlan.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyPlan;

  /// No description provided for @planPreview.
  ///
  /// In en, this message translates to:
  /// **'Plan preview'**
  String get planPreview;

  /// No description provided for @confirmApplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply Cleanup?'**
  String get confirmApplyTitle;

  /// No description provided for @confirmApplyBody.
  ///
  /// In en, this message translates to:
  /// **'This will clean {itemCount} item(s), reclaim about {size}, and use delete mode: {mode}.'**
  String confirmApplyBody(int itemCount, Object size, Object mode);

  /// No description provided for @cleanupSummary.
  ///
  /// In en, this message translates to:
  /// **'Cleanup summary'**
  String get cleanupSummary;

  /// No description provided for @cleanupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get cleanupSuccess;

  /// No description provided for @cleanupFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get cleanupFailed;

  /// No description provided for @cleanupSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get cleanupSkipped;

  /// No description provided for @reclaimed.
  ///
  /// In en, this message translates to:
  /// **'Reclaimed'**
  String get reclaimed;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @loadingXcodeCaches.
  ///
  /// In en, this message translates to:
  /// **'Loading Xcode DerivedData...'**
  String get loadingXcodeCaches;

  /// No description provided for @xcodeTotalDetected.
  ///
  /// In en, this message translates to:
  /// **'DerivedData total'**
  String get xcodeTotalDetected;

  /// No description provided for @xcodeCacheItems.
  ///
  /// In en, this message translates to:
  /// **'DerivedData entries'**
  String get xcodeCacheItems;

  /// No description provided for @xcodeAttributed.
  ///
  /// In en, this message translates to:
  /// **'Attributed'**
  String get xcodeAttributed;

  /// No description provided for @xcodeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get xcodeUnknown;

  /// No description provided for @xcodeDerivedDataTargets.
  ///
  /// In en, this message translates to:
  /// **'DerivedData targets'**
  String get xcodeDerivedDataTargets;

  /// No description provided for @noXcodeCachesDetected.
  ///
  /// In en, this message translates to:
  /// **'No Xcode DerivedData entries were detected.'**
  String get noXcodeCachesDetected;

  /// No description provided for @attributionNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'Attribution: N/A'**
  String get attributionNotApplicable;

  /// No description provided for @attributionAttributed.
  ///
  /// In en, this message translates to:
  /// **'Attribution: Attributed'**
  String get attributionAttributed;

  /// No description provided for @attributionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Attribution: Unknown'**
  String get attributionUnknown;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @evidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get evidence;

  /// No description provided for @xcodeUnknownBlockedHint.
  ///
  /// In en, this message translates to:
  /// **'Unknown attribution is blocked unless \'Allow unknown attribution cleanup\' is enabled.'**
  String get xcodeUnknownBlockedHint;

  /// No description provided for @xcodeDangerDescription.
  ///
  /// In en, this message translates to:
  /// **'Deleting DerivedData can significantly increase next Xcode build time.'**
  String get xcodeDangerDescription;

  /// No description provided for @xcodeDangerAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'I understand rebuild costs and want to enable Xcode cleanup.'**
  String get xcodeDangerAcknowledge;

  /// No description provided for @loadingGlobalCaches.
  ///
  /// In en, this message translates to:
  /// **'Loading global caches...'**
  String get loadingGlobalCaches;

  /// No description provided for @globalTotalDetected.
  ///
  /// In en, this message translates to:
  /// **'Global total'**
  String get globalTotalDetected;

  /// No description provided for @globalCacheItems.
  ///
  /// In en, this message translates to:
  /// **'Global cache items'**
  String get globalCacheItems;

  /// No description provided for @globalCachesDetected.
  ///
  /// In en, this message translates to:
  /// **'Detected global caches'**
  String get globalCachesDetected;

  /// No description provided for @noGlobalCachesDetected.
  ///
  /// In en, this message translates to:
  /// **'No global cache paths were detected on this OS.'**
  String get noGlobalCachesDetected;

  /// No description provided for @loadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Loading history...'**
  String get loadingHistory;

  /// No description provided for @historyTotalRuns.
  ///
  /// In en, this message translates to:
  /// **'Total runs'**
  String get historyTotalRuns;

  /// No description provided for @historyLatestScanDelta.
  ///
  /// In en, this message translates to:
  /// **'Latest scan delta'**
  String get historyLatestScanDelta;

  /// No description provided for @historyRecentRuns.
  ///
  /// In en, this message translates to:
  /// **'Recent runs'**
  String get historyRecentRuns;

  /// No description provided for @historyNoRunsYet.
  ///
  /// In en, this message translates to:
  /// **'No runs recorded yet.'**
  String get historyNoRunsYet;

  /// No description provided for @historyFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get historyFilters;

  /// No description provided for @historyFilterProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get historyFilterProfile;

  /// No description provided for @historyFilterPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get historyFilterPeriod;

  /// No description provided for @historyProfileAll.
  ///
  /// In en, this message translates to:
  /// **'All profiles'**
  String get historyProfileAll;

  /// No description provided for @historyPeriodAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get historyPeriodAll;

  /// No description provided for @historyPeriod7d.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get historyPeriod7d;

  /// No description provided for @historyPeriod30d.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get historyPeriod30d;

  /// No description provided for @historyPeriod90d.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get historyPeriod90d;

  /// No description provided for @historyTypeScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get historyTypeScan;

  /// No description provided for @historyTypeCleanup.
  ///
  /// In en, this message translates to:
  /// **'Cleanup'**
  String get historyTypeCleanup;

  /// No description provided for @historyTimestamp.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get historyTimestamp;

  /// No description provided for @dangerZoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZoneTitle;

  /// No description provided for @dangerZoneDescription.
  ///
  /// In en, this message translates to:
  /// **'Deleting global caches can significantly increase rebuild/re-download time across all projects.'**
  String get dangerZoneDescription;

  /// No description provided for @dangerZoneAcknowledge.
  ///
  /// In en, this message translates to:
  /// **'I understand rebuild costs and want to enable global cleanup.'**
  String get dangerZoneAcknowledge;

  /// No description provided for @confirmGlobalApplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply Global Cleanup?'**
  String get confirmGlobalApplyTitle;

  /// No description provided for @openFolder.
  ///
  /// In en, this message translates to:
  /// **'Open folder'**
  String get openFolder;

  /// No description provided for @globalPubCache.
  ///
  /// In en, this message translates to:
  /// **'Pub cache'**
  String get globalPubCache;

  /// No description provided for @globalGradleCache.
  ///
  /// In en, this message translates to:
  /// **'Gradle user home cache'**
  String get globalGradleCache;

  /// No description provided for @globalCocoaPodsCache.
  ///
  /// In en, this message translates to:
  /// **'CocoaPods cache'**
  String get globalCocoaPodsCache;

  /// No description provided for @globalCocoaPodsHome.
  ///
  /// In en, this message translates to:
  /// **'CocoaPods home'**
  String get globalCocoaPodsHome;

  /// No description provided for @loadingFvmStatus.
  ///
  /// In en, this message translates to:
  /// **'Loading FVM status...'**
  String get loadingFvmStatus;

  /// No description provided for @noFvmDataYet.
  ///
  /// In en, this message translates to:
  /// **'No FVM data yet. Click refresh.'**
  String get noFvmDataYet;

  /// No description provided for @fvmStatus.
  ///
  /// In en, this message translates to:
  /// **'FVM status'**
  String get fvmStatus;

  /// No description provided for @fvmAvailable.
  ///
  /// In en, this message translates to:
  /// **'FVM available'**
  String get fvmAvailable;

  /// No description provided for @fvmUnavailable.
  ///
  /// In en, this message translates to:
  /// **'FVM not available'**
  String get fvmUnavailable;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @path.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get path;

  /// No description provided for @installedSdks.
  ///
  /// In en, this message translates to:
  /// **'Installed SDKs'**
  String get installedSdks;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @usedByProjects.
  ///
  /// In en, this message translates to:
  /// **'Used by projects'**
  String get usedByProjects;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @notReady.
  ///
  /// In en, this message translates to:
  /// **'Not ready'**
  String get notReady;

  /// No description provided for @projectUsage.
  ///
  /// In en, this message translates to:
  /// **'Project usage'**
  String get projectUsage;

  /// No description provided for @scanToLoadProjectUsage.
  ///
  /// In en, this message translates to:
  /// **'Run scan to load project usage mapping.'**
  String get scanToLoadProjectUsage;

  /// No description provided for @fvmUnusedSdkCleanup.
  ///
  /// In en, this message translates to:
  /// **'Unused SDK cleanup'**
  String get fvmUnusedSdkCleanup;

  /// No description provided for @fvmNoUnusedSdks.
  ///
  /// In en, this message translates to:
  /// **'No unused SDKs detected.'**
  String get fvmNoUnusedSdks;

  /// No description provided for @removeSdk.
  ///
  /// In en, this message translates to:
  /// **'Remove SDK'**
  String get removeSdk;

  /// No description provided for @removeInProgress.
  ///
  /// In en, this message translates to:
  /// **'Removing...'**
  String get removeInProgress;

  /// No description provided for @removeSdkConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Flutter SDK?'**
  String get removeSdkConfirmTitle;

  /// No description provided for @removeSdkConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This removes FVM SDK \'{sdkName}\'. Continue?'**
  String removeSdkConfirmBody(Object sdkName);

  /// No description provided for @fvmRemovalSuccess.
  ///
  /// In en, this message translates to:
  /// **'Removed SDK: {sdkName}'**
  String fvmRemovalSuccess(Object sdkName);

  /// No description provided for @fvmRemovalFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove SDK: {sdkName}'**
  String fvmRemovalFailed(Object sdkName);

  /// No description provided for @sdkUsed.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get sdkUsed;

  /// No description provided for @sdkUnused.
  ///
  /// In en, this message translates to:
  /// **'Unused'**
  String get sdkUnused;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @pinnedVersion.
  ///
  /// In en, this message translates to:
  /// **'Pinned version'**
  String get pinnedVersion;

  /// No description provided for @installedLocally.
  ///
  /// In en, this message translates to:
  /// **'Installed locally'**
  String get installedLocally;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @scanRoots.
  ///
  /// In en, this message translates to:
  /// **'Scan roots'**
  String get scanRoots;

  /// No description provided for @addRoot.
  ///
  /// In en, this message translates to:
  /// **'Add root'**
  String get addRoot;

  /// No description provided for @rootPathHint.
  ///
  /// In en, this message translates to:
  /// **'/path/to/projects'**
  String get rootPathHint;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @deleteModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete mode'**
  String get deleteModeLabel;

  /// No description provided for @deleteModeTrash.
  ///
  /// In en, this message translates to:
  /// **'Trash (default)'**
  String get deleteModeTrash;

  /// No description provided for @deleteModePermanent.
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get deleteModePermanent;

  /// No description provided for @allowUnknown.
  ///
  /// In en, this message translates to:
  /// **'Allow unknown attribution cleanup'**
  String get allowUnknown;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get languageKorean;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Fluttrim'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language and default scan roots to get started.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Settings.'**
  String get onboardingLanguageHint;

  /// No description provided for @onboardingRootsTitle.
  ///
  /// In en, this message translates to:
  /// **'Default scan roots'**
  String get onboardingRootsTitle;

  /// No description provided for @onboardingRootsHint.
  ///
  /// In en, this message translates to:
  /// **'Fluttrim scans these folders for Flutter projects.'**
  String get onboardingRootsHint;

  /// No description provided for @onboardingUseHomeShortcut.
  ///
  /// In en, this message translates to:
  /// **'Use home folder'**
  String get onboardingUseHomeShortcut;

  /// No description provided for @onboardingQuickShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Quick shortcuts'**
  String get onboardingQuickShortcuts;

  /// No description provided for @onboardingAddRootLabel.
  ///
  /// In en, this message translates to:
  /// **'Add root folder'**
  String get onboardingAddRootLabel;

  /// No description provided for @onboardingSelectedRoots.
  ///
  /// In en, this message translates to:
  /// **'Selected roots ({count})'**
  String onboardingSelectedRoots(int count);

  /// No description provided for @onboardingNoRootsSelected.
  ///
  /// In en, this message translates to:
  /// **'Select at least one folder to continue.'**
  String get onboardingNoRootsSelected;

  /// No description provided for @onboardingRootInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid folder path.'**
  String get onboardingRootInvalid;

  /// No description provided for @onboardingRootNotFound.
  ///
  /// In en, this message translates to:
  /// **'The selected folder does not exist.'**
  String get onboardingRootNotFound;

  /// No description provided for @onboardingRootRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one existing root folder.'**
  String get onboardingRootRequired;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
