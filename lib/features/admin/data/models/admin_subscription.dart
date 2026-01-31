/// Subscription details for admin panel
class AdminSubscription {
  final int id;

  // Shop info
  final int shopId;
  final String shopName;
  final String? shopOwnerEmail;

  // Plan info
  final int? planId;
  final String? planCode;
  final String? planName;

  // Status
  final String status;
  final String? billingCycle;

  // Dates
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final DateTime? trialEndsAt;
  final DateTime? cancelledAt;

  // Pricing
  final double pricePaid;
  final String currency;

  // Renewal
  final bool autoRenew;
  final DateTime? nextBillingDate;

  // Usage
  final int currentEmployees;
  final int maxEmployees;
  final int currentProducts;
  final int maxProducts;

  // Computed
  final int daysUntilExpiry;
  final bool isExpiringSoon;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminSubscription({
    required this.id,
    required this.shopId,
    required this.shopName,
    this.shopOwnerEmail,
    this.planId,
    this.planCode,
    this.planName,
    required this.status,
    this.billingCycle,
    this.startedAt,
    this.expiresAt,
    this.trialEndsAt,
    this.cancelledAt,
    this.pricePaid = 0,
    this.currency = 'LAK',
    this.autoRenew = false,
    this.nextBillingDate,
    this.currentEmployees = 0,
    this.maxEmployees = 0,
    this.currentProducts = 0,
    this.maxProducts = 0,
    this.daysUntilExpiry = 0,
    this.isExpiringSoon = false,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminSubscription.fromJson(Map<String, dynamic> json) {
    return AdminSubscription(
      id: json['id'] as int,
      shopId: json['shopId'] as int,
      shopName: json['shopName'] as String? ?? '',
      shopOwnerEmail: json['shopOwnerEmail'] as String?,
      planId: json['planId'] as int?,
      planCode: json['planCode'] as String?,
      planName: json['planName'] as String?,
      status: json['status'] as String? ?? 'active',
      billingCycle: json['billingCycle'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      trialEndsAt: json['trialEndsAt'] != null
          ? DateTime.tryParse(json['trialEndsAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.tryParse(json['cancelledAt'] as String)
          : null,
      pricePaid: (json['pricePaid'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'LAK',
      autoRenew: json['autoRenew'] as bool? ?? false,
      nextBillingDate: json['nextBillingDate'] != null
          ? DateTime.tryParse(json['nextBillingDate'] as String)
          : null,
      currentEmployees: json['currentEmployees'] as int? ?? 0,
      maxEmployees: json['maxEmployees'] as int? ?? 0,
      currentProducts: json['currentProducts'] as int? ?? 0,
      maxProducts: json['maxProducts'] as int? ?? 0,
      daysUntilExpiry: json['daysUntilExpiry'] as int? ?? 0,
      isExpiringSoon: json['isExpiringSoon'] as bool? ?? false,
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
    'shopId': shopId,
    'shopName': shopName,
    'shopOwnerEmail': shopOwnerEmail,
    'planId': planId,
    'planCode': planCode,
    'planName': planName,
    'status': status,
    'billingCycle': billingCycle,
    'startedAt': startedAt?.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'trialEndsAt': trialEndsAt?.toIso8601String(),
    'cancelledAt': cancelledAt?.toIso8601String(),
    'pricePaid': pricePaid,
    'currency': currency,
    'autoRenew': autoRenew,
    'nextBillingDate': nextBillingDate?.toIso8601String(),
    'currentEmployees': currentEmployees,
    'maxEmployees': maxEmployees,
    'currentProducts': currentProducts,
    'maxProducts': maxProducts,
    'daysUntilExpiry': daysUntilExpiry,
    'isExpiringSoon': isExpiringSoon,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Check if subscription is active
  bool get isActive => status.toLowerCase() == 'active';

  /// Check if subscription is on trial
  bool get isTrial => status.toLowerCase() == 'trial';

  /// Check if subscription is expired
  bool get isExpired => status.toLowerCase() == 'expired';
}
