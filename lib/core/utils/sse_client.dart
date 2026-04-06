import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/app_exception.dart';

/// SSE事件
class SSEEvent {
  final String? event;
  final String? data;

  SSEEvent({
    this.event,
    this.data,
  });

  factory SSEEvent.parse(String line) {
    if (line.startsWith('event:')) {
      return SSEEvent(
        event: line.substring(6).trim(),
      );
    } else if (line.startsWith('data:')) {
      return SSEEvent(
        data: line.substring(5).trim(),
      );
    }
    return SSEEvent();
  }

  Map<String, dynamic>? get jsonData {
    if (data != null) {
      try {
        return json.decode(data!);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

/// SSE客户端
class SSEClient {
  final String url;
  final Map<String, String> headers;
  final Duration timeout;

  http.Client? _client;
  StreamController<SSEEvent>? _controller;
  bool _isConnected = false;

  SSEClient({
    required this.url,
    this.headers = const {},
    this.timeout = const Duration(seconds: 300),
  });

  /// 连接并监听SSE流
  Stream<SSEEvent> connect() {
    _controller = StreamController<SSEEvent>(
      onCancel: _disconnect,
    );

    _client = http.Client();
    _connect();

    return _controller!.stream;
  }

  Future<void> _connect() async {
    if (_isConnected) return;

    try {
      final request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);
      request.headers['Accept'] = 'text/event-stream';
      request.headers['Cache-Control'] = 'no-cache';

      final http.StreamedResponse response = await _client!.send(request).timeout(timeout);

      if (response.statusCode != 200) {
        throw ServerException(
          message: 'SSE连接失败: ${response.statusCode}',
        );
      }

      _isConnected = true;
      _listenToStream(response);
    } catch (e) {
      _controller?.addError(e);
      _disconnect();
    }
  }

  Future<void> _listenToStream(http.StreamedResponse response) async {
    try {
      final streamStream = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in streamStream) {
        if (!_isConnected) break;

        if (line.trim().isEmpty) continue;

        final event = SSEEvent.parse(line);
        _controller?.add(event);

        // 检查是否是done事件
        if (event.event == 'done') {
          _disconnect();
          break;
        }
      }
    } catch (e) {
      _controller?.addError(e);
      _disconnect();
    }
  }

  Future<void> _disconnect() async {
    if (!_isConnected) return;

    _isConnected = false;
    _client?.close();
    await _controller?.close();
  }

  /// 手动断开连接
  Future<void> disconnect() async {
    await _disconnect();
  }

  bool get isConnected => _isConnected;
}

/// SSE流式请求辅助类
class SSEStreamHelper {
  /// 创建SSE连接(带Token)
  static Stream<SSEEvent> connectWithToken({
    required String baseUrl,
    required String endpoint,
    required String token,
    Map<String, String>? queryParams,
    Duration? timeout,
  }) {
    final queryString = queryParams != null && queryParams.isNotEmpty
        ? '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';

    return SSEClient(
      url: '$baseUrl$endpoint$queryString',
      headers: {
        'Authorization': 'Bearer $token',
      },
      timeout: timeout ?? const Duration(seconds: 300),
    ).connect();
  }

  /// 监听特定事件类型
  static Stream<Map<String, dynamic>> listenToEvent(
    Stream<SSEEvent> stream,
    String eventType,
  ) {
    return stream.where((event) => event.event == eventType).map((event) {
      final data = event.jsonData;
      if (data == null) {
        throw AppException(
          code: -1,
          message: 'Invalid SSE data format',
        );
      }
      return data;
    });
  }

  /// 处理步骤进度流
  static Stream<StepProgress> listenToStepProgress(Stream<SSEEvent> stream) {
    return stream
        .where((event) => event.event == 'step')
        .map((event) => StepProgress.fromJson(event.jsonData!));
  }

  /// 处理Token流
  static Stream<String> listenToTokens(Stream<SSEEvent> stream) {
    return stream
        .where((event) => event.event == 'token')
        .map((event) => event.jsonData?['content'] as String? ?? '');
  }
}

/// 步骤进度
class StepProgress {
  final String step;
  final String status;
  final String message;
  final int? score;
  final String? summary;

  StepProgress({
    required this.step,
    required this.status,
    required this.message,
    this.score,
    this.summary,
  });

  factory StepProgress.fromJson(Map<String, dynamic> json) {
    return StepProgress(
      step: json['step'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
      score: json['score'] as int?,
      summary: json['summary'] as String?,
    );
  }
}
