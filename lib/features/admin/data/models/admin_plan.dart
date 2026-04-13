/// Plan details for admin panel
class AdminPlan {
  final int id;
  final String code;
  final String name;
  final String? description;

  // Pricing
  final double priceMonthly;
  final double priceYearly;
  final String currency;

  // Limits
  final int? maxEmployees;
  final int? maxProducts;
  final int? maxOrdersPerMonth;
  final int? maxStorageMb;

  // Features
  final Map<String, dynamic> features;

  // Trial
  final bool isTrialAvailable;
  final int trialDays;

  // Display
  final int displayOrder;
  final String? badgeText;

  // Status
  final bool isActive;

  // Stats
  final int activeSubscriptions;
  final int totalSubscriptions;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminPlan({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.priceMonthly = 0,
    this.priceYearly = 0,
    this.currency = 'LAK',
    this.maxEmployees,
    this.maxProducts,
    this.maxOrdersPerMonth,
    this.maxStorageMb,
    this.features = const {},
    this.isTrialAvailable = false,
    this.trialDays = 0,
    this.displayOrder = 0,
    this.badgeText,
    this.isActive = true,
    this.activeSubscriptions = 0,
    this.totalSubscriptions = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Extracts a string from a value that may be a localized map or a plain string.
  static String? _localized(dynamic value, [String fallback = '']) {
    if (value == null) return fallback.isEmpty ? null : fallback;
    if (value is String) return value;
    if (value is Map) {
      return (value['en'] ??
                  value['lo'] ??
                  value['th'] ??
                  value.values.firstOrNull)
              ?.toString() ??
          fallback;
    }
    return value.toString();
  }

  factory AdminPlan.fromJson(Map<String, dynamic> json) {
    return AdminPlan(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      name: _localized(json['name']) ?? '',
      description: _localized(json['description']),
      priceMonthly: (json['priceMonthly'] as num?)?.toDouble() ?? 0,
      priceYearly: (json['priceYearly'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'LAK',
      maxEmployees: json['maxEmployees'] as int?,
      maxProducts: json['maxProducts'] as int?,
      maxOrdersPerMonth: json['maxOrdersPerMonth'] as int?,
      maxStorageMb: json['maxStorageMb'] as int?,
      features: (json['features'] as Map<String, dynamic>?) ?? {},
      isTrialAvailable: json['isTrialAvailable'] as bool? ?? false,
      trialDays: json['trialDays'] as int? ?? 0,
      displayOrder: json['displayOrder'] as int? ?? 0,
      badgeText: json['badgeText'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      activeSubscriptions: json['activeSubscriptions'] as int? ?? 0,
      totalSubscriptions: json['totalSubscriptions'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'description': description,
    'priceMonthly': priceMonthly,
    'priceYearly': priceYearly,
    'currency': currency,
    'maxEmployees': maxEmployees,
    'maxProducts': maxProducts,
    'maxOrdersPerMonth': maxOrdersPerMonth,
    'maxStorageMb': maxStorageMb,
    'features': features,
    'isTrialAvailable': isTrialAvailable,
    'trialDays': trialDays,
    'displayOrder': displayOrder,
    'badgeText': badgeText,
    'isActive': isActive,
    'activeSubscriptions': activeSubscriptions,
    'totalSubscriptions': totalSubscriptions,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Check if plan has unlimited employees
  bool get hasUnlimitedEmployees => maxEmployees == null;

  /// Check if plan has unlimited products
  bool get hasUnlimitedProducts => maxProducts == null;
}
