class SessionResponse {
  final int userId;
  final String username;
  final String? role;

  const SessionResponse({
    required this.userId,
    required this.username,
    this.role,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'role': role,
  };

  factory SessionResponse.fromJson(Map<String, dynamic> json) =>
      SessionResponse(
        userId: json['userId'] as int,
        username: json['username'] as String,
        role: json['role'] as String?,
      );

  /// Check if the user has admin role
  bool get isAdmin => role?.toUpperCase() == 'ADMIN';
}
