import 'admin_shop.dart';

/// Makes an existing top-level shop a branch of another
/// (PUT /admin/shops/{id}/link-to-parent).
class LinkBranchRequest {
  final int parentShopId;

  /// Required when the two shops have different owners: the shop moves to
  /// the parent's owner so one login sees the whole group.
  final bool transferOwnership;

  /// Switches off the previous owner's access to the shop after a transfer.
  final bool revokePreviousOwnerAccess;

  /// Links even when the parent's plan has no branches (`multi_shop`).
  final bool ignorePlanCheck;
  final String confirmShopName;
  final String reason;

  const LinkBranchRequest({
    required this.parentShopId,
    required this.confirmShopName,
    required this.reason,
    this.transferOwnership = false,
    this.revokePreviousOwnerAccess = false,
    this.ignorePlanCheck = false,
  });

  Map<String, dynamic> toJson() => {
    'parentShopId': parentShopId,
    'transferOwnership': transferOwnership,
    'revokePreviousOwnerAccess': revokePreviousOwnerAccess,
    'ignorePlanCheck': ignorePlanCheck,
    'confirmShopName': confirmShopName,
    'reason': reason,
  };
}

/// Turns a branch back into a top-level shop on Free
/// (PUT /admin/shops/{id}/unlink-from-parent).
class UnlinkBranchRequest {
  /// Hands the shop to this account; null keeps the group's owner.
  final int? ownerUserId;

  /// Only read when [ownerUserId] changes the owner. On by default on the
  /// backend: once handed back, the shop is another business.
  final bool revokePreviousOwnerAccess;
  final String confirmShopName;
  final String reason;

  const UnlinkBranchRequest({
    required this.confirmShopName,
    required this.reason,
    this.ownerUserId,
    this.revokePreviousOwnerAccess = true,
  });

  Map<String, dynamic> toJson() => {
    if (ownerUserId != null) 'ownerUserId': ownerUserId,
    'revokePreviousOwnerAccess': revokePreviousOwnerAccess,
    'confirmShopName': confirmShopName,
    'reason': reason,
  };
}

/// Hands a top-level shop to another account (PUT /admin/shops/{id}/owner).
class ChangeOwnerRequest {
  final int newOwnerUserId;
  final bool revokePreviousOwnerAccess;
  final String confirmShopName;
  final String reason;

  const ChangeOwnerRequest({
    required this.newOwnerUserId,
    required this.confirmShopName,
    required this.reason,
    this.revokePreviousOwnerAccess = true,
  });

  Map<String, dynamic> toJson() => {
    'newOwnerUserId': newOwnerUserId,
    'revokePreviousOwnerAccess': revokePreviousOwnerAccess,
    'confirmShopName': confirmShopName,
    'reason': reason,
  };
}

/// Someone still active in a shop that changed hands and tied to its
/// previous owner. Nobody is removed automatically; the admin decides.
class StaffToReview {
  final int employeeId;
  final int userId;
  final String username;
  final String? fullName;
  final String? roleName;

  /// The previous owner themself, whose access was kept.
  final bool previousOwner;

  const StaffToReview({
    required this.employeeId,
    required this.userId,
    required this.username,
    this.fullName,
    this.roleName,
    this.previousOwner = false,
  });

  factory StaffToReview.fromJson(Map<String, dynamic> json) => StaffToReview(
    employeeId: json['employeeId'] as int,
    userId: json['userId'] as int,
    username: json['username'] as String? ?? '',
    fullName: json['fullName'] as String?,
    roleName: json['roleName'] as String?,
    previousOwner: json['previousOwner'] as bool? ?? false,
  );

  /// The name to show: full name when set, else the username.
  String get displayName =>
      (fullName ?? '').trim().isEmpty ? username : fullName!.trim();
}

/// What link, unlink and change-owner answer with: the shop as it is now and
/// the staff the admin should look at.
class ShopOwnershipResult {
  final AdminShop shop;
  final List<StaffToReview> staffToReview;

  const ShopOwnershipResult({
    required this.shop,
    this.staffToReview = const [],
  });

  factory ShopOwnershipResult.fromJson(Map<String, dynamic> json) =>
      ShopOwnershipResult(
        shop: AdminShop.fromJson(json['shop'] as Map<String, dynamic>),
        staffToReview: (json['staffToReview'] as List<dynamic>? ?? const [])
            .map((e) => StaffToReview.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// One change of a shop's owner made from the admin console.
class OwnerChange {
  final int? fromOwnerId;
  final int? toOwnerId;

  /// `link`, `unlink` or `owner_change`.
  final String? source;
  final String? reason;
  final int? performedById;
  final DateTime? createdAt;

  const OwnerChange({
    this.fromOwnerId,
    this.toOwnerId,
    this.source,
    this.reason,
    this.performedById,
    this.createdAt,
  });

  factory OwnerChange.fromJson(Map<String, dynamic> json) => OwnerChange(
    fromOwnerId: json['fromOwnerId'] as int?,
    toOwnerId: json['toOwnerId'] as int?,
    source: json['source'] as String?,
    reason: json['reason'] as String?,
    performedById: json['performedById'] as int?,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String)
        : null,
  );

  String get sourceLabel => switch (source) {
    'link' => 'Linked into a branch group',
    'unlink' => 'Unlinked from a branch group',
    'owner_change' => 'Owner changed',
    _ => 'Owner changed',
  };
}
