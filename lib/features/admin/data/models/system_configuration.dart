class SystemConfiguration {
  final int id;
  final bool isMaintenanceMode;
  final String? maintenanceTitle;
  final String? maintenanceMessage;
  final DateTime? expectedCompletionTime;
  final String minSupportedAndroidVersion;
  final String minSupportedIosVersion;
  final String minSupportedWebVersion;
  final String minSupportedWindowsVersion;
  final String minSupportedMacosVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;
  final bool? updateAvailable;
  final bool? forceUpdateRequired;

  const SystemConfiguration({
    required this.id,
    required this.isMaintenanceMode,
    this.maintenanceTitle,
    this.maintenanceMessage,
    this.expectedCompletionTime,
    required this.minSupportedAndroidVersion,
    required this.minSupportedIosVersion,
    required this.minSupportedWebVersion,
    required this.minSupportedWindowsVersion,
    required this.minSupportedMacosVersion,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,
    this.updateAvailable,
    this.forceUpdateRequired,
  });

  factory SystemConfiguration.fromJson(Map<String, dynamic> json) {
    return SystemConfiguration(
      id: json['id'] as int,
      isMaintenanceMode: json['is_maintenance_mode'] as bool? ?? json['maintenance_mode'] as bool? ?? false,
      maintenanceTitle: json['maintenance_title'] as String?,
      maintenanceMessage: json['maintenance_message'] as String?,
      expectedCompletionTime: json['expected_completion_time'] != null
          ? DateTime.parse(json['expected_completion_time'] as String)
          : null,
      minSupportedAndroidVersion: json['min_supported_android_version'] as String? ?? '5.0',
      minSupportedIosVersion: json['min_supported_ios_version'] as String? ?? '12.0',
      minSupportedWebVersion: json['min_supported_web_version'] as String? ?? '1.0.0',
      minSupportedWindowsVersion: json['min_supported_windows_version'] as String? ?? '10.0',
      minSupportedMacosVersion: json['min_supported_macos_version'] as String? ?? '10.15',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      updatedBy: json['updated_by'] as String?,
      updateAvailable: json['update_available'] as bool?,
      forceUpdateRequired: json['force_update_required'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'is_maintenance_mode': isMaintenanceMode,
    'maintenance_mode': isMaintenanceMode,
    'maintenance_title': maintenanceTitle,
    'maintenance_message': maintenanceMessage,
    'expected_completion_time': expectedCompletionTime?.toIso8601String(),
    'min_supported_android_version': minSupportedAndroidVersion,
    'min_supported_ios_version': minSupportedIosVersion,
    'min_supported_web_version': minSupportedWebVersion,
    'min_supported_windows_version': minSupportedWindowsVersion,
    'min_supported_macos_version': minSupportedMacosVersion,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'updated_by': updatedBy,
    if (updateAvailable != null) 'update_available': updateAvailable,
    if (forceUpdateRequired != null) 'force_update_required': forceUpdateRequired,
  };
}

class UpdateMaintenanceModeRequest {
  final bool isMaintenanceMode;
  final String? maintenanceTitle;
  final String? maintenanceMessage;
  final DateTime? expectedCompletionTime;

  UpdateMaintenanceModeRequest({
    required this.isMaintenanceMode,
    this.maintenanceTitle,
    this.maintenanceMessage,
    this.expectedCompletionTime,
  });

  factory UpdateMaintenanceModeRequest.fromJson(Map<String, dynamic> json) {
    return UpdateMaintenanceModeRequest(
      isMaintenanceMode: json['is_maintenance_mode'] as bool,
      maintenanceTitle: json['maintenance_title'] as String?,
      maintenanceMessage: json['maintenance_message'] as String?,
      expectedCompletionTime: json['expected_completion_time'] != null
          ? DateTime.parse(json['expected_completion_time'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'is_maintenance_mode': isMaintenanceMode,
    if (maintenanceTitle != null) 'maintenance_title': maintenanceTitle,
    if (maintenanceMessage != null) 'maintenance_message': maintenanceMessage,
    if (expectedCompletionTime != null) 'expected_completion_time': expectedCompletionTime!.toIso8601String(),
  };
}

class UpdateSystemConfigRequest {
  final String? minSupportedAndroidVersion;
  final String? minSupportedIosVersion;
  final String? minSupportedWebVersion;
  final String? minSupportedWindowsVersion;
  final String? minSupportedMacosVersion;

  UpdateSystemConfigRequest({
    this.minSupportedAndroidVersion,
    this.minSupportedIosVersion,
    this.minSupportedWebVersion,
    this.minSupportedWindowsVersion,
    this.minSupportedMacosVersion,
  });

  factory UpdateSystemConfigRequest.fromJson(Map<String, dynamic> json) {
    return UpdateSystemConfigRequest(
      minSupportedAndroidVersion: json['min_supported_android_version'] as String?,
      minSupportedIosVersion: json['min_supported_ios_version'] as String?,
      minSupportedWebVersion: json['min_supported_web_version'] as String?,
      minSupportedWindowsVersion: json['min_supported_windows_version'] as String?,
      minSupportedMacosVersion: json['min_supported_macos_version'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (minSupportedAndroidVersion != null) 'min_supported_android_version': minSupportedAndroidVersion,
    if (minSupportedIosVersion != null) 'min_supported_ios_version': minSupportedIosVersion,
    if (minSupportedWebVersion != null) 'min_supported_web_version': minSupportedWebVersion,
    if (minSupportedWindowsVersion != null) 'min_supported_windows_version': minSupportedWindowsVersion,
    if (minSupportedMacosVersion != null) 'min_supported_macos_version': minSupportedMacosVersion,
  };
}
