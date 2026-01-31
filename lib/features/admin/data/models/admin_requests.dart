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
  final String? name;
  final String? description;

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
    if (maxEmployees != null) map['maxEmployees'] = maxEmployees;
    if (maxProducts != null) map['maxProducts'] = maxProducts;
    if (maxOrdersPerMonth != null) map['maxOrdersPerMonth'] = maxOrdersPerMonth;
    if (maxStorageMb != null) map['maxStorageMb'] = maxStorageMb;
    if (features != null) map['features'] = features;
    if (isTrialAvailable != null) map['isTrialAvailable'] = isTrialAvailable;
    if (trialDays != null) map['trialDays'] = trialDays;
    if (displayOrder != null) map['displayOrder'] = displayOrder;
    if (badgeText != null) map['badgeText'] = badgeText;
    if (isActive != null) map['isActive'] = isActive;
    return map;
  }
}

/// Request to create a new subscription
class CreateSubscriptionRequest {
  final String planCode;
  final String billingCycle; // 'monthly' or 'annual'
  final int? trialDays;
  final double? pricePaid;
  final String? paymentMethod;
  final String? notes;

  const CreateSubscriptionRequest({
    required this.planCode,
    required this.billingCycle,
    this.trialDays,
    this.pricePaid,
    this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'planCode': planCode,
    'billingCycle': billingCycle,
    if (trialDays != null) 'trialDays': trialDays,
    if (pricePaid != null) 'pricePaid': pricePaid,
    if (paymentMethod != null) 'paymentMethod': paymentMethod,
    if (notes != null) 'notes': notes,
  };

  factory CreateSubscriptionRequest.fromJson(Map<String, dynamic> json) {
    return CreateSubscriptionRequest(
      planCode: json['planCode'] as String,
      billingCycle: json['billingCycle'] as String,
      trialDays: json['trialDays'] as int?,
      pricePaid: (json['pricePaid'] as num?)?.toDouble(),
      paymentMethod: json['paymentMethod'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

/// Request to cancel a subscription
class CancelSubscriptionRequest {
  final String reason;
  final bool immediate; // true = cancel now, false = cancel at end of period
  final String? notes;

  const CancelSubscriptionRequest({
    required this.reason,
    this.immediate = false,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'reason': reason,
    'immediate': immediate,
    if (notes != null) 'notes': notes,
  };

  factory CancelSubscriptionRequest.fromJson(Map<String, dynamic> json) {
    return CancelSubscriptionRequest(
      reason: json['reason'] as String,
      immediate: json['immediate'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }
}

/// Request to reactivate a subscription
class ReactivateSubscriptionRequest {
  final String? planCode; // optional, keep current plan if null
  final String? billingCycle;
  final double? pricePaid;
  final String? paymentMethod;
  final String? notes;

  const ReactivateSubscriptionRequest({
    this.planCode,
    this.billingCycle,
    this.pricePaid,
    this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    if (planCode != null) 'planCode': planCode,
    if (billingCycle != null) 'billingCycle': billingCycle,
    if (pricePaid != null) 'pricePaid': pricePaid,
    if (paymentMethod != null) 'paymentMethod': paymentMethod,
    if (notes != null) 'notes': notes,
  };

  factory ReactivateSubscriptionRequest.fromJson(Map<String, dynamic> json) {
    return ReactivateSubscriptionRequest(
      planCode: json['planCode'] as String?,
      billingCycle: json['billingCycle'] as String?,
      pricePaid: (json['pricePaid'] as num?)?.toDouble(),
      paymentMethod: json['paymentMethod'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

/// Request to record a manual payment
class RecordPaymentRequest {
  final double amount;
  final String currency;
  final String paymentMethod; // cash, bank_transfer, qr_code, card
  final int? subscriptionId;
  final String? transactionId;
  final String? referenceNumber;
  final String? description;
  final String? notes;
  final DateTime? paymentDate;

  const RecordPaymentRequest({
    required this.amount,
    this.currency = 'LAK',
    required this.paymentMethod,
    this.subscriptionId,
    this.transactionId,
    this.referenceNumber,
    this.description,
    this.notes,
    this.paymentDate,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'currency': currency,
    'paymentMethod': paymentMethod,
    if (subscriptionId != null) 'subscriptionId': subscriptionId,
    if (transactionId != null) 'transactionId': transactionId,
    if (referenceNumber != null) 'referenceNumber': referenceNumber,
    if (description != null) 'description': description,
    if (notes != null) 'notes': notes,
    if (paymentDate != null) 'paymentDate': paymentDate!.toIso8601String(),
  };

  factory RecordPaymentRequest.fromJson(Map<String, dynamic> json) {
    return RecordPaymentRequest(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'LAK',
      paymentMethod: json['paymentMethod'] as String,
      subscriptionId: json['subscriptionId'] as int?,
      transactionId: json['transactionId'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'] as String)
          : null,
    );
  }
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
