import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';

final systemConfigProvider = FutureProvider<SystemConfiguration>((ref) async {
  final repository = AdminRepository();
  try {
    final config = await repository.getSystemConfiguration();
    debugPrint('✅ System Config loaded: ${config.toJson()}');
    return config;
  } catch (e) {
    debugPrint('❌ System Config error: $e');
    rethrow;
  }
});

class SystemConfigurationPage extends ConsumerStatefulWidget {
  const SystemConfigurationPage({super.key});

  @override
  ConsumerState<SystemConfigurationPage> createState() =>
      _SystemConfigurationPageState();
}

class _SystemConfigurationPageState
    extends ConsumerState<SystemConfigurationPage> {
  late AdminRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = AdminRepository();
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(systemConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(SysText.systemConfiguration)),
      ),
      body: ContentWidth(
        child: configAsync.when(
          loading: () => const AppLoadingView(),
          error: (error, stack) => AppErrorView(
            error: error,
            title: context.tr(SysText.failedToLoadConfiguration),
            onRetry: () => ref.invalidate(systemConfigProvider),
          ),
          data: (config) => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Force Update Status Alert
                if (config.forceUpdateRequired == true)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: context.colors.errorContainer,
                      border: Border.all(color: context.colors.error, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: context.colors.error,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr(SysText.forceUpdateRequired),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: context.colors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.tr(SysText.allUsersMustUpdateTo),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: context.colors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (config.forceUpdateRequired == true)
                  const SizedBox(height: 16),

                // Maintenance Mode Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(SysText.maintenanceMode),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    config.isMaintenanceMode
                                        ? context.tr(SysText.statusActive)
                                        : context.tr(SysText.statusInactive),
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: config.isMaintenanceMode
                                              ? context.colors.error
                                              : context.status.success,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (config.isMaintenanceMode) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      config.maintenanceTitle ??
                                          context.tr(SysText.noTitleProvided),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      config.maintenanceMessage ??
                                          context.tr(SysText.noMessageProvided),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (config.expectedCompletionTime !=
                                        null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        context.tr(
                                          SysText.expectedCompletion(
                                            config.expectedCompletionTime,
                                          ),
                                        ),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _showMaintenanceModeDialog(context, config),
                              icon: Icon(
                                config.isMaintenanceMode
                                    ? Icons.stop
                                    : Icons.play_arrow,
                              ),
                              label: Text(
                                config.isMaintenanceMode
                                    ? context.tr(CommonText.disable)
                                    : context.tr(CommonText.enable),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: config.isMaintenanceMode
                                    ? context.colors.error
                                    : context.status.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // New User Verification Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(SysText.newUserVerification),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            config.enforceNewUserVerification
                                ? context.tr(SysText.statusEnforced)
                                : context.tr(SysText.statusNotEnforced),
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: config.enforceNewUserVerification
                                      ? context.status.success
                                      : context.status.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          subtitle: Text(
                            context.tr(SysText.newlyRegisteredShopOwnersMust),
                          ),
                          value: config.enforceNewUserVerification,
                          onChanged: (value) =>
                              _confirmNewUserVerification(context, value),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Version Requirements Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(SysText.minimumVersionRequirements),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        _buildVersionCard(
                          context,
                          'Android',
                          config.minSupportedAndroidVersion,
                          Icons.android,
                          context.status.success,
                        ),
                        const SizedBox(height: 12),
                        _buildVersionCard(
                          context,
                          'iOS',
                          config.minSupportedIosVersion,
                          Icons.apple,
                          context.colors.onSurface,
                        ),
                        const SizedBox(height: 12),
                        _buildVersionCard(
                          context,
                          'Windows',
                          config.minSupportedWindowsVersion,
                          Icons.desktop_mac,
                          context.status.info,
                        ),
                        const SizedBox(height: 12),
                        _buildVersionCard(
                          context,
                          'macOS',
                          config.minSupportedMacosVersion,
                          Icons.laptop_mac,
                          context.status.neutral,
                        ),
                        const SizedBox(height: 12),
                        _buildVersionCard(
                          context,
                          'Web',
                          config.minSupportedWebVersion,
                          Icons.language,
                          context.status.info,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _showUpdateVersionDialog(context, config),
                            icon: const Icon(Icons.edit),
                            label: Text(context.tr(SysText.updateVersions)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Update Status
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(SysText.updateStatus),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        _buildStatusRow(
                          context.tr(SysText.updateAvailable),
                          config.updateAvailable == true
                              ? context.tr(SysText.yes)
                              : context.tr(SysText.no),
                          config.updateAvailable == true
                              ? context.status.success
                              : context.status.neutral,
                        ),
                        const SizedBox(height: 12),
                        _buildStatusRow(
                          context.tr(SysText.forceUpdateRequired),
                          config.forceUpdateRequired == true
                              ? context.tr(SysText.yes2)
                              : context.tr(SysText.no2),
                          config.forceUpdateRequired == true
                              ? context.colors.error
                              : context.status.success,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Configuration Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr(SysText.configurationInfo),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          context.tr(CommonText.created),
                          config.createdAt.toString(),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context.tr(SysText.lastUpdated),
                          config.updatedAt.toString(),
                        ),
                        if (config.updatedBy != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            context.tr(SysText.updatedBy),
                            config.updatedBy ?? 'N/A',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionCard(
    BuildContext context,
    String platform,
    String version,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                platform,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                context.tr(SysText.minVersion(version)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(value, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildStatusRow(String label, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: statusColor.withAlpha(100)),
        borderRadius: BorderRadius.circular(8),
        color: statusColor.withAlpha(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            status,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showMaintenanceModeDialog(
    BuildContext context,
    SystemConfiguration config,
  ) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(
      text: config.maintenanceTitle ?? '',
    );
    final messageCtrl = TextEditingController(
      text: config.maintenanceMessage ?? '',
    );
    DateTime? completionTime = config.expectedCompletionTime;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          config.isMaintenanceMode
              ? context.tr(SysText.disableMaintenanceMode)
              : context.tr(SysText.enableMaintenanceMode),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!config.isMaintenanceMode) ...[
                  TextFormField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: context.tr(SysText.maintenanceTitle),
                      hintText: context.tr(SysText.systemMaintenance),
                    ),
                    validator: (v) => v?.isEmpty ?? true
                        ? context.tr(CommonText.required)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: messageCtrl,
                    decoration: InputDecoration(
                      labelText: context.tr(SysText.maintenanceMessage),
                      hintText: context.tr(
                        SysText.weArePerformingUpdatesExpected,
                      ),
                    ),
                    maxLines: 3,
                    validator: (v) => v?.isEmpty ?? true
                        ? context.tr(CommonText.required)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(context.tr(SysText.expectedCompletionTime)),
                    subtitle: Text(
                      completionTime != null
                          ? completionTime.toString()
                          : context.tr(CommonText.notSet),
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            completionTime ??
                            DateTime.now().add(const Duration(hours: 1)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setState(() => completionTime = picked);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr(CommonText.cancel)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!config.isMaintenanceMode &&
                  !formKey.currentState!.validate()) {
                return;
              }

              try {
                final request = UpdateMaintenanceModeRequest(
                  isMaintenanceMode: !config.isMaintenanceMode,
                  maintenanceTitle: titleCtrl.text.isEmpty
                      ? null
                      : titleCtrl.text,
                  maintenanceMessage: messageCtrl.text.isEmpty
                      ? null
                      : messageCtrl.text,
                  expectedCompletionTime: completionTime,
                );

                await _repository.updateMaintenanceMode(request);
                unawaited(ref.refresh(systemConfigProvider.future));

                if (!context.mounted) return;
                Navigator.pop(context);
                AppFeedback.success(
                  context,
                  !config.isMaintenanceMode
                      ? context.tr(SysText.maintenanceModeEnabled)
                      : context.tr(SysText.maintenanceModeDisabled),
                );
              } catch (e) {
                if (!context.mounted) return;
                AppFeedback.error(context, e);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: config.isMaintenanceMode
                  ? context.colors.error
                  : context.status.warning,
            ),
            child: Text(
              config.isMaintenanceMode
                  ? context.tr(CommonText.disable)
                  : context.tr(CommonText.enable),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmNewUserVerification(
    BuildContext context,
    bool enforce,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          enforce
              ? context.tr(SysText.enforceNewUserVerification)
              : context.tr(SysText.stopEnforcingNewUserVerification),
        ),
        content: Text(
          enforce
              ? context.tr(SysText.newShopOwnersWhoHave)
              : context.tr(SysText.unverifiedNewShopOwnersWill),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr(CommonText.cancel)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: enforce
                  ? context.status.warning
                  : context.colors.error,
            ),
            child: Text(
              enforce
                  ? context.tr(SysText.enforce)
                  : context.tr(SysText.stopEnforcing),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _repository.updateSystemConfiguration(
        UpdateSystemConfigRequest(enforceNewUserVerification: enforce),
      );
      unawaited(ref.refresh(systemConfigProvider.future));

      if (!context.mounted) return;
      AppFeedback.success(
        context,
        enforce
            ? context.tr(SysText.newUserVerificationEnforced)
            : context.tr(SysText.newUserVerificationNoLonger),
      );
    } catch (e) {
      if (!context.mounted) return;
      AppFeedback.error(context, e);
    }
  }

  void _showUpdateVersionDialog(
    BuildContext context,
    SystemConfiguration config,
  ) {
    final formKey = GlobalKey<FormState>();
    final androidCtrl = TextEditingController(
      text: config.minSupportedAndroidVersion,
    );
    final iosCtrl = TextEditingController(text: config.minSupportedIosVersion);
    final windowsCtrl = TextEditingController(
      text: config.minSupportedWindowsVersion,
    );
    final macosCtrl = TextEditingController(
      text: config.minSupportedMacosVersion,
    );
    final webCtrl = TextEditingController(text: config.minSupportedWebVersion);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr(SysText.updateVersionRequirements)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: androidCtrl,
                  decoration: InputDecoration(
                    labelText: context.tr(SysText.minimumAndroidVersion),
                    hintText: '5.0',
                  ),
                  validator: (v) => v?.isEmpty ?? true
                      ? context.tr(CommonText.required)
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: iosCtrl,
                  decoration: InputDecoration(
                    labelText: context.tr(SysText.minimumIosVersion),
                    hintText: '12.0',
                  ),
                  validator: (v) => v?.isEmpty ?? true
                      ? context.tr(CommonText.required)
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: windowsCtrl,
                  decoration: InputDecoration(
                    labelText: context.tr(SysText.minimumWindowsVersion),
                    hintText: '10.0',
                  ),
                  validator: (v) => v?.isEmpty ?? true
                      ? context.tr(CommonText.required)
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: macosCtrl,
                  decoration: InputDecoration(
                    labelText: context.tr(SysText.minimumMacosVersion),
                    hintText: '10.15',
                  ),
                  validator: (v) => v?.isEmpty ?? true
                      ? context.tr(CommonText.required)
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: webCtrl,
                  decoration: InputDecoration(
                    labelText: context.tr(SysText.minimumWebVersion),
                    hintText: '1.0.0',
                  ),
                  validator: (v) => v?.isEmpty ?? true
                      ? context.tr(CommonText.required)
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr(CommonText.cancel)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              try {
                final request = UpdateSystemConfigRequest(
                  minSupportedAndroidVersion: androidCtrl.text,
                  minSupportedIosVersion: iosCtrl.text,
                  minSupportedWindowsVersion: windowsCtrl.text,
                  minSupportedMacosVersion: macosCtrl.text,
                  minSupportedWebVersion: webCtrl.text,
                );

                await _repository.updateSystemConfiguration(request);
                unawaited(ref.refresh(systemConfigProvider.future));

                if (!context.mounted) return;
                Navigator.pop(context);
                AppFeedback.success(
                  context,
                  context.tr(SysText.versionRequirementsUpdatedSuccessfully),
                );
              } catch (e) {
                if (!context.mounted) return;
                AppFeedback.error(context, e);
              }
            },
            child: Text(context.tr(SysText.update)),
          ),
        ],
      ),
    );
  }
}
