import '../../domain/entities/login_entity.dart';

/// Data model for login request
class LoginModel extends LoginEntity {
  LoginModel({
    super.phone_number,
    required super.password,
    super.username,
    super.token,
    super.userId,
    required super.email,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'phone_number': phone_number,
      'password': password,
      if (username != null) 'username': username,
      'email': email,
    };
  }

  /// Create from JSON
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      phone_number: json['phone_number'] ?? json['phoneNumber'] ?? '',
      password: json['password'] ?? '',
      username: json['username'],
      token: json['token'],
      userId: json['user_id'] ?? json['userId'],
      email: json['email'] ?? '',
    );
  }
}

/// Data model for login response
class LoginResponseModel extends LoginResponseEntity {
  LoginResponseModel({
    required super.success,
    super.token,
    super.userId,
    super.username,
    super.phone_number,
    super.message,
    required super.email,
  });

  /// Create from JSON
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // Some APIs return { token: '...', customer: { ... } } without a
    // explicit `success` boolean. Detect token presence and customer
    // payloads to determine success and extract fields accordingly.
    final token = json['token'] ??
        json['access_token'] ??
        json['data']?['token'] ??
        json['data']?['access_token'] ??
        json['customer']?['token'] ??
        json['customer']?['access_token'];
    final customer = json['customer'] ?? json['data']?['customer'];

    String? userId;
    String? username;
    String? phoneNumber;
    String email = '';

    if (customer is Map<String, dynamic>) {
      userId = customer['customer_id'] ?? customer['user_id'] ?? customer['id'];
      username = customer['full_name'] ?? customer['username'] ?? customer['name'];
      phoneNumber = customer['phone_number'] ?? customer['phoneNumber'];
      email = customer['email'] ?? '';
    }

    return LoginResponseModel(
      // Treat presence of a token as success when no explicit `success` is provided
      success: json['success'] ?? (token != null),
      token: token,
      userId: userId ?? json['user_id'] ?? json['userId'] ?? json['data']?['user_id'] ?? json['data']?['userId'],
      username: username ?? json['username'] ?? json['data']?['username'],
      phone_number: phoneNumber ?? json['phone_number'] ?? json['phoneNumber'] ?? json['data']?['phone_number'] ?? json['data']?['phoneNumber'],
      message: json['message'] ?? json['error'] ?? json['data']?['message'],
      email: email.isNotEmpty ? email : (json['email'] ?? json['data']?['email'] ?? ''),
    );
  }

  /// Convert to entity
  LoginResponseEntity toEntity() {
    return LoginResponseEntity(
      success: success,
      token: token,
      userId: userId,
      username: username,
      phone_number: phone_number,
      message: message,
      email: email,
    );
  }
}

