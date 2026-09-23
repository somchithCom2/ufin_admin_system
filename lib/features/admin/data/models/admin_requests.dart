/// Request to update shop status
class UpdateShopStatusRequest {
  final String status; // active, suspended, inactive
  final String? reason;

  const UpdateShopStatusRequest({required this.status, this.reason});

  Map<String, dynamic> toJson() => {
    'status': status,
    if (reason != null) 'reason': reason,
  };

  factory UpdateShopStatusRequest.fromJson(Map<String, dynamic> json) {
    return UpdateShopStatusRequest(
      status: json['status'] as String,
      reason: json['reason'] as String?,
    );
  }
}

/// Request to update user status
class UpdateUserStatusRequest {
  final String status; // active, suspended, banned
  final String? reason;

  const UpdateUserStatusRequest({required this.status, this.reason});

  Map<String, dynamic> toJson() => {
    'status': status,
    if (reason != null) 'reason': reason,
  };

  factory UpdateUserStatusRequest.fromJson(Map<String, dynamic> json) {
    return UpdateUserStatusRequest(
      status: json['status'] as String,
      reason: json['reason'] as String?,
    );
  }
}

/// Request to reset a user's password (admin)
class ResetUserPasswordRequest {
  final String newPassword;

  const ResetUserPasswordRequest({required this.newPassword});

  Map<String, dynamic> toJson() => {'newPassword': newPassword};
}

/// Request to extend subscription
class ExtendSubscriptionRequest {
  final int? days;
  final String? billingCycle; // 'monthly' or 'annual'
  final String? reason;

  const ExtendSubscriptionRequest({this.days, this.billingCycle, this.reason});

  Map<String, dynamic> toJson() => {
    if (days != null) 'days': days,
    if (billingCycle != null) 'billingCycle': billingCycle,
    if (reason != null) 'reason': reason,
  };

  factory ExtendSubscriptionRequest.fromJson(Map<String, dynamic> json) {
    return ExtendSubscriptionRequest(
      days: json['days'] as int?,
      billingCycle: json['billingCycle'] as String?,
      reason: json['reason'] as String?,
    );
  }
}

/// Request to create a new plan
class CreatePlanRequest {
  final String code;
  final Map<String, String> name;
  final Map<String, String>? description;

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
  final Map<String, dynamic>? features;

  // Trial
  final bool isTrialAvailable;
  final int trialDays;

  // Display
  final int displayOrder;
  final String? badgeText;

  const CreatePlanRequest({
    required this.code,
    required this.name,
    this.description,
    required this.priceMonthly,
    required this.priceYearly,
    this.currency = 'LAK',
    this.maxEmployees,
    this.maxProducts,
    this.maxOrdersPerMonth,
    this.maxStorageMb,
    this.features,
    this.isTrialAvailable = false,
    this.trialDays = 0,
    this.displayOrder = 0,
    this.badgeText,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    if (description != null) 'description': description,
    'priceMonthly': priceMonthly,
    'priceYearly': priceYearly,
    'currency': currency,
    if (maxEmployees != null) 'maxEmployees': maxEmployees,
    if (maxProducts != null) 'maxProducts': maxProducts,
    if (maxOrdersPerMonth != null) 'maxOrdersPerMonth': maxOrdersPerMonth,
    if (maxStorageMb != null) 'maxStorageMb': maxStorageMb,
    if (features != null) 'features': features,
    'isTrialAvailable': isTrialAvailable,
    'trialDays': trialDays,
    'displayOrder': displayOrder,
    if (badgeText != null) 'badgeText': badgeText,
  };
}

/// Request to update an existing plan
class UpdatePlanRequest {
  final Map<String, String>? name;
  final Map<String, String>? description;
  final bool replaceLimits;

  // Pricing
  final double? priceMonthly;
  final double? priceYearly;
  final String? currency;

  // Limits
  final int? maxEmployees;
  final int? maxProducts;
  final int? maxOrdersPerMonth;
  final int? maxStorageMb;

  // Features
  final Map<String, dynamic>? features;

  // Trial
  final bool? isTrialAvailable;
  final int? trialDays;

  // Display
  final int? displayOrder;
  final String? badgeText;

  // Status
  final bool? isActive;

  const UpdatePlanRequest({
    this.replaceLimits = false,
    this.name,
    this.description,
    this.priceMonthly,
    this.priceYearly,
    this.currency,
    this.maxEmployees,
    this.maxProducts,
    this.maxOrdersPerMonth,
    this.maxStorageMb,
    this.features,
    this.isTrialAvailable,
    this.trialDays,
    this.displayOrder,
    this.badgeText,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (priceMonthly != null) map['priceMonthly'] = priceMonthly;
    if (priceYearly != null) map['priceYearly'] = priceYearly;
    if (currency != null) map['currency'] = currency;
    if (replaceLimits || maxEmployees != null) {
      map['maxEmployees'] = maxEmployees;
    }
    if (replaceLimits || maxProducts != null) map['maxProducts'] = maxProducts;
    if (replaceLimits || maxOrdersPerMonth != null) {
      map['maxOrdersPerMonth'] = maxOrdersPerMonth;
    }
    if (replaceLimits || maxStorageMb != null) {
      map['maxStorageMb'] = maxStorageMb;
    }
    if (features != null) map['features'] = features;
    if (isTrialAvailable != null) map['isTrialAvailable'] = isTrialAvailable;
    if (trialDays != null) map['trialDays'] = trialDays;
    if (displayOrder != null) map['displayOrder'] = displayOrder;
    if (badgeText != null) map['badgeText'] = badgeText;
    if (isActive != null) map['isActive'] = isActive;
    return map;
  }
}

/// Admin subscription creation uses the trial duration configured on the plan.
class CreateSubscriptionRequest {
  final String planCode;
  final String billingCycle;
  final bool startAsTrial;
  final String? notes;
  const CreateSubscriptionRequest({
    required this.planCode,
    required this.billingCycle,
    this.startAsTrial = false,
    this.notes,
  });
  Map<String, dynamic> toJson() => {
    'planCode': planCode,
    'billingCycle': billingCycle,
    'startAsTrial': startAsTrial,
    if (notes != null) 'notes': notes,
  };
}

class CancelSubscriptionRequest {
  final String reason;
  final bool immediate;
  final String? notes;
  const CancelSubscriptionRequest({
    required this.reason,
    this.immediate = false,
    this.notes,
  });
  Map<String, dynamic> toJson() => {
    'reason': reason,
    'immediateEffect': immediate,
    if (notes != null) 'notes': notes,
  };
}

class ReactivateSubscriptionRequest {
  final String? planCode;
  final String billingCycle;
  final String? reason;
  final String? notes;
  const ReactivateSubscriptionRequest({
    this.planCode,
    required this.billingCycle,
    this.reason,
    this.notes,
  });
  Map<String, dynamic> toJson() => {
    if (planCode != null) 'planCode': planCode,
    'billingCycle': billingCycle,
    if (reason != null) 'reason': reason,
    if (notes != null) 'notes': notes,
  };
}

/// Manual payments are recorded against the shop's current subscription.
class RecordPaymentRequest {
  final double amount;
  final String currency;
  final String paymentMethod;
  final String? transactionId;
  final String? gateway;
  final String? notes;
  const RecordPaymentRequest({
    required this.amount,
    this.currency = 'LAK',
    required this.paymentMethod,
    this.transactionId,
    this.gateway,
    this.notes,
  });
  Map<String, dynamic> toJson() => {
    'amount': amount,
    'currency': currency,
    'paymentMethod': paymentMethod,
    if (transactionId != null) 'transactionId': transactionId,
    if (gateway != null) 'gateway': gateway,
    if (notes != null) 'notes': notes,
  };
}

/// Request to update payment status
class UpdatePaymentStatusRequest {
  final String status; // pending, completed, failed, refunded
  final String? notes;

  const UpdatePaymentStatusRequest({required this.status, this.notes});

  Map<String, dynamic> toJson() => {
    'status': status,
    if (notes != null) 'notes': notes,
  };

  factory UpdatePaymentStatusRequest.fromJson(Map<String, dynamic> json) {
    return UpdatePaymentStatusRequest(
      status: json['status'] as String,
      notes: json['notes'] as String?,
    );
  }
}

/// Request body for approving or rejecting an upgrade request
class ReviewUpgradeRequestBody {
  final String? reviewNote;

  const ReviewUpgradeRequestBody({this.reviewNote});

  Map<String, dynamic> toJson() => {
    if (reviewNote != null) 'reviewNote': reviewNote,
  };
}
