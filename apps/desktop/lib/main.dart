import 'dart:io';

import 'package:fluttrim_core/fluttrim_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_controller.dart';
import 'l10n/app_localizations.dart';

const _brandNavy = Color(0xFF060D1A);
const _brandSurface = Color(0xFF0E1A2E);
const _brandPrimary = Color(0xFF57C7FF);
const _brandSecondary = Color(0xFF69E7BE);
const _brandAccent = Color(0xFF3A8DFF);

void main() {
  runApp(const FluttrimApp());
}

class FluttrimApp extends StatefulWidget {
  const FluttrimApp({super.key});

  @override
  State<FluttrimApp> createState() => _FluttrimAppState();
}

class _FluttrimAppState extends State<FluttrimApp> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return MaterialApp(
          locale: _controller.locale,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ko')],
          theme: _buildFluttrimTheme(),
          home: HomeShell(controller: _controller),
        );
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showXcode = Platform.isMacOS;

    final pages = <_NavPage>[
      _NavPage(
        label: l10n.navDashboard,
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
        child: DashboardPage(controller: widget.controller),
      ),
      _NavPage(
        label: l10n.navProjects,
        icon: Icons.folder_outlined,
        selectedIcon: Icons.folder,
        child: ProjectsPage(controller: widget.controller),
      ),
      if (showXcode)
        _NavPage(
          label: l10n.navXcode,
          icon: Icons.developer_mode_outlined,
          selectedIcon: Icons.developer_mode,
          child: XcodePage(controller: widget.controller),
        ),
      _NavPage(
        label: l10n.navFlutterSdk,
        icon: Icons.tune_outlined,
        selectedIcon: Icons.tune,
        child: FvmPage(controller: widget.controller),
      ),
      _NavPage(
        label: l10n.navGlobalCaches,
        icon: Icons.public_outlined,
        selectedIcon: Icons.public,
        child: GlobalCachesPage(controller: widget.controller),
      ),
      _NavPage(
        label: l10n.navHistory,
        icon: Icons.history_outlined,
        selectedIcon: Icons.history,
        child: HistoryPage(controller: widget.controller),
      ),
      _NavPage(
        label: l10n.navSettings,
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        child: SettingsPage(controller: widget.controller),
      ),
    ];

    if (_selectedIndex >= pages.length) {
      _selectedIndex = 0;
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF050A14),
            Color(0xFF0A1630),
            Color(0xFF081D2C),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned(
              top: -160,
              right: -120,
              child: _GlowOrb(
                size: 360,
                color: _brandPrimary.withValues(alpha: 0.14),
              ),
            ),
            Positioned(
              bottom: -120,
              left: 180,
              child: _GlowOrb(
                size: 280,
                color: _brandSecondary.withValues(alpha: 0.12),
              ),
            ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _brandSurface.withValues(alpha: 0.78),
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  child: NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (idx) =>
                        setState(() => _selectedIndex = idx),
                    labelType: NavigationRailLabelType.all,
                    destinations: pages
                        .map(
                          (page) => NavigationRailDestination(
                            icon: Icon(page.icon),
                            selectedIcon: Icon(page.selectedIcon),
                            label: Text(page.label),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(child: pages[_selectedIndex].child),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scan = controller.scanResult;
    final progress = _progressValue(
      controller.progressDone,
      controller.progressTotal,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navDashboard),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: controller.isScanning
                ? OutlinedButton.icon(
                    onPressed: controller.cancelScan,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: Text(l10n.cancel),
                  )
                : FilledButton.icon(
                    onPressed: controller.scanNow,
                    icon: const Icon(Icons.search),
                    label: Text(l10n.scanNow),
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.errorMessage != null)
            _ErrorBanner(
              message: controller.errorMessage!,
              onDismiss: controller.clearErrorMessage,
            ),
          if (controller.isScanning || controller.isApplying) ...[
            Text(controller.statusMessage ?? l10n.working),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 16),
          ],
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                label: l10n.totalReclaimable,
                value: formatBytes(controller.totalReclaimableBytes),
              ),
              _MetricCard(
                label: l10n.projectsCount,
                value: '${controller.projects.length}',
              ),
              _MetricCard(
                label: l10n.profileLabel,
                value: _profileLabel(l10n, controller.profile),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text(l10n.lastScanLabel),
              subtitle: Text(
                scan == null
                    ? l10n.notScannedYet
                    : formatDateTime(scan.finishedAt),
              ),
            ),
          ),
          if (controller.scanLogPath != null)
            Card(
              child: ListTile(
                title: Text(l10n.latestScanLog),
                subtitle: Text(
                  controller.scanLogPath!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          if (controller.cleanupLogPath != null)
            Card(
              child: ListTile(
                title: Text(l10n.latestCleanupLog),
                subtitle: Text(
                  controller.cleanupLogPath!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final l10n = AppLocalizations.of(context)!;
    final search = _searchController.text.trim().toLowerCase();

    final filtered = controller.projects.where((project) {
      if (search.isEmpty) return true;
      return project.name.toLowerCase().contains(search) ||
          project.rootPath.toLowerCase().contains(search);
    }).toList()..sort((a, b) => b.totalBytes.compareTo(a.totalBytes));

    final selectedProject = controller.selectedProject;
    final selectedTargetIds = controller.selectedTargetIdsForSelectedProject();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProjects),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: controller.isScanning
                ? OutlinedButton.icon(
                    onPressed: controller.cancelScan,
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: Text(l10n.cancel),
                  )
                : FilledButton.icon(
                    onPressed: controller.scanNow,
                    icon: const Icon(Icons.search),
                    label: Text(l10n.scanNow),
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.errorMessage != null)
            _ErrorBanner(
              message: controller.errorMessage!,
              onDismiss: controller.clearErrorMessage,
            ),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.searchProjects,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SizedBox(
              height: 320,
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        controller.projects.isEmpty
                            ? l10n.scanToDiscoverProjects
                            : l10n.noMatchingProjects,
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final project = filtered[index];
                        final selected =
                            controller.selectedProjectRoot == project.rootPath;
                        return ListTile(
                          selected: selected,
                          title: Text(project.name),
                          subtitle: Text(
                            project.rootPath,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(formatBytes(project.totalBytes)),
                          onTap: () =>
                              controller.selectProject(project.rootPath),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: selectedProject == null
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.selectProjectForDetails),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.projectDetail}: ${selectedProject.name}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedProject.rootPath,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        ...selectedProject.targets.map((target) {
                          final checked = selectedTargetIds.contains(
                            target.targetId,
                          );
                          final targetDef = TargetRegistry.byId(
                            target.targetId,
                          );
                          final title =
                              targetDef?.projectRelativePath ?? target.targetId;
                          return CheckboxListTile(
                            value: checked,
                            onChanged: target.exists
                                ? (value) {
                                    controller.toggleProjectTargetSelection(
                                      target.targetId,
                                      value ?? false,
                                    );
                                  }
                                : null,
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(title),
                            subtitle: Text(
                              target.exists
                                  ? formatBytes(target.sizeBytes)
                                  : l10n.targetNotFound,
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed:
                                  controller.previewPlanForSelectedProject,
                              icon: const Icon(Icons.visibility_outlined),
                              label: Text(l10n.previewPlan),
                            ),
                            FilledButton.icon(
                              onPressed:
                                  controller.currentPlan == null ||
                                      controller.isApplying
                                  ? null
                                  : () => _onApplyPressed(context, controller),
                              icon: const Icon(
                                Icons.cleaning_services_outlined,
                              ),
                              label: Text(l10n.applyPlan),
                            ),
                          ],
                        ),
                        if (controller.currentPlan != null) ...[
                          const SizedBox(height: 12),
                          _PlanPreviewCard(
                            plan: controller.currentPlan!,
                            title: l10n.planPreview,
                          ),
                        ],
                        if (controller.lastCleanupResult != null) ...[
                          const SizedBox(height: 12),
                          _CleanupSummaryCard(
                            result: controller.lastCleanupResult!,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onApplyPressed(
    BuildContext context,
    AppController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final plan = controller.currentPlan;
    if (plan == null) return;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(l10n.confirmApplyTitle),
              content: Text(
                l10n.confirmApplyBody(
                  plan.items.length,
                  formatBytes(plan.totalBytes),
                  _deleteModeLabel(l10n, plan.deleteMode),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.applyPlan),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;
    await controller.applyCurrentPlan();
  }
}

class XcodePage extends StatelessWidget {
  const XcodePage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final targets = controller.xcodeTargets;
    final totalBytes = targets.fold<int>(
      0,
      (sum, target) => sum + target.sizeBytes,
    );
    final attributedCount = targets
        .where(
          (target) => target.attributionStatus == AttributionStatus.attributed,
        )
        .length;
    final unknownCount = targets
        .where(
          (target) => target.attributionStatus == AttributionStatus.unknown,
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navXcode),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: OutlinedButton.icon(
              onPressed: controller.isRefreshingGlobalCaches
                  ? null
                  : controller.refreshXcodeCaches,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.refresh),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.errorMessage != null)
            _ErrorBanner(
              message: controller.errorMessage!,
              onDismiss: controller.clearErrorMessage,
            ),
          if (controller.isRefreshingGlobalCaches) ...[
            Text(l10n.loadingXcodeCaches),
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                label: l10n.xcodeTotalDetected,
                value: formatBytes(totalBytes),
              ),
              _MetricCard(
                label: l10n.xcodeCacheItems,
                value: '${targets.length}',
              ),
              _MetricCard(
                label: l10n.xcodeAttributed,
                value: '$attributedCount',
              ),
              _MetricCard(label: l10n.xcodeUnknown, value: '$unknownCount'),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.xcodeDerivedDataTargets,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (targets.isEmpty)
                    Text(l10n.noXcodeCachesDetected)
                  else
                    ...targets.map((target) {
                      final selected = controller.selectedXcodeTargetPaths
                          .contains(target.path);
                      final blockedUnknown =
                          target.hasUnknownAttribution &&
                          !controller.allowUnknown;
                      final subtitleParts = <String>[
                        target.path,
                        target.exists
                            ? formatBytes(target.sizeBytes)
                            : l10n.targetNotFound,
                        _xcodeAttributionLabel(l10n, target),
                      ];
                      if (target.attributedProjectRootPath != null) {
                        subtitleParts.add(
                          '${l10n.project}: ${target.attributedProjectRootPath}',
                        );
                      }
                      if (target.attributionConfidence != null) {
                        subtitleParts.add(
                          '${l10n.confidence}: ${(target.attributionConfidence! * 100).toStringAsFixed(0)}%',
                        );
                      }
                      if (target.attributionEvidencePath != null &&
                          target.attributionEvidencePath!.isNotEmpty) {
                        subtitleParts.add(
                          '${l10n.evidence}: ${target.attributionEvidencePath}',
                        );
                      }
                      if (blockedUnknown) {
                        subtitleParts.add(l10n.xcodeUnknownBlockedHint);
                      }

                      return CheckboxListTile(
                        value: selected,
                        onChanged: target.exists && !blockedUnknown
                            ? (value) {
                                controller.toggleXcodeTargetSelection(
                                  target.path,
                                  value ?? false,
                                );
                              }
                            : null,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(_basenamePath(target.path)),
                        subtitle: Text(subtitleParts.join('\n')),
                        secondary: IconButton(
                          tooltip: l10n.openFolder,
                          onPressed: target.exists
                              ? () => controller.openPath(target.path)
                              : null,
                          icon: const Icon(Icons.open_in_new),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(
              context,
            ).colorScheme.errorContainer.withValues(alpha: 0.25),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dangerZoneTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.xcodeDangerDescription),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: controller.dangerZoneConfirmed,
                    onChanged: (value) =>
                        controller.setDangerZoneConfirmed(value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.xcodeDangerAcknowledge),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: controller.dangerZoneConfirmed
                            ? controller.previewXcodeCleanupPlan
                            : null,
                        icon: const Icon(Icons.preview_outlined),
                        label: Text(l10n.previewPlan),
                      ),
                      FilledButton.icon(
                        onPressed:
                            controller.isApplying ||
                                controller.xcodeCleanupPlan == null
                            ? null
                            : () => _confirmAndApplyXcode(context, controller),
                        icon: const Icon(Icons.delete_outline),
                        label: Text(l10n.applyPlan),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (controller.xcodeCleanupPlan != null) ...[
            const SizedBox(height: 12),
            _PlanPreviewCard(
              title: l10n.planPreview,
              plan: controller.xcodeCleanupPlan!,
            ),
          ],
          if (controller.lastXcodeCleanupResult != null) ...[
            const SizedBox(height: 12),
            _CleanupSummaryCard(result: controller.lastXcodeCleanupResult!),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmAndApplyXcode(
    BuildContext context,
    AppController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final plan = controller.xcodeCleanupPlan;
    if (plan == null) return;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(l10n.confirmApplyTitle),
              content: Text(
                l10n.confirmApplyBody(
                  plan.items.length,
                  formatBytes(plan.totalBytes),
                  _deleteModeLabel(l10n, plan.deleteMode),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.applyPlan),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;
    await controller.applyXcodeCleanupPlan();
  }
}

class FvmPage extends StatelessWidget {
  const FvmPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = controller.fvmResult;
    final installedSdks = result?.installedSdks ?? const <FvmInstalledSdk>[];
    final unusedSdks = installedSdks
        .where((sdk) => !sdk.isUsed)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navFlutterSdk),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: OutlinedButton.icon(
              onPressed: controller.isRefreshingFvm
                  ? null
                  : controller.refreshFvmStatus,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.refresh),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.errorMessage != null)
            _ErrorBanner(
              message: controller.errorMessage!,
              onDismiss: controller.clearErrorMessage,
            ),
          if (controller.lastFvmRemovalResult != null) ...[
            _FvmRemovalBanner(result: controller.lastFvmRemovalResult!),
            const SizedBox(height: 12),
          ],
          if (controller.isRefreshingFvm) ...[
            Text(l10n.loadingFvmStatus),
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: result == null
                  ? Text(l10n.noFvmDataYet)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.fvmStatus,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.available
                              ? l10n.fvmAvailable
                              : l10n.fvmUnavailable,
                        ),
                        if (result.version != null)
                          Text('${l10n.version}: ${result.version}'),
                        if (result.executablePath != null)
                          Text('${l10n.path}: ${result.executablePath}'),
                        if (result.error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              result.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.installedSdks,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (result == null || installedSdks.isEmpty)
                    Text(l10n.noData)
                  else
                    ...installedSdks.map(
                      (sdk) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(sdk.name),
                        subtitle: Text(
                          '${l10n.path}: ${sdk.directory}\n'
                          '${l10n.usedByProjects}: ${sdk.usedByProjectRoots.length}',
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text(
                                sdk.isSetup ? l10n.ready : l10n.notReady,
                              ),
                            ),
                            Chip(
                              label: Text(
                                sdk.isUsed ? l10n.sdkUsed : l10n.sdkUnused,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.fvmUnusedSdkCleanup,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (result == null || unusedSdks.isEmpty)
                    Text(l10n.fvmNoUnusedSdks)
                  else
                    ...unusedSdks.map(
                      (sdk) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(sdk.name),
                        subtitle: Text(
                          sdk.directory,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                        trailing: FilledButton.tonalIcon(
                          onPressed: controller.isRemovingFvmSdk
                              ? null
                              : () => _confirmAndRemoveSdk(context, sdk.name),
                          icon: const Icon(Icons.delete_outline),
                          label: Text(
                            controller.isRemovingFvmSdk
                                ? l10n.removeInProgress
                                : l10n.removeSdk,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.projectUsage,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (result == null || result.projectUsages.isEmpty)
                    Text(l10n.scanToLoadProjectUsage)
                  else
                    _SimpleTable(
                      columns: <String>[
                        l10n.project,
                        l10n.pinnedVersion,
                        l10n.installedLocally,
                      ],
                      rows: result.projectUsages
                          .map(
                            (usage) => <String>[
                              usage.projectName,
                              usage.pinnedVersion ?? '-',
                              usage.installedLocally ? l10n.yes : l10n.no,
                            ],
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndRemoveSdk(
    BuildContext context,
    String sdkName,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(l10n.removeSdkConfirmTitle),
              content: Text(l10n.removeSdkConfirmBody(sdkName)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.removeSdk),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;
    await controller.removeFvmSdk(sdkName);
  }
}

class GlobalCachesPage extends StatelessWidget {
  const GlobalCachesPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final targets = controller.globalCacheTargets;
    final totalBytes = targets.fold<int>(
      0,
      (sum, target) => sum + target.sizeBytes,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navGlobalCaches),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: OutlinedButton.icon(
              onPressed: controller.isRefreshingGlobalCaches
                  ? null
                  : controller.refreshGlobalCaches,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.refresh),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.errorMessage != null)
            _ErrorBanner(
              message: controller.errorMessage!,
              onDismiss: controller.clearErrorMessage,
            ),
          if (controller.isRefreshingGlobalCaches) ...[
            Text(l10n.loadingGlobalCaches),
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                label: l10n.globalTotalDetected,
                value: formatBytes(totalBytes),
              ),
              _MetricCard(
                label: l10n.globalCacheItems,
                value: '${targets.length}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.globalCachesDetected,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (targets.isEmpty)
                    Text(l10n.noGlobalCachesDetected)
                  else
                    ...targets.map((target) {
                      final selected = controller.selectedGlobalTargetIds
                          .contains(target.targetId);
                      return CheckboxListTile(
                        value: selected,
                        onChanged: target.exists
                            ? (value) {
                                controller.toggleGlobalTargetSelection(
                                  target.targetId,
                                  value ?? false,
                                );
                              }
                            : null,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(_globalTargetLabel(l10n, target.targetId)),
                        subtitle: Text(
                          '${target.path}\n${target.exists ? formatBytes(target.sizeBytes) : l10n.targetNotFound}',
                        ),
                        secondary: IconButton(
                          tooltip: l10n.openFolder,
                          onPressed: target.exists
                              ? () => controller.openPath(target.path)
                              : null,
                          icon: const Icon(Icons.open_in_new),
                        ),
                      );
                    }),
                  if (controller.globalScanLogPath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${l10n.latestScanLog}: ${controller.globalScanLogPath!}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(
              context,
            ).colorScheme.errorContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dangerZoneTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.dangerZoneDescription),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    value: controller.dangerZoneConfirmed,
                    onChanged: (value) =>
                        controller.setDangerZoneConfirmed(value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(l10n.dangerZoneAcknowledge),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed:
                            controller.dangerZoneConfirmed &&
                                !controller.isApplying
                            ? controller.previewGlobalCleanupPlan
                            : null,
                        icon: const Icon(Icons.visibility_outlined),
                        label: Text(l10n.previewPlan),
                      ),
                      FilledButton.icon(
                        onPressed:
                            controller.dangerZoneConfirmed &&
                                controller.globalCleanupPlan != null &&
                                !controller.isApplying
                            ? () => _onApplyGlobalPressed(context, controller)
                            : null,
                        icon: const Icon(Icons.cleaning_services_outlined),
                        label: Text(l10n.applyPlan),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (controller.globalCleanupPlan != null) ...[
            const SizedBox(height: 12),
            _PlanPreviewCard(
              title: l10n.planPreview,
              plan: controller.globalCleanupPlan!,
            ),
          ],
          if (controller.lastGlobalCleanupResult != null) ...[
            const SizedBox(height: 12),
            _CleanupSummaryCard(result: controller.lastGlobalCleanupResult!),
          ],
        ],
      ),
    );
  }

  Future<void> _onApplyGlobalPressed(
    BuildContext context,
    AppController controller,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final plan = controller.globalCleanupPlan;
    if (plan == null) return;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(l10n.confirmGlobalApplyTitle),
              content: Text(
                l10n.confirmApplyBody(
                  plan.items.length,
                  formatBytes(plan.totalBytes),
                  _deleteModeLabel(l10n, plan.deleteMode),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.applyPlan),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;
    await controller.applyGlobalCleanupPlan();
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _includeScan = true;
  bool _includeCleanup = true;
  String _profileFilter = 'all';
  int? _periodDays;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final l10n = AppLocalizations.of(context)!;
    final entries = controller.historyEntries;
    final filteredEntries = _applyHistoryFilters(entries);
    RunHistoryEntry? latestScan;
    for (final entry in filteredEntries) {
      if (entry.kind == RunHistoryKind.scan) {
        latestScan = entry;
        break;
      }
    }
    final reclaimed = filteredEntries
        .where((entry) => entry.kind == RunHistoryKind.cleanup)
        .fold(0, (sum, entry) => sum + (entry.reclaimedBytes ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navHistory),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: OutlinedButton.icon(
              onPressed: controller.isRefreshingHistory
                  ? null
                  : controller.refreshHistory,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.refresh),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.errorMessage != null)
            _ErrorBanner(
              message: controller.errorMessage!,
              onDismiss: controller.clearErrorMessage,
            ),
          if (controller.isRefreshingHistory) ...[
            Text(l10n.loadingHistory),
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.historyFilters,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: Text(l10n.historyTypeScan),
                        selected: _includeScan,
                        onSelected: (selected) {
                          setState(() {
                            _includeScan = selected;
                          });
                        },
                      ),
                      FilterChip(
                        label: Text(l10n.historyTypeCleanup),
                        selected: _includeCleanup,
                        onSelected: (selected) {
                          setState(() {
                            _includeCleanup = selected;
                          });
                        },
                      ),
                      SizedBox(
                        width: 210,
                        child: DropdownButtonFormField<String>(
                          initialValue: _profileFilter,
                          decoration: InputDecoration(
                            labelText: l10n.historyFilterProfile,
                          ),
                          items: <DropdownMenuItem<String>>[
                            DropdownMenuItem(
                              value: 'all',
                              child: Text(l10n.historyProfileAll),
                            ),
                            DropdownMenuItem(
                              value: 'safe',
                              child: Text(l10n.profileSafe),
                            ),
                            DropdownMenuItem(
                              value: 'medium',
                              child: Text(l10n.profileMedium),
                            ),
                            DropdownMenuItem(
                              value: 'aggressive',
                              child: Text(l10n.profileAggressive),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _profileFilter = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 210,
                        child: DropdownButtonFormField<int?>(
                          initialValue: _periodDays,
                          decoration: InputDecoration(
                            labelText: l10n.historyFilterPeriod,
                          ),
                          items: <DropdownMenuItem<int?>>[
                            DropdownMenuItem(
                              value: null,
                              child: Text(l10n.historyPeriodAll),
                            ),
                            DropdownMenuItem(
                              value: 7,
                              child: Text(l10n.historyPeriod7d),
                            ),
                            DropdownMenuItem(
                              value: 30,
                              child: Text(l10n.historyPeriod30d),
                            ),
                            DropdownMenuItem(
                              value: 90,
                              child: Text(l10n.historyPeriod90d),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _periodDays = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                label: l10n.historyTotalRuns,
                value: '${filteredEntries.length}',
              ),
              _MetricCard(label: l10n.reclaimed, value: formatBytes(reclaimed)),
              _MetricCard(
                label: l10n.historyLatestScanDelta,
                value: latestScan == null
                    ? '-'
                    : _formatSignedBytes(latestScan.deltaBytesFromPreviousScan),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.historyRecentRuns,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (filteredEntries.isEmpty)
                    Text(l10n.historyNoRunsYet)
                  else
                    ...filteredEntries.map(
                      (entry) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          entry.kind == RunHistoryKind.scan
                              ? Icons.search
                              : Icons.cleaning_services_outlined,
                        ),
                        title: Text(
                          '${entry.kind == RunHistoryKind.scan ? l10n.historyTypeScan : l10n.historyTypeCleanup} • ${_historyProfileLabel(l10n, entry.profile)}',
                        ),
                        subtitle: Text(
                          '${l10n.historyTimestamp}: ${formatDateTime(entry.timestamp)}\n'
                          '${_historyMetricLine(l10n, entry)}',
                        ),
                        trailing: IconButton(
                          tooltip: l10n.openFolder,
                          onPressed: () => controller.openPath(entry.filePath),
                          icon: const Icon(Icons.open_in_new),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<RunHistoryEntry> _applyHistoryFilters(List<RunHistoryEntry> entries) {
    final now = DateTime.now().toUtc();
    final out = <RunHistoryEntry>[];

    for (final entry in entries) {
      final includeType =
          (entry.kind == RunHistoryKind.scan && _includeScan) ||
          (entry.kind == RunHistoryKind.cleanup && _includeCleanup);
      if (!includeType) {
        continue;
      }

      if (_profileFilter != 'all' &&
          entry.profile.toLowerCase() != _profileFilter) {
        continue;
      }

      if (_periodDays != null) {
        final threshold = now.subtract(Duration(days: _periodDays!));
        if (entry.timestamp.isBefore(threshold)) {
          continue;
        }
      }

      out.add(entry);
    }

    return out;
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _rootController = TextEditingController();

  @override
  void dispose() {
    _rootController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (controller.errorMessage != null)
            _ErrorBanner(
              message: controller.errorMessage!,
              onDismiss: controller.clearErrorMessage,
            ),
          Text(l10n.scanRoots, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final root in controller.roots)
                  ListTile(
                    title: Text(root),
                    trailing: IconButton(
                      onPressed: () => controller.removeRoot(root),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _rootController,
                          decoration: InputDecoration(
                            labelText: l10n.addRoot,
                            hintText: l10n.rootPathHint,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          controller.addRoot(_rootController.text);
                          _rootController.clear();
                        },
                        child: Text(l10n.add),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  DropdownButtonFormField<Profile>(
                    initialValue: controller.profile,
                    decoration: InputDecoration(
                      labelText: l10n.profileLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: Profile.values
                        .map(
                          (profile) => DropdownMenuItem<Profile>(
                            value: profile,
                            child: Text(_profileLabel(l10n, profile)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      controller.setProfile(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<DeleteMode>(
                    initialValue: controller.deleteMode,
                    decoration: InputDecoration(
                      labelText: l10n.deleteModeLabel,
                      border: const OutlineInputBorder(),
                    ),
                    items: DeleteMode.values
                        .map(
                          (mode) => DropdownMenuItem<DeleteMode>(
                            value: mode,
                            child: Text(_deleteModeLabel(l10n, mode)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      controller.setDeleteMode(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.allowUnknown),
                    value: controller.allowUnknown,
                    onChanged: controller.setAllowUnknown,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Locale>(
                    initialValue: controller.locale,
                    decoration: InputDecoration(
                      labelText: l10n.settingsLanguage,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: const Locale('en'),
                        child: Text(l10n.languageEnglish),
                      ),
                      DropdownMenuItem(
                        value: const Locale('ko'),
                        child: Text(l10n.languageKorean),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      controller.setLocale(value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(message)),
    );
  }
}

class _PlanPreviewCard extends StatelessWidget {
  const _PlanPreviewCard({required this.title, required this.plan});

  final String title;
  final CleanupPlan plan;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title (${plan.items.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(formatBytes(plan.totalBytes)),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: ListView.separated(
                itemCount: plan.items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = plan.items[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      item.path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(formatBytes(item.sizeBytes)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CleanupSummaryCard extends StatelessWidget {
  const _CleanupSummaryCard({required this.result});

  final CleanupResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.cleanupSummary,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text('${l10n.cleanupSuccess}: ${result.successCount}'),
            Text('${l10n.cleanupFailed}: ${result.failureCount}'),
            Text('${l10n.cleanupSkipped}: ${result.skippedCount}'),
            Text('${l10n.reclaimed}: ${formatBytes(result.reclaimedBytes)}'),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 240,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.25),
          ),
          gradient: LinearGradient(
            colors: <Color>[
              _brandSurface.withValues(alpha: 0.9),
              const Color(0xFF132341).withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}

class _SimpleTable extends StatelessWidget {
  const _SimpleTable({required this.columns, required this.rows});

  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns
            .map((column) => DataColumn(label: Text(column)))
            .toList(),
        rows: rows
            .map(
              (row) => DataRow(
                cells: row.map((cell) => DataCell(Text(cell))).toList(),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _FvmRemovalBanner extends StatelessWidget {
  const _FvmRemovalBanner({required this.result});

  final FvmRemovalResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSuccess = result.success;
    final colorScheme = Theme.of(context).colorScheme;
    final background = isSuccess
        ? colorScheme.secondaryContainer
        : colorScheme.errorContainer;
    final foreground = isSuccess
        ? colorScheme.onSecondaryContainer
        : colorScheme.onErrorContainer;

    final body = isSuccess
        ? l10n.fvmRemovalSuccess(result.sdkName)
        : l10n.fvmRemovalFailed(result.sdkName);
    final details = result.error ?? result.stderr ?? result.stdout;

    return Card(
      color: background,
      child: ListTile(
        leading: Icon(
          isSuccess ? Icons.check_circle_outline : Icons.error_outline,
          color: foreground,
        ),
        title: Text(body, style: TextStyle(color: foreground)),
        subtitle: details == null
            ? null
            : Text(
                details,
                style: TextStyle(color: foreground.withValues(alpha: 0.92)),
              ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        title: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        ),
        trailing: IconButton(
          onPressed: onDismiss,
          icon: const Icon(Icons.close),
        ),
      ),
    );
  }
}

class _NavPage {
  const _NavPage({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget child;
}

String _profileLabel(AppLocalizations l10n, Profile profile) {
  return switch (profile) {
    Profile.safe => l10n.profileSafe,
    Profile.medium => l10n.profileMedium,
    Profile.aggressive => l10n.profileAggressive,
  };
}

String _deleteModeLabel(AppLocalizations l10n, DeleteMode mode) {
  return switch (mode) {
    DeleteMode.trash => l10n.deleteModeTrash,
    DeleteMode.permanent => l10n.deleteModePermanent,
  };
}

String _globalTargetLabel(AppLocalizations l10n, String targetId) {
  return switch (targetId) {
    globalPubCacheTargetId => l10n.globalPubCache,
    globalGradleUserHomeTargetId => l10n.globalGradleCache,
    globalCocoaPodsCacheTargetId => l10n.globalCocoaPodsCache,
    globalCocoaPodsHomeTargetId => l10n.globalCocoaPodsHome,
    _ => targetId,
  };
}

String _xcodeAttributionLabel(AppLocalizations l10n, TargetScanResult target) {
  return switch (target.attributionStatus) {
    AttributionStatus.none => l10n.attributionNotApplicable,
    AttributionStatus.attributed => l10n.attributionAttributed,
    AttributionStatus.unknown => l10n.attributionUnknown,
  };
}

String _historyMetricLine(AppLocalizations l10n, RunHistoryEntry entry) {
  if (entry.kind == RunHistoryKind.scan) {
    return '${l10n.totalReclaimable}: ${formatBytes(entry.totalBytes ?? 0)}';
  }

  return '${l10n.reclaimed}: ${formatBytes(entry.reclaimedBytes ?? 0)} • '
      '${l10n.cleanupSuccess}: ${entry.successCount ?? 0} • '
      '${l10n.cleanupFailed}: ${entry.failureCount ?? 0}';
}

String _historyProfileLabel(AppLocalizations l10n, String profile) {
  final value = profile.toLowerCase();
  return switch (value) {
    'safe' => l10n.profileSafe,
    'medium' => l10n.profileMedium,
    'aggressive' => l10n.profileAggressive,
    _ => profile.toUpperCase(),
  };
}

String _formatSignedBytes(int? bytes) {
  if (bytes == null) return '-';
  if (bytes == 0) return '0 B';
  final sign = bytes > 0 ? '+' : '-';
  return '$sign${formatBytes(bytes.abs())}';
}

String _basenamePath(String path) {
  var value = path.replaceAll('\\', '/');
  while (value.endsWith('/')) {
    value = value.substring(0, value.length - 1);
  }
  final idx = value.lastIndexOf('/');
  if (idx < 0 || idx == value.length - 1) {
    return value;
  }
  return value.substring(idx + 1);
}

double? _progressValue(int? done, int? total) {
  if (done == null || total == null || total <= 0) return null;
  return done / total;
}

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const units = <String>['KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var index = -1;
  while (value >= 1024 && index < units.length - 1) {
    value /= 1024;
    index++;
  }
  return '${value.toStringAsFixed(value >= 10 ? 1 : 2)} ${units[index]}';
}

String formatDateTime(DateTime time) {
  final local = time.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');
  return '$y-$m-$d $hh:$mm';
}

ThemeData _buildFluttrimTheme() {
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: _brandAccent,
        brightness: Brightness.dark,
      ).copyWith(
        primary: _brandPrimary,
        secondary: _brandSecondary,
        surface: _brandSurface,
        onSurface: const Color(0xFFE6F4FF),
        error: const Color(0xFFFF6B7F),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: _brandNavy.withValues(alpha: 0.78),
    dividerColor: const Color(0xFF2A3B57),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFE6F4FF),
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF0F1B31).withValues(alpha: 0.84),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: Colors.transparent,
      selectedIconTheme: const IconThemeData(color: _brandPrimary),
      selectedLabelTextStyle: const TextStyle(
        color: _brandPrimary,
        fontWeight: FontWeight.w700,
      ),
      unselectedIconTheme: const IconThemeData(color: Color(0xFF89A7CC)),
      unselectedLabelTextStyle: const TextStyle(color: Color(0xFF89A7CC)),
      indicatorColor: _brandAccent.withValues(alpha: 0.18),
      minWidth: 88,
      minExtendedWidth: 170,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0D1628).withValues(alpha: 0.8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2A3C59)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _brandPrimary, width: 1.3),
      ),
    ),
    dataTableTheme: const DataTableThemeData(
      dataRowColor: WidgetStatePropertyAll(Colors.transparent),
      headingRowColor: WidgetStatePropertyAll(Color(0x1A57C7FF)),
    ),
  );
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: <Color>[color, Colors.transparent]),
        ),
      ),
    );
  }
}
