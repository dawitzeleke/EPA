/// Domain entity representing a user login
class LoginEntity {
  final String? phone_number;
  final String password;
  final String? username;
  final String? token;
  final String? userId;
  final String? email;

  LoginEntity({
    this.phone_number,
    this.email,
    required this.password,
    this.username,
    this.token,
    this.userId,
  });
}

/// Domain entity representing login response
class LoginResponseEntity {
  final bool success;
  final String? token;
  final String? userId;
  final String? username;
  final String? phone_number;
  final String? message;
  final String email;

  LoginResponseEntity({
    required this.success,
    this.token,
    this.userId,
    this.username,
    this.phone_number,
    this.message,
    required this.email,
  });
}

