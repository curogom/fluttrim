import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluttrim_core/fluttrim_core.dart';
import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {
  AppController() {
    _roots = _buildInitialRoots();
  }

  final ScanService _scanService = const ScanService();
  final CleanupPlanner _cleanupPlanner = const CleanupPlanner();
  final CleanupExecutor _cleanupExecutor = CleanupExecutor();
  final RunLogWriter _logWriter = const RunLogWriter();
  final RunHistoryService _runHistoryService = const RunHistoryService();
  final FvmService _fvmService = FvmService();

  Locale _locale = const Locale('en');
  List<String> _roots = <String>[];
  Profile _profile = Profile.safe;
  DeleteMode _deleteMode = DeleteMode.trash;
  bool _allowUnknown = false;

  bool _isScanning = false;
  bool _isApplying = false;
  bool _isInitialized = false;
  bool _onboardingCompleted = false;
  String? _statusMessage;
  int? _progressDone;
  int? _progressTotal;
  CancellationToken? _scanCancellationToken;
  CancellationToken? _applyCancellationToken;

  ScanResult? _scanResult;
  String? _scanLogPath;
  String? _selectedProjectRoot;
  final Set<String> _selectedProjectRoots = <String>{};
  final Map<String, Set<String>> _selectedTargetsByProject =
      <String, Set<String>>{};

  CleanupPlan? _currentPlan;
  CleanupResult? _lastCleanupResult;
  String? _cleanupLogPath;

  FvmResult? _fvmResult;
  bool _isRefreshingFvm = false;
  bool _isRemovingFvmSdk = false;
  FvmRemovalResult? _lastFvmRemovalResult;

  bool _isRefreshingHistory = false;
  List<RunHistoryEntry> _historyEntries = <RunHistoryEntry>[];

  bool _isRefreshingGlobalCaches = false;
  List<TargetScanResult> _globalCacheTargets = <TargetScanResult>[];
  final Set<String> _selectedGlobalTargetIds = <String>{};
  List<TargetScanResult> _xcodeTargets = <TargetScanResult>[];
  final Set<String> _selectedXcodeTargetPaths = <String>{};
  bool _dangerZoneConfirmed = false;
  CleanupPlan? _globalCleanupPlan;
  CleanupPlan? _xcodeCleanupPlan;
  CleanupResult? _lastGlobalCleanupResult;
  CleanupResult? _lastXcodeCleanupResult;
  String? _globalScanLogPath;
  String? _xcodeScanLogPath;

  String? _errorMessage;

  Locale get locale => _locale;
  List<String> get roots => List<String>.unmodifiable(_roots);
  Profile get profile => _profile;
  DeleteMode get deleteMode => _deleteMode;
  bool get allowUnknown => _allowUnknown;

  bool get isScanning => _isScanning;
  bool get isApplying => _isApplying;
  bool get isInitialized => _isInitialized;
  bool get needsOnboarding => !_onboardingCompleted;
  String? get statusMessage => _statusMessage;
  int? get progressDone => _progressDone;
  int? get progressTotal => _progressTotal;

  ScanResult? get scanResult => _scanResult;
  String? get scanLogPath => _scanLogPath;
  List<ProjectScanResult> get projects =>
      _scanResult?.projects ?? const <ProjectScanResult>[];
  String? get selectedProjectRoot => _selectedProjectRoot;
  Set<String> get selectedProjectRoots =>
      Set<String>.unmodifiable(_selectedProjectRoots);
  CleanupPlan? get currentPlan => _currentPlan;
  CleanupResult? get lastCleanupResult => _lastCleanupResult;
  String? get cleanupLogPath => _cleanupLogPath;
  FvmResult? get fvmResult => _fvmResult;
  bool get isRefreshingFvm => _isRefreshingFvm;
  bool get isRemovingFvmSdk => _isRemovingFvmSdk;
  FvmRemovalResult? get lastFvmRemovalResult => _lastFvmRemovalResult;
  bool get isRefreshingHistory => _isRefreshingHistory;
  List<RunHistoryEntry> get historyEntries =>
      List<RunHistoryEntry>.unmodifiable(_historyEntries);
  bool get isRefreshingGlobalCaches => _isRefreshingGlobalCaches;
  List<TargetScanResult> get globalCacheTargets =>
      List<TargetScanResult>.unmodifiable(_globalCacheTargets);
  Set<String> get selectedGlobalTargetIds =>
      Set<String>.unmodifiable(_selectedGlobalTargetIds);
  List<TargetScanResult> get xcodeTargets =>
      List<TargetScanResult>.unmodifiable(_xcodeTargets);
  Set<String> get selectedXcodeTargetPaths =>
      Set<String>.unmodifiable(_selectedXcodeTargetPaths);
  bool get dangerZoneConfirmed => _dangerZoneConfirmed;
  CleanupPlan? get globalCleanupPlan => _globalCleanupPlan;
  CleanupPlan? get xcodeCleanupPlan => _xcodeCleanupPlan;
  CleanupResult? get lastGlobalCleanupResult => _lastGlobalCleanupResult;
  CleanupResult? get lastXcodeCleanupResult => _lastXcodeCleanupResult;
  String? get globalScanLogPath => _globalScanLogPath;
  String? get xcodeScanLogPath => _xcodeScanLogPath;
  String? get errorMessage => _errorMessage;
  String? get homeRootPath => _resolveHomePath();
  List<String> get onboardingRootShortcuts =>
      _buildOnboardingRootShortcuts(homeRootPath);

  int get totalReclaimableBytes => _scanResult?.totalBytes ?? 0;
  int get totalReclaimedFromHistory => _historyEntries
      .where((entry) => entry.kind == RunHistoryKind.cleanup)
      .fold(0, (sum, entry) => sum + (entry.reclaimedBytes ?? 0));

  ProjectScanResult? get selectedProject {
    final root = _selectedProjectRoot;
    if (root == null) return null;
    for (final project in projects) {
      if (project.rootPath == root) return project;
    }
    return null;
  }

  Set<String> selectedTargetIdsForSelectedProject() {
    final root = _selectedProjectRoot;
    if (root == null) return const <String>{};
    return selectedTargetIdsForProject(root);
  }

  Set<String> selectedTargetIdsForProject(String projectRoot) {
    return Set<String>.unmodifiable(
      _selectedTargetsByProject[projectRoot] ?? <String>{},
    );
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    final persisted = await _loadDesktopSettings();
    if (persisted != null) {
      _locale = persisted.locale;
      _profile = persisted.parsedProfile;
      _deleteMode = persisted.parsedDeleteMode;
      _allowUnknown = persisted.allowUnknown;
      _onboardingCompleted = persisted.onboardingCompleted;

      final existingRoots = persisted.roots
          .where((root) => Directory(root).existsSync())
          .toList(growable: false);
      _roots = existingRoots.isNotEmpty ? existingRoots : _buildInitialRoots();
    } else {
      _onboardingCompleted = false;
      _roots = _buildInitialRoots();
    }

    _isInitialized = true;
    notifyListeners();

    Future<void>.microtask(refreshFvmStatus);
    Future<void>.microtask(refreshGlobalCaches);
    Future<void>.microtask(refreshHistory);
  }

  Future<bool> completeOnboarding({
    required Locale locale,
    required List<String> roots,
  }) async {
    final normalizedRoots = <String>{};
    for (final root in roots) {
      final normalized = _normalizeRoot(root);
      if (normalized == null) continue;
      if (!Directory(normalized).existsSync()) continue;
      normalizedRoots.add(normalized);
    }
    if (normalizedRoots.isEmpty) {
      return false;
    }

    _locale = locale;
    _roots = normalizedRoots.toList(growable: false);
    _onboardingCompleted = true;
    notifyListeners();
    await _saveDesktopSettings();
    return true;
  }

  String? normalizeRootPath(String value) => _normalizeRoot(value);

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    _saveDesktopSettingsIfReady();
  }

  void setProfile(Profile profile) {
    if (_profile == profile) return;
    _profile = profile;
    _currentPlan = null;
    notifyListeners();
    _saveDesktopSettingsIfReady();
  }

  void setDeleteMode(DeleteMode mode) {
    if (_deleteMode == mode) return;
    _deleteMode = mode;
    _currentPlan = null;
    notifyListeners();
    _saveDesktopSettingsIfReady();
  }

  void setAllowUnknown(bool value) {
    if (_allowUnknown == value) return;
    _allowUnknown = value;
    if (!value) {
      _selectedXcodeTargetPaths.removeWhere((path) {
        for (final target in _xcodeTargets) {
          if (target.path == path) {
            return target.hasUnknownAttribution;
          }
        }
        return false;
      });
      _xcodeCleanupPlan = null;
    }
    notifyListeners();
    _saveDesktopSettingsIfReady();
  }

  void setDangerZoneConfirmed(bool value) {
    if (_dangerZoneConfirmed == value) return;
    _dangerZoneConfirmed = value;
    if (!value) {
      _globalCleanupPlan = null;
      _xcodeCleanupPlan = null;
    }
    notifyListeners();
  }

  void addRoot(String root) {
    final normalized = _normalizeRoot(root);
    if (normalized == null) return;
    if (!Directory(normalized).existsSync()) {
      _setError('Root directory does not exist: $normalized');
      return;
    }
    if (_roots.contains(normalized)) return;
    _roots = <String>[..._roots, normalized];
    notifyListeners();
    _saveDesktopSettingsIfReady();
  }

  void removeRoot(String root) {
    _roots = _roots.where((value) => value != root).toList();
    if (_roots.isEmpty) {
      _roots = _buildInitialRoots();
    }
    notifyListeners();
    _saveDesktopSettingsIfReady();
  }

  void selectProject(String projectRoot) {
    var changed = false;
    if (_selectedProjectRoot != projectRoot) {
      _selectedProjectRoot = projectRoot;
      changed = true;
    }
    if (_selectedProjectRoots.add(projectRoot)) {
      changed = true;
    }
    if (!changed) return;
    _currentPlan = null;
    notifyListeners();
  }

  void toggleProjectSelection(String projectRoot, bool selected) {
    var changed = false;
    if (selected) {
      changed = _selectedProjectRoots.add(projectRoot);
      _selectedProjectRoot ??= projectRoot;
    } else {
      changed = _selectedProjectRoots.remove(projectRoot);
      if (_selectedProjectRoot == projectRoot) {
        _selectedProjectRoot = _selectedProjectRoots.isEmpty
            ? null
            : _selectedProjectRoots.first;
      }
    }
    if (!changed) return;
    _currentPlan = null;
    notifyListeners();
  }

  void selectAllProjects(Iterable<String> projectRoots) {
    var changed = false;
    for (final root in projectRoots) {
      if (_selectedProjectRoots.add(root)) {
        changed = true;
      }
    }
    if (_selectedProjectRoot == null && _selectedProjectRoots.isNotEmpty) {
      _selectedProjectRoot = _selectedProjectRoots.first;
      changed = true;
    }
    if (!changed) return;
    _currentPlan = null;
    notifyListeners();
  }

  void clearProjectSelection() {
    if (_selectedProjectRoots.isEmpty) return;
    _selectedProjectRoots.clear();
    _selectedProjectRoot = null;
    _currentPlan = null;
    notifyListeners();
  }

  void toggleProjectTargetSelection(String targetId, bool selected) {
    final root = _selectedProjectRoot;
    if (root == null) return;
    toggleProjectTargetSelectionForProject(root, targetId, selected);
  }

  void toggleProjectTargetSelectionForProject(
    String projectRoot,
    String targetId,
    bool selected,
  ) {
    final current = _selectedTargetsByProject[projectRoot] ?? <String>{};
    if (selected) {
      current.add(targetId);
    } else {
      current.remove(targetId);
    }
    _selectedTargetsByProject[projectRoot] = current;
    _currentPlan = null;
    notifyListeners();
  }

  Future<void> scanNow() async {
    if (_isScanning) return;
    final activeRoots = _roots.where((root) => root.trim().isNotEmpty).toList();
    if (activeRoots.isEmpty) {
      _setError('No scan roots configured. Add at least one root in Settings.');
      return;
    }

    _clearError();
    _isScanning = true;
    _statusMessage = null;
    _progressDone = null;
    _progressTotal = null;
    _scanCancellationToken = CancellationToken();
    notifyListeners();

    try {
      final request = ScanRequest(
        roots: activeRoots,
        profile: _profile,
        includeGlobal: false,
        maxDepth: 5,
      );
      ScanResult? result;
      await for (final event in _scanService.scan(
        request,
        cancellationToken: _scanCancellationToken,
      )) {
        _statusMessage = event.message;
        _progressDone = event.progressDone;
        _progressTotal = event.progressTotal;
        if (event.isDone) {
          result = event.result;
        }
        notifyListeners();
      }

      if (result != null) {
        _scanResult = result;
        final file = await _logWriter.writeScanResult(result);
        _scanLogPath = file.path;
        _initProjectSelection(result);
        _currentPlan = null;
        await refreshHistory();
      }
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _scanCancellationToken = null;
      _isScanning = false;
      _statusMessage = null;
      _progressDone = null;
      _progressTotal = null;
      notifyListeners();
      await refreshFvmStatus();
      await refreshGlobalCaches();
    }
  }

  void cancelScan() {
    _scanCancellationToken?.cancel();
  }

  void previewPlanForSelectedProject() {
    _clearError();
    final project = selectedProject;
    if (project == null) {
      _setError('No project selected.');
      return;
    }
    _selectedProjectRoots
      ..clear()
      ..add(project.rootPath);
    previewPlanForSelectedProjects();
  }

  void previewPlanForSelectedProjects() {
    _clearError();
    final scan = _scanResult;
    if (scan == null) {
      _setError('No scan result available.');
      return;
    }
    if (_selectedProjectRoots.isEmpty) {
      _setError('Select at least one project for cleanup.');
      return;
    }

    final selectedProjects = scan.projects
        .where((project) => project.totalBytes > 0)
        .where((project) => _selectedProjectRoots.contains(project.rootPath))
        .toList(growable: false);
    if (selectedProjects.isEmpty) {
      _setError('Selected projects are not available in the current scan.');
      return;
    }

    final selectedTargetIds = <String>{};
    for (final project in selectedProjects) {
      selectedTargetIds.addAll(
        _selectedTargetsByProject[project.rootPath] ?? const <String>{},
      );
    }

    final selectedProjectScan = ScanResult(
      startedAt: scan.startedAt,
      finishedAt: scan.finishedAt,
      profile: scan.profile,
      cancelled: scan.cancelled,
      projects: selectedProjects,
    );

    try {
      _currentPlan = _cleanupPlanner.createPlan(
        scan: selectedProjectScan,
        deleteMode: _deleteMode,
        targetIds: selectedTargetIds,
        allowUnknown: _allowUnknown,
      );
      notifyListeners();
    } on Exception catch (e) {
      _setError(e.toString());
    }
  }

  Future<CleanupResult?> applyCurrentPlan() async {
    if (_isApplying) return null;
    final plan = _currentPlan;
    if (plan == null) return null;

    _clearError();
    _isApplying = true;
    _statusMessage = null;
    _progressDone = null;
    _progressTotal = null;
    _applyCancellationToken = CancellationToken();
    notifyListeners();

    CleanupResult? result;
    try {
      await for (final event in _cleanupExecutor.execute(
        plan,
        allowUnknown: _allowUnknown,
        cancellationToken: _applyCancellationToken,
      )) {
        _statusMessage = event.message;
        _progressDone = event.progressDone;
        _progressTotal = event.progressTotal;
        if (event.isDone) {
          result = event.result;
        }
        notifyListeners();
      }

      if (result != null) {
        _lastCleanupResult = result;
        final file = await _logWriter.writeCleanupResult(result);
        _cleanupLogPath = file.path;
        _currentPlan = null;
        await refreshHistory();
      }
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _applyCancellationToken = null;
      _isApplying = false;
      _statusMessage = null;
      _progressDone = null;
      _progressTotal = null;
      notifyListeners();
    }

    if (result != null) {
      await scanNow();
    }

    return result;
  }

  void toggleGlobalTargetSelection(String targetId, bool selected) {
    if (selected) {
      _selectedGlobalTargetIds.add(targetId);
    } else {
      _selectedGlobalTargetIds.remove(targetId);
    }
    _globalCleanupPlan = null;
    notifyListeners();
  }

  void toggleXcodeTargetSelection(String targetPath, bool selected) {
    final path = targetPath.trim();
    if (path.isEmpty) return;
    if (selected) {
      _selectedXcodeTargetPaths.add(path);
    } else {
      _selectedXcodeTargetPaths.remove(path);
    }
    _xcodeCleanupPlan = null;
    notifyListeners();
  }

  Future<void> refreshXcodeCaches() => refreshGlobalCaches();

  Future<void> refreshGlobalCaches() async {
    if (_isRefreshingGlobalCaches || _isScanning) return;
    _clearError();
    _isRefreshingGlobalCaches = true;
    notifyListeners();

    try {
      final request = const ScanRequest(
        roots: <String>[],
        profile: Profile.aggressive,
        includeGlobal: true,
        maxDepth: 0,
      );

      ScanResult? result;
      await for (final event in _scanService.scan(request)) {
        if (event.isDone) {
          result = event.result;
        }
      }

      if (result == null) return;
      _globalCacheTargets =
          result.globalTargets
              .where((target) => target.path.trim().isNotEmpty)
              .where((target) => target.sizeBytes > 0)
              .toList()
            ..sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
      _xcodeTargets =
          result.xcodeTargets
              .where((target) => target.path.trim().isNotEmpty)
              .where((target) => target.sizeBytes > 0)
              .toList()
            ..sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));

      _selectedGlobalTargetIds
        ..clear()
        ..addAll(
          _globalCacheTargets
              .where((target) => target.exists && target.sizeBytes > 0)
              .map((target) => target.targetId),
        );
      _selectedXcodeTargetPaths
        ..clear()
        ..addAll(
          _xcodeTargets
              .where((target) => target.exists && target.sizeBytes > 0)
              .where((target) => _allowUnknown || !target.hasUnknownAttribution)
              .map((target) => target.path),
        );

      final file = await _logWriter.writeScanResult(result);
      _globalScanLogPath = file.path;
      _xcodeScanLogPath = file.path;
      _globalCleanupPlan = null;
      _xcodeCleanupPlan = null;
      await refreshHistory();
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _isRefreshingGlobalCaches = false;
      notifyListeners();
    }
  }

  void previewGlobalCleanupPlan() {
    _clearError();
    if (!_dangerZoneConfirmed) {
      _setError(
        'Enable Danger Zone confirmation before previewing global cleanup.',
      );
      return;
    }

    final scan = ScanResult(
      startedAt: DateTime.now().toUtc(),
      finishedAt: DateTime.now().toUtc(),
      profile: Profile.aggressive,
      cancelled: false,
      projects: const <ProjectScanResult>[],
      globalTargets: _globalCacheTargets,
    );

    try {
      _globalCleanupPlan = _cleanupPlanner.createPlan(
        scan: scan,
        deleteMode: _deleteMode,
        targetIds: _selectedGlobalTargetIds,
        allowUnknown: _allowUnknown,
      );
      notifyListeners();
    } on Exception catch (e) {
      _setError(e.toString());
    }
  }

  Future<CleanupResult?> applyGlobalCleanupPlan() async {
    if (_isApplying) return null;
    if (!_dangerZoneConfirmed) {
      _setError('Enable Danger Zone confirmation before applying.');
      return null;
    }
    final plan = _globalCleanupPlan;
    if (plan == null) return null;

    _clearError();
    _isApplying = true;
    _statusMessage = null;
    _progressDone = null;
    _progressTotal = null;
    _applyCancellationToken = CancellationToken();
    notifyListeners();

    CleanupResult? result;
    try {
      await for (final event in _cleanupExecutor.execute(
        plan,
        allowUnknown: _allowUnknown,
        cancellationToken: _applyCancellationToken,
      )) {
        _statusMessage = event.message;
        _progressDone = event.progressDone;
        _progressTotal = event.progressTotal;
        if (event.isDone) {
          result = event.result;
        }
        notifyListeners();
      }

      if (result != null) {
        _lastGlobalCleanupResult = result;
        _lastCleanupResult = result;
        final file = await _logWriter.writeCleanupResult(result);
        _cleanupLogPath = file.path;
        _globalCleanupPlan = null;
        await refreshHistory();
      }
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _applyCancellationToken = null;
      _isApplying = false;
      _statusMessage = null;
      _progressDone = null;
      _progressTotal = null;
      notifyListeners();
    }

    if (result != null) {
      await refreshGlobalCaches();
    }
    return result;
  }

  void previewXcodeCleanupPlan() {
    _clearError();
    if (!_dangerZoneConfirmed) {
      _setError(
        'Enable Danger Zone confirmation before previewing Xcode cleanup.',
      );
      return;
    }

    final selectedTargets = _xcodeTargets
        .where((target) => _selectedXcodeTargetPaths.contains(target.path))
        .toList();

    final scan = ScanResult(
      startedAt: DateTime.now().toUtc(),
      finishedAt: DateTime.now().toUtc(),
      profile: Profile.aggressive,
      cancelled: false,
      projects: const <ProjectScanResult>[],
      xcodeTargets: selectedTargets,
      globalTargets: const <TargetScanResult>[],
    );

    try {
      _xcodeCleanupPlan = _cleanupPlanner.createPlan(
        scan: scan,
        deleteMode: _deleteMode,
        allowUnknown: _allowUnknown,
      );
      notifyListeners();
    } on Exception catch (e) {
      _setError(e.toString());
    }
  }

  Future<CleanupResult?> applyXcodeCleanupPlan() async {
    if (_isApplying) return null;
    if (!_dangerZoneConfirmed) {
      _setError('Enable Danger Zone confirmation before applying.');
      return null;
    }

    final plan = _xcodeCleanupPlan;
    if (plan == null) return null;

    _clearError();
    _isApplying = true;
    _statusMessage = null;
    _progressDone = null;
    _progressTotal = null;
    _applyCancellationToken = CancellationToken();
    notifyListeners();

    CleanupResult? result;
    try {
      await for (final event in _cleanupExecutor.execute(
        plan,
        allowUnknown: _allowUnknown,
        cancellationToken: _applyCancellationToken,
      )) {
        _statusMessage = event.message;
        _progressDone = event.progressDone;
        _progressTotal = event.progressTotal;
        if (event.isDone) {
          result = event.result;
        }
        notifyListeners();
      }

      if (result != null) {
        _lastXcodeCleanupResult = result;
        _lastCleanupResult = result;
        final file = await _logWriter.writeCleanupResult(result);
        _cleanupLogPath = file.path;
        _xcodeCleanupPlan = null;
        await refreshHistory();
      }
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _applyCancellationToken = null;
      _isApplying = false;
      _statusMessage = null;
      _progressDone = null;
      _progressTotal = null;
      notifyListeners();
    }

    if (result != null) {
      await refreshGlobalCaches();
    }
    return result;
  }

  void cancelApply() {
    _applyCancellationToken?.cancel();
  }

  Future<void> refreshFvmStatus() async {
    if (_isRefreshingFvm) return;
    _isRefreshingFvm = true;
    notifyListeners();

    try {
      final projectRoots = projects
          .map((project) => project.rootPath)
          .toSet()
          .toList(growable: false);
      _fvmResult = await _fvmService.inspect(projectRoots: projectRoots);
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _isRefreshingFvm = false;
      notifyListeners();
    }
  }

  Future<FvmRemovalResult?> removeFvmSdk(String sdkName) async {
    if (_isRemovingFvmSdk) return null;
    _clearError();
    _isRemovingFvmSdk = true;
    notifyListeners();

    try {
      final result = await _fvmService.removeSdk(sdkName);
      _lastFvmRemovalResult = result;
      if (!result.success) {
        final message =
            result.error ?? result.stderr ?? 'Failed to remove SDK.';
        _setError(message);
      } else {
        await refreshFvmStatus();
        await refreshHistory();
      }
      return result;
    } on Exception catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _isRemovingFvmSdk = false;
      notifyListeners();
    }
  }

  Future<void> refreshHistory() async {
    if (_isRefreshingHistory) return;
    _isRefreshingHistory = true;
    notifyListeners();

    try {
      _historyEntries = await _runHistoryService.listRuns(limit: 200);
    } on Exception catch (e) {
      _setError(e.toString());
    } finally {
      _isRefreshingHistory = false;
      notifyListeners();
    }
  }

  Future<void> openPath(String path) async {
    final value = path.trim();
    if (value.isEmpty) return;

    String executable;
    List<String> arguments;
    if (Platform.isMacOS) {
      executable = 'open';
      arguments = <String>[value];
    } else if (Platform.isWindows) {
      executable = 'explorer';
      arguments = <String>[value];
    } else if (Platform.isLinux) {
      executable = 'xdg-open';
      arguments = <String>[value];
    } else {
      _setError('Open folder is not supported on this OS.');
      return;
    }

    try {
      final result = await Process.run(executable, arguments);
      if (result.exitCode != 0) {
        _setError('Failed to open path: ${result.stderr}');
      }
    } on ProcessException catch (e) {
      _setError(e.toString());
    }
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void _initProjectSelection(ScanResult scan) {
    final reclaimableProjects = scan.projects
        .where((project) => project.totalBytes > 0)
        .toList(growable: false);
    final reclaimableRoots = reclaimableProjects
        .map((project) => project.rootPath)
        .toSet();
    final previousSelection = Set<String>.from(
      _selectedProjectRoots,
    ).where(reclaimableRoots.contains);

    _selectedTargetsByProject.removeWhere(
      (projectRoot, _) => !reclaimableRoots.contains(projectRoot),
    );
    for (final project in reclaimableProjects) {
      _selectedTargetsByProject.putIfAbsent(
        project.rootPath,
        () => project.targets
            .where((target) => target.exists && target.sizeBytes > 0)
            .map((target) => target.targetId)
            .toSet(),
      );
    }

    _selectedProjectRoots
      ..clear()
      ..addAll(previousSelection);

    if (_selectedProjectRoot != null &&
        !reclaimableRoots.contains(_selectedProjectRoot)) {
      _selectedProjectRoot = null;
    }

    if (reclaimableProjects.isEmpty) {
      _selectedProjectRoot = null;
      return;
    }

    _selectedProjectRoot ??= _selectedProjectRoots.isEmpty
        ? reclaimableProjects.first.rootPath
        : _selectedProjectRoots.first;

    if (_selectedProjectRoot != null) {
      _selectedProjectRoots.add(_selectedProjectRoot!);
    }
  }

  void _saveDesktopSettingsIfReady() {
    if (!_isInitialized) return;
    unawaited(_saveDesktopSettings());
  }

  Future<void> _saveDesktopSettings() async {
    try {
      final file = File(_desktopSettingsFilePath());
      await file.parent.create(recursive: true);
      final settings = _DesktopSettings(
        onboardingCompleted: _onboardingCompleted,
        localeCode: _locale.languageCode,
        roots: _roots,
        profile: _profile.toJsonValue(),
        deleteMode: _deleteMode.toJsonValue(),
        allowUnknown: _allowUnknown,
      );
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString('${encoder.convert(settings.toJson())}\n');
    } on Exception {
      // Keep settings persistence best-effort to avoid blocking UX.
    }
  }

  Future<_DesktopSettings?> _loadDesktopSettings() async {
    final file = File(_desktopSettingsFilePath());
    if (!await file.exists()) {
      return null;
    }
    try {
      final text = await file.readAsString();
      final decoded = jsonDecode(text);
      if (decoded is! Map) {
        return null;
      }
      final map = Map<String, Object?>.from(decoded.cast<String, Object?>());
      return _DesktopSettings.fromJson(map);
    } on Exception {
      return null;
    }
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}

List<String> _buildInitialRoots() {
  final home = _resolveHomePath();
  if (home == null || home.isEmpty) {
    return const <String>[];
  }
  if (!Directory(home).existsSync()) {
    return const <String>[];
  }
  return <String>[home];
}

List<String> _buildOnboardingRootShortcuts(String? home) {
  if (home == null || home.isEmpty) {
    return const <String>[];
  }
  final shortcuts = <String>[
    home,
    _joinPath(home, 'Developer'),
    _joinPath(home, 'dev'),
    _joinPath(home, 'Projects'),
    _joinPath(home, 'workspace'),
  ];
  final existing = <String>{};
  for (final root in shortcuts) {
    if (Directory(root).existsSync()) {
      existing.add(Directory(root).absolute.path);
    }
  }
  return existing.toList(growable: false);
}

String? _resolveHomePath() {
  final env = Platform.environment;
  final candidates = <String>[];

  void addCandidate(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return;
    candidates.add(normalized);
  }

  if (Platform.isWindows) {
    addCandidate(env['USERPROFILE']);
    addCandidate(env['HOME']);
  } else {
    addCandidate(env['HOME']);
    addCandidate(env['USERPROFILE']);
  }

  final drive = env['HOMEDRIVE']?.trim();
  final path = env['HOMEPATH']?.trim();
  if (drive != null && drive.isNotEmpty && path != null && path.isNotEmpty) {
    addCandidate('$drive$path');
  }

  for (final candidate in candidates) {
    if (Directory(candidate).existsSync()) {
      return candidate;
    }
  }
  if (candidates.isNotEmpty) {
    return candidates.first;
  }
  return null;
}

String? _normalizeRoot(String value) {
  var root = value.trim();
  if (root.isEmpty) {
    return null;
  }

  if (root == '~' || root.startsWith('~/') || root.startsWith('~\\')) {
    final home = _resolveHomePath();
    if (home != null) {
      if (root == '~') {
        root = home;
      } else {
        root = _joinPath(home, root.substring(2));
      }
    }
  }

  return Directory(root).absolute.path;
}

String _joinPath(String base, String child) {
  final separator = Platform.pathSeparator;
  if (base.endsWith(separator)) {
    return '$base$child';
  }
  return '$base$separator$child';
}

String _desktopSettingsFilePath() {
  final logsDir = defaultRunLogDir();
  final rootDir = Directory(logsDir).parent.path;
  return _joinPath(rootDir, 'desktop_settings.json');
}

class _DesktopSettings {
  const _DesktopSettings({
    required this.onboardingCompleted,
    required this.localeCode,
    required this.roots,
    required this.profile,
    required this.deleteMode,
    required this.allowUnknown,
  });

  final bool onboardingCompleted;
  final String localeCode;
  final List<String> roots;
  final String profile;
  final String deleteMode;
  final bool allowUnknown;

  Map<String, Object?> toJson() => {
    'schemaVersion': 1,
    'onboardingCompleted': onboardingCompleted,
    'localeCode': localeCode,
    'roots': roots,
    'profile': profile,
    'deleteMode': deleteMode,
    'allowUnknown': allowUnknown,
  };

  Locale get locale => _localeFromCode(localeCode);
  Profile get parsedProfile => _profileFromJson(profile);
  DeleteMode get parsedDeleteMode => _deleteModeFromJson(deleteMode);

  static _DesktopSettings? fromJson(Map<String, Object?> json) {
    final localeCode = json['localeCode'];
    final profile = json['profile'];
    final deleteMode = json['deleteMode'];
    final rootsRaw = json['roots'];

    if (localeCode is! String ||
        profile is! String ||
        deleteMode is! String ||
        rootsRaw is! List) {
      return null;
    }

    final roots = rootsRaw
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final onboardingRaw = json['onboardingCompleted'];
    final onboardingCompleted = onboardingRaw is bool
        ? onboardingRaw
        : roots.isNotEmpty;

    return _DesktopSettings(
      onboardingCompleted: onboardingCompleted,
      localeCode: localeCode.trim().isEmpty ? 'en' : localeCode.trim(),
      roots: roots,
      profile: profile,
      deleteMode: deleteMode,
      allowUnknown: json['allowUnknown'] == true,
    );
  }
}

Locale _localeFromCode(String value) {
  final code = value.trim().toLowerCase();
  if (code == 'ko') return const Locale('ko');
  return const Locale('en');
}

Profile _profileFromJson(String value) {
  for (final profile in Profile.values) {
    if (profile.toJsonValue() == value) {
      return profile;
    }
  }
  return Profile.safe;
}

DeleteMode _deleteModeFromJson(String value) {
  for (final mode in DeleteMode.values) {
    if (mode.toJsonValue() == value) {
      return mode;
    }
  }
  return DeleteMode.trash;
}
