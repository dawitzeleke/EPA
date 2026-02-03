/// Domain entity representing a user login
class LoginEntity {
  final String? phoneNumber;
  final String password;
  final String? username;
  final String? token;
  final String? userId;
  final String email;

  LoginEntity({
    this.phoneNumber,
    required this.email,
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
  final String? phoneNumber;
  final String? message;
  final String email;

  LoginResponseEntity({
    required this.success,
    this.token,
    this.userId,
    this.username,
    this.phoneNumber,
    this.message,
    required this.email,
  });
}

