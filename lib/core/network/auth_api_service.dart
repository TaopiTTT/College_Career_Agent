import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';
import '../storage/token_storage.dart';

/// 认证API服务 - 专门处理auth-api的请求
class AuthApiService {
  late final Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();

  AuthApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.authApiUrl,
      connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // 添加 CORS 相关的头部
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
      // 添加额外的验证选项，用于开发和测试
      validateStatus: (status) => status != null && status < 500,
    ));

    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 自动添加Token
        final token = await _tokenStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // 添加详细日志
        print('🌐 [API请求] ${options.method} ${options.uri}');
        if (options.data != null) {
          print('📤 [请求数据] ${options.data}');
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 添加详细日志
        print('✅ [API响应] ${response.statusCode} ${response.requestOptions.uri}');
        print('📥 [响应数据] ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        // 详细的错误日志
        print('❌ [API错误] ${error.requestOptions.method} ${error.requestOptions.uri}');
        print('❌ [错误类型] ${error.type}');
        print('❌ [错误消息] ${error.message}');
        if (error.response != null) {
          print('❌ [响应状态] ${error.response?.statusCode}');
          print('❌ [响应数据] ${error.response?.data}');
        } else if (error.type == DioExceptionType.connectionError) {
          print('❌ [连接错误] 无法连接到服务器');
          print('💡 [提示] 请检查：');
          print('   1. 服务器是否运行在 ${AppConfig.authApiUrl}');
          print('   2. 网络连接是否正常');
          print('   3. 如果是Web环境，可能存在CORS问题');
        }

        // 处理401错误
        if (error.response?.statusCode == 401) {
          await _tokenStorage.clearTokens();
        }

        return handler.next(error);
      },
    ));

    // 添加日志拦截器
    if (AppConfig.enableLogging) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  /// POST请求
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return _handleResponse<T>(response);
    } on DioException {
      rethrow;
    }
  }

  /// GET请求
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return _handleResponse<T>(response);
    } on DioException {
      rethrow;
    }
  }

  /// 处理响应
  T _handleResponse<T>(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final code = data['code'] as int?;
        final msg = data['msg'] as String?;
        final responseData = data['data'];

        if (code == 0) {
          return responseData as T;
        } else {
          // 提供更详细的错误信息
          final errorMessage = _getErrorMessage(code, msg);
          throw Exception(errorMessage);
        }
      }

      return data as T;
    }

    // 处理其他HTTP状态码
    final errorMessage = _getHttpErrorMessage(response.statusCode, response.statusMessage);
    throw Exception(errorMessage);
  }

  /// 获取友好的错误消息
  String _getErrorMessage(int? code, String? msg) {
    if (msg != null && msg.isNotEmpty) {
      return msg;
    }

    // 根据错误码返回友好消息
    switch (code) {
      case 100001:
        return '参数校验失败，请检查输入';
      case 100002:
        return '登录已过期，请重新登录';
      case 100003:
        return '权限不足';
      case 100004:
        return '资源不存在';
      case 100101:
        return '邮箱已注册，请直接登录';
      case 100102:
        return '验证码错误或已过期';
      default:
        return '请求失败: [$code] ${msg ?? "未知错误"}';
    }
  }

  /// 获取HTTP错误消息
  String _getHttpErrorMessage(int? statusCode, String? statusMessage) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请登录';
      case 403:
        return '拒绝访问';
      case 404:
        return '请求的资源不存在';
      case 409:
        return '数据冲突，邮箱已注册';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务暂时不可用';
      default:
        return 'HTTP $statusCode: ${statusMessage ?? "未知错误"}';
    }
  }
}
