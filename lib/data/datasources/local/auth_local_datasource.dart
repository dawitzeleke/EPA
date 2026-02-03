import 'package:get_storage/get_storage.dart';

/// Local data source for authentication
/// Handles local storage operations (token, user data, etc.)
abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<void> saveUserId(String userId);
  Future<void> saveUsername(String username);
  Future<void> savePhoneNumber(String phoneNumber);
  Future<void> saveEmail(String email);
  Future<String?> getEmail();
  Future<String?> getToken();
  Future<String?> getUserId();
  Future<String?> getUsername();
  Future<String?> getPhoneNumber();
  Future<void> clearAll();
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final GetStorage storage;

  AuthLocalDataSourceImpl({required this.storage});

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _phoneNumberKey = 'phone_number';
  static const String _emailKey = 'email';

  @override
  Future<void> saveToken(String token) async {
    await storage.write(_tokenKey, token);
  }

  @override
  Future<void> saveUserId(String userId) async {
    await storage.write(_userIdKey, userId);
  }

  @override
  Future<void> saveUsername(String username) async {
    await storage.write(_usernameKey, username);
  }

  @override
  Future<void> savePhoneNumber(String phoneNumber) async {
    await storage.write(_phoneNumberKey, phoneNumber);
  }

  @override
  Future<void> saveEmail(String email) async {
    await storage.write(_emailKey, email);
  }

  @override
  Future<String?> getToken() async {
    return storage.read(_tokenKey);
  }

  @override
  Future<String?> getUserId() async {
    return storage.read(_userIdKey);
  }

  @override
  Future<String?> getUsername() async {
    return storage.read(_usernameKey);
  }

  @override
  Future<String?> getPhoneNumber() async {
    return storage.read(_phoneNumberKey);
  }

  @override
  Future<String?> getEmail() async {
    return storage.read(_emailKey);
  }

  @override
  Future<void> clearAll() async {
    await storage.remove(_tokenKey);
    await storage.remove(_userIdKey);
    await storage.remove(_usernameKey);
    await storage.remove(_phoneNumberKey);
    await storage.remove(_emailKey);  
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}

