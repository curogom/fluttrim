/// Environment diagnostics reported by [DoctorService].
class DoctorResult {
  /// Creates a doctor diagnostics result.
  const DoctorResult({
    required this.osName,
    required this.osVersion,
    required this.cachePaths,
    required this.tools,
  });

  /// OS name (for example `macos`, `linux`, `windows`).
  final String osName;

  /// Raw OS version string from the platform.
  final String osVersion;

  /// Known cache path existence checks.
  final List<CachePathStatus> cachePaths;

  /// Tool availability checks.
  final List<ToolStatus> tools;

  /// Serializes diagnostics payload as JSON.
  Map<String, Object?> toJson() => {
    'osName': osName,
    'osVersion': osVersion,
    'cachePaths': cachePaths.map((e) => e.toJson()).toList(),
    'tools': tools.map((e) => e.toJson()).toList(),
  };
}

/// Existence status for a cache path.
class CachePathStatus {
  /// Creates a cache path status entry.
  const CachePathStatus({
    required this.id,
    required this.path,
    required this.exists,
  });

  /// Stable target id for the cache path.
  final String id;

  /// Absolute path that was checked.
  final String path;

  /// Whether the path exists.
  final bool exists;

  /// Serializes status payload as JSON.
  Map<String, Object?> toJson() => {'id': id, 'path': path, 'exists': exists};
}

/// Availability status for one executable.
class ToolStatus {
  /// Creates a tool status entry.
  const ToolStatus({
    required this.name,
    required this.available,
    this.resolvedPath,
  });

  /// Executable name that was checked.
  final String name;

  /// Whether the executable is currently available in PATH.
  final bool available;

  /// Resolved absolute executable path when available.
  final String? resolvedPath;

  /// Serializes status payload as JSON.
  Map<String, Object?> toJson() => {
    'name': name,
    'available': available,
    'resolvedPath': resolvedPath,
  };
}
