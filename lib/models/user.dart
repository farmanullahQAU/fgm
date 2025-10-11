class User {
  final String? id;
  final String email;
  final String? password;
  final String firstName;
  final String lastName;
  final String? phone;
  final String role;
  final bool isActive;
  final DateTime? lastLogin;
  final List<RefreshToken>? refreshTokens;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? fullName;

  User({
    this.id,
    required this.email,
    this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.role = 'user',
    this.isActive = true,
    this.lastLogin,
    this.refreshTokens,
    this.createdAt,
    this.updatedAt,
    this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String?,
      email: json['email'] as String,
      password: json['password'] as String?,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'user',
      isActive: json['isActive'] as bool? ?? true,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      refreshTokens: json['refreshTokens'] != null
          ? (json['refreshTokens'] as List<dynamic>)
                .map((e) => RefreshToken.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      fullName: json['fullName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'email': email,
      if (password != null) 'password': password,
      'firstName': firstName,
      'lastName': lastName,
      if (phone != null) 'phone': phone,
      'role': role,
      'isActive': isActive,
      if (lastLogin != null) 'lastLogin': lastLogin!.toIso8601String(),
      if (refreshTokens != null)
        'refreshTokens': refreshTokens!.map((e) => e.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (fullName != null) 'fullName': fullName,
    }..removeWhere((key, value) => key == 'password' || key == 'refreshTokens');
  }
}

class RefreshToken {
  final String token;
  final DateTime createdAt;

  RefreshToken({required this.token, required this.createdAt});

  factory RefreshToken.fromJson(Map<String, dynamic> json) {
    return RefreshToken(
      token: json['token'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'createdAt': createdAt.toIso8601String()};
  }
}
