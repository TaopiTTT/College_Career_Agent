import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/storage/token_storage.dart';
import '../../core/network/dio_client.dart';

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
    final isLoggedIn = await _tokenStorage.isLoggedIn();
    if (isLoggedIn) {
      try {
        final user = await _authDataSource.getCurrentUser();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } catch (e) {
        // Token可能已过期
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } else {
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

  /// 清除错误消息
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSource(ref.watch(dioClientProvider));
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) {
    return AuthNotifier(ref.watch(authDataSourceProvider));
  },
);
