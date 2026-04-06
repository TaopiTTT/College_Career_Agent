/// 应用配置
class AppConfig {
  /// API基础URL
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com/api/v1',
  );

  /// 连接超时时间(毫秒)
  static const int connectTimeout = 30000;

  /// 接收超时时间(毫秒)
  static const int receiveTimeout = 30000;

  /// JWT Token过期时间(秒) - 与后端保持一致
  static const int tokenExpirationSeconds = 7 * 24 * 60 * 60; // 7天

  /// Token刷新提前量(秒) - 在过期前多久刷新
  static const int tokenRefreshThresholdSeconds = 24 * 60 * 60; // 1天

  /// 分页默认大小
  static const int defaultPageSize = 20;

  /// 分页最大大小
  static const int maxPageSize = 100;

  /// 图片上传最大大小(MB)
  static const int maxImageSizeMB = 10;

  /// 简历上传最大大小(MB)
  static const int maxResumeSizeMB = 10;

  /// 环境配置
  static const AppEnvironment environment = AppEnvironment.development;

  /// 是否启用日志
  static const bool enableLogging = true;

  /// SSE连接超时(秒)
  static const int sseTimeoutSeconds = 300;
}

enum AppEnvironment {
  development,
  staging,
  production,
}

extension AppEnvironmentExtension on AppEnvironment {
  String get name {
    switch (this) {
      case AppEnvironment.development:
        return 'Development';
      case AppEnvironment.staging:
        return 'Staging';
      case AppEnvironment.production:
        return 'Production';
    }
  }
}
