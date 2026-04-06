import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/token_storage.dart';

/// 认证数据源
class AuthDataSource {
  final DioClient _dioClient;
  final TokenStorage _tokenStorage = TokenStorage();

  AuthDataSource(this._dioClient);

  /// 登录
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response);

      // 保存Token
      await _tokenStorage.saveToken(
        token: authResponse.token,
        expiresIn: 7 * 24 * 60 * 60, // 7天
      );

      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 注册
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/auth/register',
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response);

      // 保存Token
      await _tokenStorage.saveToken(
        token: authResponse.token,
        expiresIn: 7 * 24 * 60 * 60,
      );

      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 发送验证码
  Future<void> sendCode(SendCodeRequest request) async {
    try {
      await _dioClient.post<void>(
        '/auth/send-code',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取当前用户信息
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>('/user/me');
      return UserModel.fromJson(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      await _tokenStorage.clearTokens();
    } catch (e) {
      // 即使失败也继续
    }
  }

  dynamic _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        final code = data['code'] as int?;
        final msg = data['msg'] as String?;
        throw Exception('[$code] $msg');
      }
    }
    throw Exception(error.message ?? '网络请求失败');
  }
}
