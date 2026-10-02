/// Subscription history entry
class SubscriptionHistory {
  final int id;
  final int shopId;
  final String shopName;
  final String
  actionType; // upgraded, downgraded, renewed, cancelled, expired, created,
  // trial_started, trial_ended, payment_received, payment_failed, suspended,
  // unsuspended, reactivated, auto_renew_enabled, auto_renew_disabled
  final String? fromPlanCode;
  final String? fromPlanName;
  final String? toPlanCode;
  final String? toPlanName;
  final String? previousStatus;
  final String? newStatus;
  final String? reason;
  final String? notes;
  final int? daysExtended;
  final double? pricePaid;
  final String? performedBy; // username of admin/system
  final int? performedByUserId;
  final DateTime createdAt;

  const SubscriptionHistory({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.actionType,
    this.fromPlanCode,
    this.fromPlanName,
    this.toPlanCode,
    this.toPlanName,
    this.previousStatus,
    this.newStatus,
    this.reason,
    this.notes,
    this.daysExtended,
    this.pricePaid,
    this.performedBy,
    this.performedByUserId,
    required this.createdAt,
  });

  factory SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    // Handle different possible field names for shop name
    final shopName =
        json['shopName'] as String? ??
        json['shop_name'] as String? ??
        (json['shop'] as Map<String, dynamic>?)?['name'] as String? ??
        '';

    // Plan name may be a plain String or a localized map {"en":…, "lo":…}
    String? _parsePlanName(dynamic raw) {
      if (raw == null) return null;
      if (raw is String) return raw;
      if (raw is Map) {
        return (raw['en'] ?? raw.values.firstOrNull)?.toString();
      }
      return raw.toString();
    }

    return SubscriptionHistory(
      id: json['id'] as int,
      shopId: json['shopId'] as int? ?? json['shop_id'] as int? ?? 0,
      shopName: shopName,
      actionType:
          json['action'] as String? ??
          json['actionType'] as String? ??
          json['action_type'] as String? ??
          'unknown',
      fromPlanCode: json['fromPlanCode'] as String?,
      fromPlanName: _parsePlanName(json['fromPlanName']),
      toPlanCode: json['toPlanCode'] as String?,
      toPlanName: _parsePlanName(json['toPlanName']),
      previousStatus:
          json['fromStatus'] as String? ?? json['previousStatus'] as String?,
      newStatus: json['toStatus'] as String? ?? json['newStatus'] as String?,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      daysExtended: json['daysExtended'] as int?,
      pricePaid: (json['pricePaid'] as num?)?.toDouble(),
      performedBy: json['performedBy'] as String?,
      performedByUserId: json['performedByUserId'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'shopId': shopId,
    'shopName': shopName,
    'actionType': actionType,
    if (fromPlanCode != null) 'fromPlanCode': fromPlanCode,
    if (fromPlanName != null) 'fromPlanName': fromPlanName,
    if (toPlanCode != null) 'toPlanCode': toPlanCode,
    if (toPlanName != null) 'toPlanName': toPlanName,
    if (previousStatus != null) 'previousStatus': previousStatus,
    if (newStatus != null) 'newStatus': newStatus,
    if (reason != null) 'reason': reason,
    if (notes != null) 'notes': notes,
    if (daysExtended != null) 'daysExtended': daysExtended,
    if (pricePaid != null) 'pricePaid': pricePaid,
    if (performedBy != null) 'performedBy': performedBy,
    if (performedByUserId != null) 'performedByUserId': performedByUserId,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Get display text for action type
  String get actionDisplayText {
    switch (actionType.toLowerCase()) {
      case 'upgraded':
        return 'Upgraded';
      case 'downgraded':
        return 'Downgraded';
      case 'renewed':
        return 'Renewed';
      case 'cancelled':
        return 'Cancelled';
      case 'extended':
        return 'Extended';
      case 'created':
        return 'Created';
      case 'changed':
        return 'Plan Changed';
      case 'expired':
        return 'Expired';
      case 'reactivated':
        return 'Reactivated';
      case 'trial_started':
        return 'Trial Started';
      case 'trial_ended':
        return 'Trial Ended';
      case 'payment_received':
        return 'Payment Received';
      case 'payment_failed':
        return 'Payment Failed';
      case 'suspended':
        return 'Suspended';
      case 'unsuspended':
        return 'Unsuspended';
      case 'auto_renew_enabled':
        return 'Auto-renew On';
      case 'auto_renew_disabled':
        return 'Auto-renew Off';
      default:
        // Unknown action: "some_new_action" reads better than the raw code.
        return actionType
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (w) => w.isEmpty
                  ? w
                  : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
            )
            .join(' ');
    }
  }

  /// Check if this is an upgrade action
  bool get isUpgrade => actionType.toLowerCase() == 'upgraded';

  /// Check if this is a downgrade action
  bool get isDowngrade => actionType.toLowerCase() == 'downgraded';
}

/// Request to change subscription plan (auto-detects upgrade/downgrade)
class ChangePlanRequest {
  final String newPlanCode;
  final String? billingCycle; // 'monthly' or 'annual'
  final String? reason;
  final bool? prorated; // Whether to prorate the charge
  final bool?
  immediate; // Whether to apply immediately or at end of billing cycle

  const ChangePlanRequest({
    required this.newPlanCode,
    this.billingCycle,
    this.reason,
    this.prorated,
    this.immediate,
  });

  Map<String, dynamic> toJson() => {
    'newPlanCode': newPlanCode,
    if (billingCycle != null) 'billingCycle': billingCycle,
    if (reason != null) 'reason': reason,
    if (prorated != null) 'prorated': prorated,
    if (immediate != null) 'immediate': immediate,
  };

  factory ChangePlanRequest.fromJson(Map<String, dynamic> json) {
    return ChangePlanRequest(
      newPlanCode: json['newPlanCode'] as String,
      billingCycle: json['billingCycle'] as String?,
      reason: json['reason'] as String?,
      prorated: json['prorated'] as bool?,
      immediate: json['immediate'] as bool?,
    );
  }
}
