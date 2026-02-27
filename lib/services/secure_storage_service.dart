import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      keyCipherAlgorithm:
          KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      resetOnError: true,
    ),
    iOptions: const IOSOptions(),
  );

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Future<void> saveUserData({
  //   required String userId,
  //   required String email,
  //   required String name,
  // }) async {
  //   await Future.wait([
  //     _secureStorage.write(key: _userIdKey, value: userId),
  //     _secureStorage.write(key: _userEmailKey, value: email),
  //     _secureStorage.write(key: _userNameKey, value: name),
  //   ]);
  // }

  // Future<Map<String, String?>> getUserData() async {
  //   final values = await Future.wait([
  //     _secureStorage.read(key: _userIdKey),
  //     _secureStorage.read(key: _userEmailKey),
  //     _secureStorage.read(key: _userNameKey),
  //   ]);

  //   return {'userId': values[0], 'email': values[1], 'name': values[2]};
  // }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  Future<void> saveUserData({
    required String userId,
    required String email,
    required String name,
  }) async {
    try {
      await Future.wait([
        _secureStorage.write(key: _userIdKey, value: userId),
        _secureStorage.write(key: _userEmailKey, value: email),
        _secureStorage.write(key: _userNameKey, value: name),
      ]);
    } catch (e) {
      // Fallback: Log the error but allow login to proceed
      print('Warning: Secure storage failed, using app session only: $e');
      // In production, you might want to notify the user
    }
  }

  Future<Map<String, String?>> getUserData() async {
    try {
      final values = await Future.wait([
        _secureStorage.read(key: _userIdKey),
        _secureStorage.read(key: _userEmailKey),
        _secureStorage.read(key: _userNameKey),
      ]);

      return {'userId': values[0], 'email': values[1], 'name': values[2]};
    } catch (e) {
      print('Warning: Failed to retrieve secure storage: $e');
      return {};
    }
  }
}
