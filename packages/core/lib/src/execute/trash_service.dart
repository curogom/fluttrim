import 'dart:io';

import 'package:path/path.dart' as p;

abstract class TrashService {
  const TrashService();

  Future<void> moveToTrash(String absolutePath);
}

class SystemTrashService extends TrashService {
  const SystemTrashService();

  @override
  Future<void> moveToTrash(String absolutePath) async {
    final normalized = p.normalize(absolutePath);
    final type = await FileSystemEntity.type(normalized, followLinks: false);
    if (type == FileSystemEntityType.notFound) return;

    if (Platform.isMacOS) {
      await _moveToTrashMacOS(normalized);
      return;
    }
    if (Platform.isLinux) {
      await _moveToTrashLinux(normalized);
      return;
    }
    if (Platform.isWindows) {
      await _moveToTrashWindows(normalized);
      return;
    }
    throw TrashOperationException(
      'Trash mode is not supported on ${Platform.operatingSystem}.',
    );
  }
}

class TrashOperationException implements Exception {
  TrashOperationException(this.message);

  final String message;

  @override
  String toString() => 'TrashOperationException: $message';
}

Future<void> _moveToTrashMacOS(String path) async {
  final home = Platform.environment['HOME'];
  if (home == null || home.isEmpty) {
    throw TrashOperationException('HOME is not set.');
  }
  final trashDir = Directory(p.join(home, '.Trash'));
  await trashDir.create(recursive: true);
  final destination = await _uniqueDestination(trashDir.path, p.basename(path));
  await _movePath(path, destination);
}

Future<void> _moveToTrashLinux(String path) async {
  final gioPath = await _resolveExecutable('gio');
  if (gioPath != null) {
    final result = await Process.run(gioPath, ['trash', path]);
    if (result.exitCode == 0) {
      return;
    }
  }

  final home = Platform.environment['HOME'];
  if (home == null || home.isEmpty) {
    throw TrashOperationException('HOME is not set.');
  }

  final trashRoot = Directory(p.join(home, '.local', 'share', 'Trash'));
  final filesDir = Directory(p.join(trashRoot.path, 'files'));
  final infoDir = Directory(p.join(trashRoot.path, 'info'));
  await filesDir.create(recursive: true);
  await infoDir.create(recursive: true);

  final destination = await _uniqueDestination(filesDir.path, p.basename(path));
  final destinationBase = p.basename(destination);
  final infoPath = p.join(infoDir.path, '$destinationBase.trashinfo');
  final deletionDate = DateTime.now()
      .toLocal()
      .toIso8601String()
      .split('.')
      .first;

  await _movePath(path, destination);
  await File(infoPath).writeAsString(
    '[Trash Info]\n'
    'Path=${_encodeTrashInfoPath(path)}\n'
    'DeletionDate=$deletionDate\n',
  );
}

Future<void> _moveToTrashWindows(String path) async {
  const script = r'''
$target = $env:FLUTTRIM_TRASH_TARGET
if ([string]::IsNullOrWhiteSpace($target)) {
  throw "FLUTTRIM_TRASH_TARGET was not provided."
}
Add-Type -AssemblyName Microsoft.VisualBasic
if (Test-Path -LiteralPath $target -PathType Container) {
  [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory(
    $target,
    [Microsoft.VisualBasic.FileIO.UIOption]::OnlyErrorDialogs,
    [Microsoft.VisualBasic.FileIO.RecycleOption]::SendToRecycleBin
  )
  exit 0
}
if (Test-Path -LiteralPath $target -PathType Leaf) {
  [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(
    $target,
    [Microsoft.VisualBasic.FileIO.UIOption]::OnlyErrorDialogs,
    [Microsoft.VisualBasic.FileIO.RecycleOption]::SendToRecycleBin
  )
  exit 0
}
exit 0
''';

  Future<ProcessResult> runPowerShell(String executable) {
    return Process.run(
      executable,
      ['-NoProfile', '-NonInteractive', '-Command', script],
      environment: {'FLUTTRIM_TRASH_TARGET': path},
    );
  }

  ProcessResult result;
  try {
    result = await runPowerShell('powershell');
  } on ProcessException {
    try {
      result = await runPowerShell('pwsh');
    } on ProcessException {
      throw TrashOperationException(
        'PowerShell is unavailable, cannot use Recycle Bin.',
      );
    }
  }

  if (result.exitCode != 0) {
    throw TrashOperationException(
      'Recycle Bin operation failed: ${result.stderr}',
    );
  }
}

Future<String> _uniqueDestination(String trashDirPath, String baseName) async {
  var candidate = p.join(trashDirPath, baseName);
  if (await FileSystemEntity.type(candidate, followLinks: false) ==
      FileSystemEntityType.notFound) {
    return candidate;
  }

  final timestamp = DateTime.now().millisecondsSinceEpoch;
  var index = 1;
  while (true) {
    final next = p.join(trashDirPath, '$baseName.$timestamp.$index');
    if (await FileSystemEntity.type(next, followLinks: false) ==
        FileSystemEntityType.notFound) {
      return next;
    }
    index++;
  }
}

Future<void> _movePath(String from, String to) async {
  try {
    final type = await FileSystemEntity.type(from, followLinks: false);
    switch (type) {
      case FileSystemEntityType.file:
        await File(from).rename(to);
        return;
      case FileSystemEntityType.directory:
        await Directory(from).rename(to);
        return;
      case FileSystemEntityType.link:
        await Link(from).rename(to);
        return;
      case FileSystemEntityType.notFound:
        return;
      case FileSystemEntityType.pipe:
      case FileSystemEntityType.unixDomainSock:
      default:
        break;
    }
    return;
  } on FileSystemException {
    // Cross-device moves can fail on rename; shell mv handles copy+delete.
  }

  final result = await Process.run('mv', [from, to]);
  if (result.exitCode != 0) {
    throw TrashOperationException(
      'Failed to move "$from" to trash: ${result.stderr}',
    );
  }
}

String _encodeTrashInfoPath(String path) {
  final absolute = p.normalize(path).replaceAll('\\', '/');
  final segments = absolute.split('/');
  return segments.map(Uri.encodeComponent).join('/');
}

Future<String?> _resolveExecutable(String executable) async {
  final whichCmd = Platform.isWindows ? 'where' : 'which';
  try {
    final result = await Process.run(whichCmd, [executable]);
    if (result.exitCode != 0) return null;
    final text = (result.stdout as String).trim();
    if (text.isEmpty) return null;
    return text.split(RegExp(r'[\r\n]+')).first;
  } on ProcessException {
    return null;
  }
}
