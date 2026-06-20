/// Product item returned from GET /products/{shopId}/{empId}/paginated
class AdminProduct {
  final int id;
  final String name;
  final String? sku;
  final String? description;
  final double price;
  final double? cost;
  final int stockQuantity;
  final String? imageUrl;
  final String? categoryName;
  final int? categoryId;
  final bool isActive;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminProduct({
    required this.id,
    required this.name,
    this.sku,
    this.description,
    required this.price,
    this.cost,
    required this.stockQuantity,
    this.imageUrl,
    this.categoryName,
    this.categoryId,
    required this.isActive,
    required this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminProduct.fromJson(Map<String, dynamic> json) {
    return AdminProduct(
      id: json['id'] as int,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : null,
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String?,
      categoryName: json['categoryName'] as String?,
      categoryId: json['categoryId'] as int?,
      isActive: json['isActive'] as bool? ?? true,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}
