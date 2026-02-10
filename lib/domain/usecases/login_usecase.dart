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
    required String phone_number,
    required String password,
  }) async {
    // Validate input
    if (phone_number.trim().isEmpty) {
      throw Exception('Phone number cannot be empty');
    }

    if (password.trim().isEmpty) {
      throw Exception('Password cannot be empty');
    }

    // Validate Ethiopian phone number format
    final isValidPhoneNumber = RegExp(
      r'^[\+]?(251|0)?9\d{8}$',
    ).hasMatch(phone_number.trim());
    if (!isValidPhoneNumber) {
      throw Exception('Please enter a valid phone number');
    }

    // Create login entity
    final loginEntity = LoginEntity(
      phone_number: phone_number.trim(),
      password: password.trim(),
    );

    // Call repository
    return await repository.login(loginEntity);
  }
}

