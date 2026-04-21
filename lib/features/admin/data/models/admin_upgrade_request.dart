/// DTO for a subscription upgrade request (admin view)
class UpgradeRequestDto {
  final int id;
  final int shopId;
  final String shopName;
  final String fromPlanCode;
  final Map<String, String> fromPlanName;
  final String toPlanCode;
  final Map<String, String> toPlanName;
  final String billingCycle;
  final String? notes;
  final String status; // PENDING, APPROVED, REJECTED, CANCELLED
  final String requestedByUsername;
  final String? reviewedByUsername;
  final String? reviewNote;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UpgradeRequestDto({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.fromPlanCode,
    required this.fromPlanName,
    required this.toPlanCode,
    required this.toPlanName,
    required this.billingCycle,
    this.notes,
    required this.status,
    required this.requestedByUsername,
    this.reviewedByUsername,
    this.reviewNote,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UpgradeRequestDto.fromJson(Map<String, dynamic> json) {
    Map<String, String> _parseLocalizedName(dynamic raw) {
      if (raw is Map) {
        return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
      return {'en': raw?.toString() ?? ''};
    }

    return UpgradeRequestDto(
      id: json['id'] as int,
      shopId: json['shopId'] as int,
      shopName: json['shopName'] as String? ?? '',
      fromPlanCode: json['fromPlanCode'] as String? ?? '',
      fromPlanName: _parseLocalizedName(json['fromPlanName']),
      toPlanCode: json['toPlanCode'] as String? ?? '',
      toPlanName: _parseLocalizedName(json['toPlanName']),
      billingCycle: json['billingCycle'] as String? ?? '',
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      requestedByUsername: json['requestedByUsername'] as String? ?? '',
      reviewedByUsername: json['reviewedByUsername'] as String?,
      reviewNote: json['reviewNote'] as String?,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'shopId': shopId,
    'shopName': shopName,
    'fromPlanCode': fromPlanCode,
    'fromPlanName': fromPlanName,
    'toPlanCode': toPlanCode,
    'toPlanName': toPlanName,
    'billingCycle': billingCycle,
    if (notes != null) 'notes': notes,
    'status': status,
    'requestedByUsername': requestedByUsername,
    if (reviewedByUsername != null) 'reviewedByUsername': reviewedByUsername,
    if (reviewNote != null) 'reviewNote': reviewNote,
    if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Returns the localized plan name, falling back to English then the raw code.
  String localizedFromPlanName(String locale) =>
      fromPlanName[locale] ?? fromPlanName['en'] ?? fromPlanCode;

  String localizedToPlanName(String locale) =>
      toPlanName[locale] ?? toPlanName['en'] ?? toPlanCode;
}
