import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../cancellation/cancellation_token.dart';
import '../global/global_cache_paths.dart';
import '../models/cache_category.dart';
import '../models/cleanup_event.dart';
import '../models/cleanup_plan.dart';
import '../models/cleanup_result.dart';
import '../models/delete_mode.dart';
import '../targets/target_registry.dart';
import 'trash_service.dart';
import '../xcode/xcode_cache_paths.dart';

class CleanupExecutor {
  CleanupExecutor({TrashService trashService = const SystemTrashService()})
    : _trashService = trashService;

  final TrashService _trashService;

  Stream<CleanupEvent> execute(
    CleanupPlan plan, {
    bool allowUnknown = false,
    CancellationToken? cancellationToken,
  }) {
    final controller = StreamController<CleanupEvent>();
    final token = cancellationToken ?? CancellationToken();

    () async {
      final startedAt = DateTime.now().toUtc();
      final results = <CleanupItemResult>[];

      try {
        var index = 0;
        for (final item in plan.items) {
          token.throwIfCancelled();
          index++;
          controller.add(
            CleanupEvent.validating(
              progressDone: index,
              progressTotal: plan.items.length,
              currentPath: item.path,
              message: 'Validating ${item.targetId}',
            ),
          );

          final validationError = _validatePlanItem(item, plan, allowUnknown);
          if (validationError != null) {
            results.add(
              CleanupItemResult(
                targetId: item.targetId,
                path: item.path,
                status: CleanupItemStatus.failed,
                reclaimedBytes: 0,
                error: validationError,
              ),
            );
            continue;
          }

          controller.add(
            CleanupEvent.deleting(
              progressDone: index,
              progressTotal: plan.items.length,
              currentPath: item.path,
              message: 'Deleting ${item.targetId}',
            ),
          );

          final type = await FileSystemEntity.type(
            item.path,
            followLinks: false,
          );
          if (type == FileSystemEntityType.notFound) {
            results.add(
              CleanupItemResult(
                targetId: item.targetId,
                path: item.path,
                status: CleanupItemStatus.skipped,
                reclaimedBytes: 0,
                error: 'Path does not exist.',
              ),
            );
            continue;
          }

          try {
            if (plan.deleteMode == DeleteMode.trash) {
              await _trashService.moveToTrash(item.path);
            } else {
              await _deletePermanent(item.path, type);
            }
            results.add(
              CleanupItemResult(
                targetId: item.targetId,
                path: item.path,
                status: CleanupItemStatus.success,
                reclaimedBytes: item.sizeBytes,
              ),
            );
          } on Exception catch (e) {
            results.add(
              CleanupItemResult(
                targetId: item.targetId,
                path: item.path,
                status: CleanupItemStatus.failed,
                reclaimedBytes: 0,
                error: e.toString(),
              ),
            );
          }
        }
      } on CancelledException {
        // The partially completed results are still surfaced.
      } finally {
        final finishedAt = DateTime.now().toUtc();
        controller.add(
          CleanupEvent.done(
            CleanupResult(
              startedAt: startedAt,
              finishedAt: finishedAt,
              profile: plan.profile,
              deleteMode: plan.deleteMode,
              allowUnknown: allowUnknown,
              items: results,
            ),
          ),
        );
        await controller.close();
      }
    }();

    return controller.stream;
  }
}

String? _validatePlanItem(
  CleanupPlanItem item,
  CleanupPlan plan,
  bool allowUnknown,
) {
  final target = TargetRegistry.byId(item.targetId);
  if (target == null) {
    return 'Unknown targetId: ${item.targetId}';
  }

  if (!target.isIncludedIn(plan.profile)) {
    return 'Target is not eligible for profile: ${plan.profile.name}';
  }

  if (target.category != item.category) {
    return 'Target/category mismatch.';
  }

  if (item.hasUnknownAttribution && !allowUnknown) {
    return 'Unknown-attribution targets are blocked by default.';
  }

  if (target.category == CacheCategory.project) {
    if (target.projectRelativePath == null) {
      return 'Project target is missing projectRelativePath.';
    }
    final root = item.projectRootPath;
    if (root == null || root.isEmpty) {
      return 'Project target is missing projectRootPath.';
    }
    final normalizedRoot = p.normalize(root);
    final normalizedPath = p.normalize(item.path);
    if (!(p.equals(normalizedRoot, normalizedPath) ||
        p.isWithin(normalizedRoot, normalizedPath))) {
      return 'Path escapes project root.';
    }

    final expectedPath = p.normalize(
      p.join(normalizedRoot, target.projectRelativePath),
    );
    if (!p.equals(expectedPath, normalizedPath)) {
      return 'Path is not allowlisted for target ${target.id}.';
    }
  }

  if (target.category == CacheCategory.global) {
    final expectedPath = resolveGlobalCachePathByTargetId(target.id);
    if (expectedPath == null) {
      return 'Global target is not supported on this OS.';
    }
    final normalizedItemPath = p.normalize(item.path);
    final normalizedExpected = p.normalize(expectedPath);
    if (!p.equals(normalizedItemPath, normalizedExpected)) {
      return 'Path is not allowlisted for global target ${target.id}.';
    }
  }

  if (target.category == CacheCategory.xcode) {
    final derivedDataRoot = resolveXcodeDerivedDataPath();
    if (derivedDataRoot == null) {
      return 'Xcode target is not supported on this OS.';
    }

    final normalizedItemPath = p.normalize(item.path);
    final normalizedRoot = p.normalize(derivedDataRoot);
    if (p.equals(normalizedItemPath, normalizedRoot)) {
      return 'Deleting the DerivedData root directly is not allowed.';
    }
    if (!p.isWithin(normalizedRoot, normalizedItemPath)) {
      return 'Path escapes Xcode DerivedData root.';
    }
  }

  return null;
}

Future<void> _deletePermanent(String path, FileSystemEntityType type) async {
  switch (type) {
    case FileSystemEntityType.file:
      await File(path).delete();
      break;
    case FileSystemEntityType.directory:
      await Directory(path).delete(recursive: true);
      break;
    case FileSystemEntityType.link:
      await Link(path).delete();
      break;
    case FileSystemEntityType.notFound:
      return;
    case FileSystemEntityType.pipe:
      throw const FileSystemException('Cannot delete named pipe entry.');
    case FileSystemEntityType.unixDomainSock:
      throw const FileSystemException('Cannot delete unix socket entry.');
    default:
      throw FileSystemException('Unsupported filesystem type: $type');
  }
}
