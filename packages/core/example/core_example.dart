import 'dart:io';

import 'package:fluttrim_core/fluttrim_core.dart';

Future<void> main(List<String> args) async {
  final roots = args.isEmpty ? [Directory.current.path] : args;
  final service = ScanService();

  await for (final event in service.scan(ScanRequest(roots: roots))) {
    if (event.isDone) {
      stdout.writeln(event.result!.toJson());
    } else if (event.message != null) {
      stderr.writeln(event.message);
    }
  }
}
