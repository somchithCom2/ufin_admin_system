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
      referenceNumber: json['referenceNumber'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      processedBy: json['processedBy'] as String?,
      processedByUserId: json['processedByUserId'] as int?,
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
    );
  }

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
