/// User details for admin panel
class AdminUser {
  final int id;
  final String username;
  final String? email;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String userType;
  final String status;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Shops this user belongs to
  final List<UserShopInfo> shops;

  const AdminUser({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    required this.userType,
    required this.status,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
    this.shops = const [],
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      userType: json['userType'] as String? ?? 'user',
      status: json['status'] as String? ?? 'active',
      emailVerified: json['emailVerified'] as bool? ?? false,
      phoneVerified: json['phoneVerified'] as bool? ?? false,
      lastLogin: json['lastLogin'] != null
          ? DateTime.tryParse(json['lastLogin'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      shops:
          (json['shops'] as List<dynamic>?)
              ?.map((e) => UserShopInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'phone': phone,
    'firstName': firstName,
    'lastName': lastName,
    'avatarUrl': avatarUrl,
    'userType': userType,
    'status': status,
    'emailVerified': emailVerified,
    'phoneVerified': phoneVerified,
    'lastLogin': lastLogin?.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'shops': shops.map((e) => e.toJson()).toList(),
  };

  /// Get full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? username;
  }

  /// Check if user is active
  bool get isActive => status.toLowerCase() == 'active';

  /// Check if user is shop owner
  bool get isShopOwner => userType.toUpperCase() == 'SHOP_OWNER';
}

/// User's shop membership info
class UserShopInfo {
  final int shopId;
  final String shopName;
  final String role;
  final String? employeeStatus;

  const UserShopInfo({
    required this.shopId,
    required this.shopName,
    required this.role,
    this.employeeStatus,
  });

  factory UserShopInfo.fromJson(Map<String, dynamic> json) {
    return UserShopInfo(
      shopId: json['shopId'] as int,
      shopName: json['shopName'] as String? ?? '',
      role: json['role'] as String? ?? '',
      employeeStatus: json['employeeStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'shopId': shopId,
    'shopName': shopName,
    'role': role,
    'employeeStatus': employeeStatus,
  };
}
