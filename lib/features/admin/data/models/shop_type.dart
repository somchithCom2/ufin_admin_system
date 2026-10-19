/// How many shops use a shop type, from `GET /business-types/stats`.
class ShopTypeUsage {
  final int total;
  final int active;
  final int inactive;
  final int suspended;

  const ShopTypeUsage({
    this.total = 0,
    this.active = 0,
    this.inactive = 0,
    this.suspended = 0,
  });

  factory ShopTypeUsage.fromJson(Map<String, dynamic> json) {
    int count(String key) => (json[key] as num?)?.toInt() ?? 0;
    return ShopTypeUsage(
      total: count('totalShops'),
      active: count('activeShops'),
      inactive: count('inactiveShops'),
      suspended: count('suspendedShops'),
    );
  }
}

/// Shop type for categorizing shops
class ShopType {
  final int id;
  final String code;
  final String name;
  final String? description;

  /// All translations as sent by the server (e.g. `{en: ..., lo: ...}`).
  /// Edit forms must round-trip these, or saving drops non-English text.
  final Map<String, String> nameI18n;
  final Map<String, String> descriptionI18n;

  /// Feature keys the POS app unlocks for shops of this type. The backend
  /// replaces them on every update, so edits must send them back.
  final List<String> features;
  final bool enabled;
  final DateTime? createdAt;

  /// Null when the stats endpoint could not be read: unknown, not zero.
  final ShopTypeUsage? usage;

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

  static Map<String, String> _translations(dynamic value) {
    if (value is Map) {
      return {
        for (final e in value.entries)
          if (e.value != null && e.value.toString().isNotEmpty)
            e.key.toString(): e.value.toString(),
      };
    }
    if (value is String && value.isNotEmpty) return {'en': value};
    return const {};
  }

  const ShopType({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.nameI18n = const {},
    this.descriptionI18n = const {},
    this.features = const [],
    this.enabled = true,
    this.createdAt,
    this.usage,
  });

  factory ShopType.fromJson(Map<String, dynamic> json) {
    return ShopType(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String? ?? '',
      name: _localized(json['name']) ?? '',
      description: _localized(json['description']),
      nameI18n: _translations(json['name']),
      descriptionI18n: _translations(json['description']),
      features: (json['features'] as List<dynamic>?)?.cast<String>() ?? [],
      enabled: (json['enabled'] ?? json['isActive']) as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      usage: json.containsKey('totalShops')
          ? ShopTypeUsage.fromJson(json)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': nameI18n.isEmpty ? name : nameI18n,
    'description': descriptionI18n.isEmpty ? description : descriptionI18n,
    'features': features,
    'enabled': enabled,
    'createdAt': createdAt?.toIso8601String(),
  };

  ShopType withUsage(ShopTypeUsage? usage) => ShopType(
    id: id,
    code: code,
    name: name,
    description: description,
    nameI18n: nameI18n,
    descriptionI18n: descriptionI18n,
    features: features,
    enabled: enabled,
    createdAt: createdAt,
    usage: usage,
  );
}

/// Request to create a new shop type
class CreateShopTypeRequest {
  final String code;
  final Map<String, dynamic> name;
  final Map<String, dynamic>? description;
  final List<String>? features;

  const CreateShopTypeRequest({
    required this.code,
    required this.name,
    this.description,
    this.features,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    if (description != null) 'description': description,
    if (features != null) 'features': features,
  };
}

/// Request to update a shop type. `PUT /business-types/{id}` replaces every
/// field: an omitted description or feature list is cleared, not kept.
class UpdateShopTypeRequest {
  final String code;
  final Map<String, dynamic> name;
  final Map<String, dynamic> description;
  final List<String> features;

  const UpdateShopTypeRequest({
    required this.code,
    required this.name,
    required this.description,
    required this.features,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'description': description,
    'features': features,
  };
}
