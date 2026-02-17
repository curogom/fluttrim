import 'dart:async';
import 'dart:io';

import 'package:fluttrim_core/fluttrim_core.dart';
import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {
  AppController() {
    _roots = _buildInitialRoots();
    Future<void>.microtask(refreshFvmStatus);
    Future<void>.microtask(refreshGlobalCaches);
    Future<void>.microtask(refreshHistory);
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
  String? _statusMessage;
  int? _progressDone;
  int? _progressTotal;
  CancellationToken? _scanCancellationToken;
  CancellationToken? _applyCancellationToken;

  ScanResult? _scanResult;
  String? _scanLogPath;
  String? _selectedProjectRoot;
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
  String? get statusMessage => _statusMessage;
  int? get progressDone => _progressDone;
  int? get progressTotal => _progressTotal;

  ScanResult? get scanResult => _scanResult;
  String? get scanLogPath => _scanLogPath;
  List<ProjectScanResult> get projects =>
      _scanResult?.projects ?? const <ProjectScanResult>[];
  String? get selectedProjectRoot => _selectedProjectRoot;
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
    return Set<String>.unmodifiable(
      _selectedTargetsByProject[root] ?? <String>{},
    );
  }

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void setProfile(Profile profile) {
    if (_profile == profile) return;
    _profile = profile;
    _currentPlan = null;
    notifyListeners();
  }

  void setDeleteMode(DeleteMode mode) {
    if (_deleteMode == mode) return;
    _deleteMode = mode;
    _currentPlan = null;
    notifyListeners();
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
  }

  void removeRoot(String root) {
    _roots = _roots.where((value) => value != root).toList();
    if (_roots.isEmpty) {
      _roots = _buildInitialRoots();
    }
    notifyListeners();
  }

  void selectProject(String projectRoot) {
    if (_selectedProjectRoot == projectRoot) return;
    _selectedProjectRoot = projectRoot;
    _currentPlan = null;
    notifyListeners();
  }

  void toggleProjectTargetSelection(String targetId, bool selected) {
    final root = _selectedProjectRoot;
    if (root == null) return;
    final current = _selectedTargetsByProject[root] ?? <String>{};
    if (selected) {
      current.add(targetId);
    } else {
      current.remove(targetId);
    }
    _selectedTargetsByProject[root] = current;
    _currentPlan = null;
    notifyListeners();
  }

  Future<void> scanNow() async {
    if (_isScanning) return;
    _clearError();
    _isScanning = true;
    _statusMessage = null;
    _progressDone = null;
    _progressTotal = null;
    _scanCancellationToken = CancellationToken();
    notifyListeners();

    try {
      final request = ScanRequest(
        roots: _roots,
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
    final scan = _scanResult;
    final project = selectedProject;
    if (scan == null || project == null) {
      _setError('No project selected.');
      return;
    }
    final selectedIds =
        _selectedTargetsByProject[project.rootPath] ?? <String>{};

    final singleProjectScan = ScanResult(
      startedAt: scan.startedAt,
      finishedAt: scan.finishedAt,
      profile: scan.profile,
      cancelled: scan.cancelled,
      projects: <ProjectScanResult>[project],
    );

    try {
      _currentPlan = _cleanupPlanner.createPlan(
        scan: singleProjectScan,
        deleteMode: _deleteMode,
        targetIds: selectedIds,
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
              .toList()
            ..sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
      _xcodeTargets =
          result.xcodeTargets
              .where((target) => target.path.trim().isNotEmpty)
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
      _fvmResult = await _fvmService.inspect(
        projectRoots: projects.map((project) => project.rootPath).toList(),
      );
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
    _selectedTargetsByProject.clear();
    for (final project in scan.projects) {
      final existingIds = project.targets
          .where((target) => target.exists)
          .map((target) => target.targetId)
          .toSet();
      _selectedTargetsByProject[project.rootPath] = existingIds;
    }

    if (scan.projects.isEmpty) {
      _selectedProjectRoot = null;
      return;
    }
    if (_selectedProjectRoot != null &&
        scan.projects.any((p) => p.rootPath == _selectedProjectRoot)) {
      return;
    }
    _selectedProjectRoot = scan.projects.first.rootPath;
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
    return <String>[Directory.current.path];
  }

  final candidates = <String>[
    _joinPath(home, 'Developer'),
    _joinPath(home, 'dev'),
    _joinPath(home, 'Dev'),
    _joinPath(home, 'Projects'),
    _joinPath(home, 'workspace'),
    _joinPath(home, 'Work'),
  ];

  final existing = <String>[];
  for (final candidate in candidates) {
    if (Directory(candidate).existsSync()) {
      existing.add(candidate);
    }
  }

  if (existing.isNotEmpty) {
    return existing;
  }

  if (Directory(home).existsSync()) {
    return <String>[home];
  }

  return <String>[Directory.current.path];
}

String? _resolveHomePath() {
  final env = Platform.environment;

  final home = env['HOME']?.trim();
  if (home != null && home.isNotEmpty) {
    return home;
  }

  final userProfile = env['USERPROFILE']?.trim();
  if (userProfile != null && userProfile.isNotEmpty) {
    return userProfile;
  }

  final drive = env['HOMEDRIVE']?.trim();
  final path = env['HOMEPATH']?.trim();
  if (drive != null && drive.isNotEmpty && path != null && path.isNotEmpty) {
    return '$drive$path';
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
