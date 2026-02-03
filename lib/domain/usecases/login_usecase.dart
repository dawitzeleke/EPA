import '../entities/login_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login
/// This encapsulates the business logic for login
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Execute login with phone number and password
  /// Returns LoginResponseEntity on success
  /// Throws exception on failure
  Future<LoginResponseEntity> execute({
    required String email,
    required String password,
  }) async {
    // Validate input
    if (email.trim().isEmpty) {
      throw Exception('Email cannot be empty');
    }

    if (password.trim().isEmpty) {
      throw Exception('Password cannot be empty');
    }

    // Validate Ethiopian phone number format
    final isValidEmail = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);
    if (!isValidEmail) {
      throw Exception('Please enter a valid email address');
    }

    // Create login entity
    final loginEntity = LoginEntity(
      email: email.trim(),
      password: password.trim(),
    );

    // Call repository
    return await repository.login(loginEntity);
  }
}

