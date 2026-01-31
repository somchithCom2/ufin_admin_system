/// Shop details for admin panel
class AdminShop {
  final int id;
  final String name;
  final String? businessName;
  final String? address;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final String? businessType;
  final String status;
  final String? currency;
  final String? timezone;

  // Owner info
  final int? ownerId;
  final String? ownerUsername;
  final String? ownerEmail;
  final String? ownerPhone;

  // Subscription info
  final String? subscriptionPlan;
  final String? subscriptionStatus;
  final DateTime? subscriptionExpires;

  // Stats
  final int employeeCount;
  final int productCount;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminShop({
    required this.id,
    required this.name,
    this.businessName,
    this.address,
    this.phone,
    this.email,
    this.logoUrl,
    this.businessType,
    required this.status,
    this.currency,
    this.timezone,
    this.ownerId,
    this.ownerUsername,
    this.ownerEmail,
    this.ownerPhone,
    this.subscriptionPlan,
    this.subscriptionStatus,
    this.subscriptionExpires,
    this.employeeCount = 0,
    this.productCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminShop.fromJson(Map<String, dynamic> json) {
    return AdminShop(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      businessName: json['businessName'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      logoUrl: json['logoUrl'] as String?,
      businessType: json['businessType'] as String?,
      status: json['status'] as String? ?? 'active',
      currency: json['currency'] as String?,
      timezone: json['timezone'] as String?,
      ownerId: json['ownerId'] as int?,
      ownerUsername: json['ownerUsername'] as String?,
      ownerEmail: json['ownerEmail'] as String?,
      ownerPhone: json['ownerPhone'] as String?,
      subscriptionPlan: json['subscriptionPlan'] as String?,
      subscriptionStatus: json['subscriptionStatus'] as String?,
      subscriptionExpires: json['subscriptionExpires'] != null
          ? DateTime.tryParse(json['subscriptionExpires'] as String)
          : null,
      employeeCount: json['employeeCount'] as int? ?? 0,
      productCount: json['productCount'] as int? ?? 0,
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
    'name': name,
    'businessName': businessName,
    'address': address,
    'phone': phone,
    'email': email,
    'logoUrl': logoUrl,
    'businessType': businessType,
    'status': status,
    'currency': currency,
    'timezone': timezone,
    'ownerId': ownerId,
    'ownerUsername': ownerUsername,
    'ownerEmail': ownerEmail,
    'ownerPhone': ownerPhone,
    'subscriptionPlan': subscriptionPlan,
    'subscriptionStatus': subscriptionStatus,
    'subscriptionExpires': subscriptionExpires?.toIso8601String(),
    'employeeCount': employeeCount,
    'productCount': productCount,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  /// Check if shop is active
  bool get isActive => status.toLowerCase() == 'active';

  /// Check if shop is suspended
  bool get isSuspended => status.toLowerCase() == 'suspended';
}
