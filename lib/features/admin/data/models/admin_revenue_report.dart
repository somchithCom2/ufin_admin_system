/// Admin Revenue Report model
class AdminRevenueReport {
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final double subscriptionRevenue;
  final double otherRevenue;
  final int totalTransactions;
  final int successfulTransactions;
  final int failedTransactions;
  final double averageTransactionValue;
  final List<RevenueByPeriod> revenueByPeriod;
  final List<RevenueByPlan> revenueByPlan;
  final List<RevenueByPaymentMethod> revenueByPaymentMethod;

  const AdminRevenueReport({
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.subscriptionRevenue,
    required this.otherRevenue,
    required this.totalTransactions,
    required this.successfulTransactions,
    required this.failedTransactions,
    required this.averageTransactionValue,
    required this.revenueByPeriod,
    required this.revenueByPlan,
    required this.revenueByPaymentMethod,
  });

  factory AdminRevenueReport.fromJson(Map<String, dynamic> json) {
    return AdminRevenueReport(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      subscriptionRevenue:
          (json['subscriptionRevenue'] as num?)?.toDouble() ?? 0.0,
      otherRevenue: (json['otherRevenue'] as num?)?.toDouble() ?? 0.0,
      totalTransactions: json['totalTransactions'] as int? ?? 0,
      successfulTransactions: json['successfulTransactions'] as int? ?? 0,
      failedTransactions: json['failedTransactions'] as int? ?? 0,
      averageTransactionValue:
          (json['averageTransactionValue'] as num?)?.toDouble() ?? 0.0,
      revenueByPeriod:
          (json['revenueByPeriod'] as List<dynamic>?)
              ?.map((e) => RevenueByPeriod.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      revenueByPlan:
          (json['revenueByPlan'] as List<dynamic>?)
              ?.map((e) => RevenueByPlan.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      revenueByPaymentMethod:
          (json['revenueByPaymentMethod'] as List<dynamic>?)
              ?.map(
                (e) =>
                    RevenueByPaymentMethod.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'totalRevenue': totalRevenue,
    'subscriptionRevenue': subscriptionRevenue,
    'otherRevenue': otherRevenue,
    'totalTransactions': totalTransactions,
    'successfulTransactions': successfulTransactions,
    'failedTransactions': failedTransactions,
    'averageTransactionValue': averageTransactionValue,
    'revenueByPeriod': revenueByPeriod.map((e) => e.toJson()).toList(),
    'revenueByPlan': revenueByPlan.map((e) => e.toJson()).toList(),
    'revenueByPaymentMethod': revenueByPaymentMethod
        .map((e) => e.toJson())
        .toList(),
  };

  /// Success rate as percentage
  double get successRate => totalTransactions > 0
      ? (successfulTransactions / totalTransactions) * 100
      : 0;
}

/// Revenue breakdown by time period
class RevenueByPeriod {
  final String period; // date string or month
  final double revenue;
  final int transactionCount;

  const RevenueByPeriod({
    required this.period,
    required this.revenue,
    required this.transactionCount,
  });

  factory RevenueByPeriod.fromJson(Map<String, dynamic> json) {
    return RevenueByPeriod(
      period: json['period'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transactionCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'period': period,
    'revenue': revenue,
    'transactionCount': transactionCount,
  };
}

/// Revenue breakdown by plan
class RevenueByPlan {
  final String planCode;
  final String planName;
  final double revenue;
  final int subscriptionCount;
  final double percentage;

  const RevenueByPlan({
    required this.planCode,
    required this.planName,
    required this.revenue,
    required this.subscriptionCount,
    required this.percentage,
  });

  factory RevenueByPlan.fromJson(Map<String, dynamic> json) {
    return RevenueByPlan(
      planCode: json['planCode'] as String? ?? '',
      planName: json['planName'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      subscriptionCount: json['subscriptionCount'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'planCode': planCode,
    'planName': planName,
    'revenue': revenue,
    'subscriptionCount': subscriptionCount,
    'percentage': percentage,
  };
}

/// Revenue breakdown by payment method
class RevenueByPaymentMethod {
  final String paymentMethod;
  final double revenue;
  final int transactionCount;
  final double percentage;

  const RevenueByPaymentMethod({
    required this.paymentMethod,
    required this.revenue,
    required this.transactionCount,
    required this.percentage,
  });

  factory RevenueByPaymentMethod.fromJson(Map<String, dynamic> json) {
    return RevenueByPaymentMethod(
      paymentMethod: json['paymentMethod'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      transactionCount: json['transactionCount'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'paymentMethod': paymentMethod,
    'revenue': revenue,
    'transactionCount': transactionCount,
    'percentage': percentage,
  };

  /// Get payment method display name
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
