/// Admin status enum
enum AdminStatus {
  active,
  inactive,
  suspended;

  String get value => name;

  String get displayName {
    switch (this) {
      case AdminStatus.active:
        return 'Active';
      case AdminStatus.inactive:
        return 'Inactive';
      case AdminStatus.suspended:
        return 'Suspended';
    }
  }

  static AdminStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AdminStatus.active;
      case 'inactive':
        return AdminStatus.inactive;
      case 'suspended':
        return AdminStatus.suspended;
      default:
        return AdminStatus.active;
    }
  }
}

/// Admin user entity for the admin system
class AdminUser {
  final int id;
  final String username;
  final String? email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final AdminStatus status;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminUser({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.status = AdminStatus.active,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });

  /// Full name of the admin
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return username;
  }

  /// Initials for avatar
  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    } else if (firstName != null && firstName!.isNotEmpty) {
      return firstName![0].toUpperCase();
    } else if (username.isNotEmpty) {
      return username[0].toUpperCase();
    }
    return 'A';
  }

  /// Display contact (email or phone)
  String get displayContact => email ?? phone ?? 'No contact';

  /// Check if admin is active
  bool get isActive => status == AdminStatus.active;

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
    id: json['id'] as int? ?? json['userId'] as int,
    username: json['username'] as String,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    firstName: json['firstName'] as String? ?? json['first_name'] as String?,
    lastName: json['lastName'] as String? ?? json['last_name'] as String?,
    avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
    status: json['status'] != null
        ? AdminStatus.fromString(json['status'] as String)
        : AdminStatus.active,
    lastLogin: json['lastLogin'] != null
        ? DateTime.parse(json['lastLogin'] as String)
        : json['last_login'] != null
        ? DateTime.parse(json['last_login'] as String)
        : null,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : null,
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'phone': phone,
    'firstName': firstName,
    'lastName': lastName,
    'avatarUrl': avatarUrl,
    'status': status.value,
    'lastLogin': lastLogin?.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  AdminUser copyWith({
    int? id,
    String? username,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    AdminStatus? status,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminUser && other.id == id && other.username == username;
  }

  @override
  int get hashCode => id.hashCode ^ username.hashCode;

  @override
  String toString() =>
      'AdminUser(id: $id, username: $username, status: $status)';
}
