import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../core/network/auth_api_service.dart';
import '../../core/storage/token_storage.dart';

/// 认证数据源
class AuthDataSource {
  final AuthApiService _authApiService;
  final TokenStorage _tokenStorage = TokenStorage();

  AuthDataSource(this._authApiService);

  /// 登录
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _authApiService.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response);

      // 保存Token，优先使用服务器返回的过期时间，否则默认7天
      await _tokenStorage.saveToken(
        token: authResponse.token,
        refreshToken: authResponse.refreshToken,
        expiresIn: authResponse.expiresIn ?? (7 * 24 * 60 * 60), // 默认7天
      );

      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 注册
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _authApiService.post<Map<String, dynamic>>(
        '/auth/register',
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response);

      // 保存Token，优先使用服务器返回的过期时间，否则默认7天
      await _tokenStorage.saveToken(
        token: authResponse.token,
        refreshToken: authResponse.refreshToken,
        expiresIn: authResponse.expiresIn ?? (7 * 24 * 60 * 60), // 默认7天
      );

      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 发送验证码
  Future<void> sendCode(SendCodeRequest request) async {
    try {
      await _authApiService.post<void>(
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
      final response = await _authApiService.get<Map<String, dynamic>>('/user/me');
      return UserModel.fromJson(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 刷新Token
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _authApiService.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final authResponse = AuthResponse.fromJson(response);

      // 保存新Token
      await _tokenStorage.saveToken(
        token: authResponse.token,
        refreshToken: authResponse.refreshToken ?? refreshToken,
        expiresIn: authResponse.expiresIn ?? (7 * 24 * 60 * 60), // 默认7天
      );

      return authResponse;
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
    // 处理网络连接错误
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      throw Exception('网络连接失败，请检查网络设置或稍后重试');
    }

    // 处理接收超时
    if (error.type == DioExceptionType.receiveTimeout) {
      throw Exception('请求超时，请稍后重试');
    }

    // 处理发送超时
    if (error.type == DioExceptionType.sendTimeout) {
      throw Exception('请求发送超时，请稍后重试');
    }

    // 处理响应错误
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        final msg = data['msg'] as String?;

        // 如果有明确的错误消息，优先使用
        if (msg != null && msg.isNotEmpty) {
          throw Exception(msg);
        }

        // 根据HTTP状态码提供友好消息
        final statusCode = error.response!.statusCode;
        switch (statusCode) {
          case 400:
            throw Exception('请求参数错误，请检查输入');
          case 401:
            throw Exception('未授权，请重新登录');
          case 403:
            throw Exception('权限不足');
          case 404:
            throw Exception('请求的资源不存在');
          case 409:
            throw Exception('邮箱已注册，请直接登录');
          case 500:
            throw Exception('服务器内部错误，请稍后重试');
          case 502:
          case 503:
            throw Exception('服务暂时不可用，请稍后重试');
          default:
            throw Exception('请求失败: HTTP $statusCode');
        }
      }
    }

    // 默认错误消息
    throw Exception(error.message ?? '网络请求失败，请稍后重试');
  }
}
