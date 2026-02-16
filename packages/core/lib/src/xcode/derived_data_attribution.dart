import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/attribution_status.dart';

class DerivedDataAttribution {
  const DerivedDataAttribution({
    required this.status,
    required this.projectRootPath,
    required this.confidence,
    required this.evidencePath,
  });

  const DerivedDataAttribution.none()
    : status = AttributionStatus.none,
      projectRootPath = null,
      confidence = null,
      evidencePath = null;

  const DerivedDataAttribution.unknown({this.evidencePath})
    : status = AttributionStatus.unknown,
      projectRootPath = null,
      confidence = null;

  const DerivedDataAttribution.attributed({
    required this.projectRootPath,
    required this.confidence,
    this.evidencePath,
  }) : status = AttributionStatus.attributed;

  final AttributionStatus status;
  final String? projectRootPath;
  final double? confidence;
  final String? evidencePath;
}

Future<DerivedDataAttribution> attributeDerivedDataDirectory(
  Directory derivedDataDirectory,
) async {
  final infoPlist = File(p.join(derivedDataDirectory.path, 'Info.plist'));
  if (!await infoPlist.exists()) {
    return const DerivedDataAttribution.unknown();
  }

  final workspacePath = await _readPlistStringValue(infoPlist, 'WorkspacePath');
  if (workspacePath != null) {
    final projectRoot = await _findFlutterProjectRoot(workspacePath);
    if (projectRoot != null) {
      return DerivedDataAttribution.attributed(
        projectRootPath: projectRoot,
        confidence: 0.95,
        evidencePath: workspacePath,
      );
    }
  }

  final projectPath = await _readPlistStringValue(infoPlist, 'ProjectPath');
  if (projectPath != null) {
    final projectRoot = await _findFlutterProjectRoot(projectPath);
    if (projectRoot != null) {
      return DerivedDataAttribution.attributed(
        projectRootPath: projectRoot,
        confidence: 0.85,
        evidencePath: projectPath,
      );
    }
  }

  return DerivedDataAttribution.unknown(
    evidencePath: workspacePath ?? projectPath,
  );
}

Future<String?> _readPlistStringValue(File plistFile, String key) async {
  try {
    final text = await plistFile.readAsString();
    final xmlValue = _extractXmlPlistValue(text, key);
    if (xmlValue != null) {
      return xmlValue;
    }

    if (text.startsWith('bplist')) {
      return _readPlistValueWithPlUtil(plistFile.path, key);
    }
  } on FileSystemException {
    return null;
  }

  return _readPlistValueWithPlUtil(plistFile.path, key);
}

String? _extractXmlPlistValue(String text, String key) {
  final pattern = RegExp(
    '<key>\\s*${RegExp.escape(key)}\\s*</key>\\s*<string>(.*?)</string>',
    dotAll: true,
  );
  final match = pattern.firstMatch(text);
  if (match == null) return null;
  final value = match.group(1)?.trim();
  if (value == null || value.isEmpty) return null;

  return value
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'");
}

Future<String?> _readPlistValueWithPlUtil(String plistPath, String key) async {
  if (!Platform.isMacOS) return null;

  try {
    final result = await Process.run('/usr/bin/plutil', [
      '-extract',
      key,
      'raw',
      '-o',
      '-',
      plistPath,
    ]);
    if (result.exitCode != 0) return null;
    final value = (result.stdout as String).trim();
    if (value.isEmpty || value == 'null') return null;
    return value;
  } on ProcessException {
    return null;
  }
}

Future<String?> _findFlutterProjectRoot(String workspaceOrProjectPath) async {
  var cursor = p.normalize(workspaceOrProjectPath);
  if (_isWorkspaceOrProject(cursor)) {
    cursor = p.dirname(cursor);
  }

  var depth = 0;
  while (depth < 12) {
    if (await _isFlutterProjectRoot(cursor)) {
      return p.normalize(cursor);
    }
    final parent = p.dirname(cursor);
    if (parent == cursor) break;
    cursor = parent;
    depth++;
  }

  return null;
}

bool _isWorkspaceOrProject(String path) {
  final base = p.basename(path).toLowerCase();
  return base.endsWith('.xcworkspace') || base.endsWith('.xcodeproj');
}

Future<bool> _isFlutterProjectRoot(String dirPath) async {
  final pubspec = File(p.join(dirPath, 'pubspec.yaml'));
  if (!await pubspec.exists()) return false;

  final metadata = File(p.join(dirPath, '.metadata'));
  if (await metadata.exists()) return true;

  final iosDir = Directory(p.join(dirPath, 'ios'));
  if (await iosDir.exists()) return true;

  final androidDir = Directory(p.join(dirPath, 'android'));
  if (await androidDir.exists()) return true;

  return false;
}
