class DoctorResult {
  const DoctorResult({
    required this.osName,
    required this.osVersion,
    required this.cachePaths,
    required this.tools,
  });

  final String osName;
  final String osVersion;
  final List<CachePathStatus> cachePaths;
  final List<ToolStatus> tools;

  Map<String, Object?> toJson() => {
    'osName': osName,
    'osVersion': osVersion,
    'cachePaths': cachePaths.map((e) => e.toJson()).toList(),
    'tools': tools.map((e) => e.toJson()).toList(),
  };
}

class CachePathStatus {
  const CachePathStatus({
    required this.id,
    required this.path,
    required this.exists,
  });

  final String id;
  final String path;
  final bool exists;

  Map<String, Object?> toJson() => {'id': id, 'path': path, 'exists': exists};
}

class ToolStatus {
  const ToolStatus({
    required this.name,
    required this.available,
    this.resolvedPath,
  });

  final String name;
  final bool available;
  final String? resolvedPath;

  Map<String, Object?> toJson() => {
    'name': name,
    'available': available,
    'resolvedPath': resolvedPath,
  };
}
