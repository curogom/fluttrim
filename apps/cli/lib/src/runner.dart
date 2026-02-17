import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:fluttrim_core/fluttrim_core.dart';

const toolName = 'fluttrim';
const toolVersion = '1.0.2';

Future<void> runCli(List<String> arguments) async {
  exitCode = await _run(arguments);
}

Future<int> _run(List<String> arguments) async {
  final parser = _buildParser();
  final ArgResults root;

  try {
    root = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln('');
    _printTopLevelUsage(parser);
    return 64;
  }

  if ((root['version'] as bool)) {
    stdout.writeln('$toolName $toolVersion');
    return 0;
  }

  if ((root['help'] as bool) || root.command == null) {
    _printTopLevelUsage(parser);
    return 0;
  }

  final command = root.command!;
  try {
    switch (command.name) {
      case 'scan':
        if (_helpRequested(command, parser, 'scan')) return 0;
        return _runScanCommand(command);
      case 'plan':
        if (_helpRequested(command, parser, 'plan')) return 0;
        return _runPlanCommand(command);
      case 'apply':
        if (_helpRequested(command, parser, 'apply')) return 0;
        return _runApplyCommand(command);
      case 'doctor':
        if (_helpRequested(command, parser, 'doctor')) return 0;
        return _runDoctorCommand(command);
      default:
        stderr.writeln('Unknown command: ${command.name}');
        _printTopLevelUsage(parser);
        return 64;
    }
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    return 64;
  } on InvalidPlanException catch (e) {
    stderr.writeln(e.toString());
    return 1;
  } on Exception catch (e) {
    stderr.writeln('Error: $e');
    return 1;
  }
}

ArgParser _buildParser() {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show help.')
    ..addFlag('version', negatable: false, help: 'Print version.');

  parser.addCommand('scan', _scanParser(includeDeleteModeFlags: false));
  parser.addCommand('plan', _scanParser(includeDeleteModeFlags: true));
  parser.addCommand('apply', _applyParser());
  parser.addCommand('doctor', _doctorParser());
  return parser;
}

ArgParser _scanParser({required bool includeDeleteModeFlags}) {
  final parser = _scanOptionsParser()
    ..addFlag('json', negatable: false, help: 'Output JSON.')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show command help.');

  if (includeDeleteModeFlags) {
    parser
      ..addFlag(
        'trash',
        defaultsTo: true,
        help: 'Set plan delete mode to trash (default).',
      )
      ..addFlag(
        'permanent',
        negatable: false,
        help: 'Set plan delete mode to permanent.',
      )
      ..addFlag(
        'allow-unknown',
        defaultsTo: false,
        help: 'Include unknown-attribution targets in cleanup plan.',
      );
  }

  return parser;
}

ArgParser _applyParser() {
  return _scanOptionsParser()
    ..addFlag('json', negatable: false, help: 'Output JSON.')
    ..addFlag(
      'yes',
      abbr: 'y',
      negatable: false,
      help: 'Skip confirmation prompt.',
    )
    ..addFlag('trash', defaultsTo: true, help: 'Delete mode trash (default).')
    ..addFlag(
      'permanent',
      negatable: false,
      help: 'Delete mode permanent. Requires --yes.',
    )
    ..addFlag(
      'allow-unknown',
      defaultsTo: false,
      help: 'Allow deleting unknown-attribution items (off by default).',
    )
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show command help.');
}

ArgParser _doctorParser() {
  return ArgParser()
    ..addFlag('json', negatable: false, help: 'Output JSON.')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show command help.');
}

ArgParser _scanOptionsParser() {
  return ArgParser()
    ..addMultiOption(
      'root',
      abbr: 'r',
      help:
          'Root directory to scan (repeatable). Defaults to current directory.',
    )
    ..addOption(
      'profile',
      defaultsTo: 'safe',
      allowed: ['safe', 'medium', 'aggressive'],
      help: 'Cleanup profile.',
    )
    ..addMultiOption('exclude', help: 'Exclude pattern (repeatable).')
    ..addOption(
      'max-depth',
      defaultsTo: '5',
      help: 'Project discovery depth from each root.',
    )
    ..addFlag(
      'include-global',
      defaultsTo: false,
      help: 'Include global cache discovery (v1+).',
    );
}

bool _helpRequested(ArgResults cmd, ArgParser rootParser, String commandName) {
  if ((cmd['help'] as bool)) {
    _printCommandUsage(rootParser, commandName);
    return true;
  }
  return false;
}

void _printTopLevelUsage(ArgParser parser) {
  stdout.writeln('Usage: $toolName <command> [options]');
  stdout.writeln('');
  stdout.writeln('Commands:');
  stdout.writeln('  scan    Scan Flutter project caches.');
  stdout.writeln('  plan    Generate cleanup plan (no deletion).');
  stdout.writeln('  apply   Execute cleanup plan.');
  stdout.writeln('  doctor  Print environment/tool diagnostics.');
  stdout.writeln('');
  stdout.writeln(parser.usage);
}

void _printCommandUsage(ArgParser rootParser, String commandName) {
  final command = rootParser.commands[commandName];
  if (command == null) return;
  stdout.writeln('Usage: $toolName $commandName [options]');
  stdout.writeln(command.usage);
}

Future<int> _runScanCommand(ArgResults cmd) async {
  final request = _scanRequestFrom(cmd);
  final jsonMode = cmd['json'] as bool;
  final scan = await _scanAndCollect(request, jsonMode: jsonMode);

  final logger = const RunLogWriter();
  final logFile = await logger.writeScanResult(scan);

  if (jsonMode) {
    _writeJson(scan.toJson());
  } else {
    stdout.writeln('Profile: ${scan.profile.toJsonValue()}');
    stdout.writeln('Projects: ${scan.projects.length}');
    stdout.writeln('Total: ${_formatBytes(scan.totalBytes)}');
    stdout.writeln('');
    _printProjectRows(scan.projects);
    stdout.writeln('');
    _printCategoryTotals(scan);
  }

  stderr.writeln('Scan log: ${logFile.path}');
  return scan.cancelled ? 130 : 0;
}

Future<int> _runPlanCommand(ArgResults cmd) async {
  final request = _scanRequestFrom(cmd);
  final jsonMode = cmd['json'] as bool;
  final deleteMode = _deleteModeFromFlags(cmd);
  final allowUnknown = (cmd['allow-unknown'] as bool?) ?? false;
  final scan = await _scanAndCollect(request, jsonMode: jsonMode);
  if (scan.cancelled) return 130;
  final plan = const CleanupPlanner().createPlan(
    scan: scan,
    deleteMode: deleteMode,
    allowUnknown: allowUnknown,
  );

  if (jsonMode) {
    _writeJson(plan.toJson());
    return 0;
  }

  stdout.writeln('Delete mode: ${plan.deleteMode.toJsonValue()}');
  stdout.writeln('Items: ${plan.items.length}');
  stdout.writeln('Total: ${_formatBytes(plan.totalBytes)}');
  if (plan.warnings.isNotEmpty) {
    stdout.writeln('Warnings:');
    for (final warning in plan.warnings) {
      stdout.writeln('- $warning');
    }
  }
  stdout.writeln('');
  _printPlanRows(plan);
  return 0;
}

Future<int> _runApplyCommand(ArgResults cmd) async {
  final request = _scanRequestFrom(cmd);
  final jsonMode = cmd['json'] as bool;
  final yes = cmd['yes'] as bool;
  final allowUnknown = cmd['allow-unknown'] as bool;
  final deleteMode = _deleteModeFromFlags(cmd);

  if (deleteMode == DeleteMode.permanent && !yes) {
    stderr.writeln(
      'Permanent deletion requires --yes for explicit confirmation.',
    );
    return 64;
  }

  final scan = await _scanAndCollect(request, jsonMode: jsonMode);
  if (scan.cancelled) return 130;
  final plan = const CleanupPlanner().createPlan(
    scan: scan,
    deleteMode: deleteMode,
    allowUnknown: allowUnknown,
  );

  if (plan.items.isEmpty) {
    if (jsonMode) {
      final now = DateTime.now().toUtc();
      final noOpResult = CleanupResult(
        startedAt: now,
        finishedAt: now,
        profile: plan.profile,
        deleteMode: plan.deleteMode,
        allowUnknown: allowUnknown,
        items: const <CleanupItemResult>[],
      );
      _writeJson(noOpResult.toJson());
    } else {
      stdout.writeln('Nothing to clean for selected profile/roots.');
    }
    return 0;
  }

  if (!jsonMode) {
    stdout.writeln('Plan created: ${plan.items.length} items');
    stdout.writeln('Estimated reclaimable: ${_formatBytes(plan.totalBytes)}');
    stdout.writeln('Delete mode: ${plan.deleteMode.toJsonValue()}');
    if (plan.warnings.isNotEmpty) {
      stdout.writeln('Warnings:');
      for (final warning in plan.warnings) {
        stdout.writeln('- $warning');
      }
    }
  }

  if (!yes) {
    final approved = _confirmApply(plan);
    if (!approved) {
      stdout.writeln('Cancelled by user.');
      return 0;
    }
  }

  final token = CancellationToken();
  final sigSub = _installSigIntCancellation(token);
  try {
    final executor = CleanupExecutor();
    CleanupResult? result;
    await for (final event in executor.execute(
      plan,
      allowUnknown: allowUnknown,
      cancellationToken: token,
    )) {
      if (!jsonMode && event.phase == CleanupPhase.deleting) {
        _emitProgress(
          event.progressDone,
          event.progressTotal,
          event.currentPath,
        );
      }
      if (event.isDone) {
        result = event.result;
      }
    }

    if (result == null) {
      stderr.writeln('Cleanup did not produce a result.');
      return 1;
    }

    final logger = const RunLogWriter();
    final logFile = await logger.writeCleanupResult(result);

    if (jsonMode) {
      _writeJson(result.toJson());
    } else {
      stdout.writeln('');
      stdout.writeln('Cleanup completed.');
      stdout.writeln('Success: ${result.successCount}');
      stdout.writeln('Failed: ${result.failureCount}');
      stdout.writeln('Skipped: ${result.skippedCount}');
      stdout.writeln('Reclaimed: ${_formatBytes(result.reclaimedBytes)}');
      _printCleanupFailures(result);
    }

    stderr.writeln('Cleanup log: ${logFile.path}');
    return result.failureCount > 0 ? 1 : 0;
  } finally {
    await sigSub.cancel();
  }
}

Future<int> _runDoctorCommand(ArgResults cmd) async {
  final jsonMode = cmd['json'] as bool;
  final doctor = await const DoctorService().run();

  if (jsonMode) {
    _writeJson(doctor.toJson());
    return 0;
  }

  stdout.writeln('OS: ${doctor.osName}');
  stdout.writeln('Version: ${doctor.osVersion}');
  stdout.writeln('');
  stdout.writeln('Detected cache paths:');
  _printRows(<List<String>>[
    ['ID', 'Exists', 'Path'],
    ...doctor.cachePaths.map((p) => [p.id, p.exists ? 'yes' : 'no', p.path]),
  ]);
  stdout.writeln('');
  stdout.writeln('Tool availability:');
  _printRows(<List<String>>[
    ['Tool', 'Available', 'Path'],
    ...doctor.tools.map(
      (t) => [t.name, t.available ? 'yes' : 'no', t.resolvedPath ?? '-'],
    ),
  ]);
  return 0;
}

ScanRequest _scanRequestFrom(ArgResults cmd) {
  final rootsRaw = (cmd['root'] as List<String>).map((e) => e.trim()).toList();
  final roots = rootsRaw.where((e) => e.isNotEmpty).toList();
  final maxDepthRaw = cmd['max-depth'] as String;
  final maxDepth = int.tryParse(maxDepthRaw);
  if (maxDepth == null || maxDepth < 0) {
    throw FormatException('--max-depth must be a non-negative integer.');
  }

  return ScanRequest(
    roots: roots.isEmpty ? [Directory.current.path] : roots,
    profile: profileFromJsonValue(cmd['profile'] as String),
    includeGlobal: cmd['include-global'] as bool,
    maxDepth: maxDepth,
    exclusions: (cmd['exclude'] as List<String>)
        .where((e) => e.trim().isNotEmpty)
        .toList(),
  );
}

DeleteMode _deleteModeFromFlags(ArgResults cmd) {
  final permanent = (cmd['permanent'] as bool?) ?? false;
  final trash = (cmd['trash'] as bool?) ?? true;
  if (permanent) return DeleteMode.permanent;
  if (trash) return DeleteMode.trash;
  return DeleteMode.trash;
}

Future<ScanResult> _scanAndCollect(
  ScanRequest request, {
  required bool jsonMode,
}) async {
  final token = CancellationToken();
  final sigSub = _installSigIntCancellation(token);
  try {
    final service = const ScanService();
    ScanResult? result;
    await for (final event in service.scan(request, cancellationToken: token)) {
      if (!jsonMode && event.phase != ScanPhase.done) {
        _emitProgress(
          event.progressDone,
          event.progressTotal,
          event.currentPath,
        );
      }
      if (event.isDone) {
        result = event.result;
      }
    }
    if (result == null) {
      throw StateError('Scan finished without result.');
    }
    return result;
  } finally {
    await sigSub.cancel();
  }
}

StreamSubscription<ProcessSignal> _installSigIntCancellation(
  CancellationToken token,
) {
  try {
    return ProcessSignal.sigint.watch().listen((_) {
      if (token.isCancelled) return;
      token.cancel();
      stderr.writeln('');
      stderr.writeln('Cancellation requested. Finishing current step...');
    });
  } on Exception {
    return const Stream<ProcessSignal>.empty().listen((_) {});
  }
}

void _emitProgress(int? done, int? total, String? path) {
  final progress = (done != null && total != null && total > 0)
      ? '[$done/$total]'
      : '[..]';
  final suffix = (path == null || path.isEmpty) ? '' : ' $path';
  stderr.writeln('$progress$suffix');
}

void _printProjectRows(List<ProjectScanResult> projects) {
  final sorted = [...projects]
    ..sort((a, b) => b.totalBytes.compareTo(a.totalBytes));
  final rows = <List<String>>[
    ['Project', 'Total', 'Path'],
    ...sorted.map((p) => [p.name, _formatBytes(p.totalBytes), p.rootPath]),
  ];
  _printRows(rows);
}

void _printCategoryTotals(ScanResult scan) {
  final rows = <List<String>>[
    ['Category', 'Total'],
    ...scan.totalsByCategory.entries.map(
      (e) => [e.key.toJsonValue(), _formatBytes(e.value)],
    ),
  ];
  _printRows(rows);
}

void _printPlanRows(CleanupPlan plan) {
  final rows = <List<String>>[
    ['Target', 'Risk', 'Size', 'Path'],
    ...plan.items.map(
      (i) => [
        i.targetId,
        i.risk.toJsonValue(),
        _formatBytes(i.sizeBytes),
        i.path,
      ],
    ),
  ];
  _printRows(rows);
}

void _printCleanupFailures(CleanupResult result) {
  final failures = result.items
      .where((item) => item.status == CleanupItemStatus.failed)
      .toList();
  if (failures.isEmpty) return;

  stdout.writeln('');
  stdout.writeln('Failures:');
  for (final failure in failures) {
    stdout.writeln('- ${failure.path}');
    if (failure.error != null && failure.error!.isNotEmpty) {
      stdout.writeln('  ${failure.error}');
    }
  }
}

bool _confirmApply(CleanupPlan plan) {
  stdout.writeln('');
  stdout.writeln(
    'Apply cleanup for ${plan.items.length} item(s), reclaim ~${_formatBytes(plan.totalBytes)}?',
  );
  stdout.write('Type "yes" to continue: ');
  final input = stdin.readLineSync()?.trim().toLowerCase();
  return input == 'yes';
}

void _printRows(List<List<String>> rows) {
  if (rows.isEmpty) return;

  final widths = <int>[];
  for (var i = 0; i < rows.first.length; i++) {
    var max = 0;
    for (final row in rows) {
      if (i >= row.length) continue;
      final len = row[i].length;
      if (len > max) max = len;
    }
    widths.add(max);
  }

  for (var r = 0; r < rows.length; r++) {
    final row = rows[r];
    final cells = <String>[];
    for (var c = 0; c < widths.length; c++) {
      final value = c < row.length ? row[c] : '';
      final isLast = c == widths.length - 1;
      cells.add(isLast ? value : value.padRight(widths[c]));
    }
    stdout.writeln(cells.join('  '));
    if (r == 0) {
      stdout.writeln(widths.map((w) => ''.padRight(w, '-')).join('  '));
    }
  }
}

void _writeJson(Map<String, Object?> jsonMap) {
  final encoder = const JsonEncoder.withIndent('  ');
  stdout.writeln(encoder.convert(jsonMap));
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var idx = -1;
  while (value >= 1024 && idx < units.length - 1) {
    value /= 1024;
    idx++;
  }
  return '${value.toStringAsFixed(value >= 10 ? 1 : 2)} ${units[idx]}';
}
