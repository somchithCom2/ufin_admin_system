import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';

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
        title: const Text('System Configuration'),
      ),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load configuration',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(systemConfigProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (config) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Maintenance Mode Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Maintenance Mode',
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
                                      ? 'Status: ACTIVE'
                                      : 'Status: INACTIVE',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: config.isMaintenanceMode
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (config.isMaintenanceMode) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    config.maintenanceTitle ??
                                        'No title provided',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    config.maintenanceMessage ??
                                        'No message provided',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (config.expectedCompletionTime != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Expected completion: ${config.expectedCompletionTime}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showMaintenanceModeDialog(context, config),
                            icon: Icon(config.isMaintenanceMode
                                ? Icons.stop
                                : Icons.play_arrow),
                            label: Text(config.isMaintenanceMode
                                ? 'Disable'
                                : 'Enable'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: config.isMaintenanceMode
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                          ),
                        ],
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
                        'Minimum Version Requirements',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _buildVersionCard(
                        context,
                        'Android',
                        config.minSupportedAndroidVersion,
                        Icons.android,
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildVersionCard(
                        context,
                        'iOS',
                        config.minSupportedIosVersion,
                        Icons.apple,
                        Colors.black,
                      ),
                      const SizedBox(height: 12),
                      _buildVersionCard(
                        context,
                        'Web',
                        config.minSupportedWebVersion,
                        Icons.language,
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showUpdateVersionDialog(context, config),
                          icon: const Icon(Icons.edit),
                          label: const Text('Update Versions'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Configuration Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuration Info',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Created', config.createdAt.toString()),
                      const SizedBox(height: 8),
                      _buildInfoRow('Last Updated', config.updatedAt.toString()),
                      if (config.updatedBy != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow('Updated By', config.updatedBy ?? 'N/A'),
                      ],
                    ],
                  ),
                ),
              ),
            ],
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
        border: Border.all(color: Colors.grey.shade300),
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Min version: $version',
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
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
        title: Text(config.isMaintenanceMode
            ? 'Disable Maintenance Mode'
            : 'Enable Maintenance Mode'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!config.isMaintenanceMode) ...[
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Maintenance Title',
                      hintText: 'System Maintenance',
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: messageCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Maintenance Message',
                      hintText:
                          'We are performing updates. Expected time...',
                    ),
                    maxLines: 3,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('Expected Completion Time'),
                    subtitle: Text(
                      completionTime != null
                          ? completionTime.toString()
                          : 'Not set',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            completionTime ?? DateTime.now().add(
                              const Duration(hours: 1),
                            ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 30),
                        ),
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
            child: const Text('Cancel'),
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
                  maintenanceTitle: titleCtrl.text.isEmpty ? null : titleCtrl.text,
                  maintenanceMessage:
                      messageCtrl.text.isEmpty ? null : messageCtrl.text,
                  expectedCompletionTime: completionTime,
                );

                await _repository.updateMaintenanceMode(request);
                unawaited(ref.refresh(systemConfigProvider.future));

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Maintenance mode ${!config.isMaintenanceMode ? 'enabled' : 'disabled'}',
                    ),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  config.isMaintenanceMode ? Colors.red : Colors.orange,
            ),
            child: Text(config.isMaintenanceMode ? 'Disable' : 'Enable'),
          ),
        ],
      ),
    );
  }

  void _showUpdateVersionDialog(
    BuildContext context,
    SystemConfiguration config,
  ) {
    final formKey = GlobalKey<FormState>();
    final androidCtrl =
        TextEditingController(text: config.minSupportedAndroidVersion);
    final iosCtrl =
        TextEditingController(text: config.minSupportedIosVersion);
    final webCtrl =
        TextEditingController(text: config.minSupportedWebVersion);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Version Requirements'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: androidCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Minimum Android Version',
                    hintText: '5.0',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: iosCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Minimum iOS Version',
                    hintText: '12.0',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: webCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Minimum Web Version',
                    hintText: '1.0.0',
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              try {
                final request = UpdateSystemConfigRequest(
                  minSupportedAndroidVersion: androidCtrl.text,
                  minSupportedIosVersion: iosCtrl.text,
                  minSupportedWebVersion: webCtrl.text,
                );

                await _repository.updateSystemConfiguration(request);
                unawaited(ref.refresh(systemConfigProvider.future));

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Version requirements updated successfully'),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
