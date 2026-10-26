import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'auth_token';
  static const _keyRole = 'user_role';
  static const _keyUserName = 'user_name';
  static const _keyUserEmail = 'user_email';

  static Future<void> saveAuthSession({
    required String token,
    required String role,
    required String name,
    required String email,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyRole, value: role);
    await _storage.write(key: _keyUserName, value: name);
    await _storage.write(key: _keyUserEmail, value: email);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: _keyRole);
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: _keyUserName);
  }

  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}
