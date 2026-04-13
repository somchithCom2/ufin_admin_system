/// Shop type for categorizing shops
class ShopType {
  final int id;
  final String code;
  final String name;
  final String? description;
  final String? iconName;
  final List<String> features;
  final bool enabled;
  final int displayOrder;
  final int shopCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Extracts a string from a value that may be a localized map or a plain string.
  static String? _localized(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      return (value['en'] ??
              value['lo'] ??
              value['th'] ??
              value.values.firstOrNull)
          ?.toString();
    }
    return value.toString();
  }

  const ShopType({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.iconName,
    this.features = const [],
    this.enabled = true,
    this.displayOrder = 0,
    this.shopCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ShopType.fromJson(Map<String, dynamic> json) {
    return ShopType(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      name: _localized(json['name']) ?? '',
      description: _localized(json['description']),
      iconName: json['iconName'] as String?,
      features: (json['features'] as List<dynamic>?)?.cast<String>() ?? [],
      enabled: (json['enabled'] ?? json['isActive']) as bool? ?? true,
      displayOrder: json['displayOrder'] as int? ?? 0,
      shopCount: json['shopCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'description': description,
    'iconName': iconName,
    'features': features,
    'enabled': enabled,
    'displayOrder': displayOrder,
    'shopCount': shopCount,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  ShopType copyWith({
    int? id,
    String? code,
    String? name,
    String? description,
    String? iconName,
    List<String>? features,
    bool? enabled,
    int? displayOrder,
    int? shopCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ShopType(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      features: features ?? this.features,
      enabled: enabled ?? this.enabled,
      displayOrder: displayOrder ?? this.displayOrder,
      shopCount: shopCount ?? this.shopCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Request to create a new shop type
class CreateShopTypeRequest {
  final String code;
  final Map<String, dynamic> name;
  final Map<String, dynamic>? description;
  final String? iconName;
  final List<String>? features;
  final int? displayOrder;

  const CreateShopTypeRequest({
    required this.code,
    required this.name,
    this.description,
    this.iconName,
    this.features,
    this.displayOrder,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    if (description != null) 'description': description,
    if (iconName != null) 'iconName': iconName,
    if (features != null) 'features': features,
    if (displayOrder != null) 'displayOrder': displayOrder,
  };
}

/// Request to update a shop type
class UpdateShopTypeRequest {
  final String? code;
  final Map<String, dynamic>? name;
  final Map<String, dynamic>? description;
  final String? iconName;
  final List<String>? features;
  final int? displayOrder;

  const UpdateShopTypeRequest({
    this.code,
    this.name,
    this.description,
    this.iconName,
    this.features,
    this.displayOrder,
  });

  Map<String, dynamic> toJson() => {
    if (code != null) 'code': code,
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (iconName != null) 'iconName': iconName,
    if (features != null) 'features': features,
    if (displayOrder != null) 'displayOrder': displayOrder,
  };
}
