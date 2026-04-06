import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';

/// 模拟认证状态 - 用于无后端时的界面展示
class MockAuthState {
  final bool isAuthenticated;
  final UserModel? mockUser;

  const MockAuthState({
    this.isAuthenticated = true,
    this.mockUser,
  });

  MockAuthState copyWith({
    bool? isAuthenticated,
    UserModel? mockUser,
  }) {
    return MockAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      mockUser: mockUser ?? this.mockUser,
    );
  }
}

/// 模拟用户数据
final mockUserProvider = Provider<UserModel>((ref) {
  return UserModel(
    userId: 100001,
    email: 'demo@example.com',
    nickname: '演示用户',
    avatarUrl: null,
    role: 'student',
    createdAt: DateTime.now(),
  );
});

/// 模拟认证状态Provider
final mockAuthStateProvider = Provider<MockAuthState>((ref) {
  final user = ref.watch(mockUserProvider);
  return MockAuthState(
    isAuthenticated: true,
    mockUser: user,
  );
});
