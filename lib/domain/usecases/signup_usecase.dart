import '../entities/signup_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for user signup
/// This encapsulates the business logic for signup
class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  /// Execute signup with full name, email, phone number and password
  /// Returns SignupResponseEntity on success
  /// Throws exception on failure
  Future<SignupResponseEntity> execute({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    // Validate input
    if (fullName.trim().isEmpty) {
      throw Exception('Full name cannot be empty');
    }

    if (email.trim().isEmpty) {
      throw Exception('Email cannot be empty');
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      throw Exception('Please enter a valid email address');
    }

    if (phoneNumber.trim().isEmpty) {
      throw Exception('Phone number cannot be empty');
    }

    // Validate Ethiopian phone number format (starts with 09 and has 10 digits)
    final isValidPhone = RegExp(r'^09\d{8}$').hasMatch(phoneNumber.trim());
    if (!isValidPhone) {
      throw Exception('Please enter a valid Ethiopian phone number (e.g. 0912345678)');
    }

    if (password.trim().isEmpty) {
      throw Exception('Password cannot be empty');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long');
    }

    if (confirmPassword.trim().isEmpty) {
      throw Exception('Password confirmation cannot be empty');
    }

    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }

    // Create signup entity
    final signupEntity = SignupEntity(
      fullName: fullName.trim(),
      email: email.trim(),
      phoneNumber: phoneNumber.trim(),
      password: password.trim(),
      confirmPassword: confirmPassword.trim(),
    );

    // Call repository
    return await repository.signup(signupEntity);
  }
}

