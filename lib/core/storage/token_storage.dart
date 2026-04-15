import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Token存储服务
class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  late final FlutterSecureStorage _secureStorage;

  TokenStorage() {
    // 根据平台配置不同的存储选项
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
      // Web平台使用localStorage
      webOptions: WebOptions(
        publicKey: 'MyAppKey',
      ),
    );
  }

  /// 保存Token
  Future<void> saveToken({
    required String token,
    String? refreshToken,
    int? expiresIn,
  }) async {
    try {
      debugPrint('🔐 开始保存Token...');
      await _secureStorage.write(key: _tokenKey, value: token);
      debugPrint('✅ Token已保存到安全存储');

      if (refreshToken != null) {
        await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
        debugPrint('✅ RefreshToken已保存到安全存储');
      }

      if (expiresIn != null) {
        final expiry = DateTime.now().add(Duration(seconds: expiresIn));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
        debugPrint('✅ Token过期时间已保存: $expiry (有效期: ${expiresIn ~/ 3600}小时)');
      }

      // 验证保存是否成功
      final savedToken = await _secureStorage.read(key: _tokenKey);
      if (savedToken != null && savedToken == token) {
        debugPrint('✅ Token保存验证成功');
      } else {
        debugPrint('❌ Token保存验证失败');
      }
    } catch (e) {
      debugPrint('❌ 保存Token时出错: $e');
      rethrow;
    }
  }

  /// 获取Token
  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      debugPrint('🔍 读取Token: ${token != null ? "成功" : "失败"}');
      return token;
    } catch (e) {
      debugPrint('❌ 读取Token时出错: $e');
      return null;
    }
  }

  /// 获取刷新Token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// 获取Token过期时间
  Future<DateTime?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString(_tokenExpiryKey);
    if (expiryStr != null) {
      return DateTime.parse(expiryStr);
    }
    return null;
  }

  /// 检查Token是否已过期
  Future<bool> isTokenExpired() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return false;

    final now = DateTime.now();
    return now.isAfter(expiry);
  }

  /// 检查Token是否即将过期（默认提前1天）
  Future<bool> isTokenAboutToExpire({int thresholdSeconds = 86400}) async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return false;

    final now = DateTime.now();
    final threshold = expiry.subtract(Duration(seconds: thresholdSeconds));
    return now.isAfter(threshold);
  }

  /// 获取Token剩余有效时间（秒）
  /// 如果Token已过期返回负数，如果无过期时间返回null
  Future<int?> getTokenRemainingSeconds() async {
    final expiry = await getTokenExpiry();
    if (expiry == null) return null;

    final now = DateTime.now();
    return expiry.difference(now).inSeconds;
  }

  /// 清除Token
  Future<void> clearTokens() async {
    try {
      debugPrint('🗑️ 开始清除Token...');
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenExpiryKey);
      debugPrint('✅ Token已清除');
    } catch (e) {
      debugPrint('❌ 清除Token时出错: $e');
    }
  }

  /// 检查是否已登录（检查Token是否存在且未过期）
  Future<bool> isLoggedIn() async {
    try {
      debugPrint('🔍 检查登录状态...');
      final token = await getToken();

      if (token == null || token.isEmpty) {
        debugPrint('❌ Token不存在或为空');
        return false;
      }

      // 检查Token是否已过期
      final expiry = await getTokenExpiry();
      if (expiry != null) {
        final now = DateTime.now();
        final isExpired = now.isAfter(expiry);

        debugPrint('📅 Token过期检查: $expiry, 当前: $now, 已过期: $isExpired');

        if (isExpired) {
          // Token已过期，清除本地存储
          debugPrint('⏰ Token已过期，清除本地存储');
          await clearTokens();
          return false;
        }
      } else {
        debugPrint('⚠️ 未设置Token过期时间，假设有效');
      }

      debugPrint('✅ 用户已登录');
      return true;
    } catch (e) {
      debugPrint('❌ 检查登录状态时出错: $e');
      return false;
    }
  }
}
