class FvmResult {
  const FvmResult({
    required this.available,
    required this.executablePath,
    required this.version,
    required this.installedSdks,
    required this.projectUsages,
    this.error,
  });

  final bool available;
  final String? executablePath;
  final String? version;
  final List<FvmInstalledSdk> installedSdks;
  final List<FvmProjectUsage> projectUsages;
  final String? error;

  Map<String, Object?> toJson() => {
    'available': available,
    'executablePath': executablePath,
    'version': version,
    'installedSdks': installedSdks.map((e) => e.toJson()).toList(),
    'projectUsages': projectUsages.map((e) => e.toJson()).toList(),
    'error': error,
  };
}

class FvmRemovalResult {
  const FvmRemovalResult({
    required this.sdkName,
    required this.success,
    required this.exitCode,
    this.stdout,
    this.stderr,
    this.error,
  });

  final String sdkName;
  final bool success;
  final int exitCode;
  final String? stdout;
  final String? stderr;
  final String? error;

  Map<String, Object?> toJson() => {
    'sdkName': sdkName,
    'success': success,
    'exitCode': exitCode,
    'stdout': stdout,
    'stderr': stderr,
    'error': error,
  };
}

class FvmInstalledSdk {
  const FvmInstalledSdk({
    required this.name,
    required this.directory,
    required this.type,
    required this.isSetup,
    required this.usedByProjectRoots,
    this.flutterSdkVersion,
    this.dartSdkVersion,
  });

  final String name;
  final String directory;
  final String type;
  final bool isSetup;
  final String? flutterSdkVersion;
  final String? dartSdkVersion;
  final List<String> usedByProjectRoots;

  bool get isUsed => usedByProjectRoots.isNotEmpty;

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

class FvmProjectUsage {
  const FvmProjectUsage({
    required this.projectRoot,
    required this.projectName,
    required this.hasConfig,
    required this.isFlutterProject,
    required this.pinnedVersion,
    required this.installedLocally,
  });

  final String projectRoot;
  final String projectName;
  final bool hasConfig;
  final bool isFlutterProject;
  final String? pinnedVersion;
  final bool installedLocally;

  bool get usesFvm => pinnedVersion != null && pinnedVersion!.trim().isNotEmpty;

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
