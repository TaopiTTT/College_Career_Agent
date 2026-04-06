import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 模拟登录状态
class MockLoginState {
  final bool isLoading;
  final String? errorMessage;

  const MockLoginState({
    this.isLoading = false,
    this.errorMessage,
  });

  MockLoginState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return MockLoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// 模拟登录Notifier
class MockLoginNotifier extends StateNotifier<MockLoginState> {
  MockLoginNotifier() : super(const MockLoginState());

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 1));

    // 简单验证
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '邮箱和密码不能为空',
      );
      return false;
    }

    if (password.length < 6) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '密码至少6位',
      );
      return false;
    }

    // 模拟登录成功
    state = state.copyWith(isLoading: false);
    return true;
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// 模拟登录Provider
final mockLoginNotifierProvider =
    StateNotifierProvider<MockLoginNotifier, MockLoginState>((ref) {
  return MockLoginNotifier();
});
