import 'package:flutter_test/flutter_test.dart';
import 'package:ai_student_career/core/storage/token_storage.dart';

void main() {
  // 初始化Flutter测试绑定
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TokenStorage Tests', () {
    late TokenStorage tokenStorage;

    setUp(() async {
      // 在每个测试前初始化
      tokenStorage = TokenStorage();
    });

    test('保存和获取Token', () async {
      const testToken = 'test_token_123';

      await tokenStorage.saveToken(
        token: testToken,
        expiresIn: 7 * 24 * 60 * 60, // 7天
      );

      final retrievedToken = await tokenStorage.getToken();
      expect(retrievedToken, equals(testToken));
    });

    test('保存Token时设置正确的过期时间', () async {
      const testToken = 'test_token_123';
      const expiresIn = 7 * 24 * 60 * 60; // 7天

      final beforeSave = DateTime.now();

      await tokenStorage.saveToken(
        token: testToken,
        expiresIn: expiresIn,
      );

      final expiry = await tokenStorage.getTokenExpiry();
      expect(expiry, isNotNull);

      final afterSave = DateTime.now();
      final expectedMinExpiry = beforeSave.add(Duration(seconds: expiresIn));
      final expectedMaxExpiry = afterSave.add(Duration(seconds: expiresIn));

      expect(
        expiry!.isAfter(expectedMinExpiry.subtract(const Duration(seconds: 1))) &&
            expiry.isBefore(expectedMaxExpiry.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('检查Token是否过期', () async {
      const testToken = 'test_token_123';

      // 保存一个已经过期的Token（过期时间为-1秒）
      await tokenStorage.saveToken(
        token: testToken,
        expiresIn: -1,
      );

      final isExpired = await tokenStorage.isTokenExpired();
      expect(isExpired, isTrue);
    });

    test('检查未过期的Token', () async {
      const testToken = 'test_token_123';

      // 保存一个未过期的Token（过期时间为7天）
      await tokenStorage.saveToken(
        token: testToken,
        expiresIn: 7 * 24 * 60 * 60,
      );

      final isExpired = await tokenStorage.isTokenExpired();
      expect(isExpired, isFalse);
    });

    test('isLoggedIn应该返回false对于过期的Token', () async {
      const testToken = 'test_token_123';

      // 保存一个已经过期的Token
      await tokenStorage.saveToken(
        token: testToken,
        expiresIn: -1,
      );

      final isLoggedIn = await tokenStorage.isLoggedIn();
      expect(isLoggedIn, isFalse);
    });

    test('isLoggedIn应该返回true对于有效的Token', () async {
      const testToken = 'test_token_123';

      // 保存一个有效的Token
      await tokenStorage.saveToken(
        token: testToken,
        expiresIn: 7 * 24 * 60 * 60,
      );

      final isLoggedIn = await tokenStorage.isLoggedIn();
      expect(isLoggedIn, isTrue);
    });

    test('清除Token', () async {
      const testToken = 'test_token_123';

      await tokenStorage.saveToken(
        token: testToken,
        expiresIn: 7 * 24 * 60 * 60,
      );

      await tokenStorage.clearTokens();

      final retrievedToken = await tokenStorage.getToken();
      expect(retrievedToken, isNull);

      final expiry = await tokenStorage.getTokenExpiry();
      expect(expiry, isNull);
    });

    test('获取Token剩余有效时间', () async {
      const testToken = 'test_token_123';
      const expiresIn = 3600; // 1小时

      await tokenStorage.saveToken(
        token: testToken,
        expiresIn: expiresIn,
      );

      final remainingSeconds = await tokenStorage.getTokenRemainingSeconds();
      expect(remainingSeconds, isNotNull);
      expect(remainingSeconds!, greaterThan(3500)); // 至少还剩58分钟
      expect(remainingSeconds, lessThanOrEqualTo(expiresIn));
    });

    test('检查Token是否即将过期', () async {
      const testToken = 'test_token_123';

      // 保存一个即将过期的Token（剩余时间少于默认阈值）
      await tokenStorage.saveToken(
        token: testToken,
        expiresIn: 3600, // 1小时（小于默认的1天阈值）
      );

      final isAboutToExpire = await tokenStorage.isTokenAboutToExpire();
      expect(isAboutToExpire, isTrue);
    });

    test('保存和获取RefreshToken', () async {
      const testToken = 'test_token_123';
      const testRefreshToken = 'refresh_token_456';

      await tokenStorage.saveToken(
        token: testToken,
        refreshToken: testRefreshToken,
        expiresIn: 7 * 24 * 60 * 60,
      );

      final retrievedRefreshToken = await tokenStorage.getRefreshToken();
      expect(retrievedRefreshToken, equals(testRefreshToken));
    });

    test('没有Token时isLoggedIn应该返回false', () async {
      // 清除所有Token
      await tokenStorage.clearTokens();

      final isLoggedIn = await tokenStorage.isLoggedIn();
      expect(isLoggedIn, isFalse);
    });
  });
}
