class LoginResponse {
  final int userId;
  final String username;
  final int? shopId;
  final String role;
  final String token;

  const LoginResponse({
    required this.userId,
    required this.username,
    this.shopId,
    required this.role,
    required this.token,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'shopId': shopId,
    'role': role,
    'token': token,
  };

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    userId: json['userId'] as int,
    username: json['username'] as String,
    shopId: json['shopId'] as int?,
    role: json['role'] as String,
    token: json['token'] as String,
  );

  /// Check if the user has admin role (ADMIN or SYSTEM_ADMIN)
  bool get isAdmin {
    final r = role.toUpperCase();
    return r == 'ADMIN' || r == 'SYSTEM_ADMIN';
  }
}
