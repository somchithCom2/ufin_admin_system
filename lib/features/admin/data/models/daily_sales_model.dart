/// Daily sales report model
class DailySalesResponse {
  final bool success;
  final DailySalesData data;
  final String message;
  final int statusCode;

  const DailySalesResponse({
    required this.success,
    required this.data,
    required this.message,
    required this.statusCode,
  });

  factory DailySalesResponse.fromJson(Map<String, dynamic> json) {
    return DailySalesResponse(
      success: json['success'] as bool? ?? false,
      data: DailySalesData.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String? ?? '',
      statusCode: json['statusCode'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data.toJson(),
    'message': message,
    'statusCode': statusCode,
  };
}

/// Daily sales data with summary and shop breakdown
class DailySalesData {
  final DateTime date;
  final int totalShopsWithSales;
  final int totalShopsActive;
  final int totalOrders;
  final double totalNetIncome;
  final List<ShopSalesData> shopSales;

  const DailySalesData({
    required this.date,
    required this.totalShopsWithSales,
    required this.totalShopsActive,
    required this.totalOrders,
    required this.totalNetIncome,
    required this.shopSales,
  });

  factory DailySalesData.fromJson(Map<String, dynamic> json) {
    return DailySalesData(
      date: DateTime.parse(json['date'] as String),
      totalShopsWithSales: json['totalShopsWithSales'] as int? ?? 0,
      totalShopsActive: json['totalShopsActive'] as int? ?? 0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalNetIncome: (json['totalNetIncome'] as num?)?.toDouble() ?? 0.0,
      shopSales:
          (json['shopSales'] as List<dynamic>?)
              ?.map((e) => ShopSalesData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'totalShopsWithSales': totalShopsWithSales,
    'totalShopsActive': totalShopsActive,
    'totalOrders': totalOrders,
    'totalNetIncome': totalNetIncome,
    'shopSales': shopSales.map((e) => e.toJson()).toList(),
  };
}

/// Individual shop sales data
class ShopSalesData {
  final int shopId;
  final String shopName;
  final int totalOrders;
  final double totalNetIncome;
  final double totalRevenue;
  final double totalDiscounts;
  final double totalTax;
  final int itemsSold;
  final double averageOrderValue;

  const ShopSalesData({
    required this.shopId,
    required this.shopName,
    required this.totalOrders,
    required this.totalNetIncome,
    required this.totalRevenue,
    required this.totalDiscounts,
    required this.totalTax,
    required this.itemsSold,
    required this.averageOrderValue,
  });

  factory ShopSalesData.fromJson(Map<String, dynamic> json) {
    return ShopSalesData(
      shopId: json['shopId'] as int? ?? 0,
      shopName: json['shopName'] as String? ?? '',
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalNetIncome: (json['totalNetIncome'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalDiscounts: (json['totalDiscounts'] as num?)?.toDouble() ?? 0.0,
      totalTax: (json['totalTax'] as num?)?.toDouble() ?? 0.0,
      itemsSold: json['itemsSold'] as int? ?? 0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'shopId': shopId,
    'shopName': shopName,
    'totalOrders': totalOrders,
    'totalNetIncome': totalNetIncome,
    'totalRevenue': totalRevenue,
    'totalDiscounts': totalDiscounts,
    'totalTax': totalTax,
    'itemsSold': itemsSold,
    'averageOrderValue': averageOrderValue,
  };
}
