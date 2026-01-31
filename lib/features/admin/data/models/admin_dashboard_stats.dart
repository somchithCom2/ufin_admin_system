/// Dashboard statistics for admin panel
class AdminDashboardStats {
  // Shop stats
  final int totalShops;
  final int activeShops;
  final int suspendedShops;
  final int newShopsToday;
  final int newShopsThisWeek;
  final int newShopsThisMonth;

  // User stats
  final int totalUsers;
  final int activeUsers;
  final int totalEmployees;

  // Subscription stats
  final int totalSubscriptions;
  final int activeSubscriptions;
  final int trialSubscriptions;
  final int expiredSubscriptions;
  final int expiringSoon;

  // Plan distribution
  final Map<String, int> subscriptionsByPlan;

  // Revenue stats
  final double totalRevenueThisMonth;
  final double totalRevenueThisYear;
  final int totalPaymentsThisMonth;

  // Recent activity
  final List<RecentActivity> recentActivities;

  const AdminDashboardStats({
    this.totalShops = 0,
    this.activeShops = 0,
    this.suspendedShops = 0,
    this.newShopsToday = 0,
    this.newShopsThisWeek = 0,
    this.newShopsThisMonth = 0,
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.totalEmployees = 0,
    this.totalSubscriptions = 0,
    this.activeSubscriptions = 0,
    this.trialSubscriptions = 0,
    this.expiredSubscriptions = 0,
    this.expiringSoon = 0,
    this.subscriptionsByPlan = const {},
    this.totalRevenueThisMonth = 0,
    this.totalRevenueThisYear = 0,
    this.totalPaymentsThisMonth = 0,
    this.recentActivities = const [],
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalShops: json['totalShops'] as int? ?? 0,
      activeShops: json['activeShops'] as int? ?? 0,
      suspendedShops: json['suspendedShops'] as int? ?? 0,
      newShopsToday: json['newShopsToday'] as int? ?? 0,
      newShopsThisWeek: json['newShopsThisWeek'] as int? ?? 0,
      newShopsThisMonth: json['newShopsThisMonth'] as int? ?? 0,
      totalUsers: json['totalUsers'] as int? ?? 0,
      activeUsers: json['activeUsers'] as int? ?? 0,
      totalEmployees: json['totalEmployees'] as int? ?? 0,
      totalSubscriptions: json['totalSubscriptions'] as int? ?? 0,
      activeSubscriptions: json['activeSubscriptions'] as int? ?? 0,
      trialSubscriptions: json['trialSubscriptions'] as int? ?? 0,
      expiredSubscriptions: json['expiredSubscriptions'] as int? ?? 0,
      expiringSoon: json['expiringSoon'] as int? ?? 0,
      subscriptionsByPlan:
          (json['subscriptionsByPlan'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          {},
      totalRevenueThisMonth:
          (json['totalRevenueThisMonth'] as num?)?.toDouble() ?? 0,
      totalRevenueThisYear:
          (json['totalRevenueThisYear'] as num?)?.toDouble() ?? 0,
      totalPaymentsThisMonth: json['totalPaymentsThisMonth'] as int? ?? 0,
      recentActivities:
          (json['recentActivities'] as List<dynamic>?)
              ?.map((e) => RecentActivity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'totalShops': totalShops,
    'activeShops': activeShops,
    'suspendedShops': suspendedShops,
    'newShopsToday': newShopsToday,
    'newShopsThisWeek': newShopsThisWeek,
    'newShopsThisMonth': newShopsThisMonth,
    'totalUsers': totalUsers,
    'activeUsers': activeUsers,
    'totalEmployees': totalEmployees,
    'totalSubscriptions': totalSubscriptions,
    'activeSubscriptions': activeSubscriptions,
    'trialSubscriptions': trialSubscriptions,
    'expiredSubscriptions': expiredSubscriptions,
    'expiringSoon': expiringSoon,
    'subscriptionsByPlan': subscriptionsByPlan,
    'totalRevenueThisMonth': totalRevenueThisMonth,
    'totalRevenueThisYear': totalRevenueThisYear,
    'totalPaymentsThisMonth': totalPaymentsThisMonth,
    'recentActivities': recentActivities.map((e) => e.toJson()).toList(),
  };
}

/// Recent activity item
class RecentActivity {
  final String type;
  final String description;
  final int? shopId;
  final String? shopName;
  final String timestamp;

  const RecentActivity({
    required this.type,
    required this.description,
    this.shopId,
    this.shopName,
    required this.timestamp,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      shopId: json['shopId'] as int?,
      shopName: json['shopName'] as String?,
      timestamp: json['timestamp'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'description': description,
    'shopId': shopId,
    'shopName': shopName,
    'timestamp': timestamp,
  };
}
