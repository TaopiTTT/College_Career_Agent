/// 应用异常类
class AppException implements Exception {
  final int code;
  final String message;
  final dynamic data;

  AppException({
    required this.code,
    required this.message,
    this.data,
  });

  @override
  String toString() {
    return 'AppException: [$code] $message';
  }

  /// 从DioException创建
  factory AppException.fromDioException(dynamic error) {
    if (error is AppException) {
      return error;
    }

    return AppException(
      code: -1,
      message: error.toString(),
    );
  }

  /// 常见错误码
  static const int unauthorized = 10002; // 未授权
  static const int forbidden = 10003; // 权限不足
  static const int notFound = 10004; // 资源不存在
  static const int validationError = 10001; // 参数校验失败
  static const int emailExists = 10101; // 邮箱已注册
  static const int passwordError = 10102; // 密码错误
  static const int codeExpired = 10103; // 验证码过期
  static const int profileNotReady = 10501; // 画像未就绪
}

/// 网络异常
class NetworkException extends AppException {
  NetworkException({String? message})
      : super(
          code: -1000,
          message: message ?? '网络连接失败,请检查网络设置',
        );
}

/// 超时异常
class TimeoutException extends AppException {
  TimeoutException()
      : super(
          code: -1001,
          message: '请求超时,请稍后重试',
        );
}

/// 服务器异常
class ServerException extends AppException {
  ServerException({String? message})
      : super(
          code: -1002,
          message: message ?? '服务器错误,请稍后重试',
        );
}
