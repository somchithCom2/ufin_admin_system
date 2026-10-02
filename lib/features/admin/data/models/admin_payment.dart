/// Admin Payment model
class AdminPayment {
  final int id;
  final int shopId;
  final String shopName;
  final int? subscriptionId;
  final double amount;
  final String currency;
  final String paymentMethod; // cash, bank_transfer, qr_code, card, etc.
  final String status; // pending, completed, failed, refunded
  final String? transactionId;
  final String? referenceNumber;
  final String? description;
  final String? notes;
  final DateTime paymentDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? processedBy;
  final int? processedByUserId;

  /// When this payment was spent to extend the subscription.
  ///
  /// `null` means it is still available to fund the next auto-renewal. Payment
  /// collection is manual, so this is how a recorded payment turns into a
  /// billing period: the scheduler spends the oldest unapplied payment when the
  /// current period runs out.
  final DateTime? appliedAt;

  /// Billing period this payment ended up paying for, once it was spent.
  final DateTime? billingPeriodStart;
  final DateTime? billingPeriodEnd;

  const AdminPayment({
    required this.id,
    required this.shopId,
    required this.shopName,
    this.subscriptionId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.referenceNumber,
    this.description,
    this.notes,
    required this.paymentDate,
    required this.createdAt,
    this.updatedAt,
    this.processedBy,
    this.processedByUserId,
    this.appliedAt,
    this.billingPeriodStart,
    this.billingPeriodEnd,
  });

  factory AdminPayment.fromJson(Map<String, dynamic> json) {
    return AdminPayment(
      id: json['id'] as int,
      shopId: json['shopId'] as int,
      shopName: json['shopName'] as String? ?? '',
      subscriptionId: json['subscriptionId'] as int?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'LAK',
      paymentMethod: json['paymentMethod'] as String? ?? 'unknown',
      status: json['status'] as String? ?? 'pending',
      transactionId: json['transactionId'] as String?,
      referenceNumber:
          (json['referenceNumber'] ?? json['invoiceNumber']) as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      paymentDate: DateTime.parse(
        (json['paymentDate'] ?? json['paidAt'] ?? json['createdAt']) as String,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      processedBy: json['processedBy'] as String?,
      processedByUserId: json['processedByUserId'] as int?,
      appliedAt: json['appliedAt'] != null
          ? DateTime.tryParse(json['appliedAt'] as String)
          : null,
      billingPeriodStart: json['billingPeriodStart'] != null
          ? DateTime.tryParse(json['billingPeriodStart'] as String)
          : null,
      billingPeriodEnd: json['billingPeriodEnd'] != null
          ? DateTime.tryParse(json['billingPeriodEnd'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'shopId': shopId,
    'shopName': shopName,
    'subscriptionId': subscriptionId,
    'amount': amount,
    'currency': currency,
    'paymentMethod': paymentMethod,
    'status': status,
    'transactionId': transactionId,
    'referenceNumber': referenceNumber,
    'description': description,
    'notes': notes,
    'paymentDate': paymentDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'processedBy': processedBy,
    'processedByUserId': processedByUserId,
    'appliedAt': appliedAt?.toIso8601String(),
    'billingPeriodStart': billingPeriodStart?.toIso8601String(),
    'billingPeriodEnd': billingPeriodEnd?.toIso8601String(),
  };

  AdminPayment copyWith({
    int? id,
    int? shopId,
    String? shopName,
    int? subscriptionId,
    double? amount,
    String? currency,
    String? paymentMethod,
    String? status,
    String? transactionId,
    String? referenceNumber,
    String? description,
    String? notes,
    DateTime? paymentDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? processedBy,
    int? processedByUserId,
    DateTime? appliedAt,
    DateTime? billingPeriodStart,
    DateTime? billingPeriodEnd,
  }) {
    return AdminPayment(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      processedBy: processedBy ?? this.processedBy,
      processedByUserId: processedByUserId ?? this.processedByUserId,
      appliedAt: appliedAt ?? this.appliedAt,
      billingPeriodStart: billingPeriodStart ?? this.billingPeriodStart,
      billingPeriodEnd: billingPeriodEnd ?? this.billingPeriodEnd,
    );
  }

  /// True while this payment can still be spent on a renewal.
  ///
  /// Only completed payments fund anything, and only once.
  bool get isAvailableForRenewal =>
      status.toLowerCase() == 'completed' && appliedAt == null;

  /// Get status color
  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  /// Get payment method display
  String get paymentMethodDisplay {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'qr_code':
        return 'QR Code';
      case 'card':
        return 'Card';
      case 'credit_card':
        return 'Credit Card';
      default:
        return paymentMethod;
    }
  }
}
