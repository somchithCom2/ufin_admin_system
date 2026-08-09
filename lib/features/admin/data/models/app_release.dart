class AppRelease {
  final int id;
  final String versionName;
  final int versionCode;
  final String platform;
  final String title;
  final String changelog;
  final bool isMandatory;
  final bool isPublished;
  final String downloadUrl;
  final DateTime releasedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppRelease({
    required this.id,
    required this.versionName,
    required this.versionCode,
    required this.platform,
    required this.title,
    required this.changelog,
    required this.isMandatory,
    required this.isPublished,
    required this.downloadUrl,
    required this.releasedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppRelease.fromJson(Map<String, dynamic> json) {
    return AppRelease(
      id: json['id'] as int,
      versionName: json['version_name'] as String,
      versionCode: json['version_code'] as int,
      platform: json['platform'] as String,
      title: json['title'] as String,
      changelog: json['changelog'] as String,
      isMandatory: json['is_mandatory'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? false,
      downloadUrl: json['download_url'] as String,
      releasedAt: DateTime.parse(json['released_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'version_name': versionName,
    'version_code': versionCode,
    'platform': platform,
    'title': title,
    'changelog': changelog,
    'is_mandatory': isMandatory,
    'is_published': isPublished,
    'download_url': downloadUrl,
    'released_at': releasedAt.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class CreateAppReleaseRequest {
  final String versionName;
  final int versionCode;
  final String platform;
  final String title;
  final String changelog;
  final bool? isMandatory;
  final String downloadUrl;
  final DateTime? releasedAt;

  CreateAppReleaseRequest({
    required this.versionName,
    required this.versionCode,
    required this.platform,
    required this.title,
    required this.changelog,
    this.isMandatory,
    required this.downloadUrl,
    this.releasedAt,
  });

  factory CreateAppReleaseRequest.fromJson(Map<String, dynamic> json) {
    return CreateAppReleaseRequest(
      versionName: json['version_name'] as String,
      versionCode: json['version_code'] as int,
      platform: json['platform'] as String,
      title: json['title'] as String,
      changelog: json['changelog'] as String,
      isMandatory: json['is_mandatory'] as bool?,
      downloadUrl: json['download_url'] as String,
      releasedAt: json['released_at'] != null
          ? DateTime.parse(json['released_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'version_name': versionName,
    'version_code': versionCode,
    'platform': platform,
    'title': title,
    'changelog': changelog,
    if (isMandatory != null) 'is_mandatory': isMandatory,
    'download_url': downloadUrl,
    if (releasedAt != null) 'released_at': releasedAt!.toIso8601String(),
  };
}

class UpdateAppReleaseRequest {
  final String? title;
  final String? changelog;
  final bool? isMandatory;
  final String? downloadUrl;

  UpdateAppReleaseRequest({
    this.title,
    this.changelog,
    this.isMandatory,
    this.downloadUrl,
  });

  factory UpdateAppReleaseRequest.fromJson(Map<String, dynamic> json) {
    return UpdateAppReleaseRequest(
      title: json['title'] as String?,
      changelog: json['changelog'] as String?,
      isMandatory: json['is_mandatory'] as bool?,
      downloadUrl: json['download_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (changelog != null) 'changelog': changelog,
    if (isMandatory != null) 'is_mandatory': isMandatory,
    if (downloadUrl != null) 'download_url': downloadUrl,
  };
}
