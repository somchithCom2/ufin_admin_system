class AdminProduct {
  final int id;
  final String name;
  final String? displayName;
  final String? sku;
  final String? barcode;
  final String? description;
  final double price;
  final double? cost;
  final double stockQuantity;
  final bool trackInventory;
  final bool isInStock;
  final bool isLowStock;
  final bool isPerishable;
  final int? shelfLifeDays;
  final int? expirationAlertDays;
  final bool hasVariants;
  final int variantCount;
  final double? totalStockQuantity;
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? categoryName;
  final int? categoryId;
  final int? baseUnitId;
  final String? baseUnitCode;
  final String? baseUnitName;
  final bool isActive;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminProduct({
    required this.id,
    required this.name,
    this.displayName,
    this.sku,
    this.barcode,
    this.description,
    required this.price,
    this.cost,
    required this.stockQuantity,
    this.trackInventory = false,
    this.isInStock = true,
    this.isLowStock = false,
    this.isPerishable = false,
    this.shelfLifeDays,
    this.expirationAlertDays,
    this.hasVariants = false,
    this.variantCount = 0,
    this.totalStockQuantity,
    this.imageUrl,
    this.thumbnailUrl,
    this.categoryName,
    this.categoryId,
    this.baseUnitId,
    this.baseUnitCode,
    this.baseUnitName,
    required this.isActive,
    required this.isDeleted,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminProduct.fromJson(Map<String, dynamic> json) {
    // Handle category object if present
    Map<String, dynamic>? category = json['category'] as Map<String, dynamic>?;

    return AdminProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      displayName: json['displayName'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      stockQuantity: (json['stockQuantity'] as num?)?.toDouble() ?? 0.0,
      trackInventory: json['trackInventory'] as bool? ?? false,
      isInStock: json['isInStock'] as bool? ?? true,
      isLowStock: json['isLowStock'] as bool? ?? false,
      isPerishable: json['isPerishable'] as bool? ?? false,
      shelfLifeDays: json['shelfLifeDays'] as int?,
      expirationAlertDays: json['expirationAlertDays'] as int?,
      hasVariants: json['hasVariants'] as bool? ?? false,
      variantCount: json['variantCount'] as int? ?? 0,
      totalStockQuantity: json['totalStockQuantity'] != null
          ? (json['totalStockQuantity'] as num).toDouble()
          : null,
      imageUrl: json['imageUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      categoryName: category != null
          ? category['name'] as String?
          : json['categoryName'] as String?,
      categoryId: category != null
          ? category['id'] as int?
          : json['categoryId'] as int?,
      baseUnitId: json['baseUnitId'] as int?,
      baseUnitCode: json['baseUnitCode'] as String?,
      baseUnitName: json['baseUnitName'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt: json['deletedAt'] != null
          ? DateTime.tryParse(json['deletedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  AdminProduct copyWith({
    int? id,
    String? name,
    String? displayName,
    String? sku,
    String? barcode,
    String? description,
    double? price,
    double? cost,
    double? stockQuantity,
    bool? trackInventory,
    bool? isInStock,
    bool? isLowStock,
    bool? isPerishable,
    int? shelfLifeDays,
    int? expirationAlertDays,
    bool? hasVariants,
    int? variantCount,
    double? totalStockQuantity,
    String? imageUrl,
    String? thumbnailUrl,
    String? categoryName,
    int? categoryId,
    int? baseUnitId,
    String? baseUnitCode,
    String? baseUnitName,
    bool? isActive,
    bool? isDeleted,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      trackInventory: trackInventory ?? this.trackInventory,
      isInStock: isInStock ?? this.isInStock,
      isLowStock: isLowStock ?? this.isLowStock,
      isPerishable: isPerishable ?? this.isPerishable,
      shelfLifeDays: shelfLifeDays ?? this.shelfLifeDays,
      expirationAlertDays: expirationAlertDays ?? this.expirationAlertDays,
      hasVariants: hasVariants ?? this.hasVariants,
      variantCount: variantCount ?? this.variantCount,
      totalStockQuantity: totalStockQuantity ?? this.totalStockQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      categoryName: categoryName ?? this.categoryName,
      categoryId: categoryId ?? this.categoryId,
      baseUnitId: baseUnitId ?? this.baseUnitId,
      baseUnitCode: baseUnitCode ?? this.baseUnitCode,
      baseUnitName: baseUnitName ?? this.baseUnitName,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
