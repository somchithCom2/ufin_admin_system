import 'dart:convert';

class Unit {
  final int id;
  final String code;
  final Map<String, dynamic> name;
  final String abbreviation;
  final String category;
  final String? description;
  final bool isActive;
  final bool isDefault;
  final int sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Unit({
    required this.id,
    required this.code,
    required this.name,
    required this.abbreviation,
    required this.category,
    this.description,
    required this.isActive,
    required this.isDefault,
    required this.sortOrder,
    this.createdAt,
    this.updatedAt,
  });

  String displayName({String locale = 'en'}) {
    if (name[locale] != null) return name[locale].toString();
    if (name['en'] != null) return name['en'].toString();
    return name.values.firstOrNull?.toString() ?? '';
  }

  String displayNameMultilingual() {
    final parts = <String>[];
    const langs = ['en', 'lo', 'th', 'vi', 'zh'];
    for (final lang in langs) {
      if (name[lang] != null && (name[lang] as String?)?.isNotEmpty == true) {
        parts.add('${lang.toUpperCase()}: ${name[lang]}');
      }
    }
    return parts.isNotEmpty ? parts.join(' / ') : code;
  }

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: _parseNameMap(json['name']),
      abbreviation: json['abbreviation'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isDefault: json['isDefault'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  static Map<String, dynamic> _parseNameMap(dynamic value) {
    if (value == null) return {};

    // If it's already a Map, convert to Map<String, dynamic>
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    // If it's a JSON string, parse it
    if (value is String) {
      try {
        final parsed = jsonDecode(value);
        if (parsed is Map<String, dynamic>) {
          return parsed;
        } else if (parsed is Map) {
          return Map<String, dynamic>.from(parsed);
        }
      } catch (_) {
        // If JSON parsing fails, treat the whole string as English name
        return {'en': value};
      }
    }

    return {};
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'abbreviation': abbreviation,
    'category': category,
    if (description != null) 'description': description,
    'isActive': isActive,
    'isDefault': isDefault,
    'sortOrder': sortOrder,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  Unit copyWith({
    int? id,
    String? code,
    Map<String, dynamic>? name,
    String? abbreviation,
    String? category,
    String? description,
    bool? isActive,
    bool? isDefault,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Unit(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      category: category ?? this.category,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CreateUnitRequest {
  final String code;
  final Map<String, dynamic> name;
  final String abbreviation;
  final String category;
  final String? description;
  final bool? isActive;
  final bool? isDefault;
  final int? sortOrder;

  const CreateUnitRequest({
    required this.code,
    required this.name,
    required this.abbreviation,
    required this.category,
    this.description,
    this.isActive,
    this.isDefault,
    this.sortOrder,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'abbreviation': abbreviation,
    'category': category,
    if (description != null) 'description': description,
    if (isActive != null) 'isActive': isActive,
    if (isDefault != null) 'isDefault': isDefault,
    if (sortOrder != null) 'sortOrder': sortOrder,
  };
}

class UpdateUnitRequest {
  final String? code;
  final Map<String, dynamic>? name;
  final String? abbreviation;
  final String? category;
  final String? description;
  final bool? isActive;
  final bool? isDefault;
  final int? sortOrder;

  const UpdateUnitRequest({
    this.code,
    this.name,
    this.abbreviation,
    this.category,
    this.description,
    this.isActive,
    this.isDefault,
    this.sortOrder,
  });

  Map<String, dynamic> toJson() => {
    if (code != null) 'code': code,
    if (name != null) 'name': name,
    if (abbreviation != null) 'abbreviation': abbreviation,
    if (category != null) 'category': category,
    if (description != null) 'description': description,
    if (isActive != null) 'isActive': isActive,
    if (isDefault != null) 'isDefault': isDefault,
    if (sortOrder != null) 'sortOrder': sortOrder,
  };
}

class UnitsPageResponse {
  final List<Unit> data;
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  const UnitsPageResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });
}
