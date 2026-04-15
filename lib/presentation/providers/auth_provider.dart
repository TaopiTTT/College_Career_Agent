import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/storage/token_storage.dart';
import '../../core/network/auth_api_service.dart';

/// 认证状态
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

/// 认证状态类
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

/// 认证状态Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthDataSource _authDataSource;
  final TokenStorage _tokenStorage = TokenStorage();

  AuthNotifier(this._authDataSource) : super(const AuthState()) {
    _init();
  }

  /// 初始化 - 检查登录状态
  Future<void> _init() async {
    debugPrint('🔄 AuthNotifier: 开始初始化...');
    state = state.copyWith(status: AuthStatus.loading);

    final isLoggedIn = await _tokenStorage.isLoggedIn();

    if (!isLoggedIn) {
      debugPrint('❌ AuthNotifier: 用户未登录');
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      debugPrint('✅ AuthNotifier: Token有效，获取用户信息...');
      // Token存在且未过期，尝试验证并获取用户信息
      final user = await _authDataSource.getCurrentUser();
      debugPrint('✅ AuthNotifier: 用户信息获取成功 - ${user.nickname}');
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      // Token验证失败（可能被服务器撤销等），清除本地数据
      debugPrint('❌ AuthNotifier: 获取用户信息失败 - $e');
      await _tokenStorage.clearTokens();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// 登录
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authDataSource.login(request);

      // 获取用户信息
      final user = await _authDataSource.getCurrentUser();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 注册
  Future<bool> register({
    required String email,
    required String nickname,
    required String password,
    required String verifyCode,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final request = RegisterRequest(
        email: email,
        nickname: nickname,
        password: password,
        verifyCode: verifyCode,
      );

      final response = await _authDataSource.register(request);

      // 获取用户信息
      final user = await _authDataSource.getCurrentUser();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 发送验证码
  Future<bool> sendCode({
    required String email,
    required String purpose,
  }) async {
    try {
      final request = SendCodeRequest(email: email, purpose: purpose);
      await _authDataSource.sendCode(request);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// 登出
  Future<void> logout() async {
    await _authDataSource.logout();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }

  /// 尝试自动刷新Token
  Future<bool> tryRefreshToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      await _authDataSource.refreshToken(refreshToken);

      // 获取用户信息
      final user = await _authDataSource.getCurrentUser();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );

      return true;
    } catch (e) {
      // 刷新失败，清除所有Token
      await _tokenStorage.clearTokens();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      );
      return false;
    }
  }

  /// 清除错误消息
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider
final authApiServiceProvider = Provider<AuthApiService>((ref) => AuthApiService());

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSource(ref.watch(authApiServiceProvider));
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) {
    return AuthNotifier(ref.watch(authDataSourceProvider));
  },
);
