/// Admin Subscription Statistics model
class AdminSubscriptionStats {
  final int totalSubscriptions;
  final int activeSubscriptions;
  final int expiredSubscriptions;
  final int cancelledSubscriptions;
  final int trialSubscriptions;
  final int expiringSoon;
  final Map<String, int> byPlan;
  final Map<String, int> byStatus;
  final double totalRevenue;
  final double monthlyRecurringRevenue;
  final double averageRevenuePerUser;

  const AdminSubscriptionStats({
    required this.totalSubscriptions,
    required this.activeSubscriptions,
    required this.expiredSubscriptions,
    required this.cancelledSubscriptions,
    required this.trialSubscriptions,
    required this.expiringSoon,
    required this.byPlan,
    required this.byStatus,
    required this.totalRevenue,
    required this.monthlyRecurringRevenue,
    required this.averageRevenuePerUser,
  });

  factory AdminSubscriptionStats.fromJson(Map<String, dynamic> json) {
    return AdminSubscriptionStats(
      totalSubscriptions: json['totalSubscriptions'] as int? ?? 0,
      activeSubscriptions: json['activeSubscriptions'] as int? ?? 0,
      expiredSubscriptions: json['expiredSubscriptions'] as int? ?? 0,
      cancelledSubscriptions: json['cancelledSubscriptions'] as int? ?? 0,
      trialSubscriptions: json['trialSubscriptions'] as int? ?? 0,
      expiringSoon: json['expiringSoon'] as int? ?? 0,
      byPlan:
          (json['byPlan'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
      byStatus:
          (json['byStatus'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      monthlyRecurringRevenue:
          (json['monthlyRecurringRevenue'] as num?)?.toDouble() ?? 0.0,
      averageRevenuePerUser:
          (json['averageRevenuePerUser'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalSubscriptions': totalSubscriptions,
    'activeSubscriptions': activeSubscriptions,
    'expiredSubscriptions': expiredSubscriptions,
    'cancelledSubscriptions': cancelledSubscriptions,
    'trialSubscriptions': trialSubscriptions,
    'expiringSoon': expiringSoon,
    'byPlan': byPlan,
    'byStatus': byStatus,
    'totalRevenue': totalRevenue,
    'monthlyRecurringRevenue': monthlyRecurringRevenue,
    'averageRevenuePerUser': averageRevenuePerUser,
  };
}

/// Expiring subscription entry
class ExpiringSubscription {
  final int id;
  final int shopId;
  final String shopName;
  final String planCode;
  final String planName;
  final String status;
  final DateTime endDate;
  final int daysUntilExpiry;

  const ExpiringSubscription({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.planCode,
    required this.planName,
    required this.status,
    required this.endDate,
    required this.daysUntilExpiry,
  });

  factory ExpiringSubscription.fromJson(Map<String, dynamic> json) {
    return ExpiringSubscription(
      id: json['id'] as int,
      shopId: json['shopId'] as int,
      shopName: json['shopName'] as String? ?? '',
      planCode: json['planCode'] as String? ?? '',
      planName: json['planName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      endDate: DateTime.parse(json['endDate'] as String),
      daysUntilExpiry: json['daysUntilExpiry'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'shopId': shopId,
    'shopName': shopName,
    'planCode': planCode,
    'planName': planName,
    'status': status,
    'endDate': endDate.toIso8601String(),
    'daysUntilExpiry': daysUntilExpiry,
  };

  /// Check if expiring soon (within 7 days)
  bool get isUrgent => daysUntilExpiry <= 7;

  /// Check if expiring very soon (within 3 days)
  bool get isCritical => daysUntilExpiry <= 3;
}
