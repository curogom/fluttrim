/// Aggregated FVM environment and usage inspection result.
class FvmResult {
  /// Creates an FVM inspection result.
  const FvmResult({
    required this.available,
    required this.executablePath,
    required this.version,
    required this.installedSdks,
    required this.projectUsages,
    this.error,
  });

  /// Whether `fvm` executable is available.
  final bool available;

  /// Resolved `fvm` executable path, when available.
  final String? executablePath;

  /// FVM version output, when available.
  final String? version;

  /// Locally installed SDKs known to FVM.
  final List<FvmInstalledSdk> installedSdks;

  /// Per-project FVM pin usage entries.
  final List<FvmProjectUsage> projectUsages;

  /// Fatal inspection error, when inspection failed.
  final String? error;

  /// Serializes result payload as JSON.
  Map<String, Object?> toJson() => {
    'available': available,
    'executablePath': executablePath,
    'version': version,
    'installedSdks': installedSdks.map((e) => e.toJson()).toList(),
    'projectUsages': projectUsages.map((e) => e.toJson()).toList(),
    'error': error,
  };
}

/// Result of `fvm remove <sdk>`.
class FvmRemovalResult {
  /// Creates an SDK removal result.
  const FvmRemovalResult({
    required this.sdkName,
    required this.success,
    required this.exitCode,
    this.stdout,
    this.stderr,
    this.error,
  });

  /// SDK name requested for removal.
  final String sdkName;

  /// Whether the command exited successfully.
  final bool success;

  /// Raw process exit code.
  final int exitCode;

  /// Captured standard output.
  final String? stdout;

  /// Captured standard error.
  final String? stderr;

  /// Error text when execution failed before process completion.
  final String? error;

  /// Serializes result payload as JSON.
  Map<String, Object?> toJson() => {
    'sdkName': sdkName,
    'success': success,
    'exitCode': exitCode,
    'stdout': stdout,
    'stderr': stderr,
    'error': error,
  };
}

/// One SDK installation managed by FVM.
class FvmInstalledSdk {
  /// Creates an installed SDK entry.
  const FvmInstalledSdk({
    required this.name,
    required this.directory,
    required this.type,
    required this.isSetup,
    required this.usedByProjectRoots,
    this.flutterSdkVersion,
    this.dartSdkVersion,
  });

  /// FVM SDK identifier (usually Flutter version).
  final String name;

  /// Local filesystem path of the SDK.
  final String directory;

  /// FVM channel/type metadata.
  final String type;

  /// Whether the SDK is fully set up.
  final bool isSetup;

  /// Flutter SDK semantic version, when provided by FVM.
  final String? flutterSdkVersion;

  /// Dart SDK semantic version, when provided by FVM.
  final String? dartSdkVersion;

  /// Project roots currently pinned to this SDK.
  final List<String> usedByProjectRoots;

  /// Returns `true` when at least one project uses this SDK.
  bool get isUsed => usedByProjectRoots.isNotEmpty;

  /// Serializes entry as JSON.
  Map<String, Object?> toJson() => {
    'name': name,
    'directory': directory,
    'type': type,
    'isSetup': isSetup,
    'flutterSdkVersion': flutterSdkVersion,
    'dartSdkVersion': dartSdkVersion,
    'usedByProjectRoots': usedByProjectRoots,
    'isUsed': isUsed,
  };
}

/// FVM usage status for one project root.
class FvmProjectUsage {
  /// Creates an FVM project usage entry.
  const FvmProjectUsage({
    required this.projectRoot,
    required this.projectName,
    required this.hasConfig,
    required this.isFlutterProject,
    required this.pinnedVersion,
    required this.installedLocally,
  });

  /// Absolute project root path.
  final String projectRoot;

  /// Human-friendly project name.
  final String projectName;

  /// Whether `.fvm`/FVM config exists for the project.
  final bool hasConfig;

  /// Whether the project is detected as a Flutter project.
  final bool isFlutterProject;

  /// Pinned SDK version from FVM config.
  final String? pinnedVersion;

  /// Whether pinned SDK exists in local FVM installs.
  final bool installedLocally;

  /// Returns `true` when the project has a non-empty pinned version.
  bool get usesFvm => pinnedVersion != null && pinnedVersion!.trim().isNotEmpty;

  /// Serializes entry as JSON.
  Map<String, Object?> toJson() => {
    'projectRoot': projectRoot,
    'projectName': projectName,
    'hasConfig': hasConfig,
    'isFlutterProject': isFlutterProject,
    'pinnedVersion': pinnedVersion,
    'usesFvm': usesFvm,
    'installedLocally': installedLocally,
  };
}
