import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Wiro API Response for run task
class WiroRunResponse {
  WiroRunResponse({
    required this.taskId,
    required this.socketToken,
    required this.result,
    this.errors = const [],
  });

  factory WiroRunResponse.fromJson(Map<String, dynamic> json) {
    return WiroRunResponse(
      taskId: json['taskid'] as String? ?? '',
      socketToken: json['socketaccesstoken'] as String? ?? '',
      result: json['result'] as bool? ?? false,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  final String taskId;
  final String socketToken;
  final bool result;
  final List<String> errors;

  bool get hasError => !result || errors.isNotEmpty;
  String get errorMessage => errors.join(', ');
}

/// Wiro Task Output
class WiroTaskOutput {
  WiroTaskOutput({
    required this.id,
    required this.name,
    required this.url,
    required this.contentType,
  });

  factory WiroTaskOutput.fromJson(Map<String, dynamic> json) {
    return WiroTaskOutput(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      contentType: json['contenttype'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final String url;
  final String contentType;

  bool get isVideo =>
      contentType.contains('video') || name.endsWith('.mp4') || name.endsWith('.webm');
}

/// Wiro Task Detail
class WiroTaskDetailResult {
  WiroTaskDetailResult({
    required this.id,
    required this.status,
    required this.outputs,
    this.debugError,
  });

  factory WiroTaskDetailResult.fromJson(Map<String, dynamic> json) {
    final outputsList = json['outputs'] as List<dynamic>? ?? [];
    return WiroTaskDetailResult(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      outputs: outputsList.map((e) => WiroTaskOutput.fromJson(e as Map<String, dynamic>)).toList(),
      debugError: json['debugerror'] as String?,
    );
  }

  final String id;
  final String status;
  final List<WiroTaskOutput> outputs;
  final String? debugError;

  bool get isCompleted => status == 'task_postprocess_end' || status == 'task_cancel';
  bool get isSuccess => status == 'task_postprocess_end';
  bool get isCancelled => status == 'task_cancel';

  String? get videoUrl {
    final videoOutput = outputs.where((o) => o.isVideo).firstOrNull;
    return videoOutput?.url;
  }

  String get displayStatus {
    switch (status) {
      case 'task_queue':
        return 'Waiting in queue...';
      case 'task_accept':
        return 'Task accepted';
      case 'task_assign':
        return 'Assigning worker...';
      case 'task_preprocess_start':
        return 'Preprocessing...';
      case 'task_preprocess_end':
        return 'Preprocessing complete';
      case 'task_start':
        return 'Generating video...';
      case 'task_output':
        return 'Creating output...';
      case 'task_postprocess_end':
        return 'Completed!';
      case 'task_cancel':
        return 'Cancelled';
      default:
        return 'Processing...';
    }
  }

  double get progress {
    switch (status) {
      case 'task_queue':
        return 0.1;
      case 'task_accept':
        return 0.2;
      case 'task_assign':
        return 0.3;
      case 'task_preprocess_start':
        return 0.4;
      case 'task_preprocess_end':
        return 0.5;
      case 'task_start':
        return 0.7;
      case 'task_output':
        return 0.9;
      case 'task_postprocess_end':
        return 1;
      case 'task_cancel':
        return 0;
      default:
        return 0.3;
    }
  }
}

/// Wiro API Client - Direct communication with Wiro API
class WiroApiClient {
  WiroApiClient({
    required this.apiKey,
    required this.apiSecret,
  });

  final String apiKey;
  final String apiSecret;

  static const String _baseUrl = 'https://api.wiro.ai/v1';

  /// Generate authentication headers
  Map<String, String> _generateHeaders() {
    final nonce = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final signatureData = '$apiSecret$nonce';
    final hmac = Hmac(sha256, utf8.encode(apiKey));
    final digest = hmac.convert(utf8.encode(signatureData));
    final signature = digest.toString();

    // Debug logging
    debugPrint('=== WIRO AUTH DEBUG ===');
    debugPrint('API Key: $apiKey');
    debugPrint('API Secret: ${apiSecret.substring(0, 5)}...');
    debugPrint('Nonce: $nonce');
    debugPrint('SignatureData: ${signatureData.substring(0, 10)}...$nonce');
    debugPrint('Signature: $signature');
    debugPrint('=======================');

    return {
      'x-api-key': apiKey,
      'x-nonce': nonce,
      'x-signature': signature,
    };
  }

  /// Run 3D Text Animations
  Future<WiroRunResponse> runTextAnimations({
    required String caption,
    required String effectType,
    String videoMode = 'std',
  }) async {
    final uri = Uri.parse('$_baseUrl/Run/wiro/3d-text-animations');

    final request = http.MultipartRequest('POST', uri)..headers.addAll(_generateHeaders());

    request.fields['caption'] = caption;
    request.fields['effectType'] = effectType;
    request.fields['videoMode'] = videoMode;

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Wiro API error: ${response.statusCode} - $responseBody');
    }

    return WiroRunResponse.fromJson(json.decode(responseBody) as Map<String, dynamic>);
  }

  /// Run Product Ads
  Future<WiroRunResponse> runProductAds({
    required Uint8List imageBytes,
    required String effectType,
    String videoMode = 'std',
  }) async {
    final uri = Uri.parse('$_baseUrl/Run/wiro/product-ads');

    final headers = _generateHeaders();
    final request = http.MultipartRequest('POST', uri)..headers.addAll(headers);

    request.files.add(http.MultipartFile.fromBytes(
      'inputImage',
      imageBytes,
      filename: 'product.jpg',
      contentType: MediaType('image', 'jpeg'),
    ));
    request.fields['effectType'] = effectType;
    request.fields['videoMode'] = videoMode;

    debugPrint('=== REQUEST DEBUG ===');
    debugPrint('URL: $uri');
    debugPrint('Headers: $headers');
    debugPrint('Fields: ${request.fields}');
    debugPrint('Files: ${request.files.map((f) => '${f.field}: ${f.filename} (${f.length} bytes)').toList()}');
    debugPrint('====================');

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response: $responseBody');

    if (response.statusCode != 200) {
      throw Exception('Wiro API error: ${response.statusCode} - $responseBody');
    }

    return WiroRunResponse.fromJson(json.decode(responseBody) as Map<String, dynamic>);
  }

  /// Run Product Ads with Caption
  Future<WiroRunResponse> runProductAdsWithCaption({
    required Uint8List imageBytes,
    required String caption,
    required String effectType,
    String videoMode = 'std',
  }) async {
    final uri = Uri.parse('$_baseUrl/Run/wiro/product-ads-with-caption');

    final request = http.MultipartRequest('POST', uri)..headers.addAll(_generateHeaders());

    request.files.add(http.MultipartFile.fromBytes(
      'inputImage',
      imageBytes,
      filename: 'product.jpg',
      contentType: MediaType('image', 'jpeg'),
    ));
    request.fields['caption'] = caption;
    request.fields['effectType'] = effectType;
    request.fields['videoMode'] = videoMode;

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Wiro API error: ${response.statusCode} - $responseBody');
    }

    return WiroRunResponse.fromJson(json.decode(responseBody) as Map<String, dynamic>);
  }

  /// Run Product Ads with Logo
  Future<WiroRunResponse> runProductAdsWithLogo({
    required Uint8List productImageBytes,
    required Uint8List logoImageBytes,
    required String effectType,
    String videoMode = 'std',
  }) async {
    final uri = Uri.parse('$_baseUrl/Run/wiro/product-ads-with-logo');

    final request = http.MultipartRequest('POST', uri)..headers.addAll(_generateHeaders());

    // Both images go in the same field name (Wiro expects array)
    request.files.add(http.MultipartFile.fromBytes(
      'inputImage',
      productImageBytes,
      filename: 'product.jpg',
      contentType: MediaType('image', 'jpeg'),
    ));
    request.files.add(http.MultipartFile.fromBytes(
      'inputImage',
      logoImageBytes,
      filename: 'logo.png',
      contentType: MediaType('image', 'png'),
    ));
    request.fields['effectType'] = effectType;
    request.fields['videoMode'] = videoMode;

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Wiro API error: ${response.statusCode} - $responseBody');
    }

    return WiroRunResponse.fromJson(json.decode(responseBody) as Map<String, dynamic>);
  }

  /// Get task detail by ID
  Future<WiroTaskDetailResult?> getTaskDetail(String taskId) async {
    final uri = Uri.parse('$_baseUrl/Task/Detail');

    final response = await http.post(
      uri,
      headers: {
        ..._generateHeaders(),
        'Content-Type': 'application/json',
      },
      body: json.encode({'taskid': taskId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Wiro API error: ${response.statusCode} - ${response.body}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final taskList = data['tasklist'] as List<dynamic>?;

    if (taskList == null || taskList.isEmpty) {
      return null;
    }

    return WiroTaskDetailResult.fromJson(taskList.first as Map<String, dynamic>);
  }

  /// Poll task status with stream
  Stream<WiroTaskDetailResult> pollTaskStatus(String taskId, {Duration interval = const Duration(seconds: 2)}) async* {
    while (true) {
      final result = await getTaskDetail(taskId);
      if (result != null) {
        yield result;
        if (result.isCompleted) {
          break;
        }
      }
      await Future<void>.delayed(interval);
    }
  }

  /// Cancel a queued task
  Future<void> cancelTask(String taskId) async {
    final uri = Uri.parse('$_baseUrl/Task/Cancel');

    final response = await http.post(
      uri,
      headers: {
        ..._generateHeaders(),
        'Content-Type': 'application/json',
      },
      body: json.encode({'taskid': taskId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Wiro API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Kill a running task
  Future<void> killTask(String taskId) async {
    final uri = Uri.parse('$_baseUrl/Task/Kill');

    final response = await http.post(
      uri,
      headers: {
        ..._generateHeaders(),
        'Content-Type': 'application/json',
      },
      body: json.encode({'taskid': taskId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Wiro API error: ${response.statusCode} - ${response.body}');
    }
  }
}

