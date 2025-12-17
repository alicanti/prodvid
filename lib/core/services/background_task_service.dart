import 'dart:async';
import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Background task service provider
final backgroundTaskServiceProvider = Provider<BackgroundTaskService>((ref) {
  return BackgroundTaskService();
});

/// Active tasks provider - tracks currently polling tasks
final activeTasksProvider = StateProvider<Map<String, TaskPollingState>>((ref) {
  return {};
});

/// Task polling state
class TaskPollingState {
  TaskPollingState({
    required this.taskId,
    required this.status,
    this.progress = 0,
    this.error,
  });

  final String taskId;
  final String status;
  final double progress;
  final String? error;

  TaskPollingState copyWith({
    String? status,
    double? progress,
    String? error,
  }) {
    return TaskPollingState(
      taskId: taskId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }
}

/// Service for handling background video generation tasks
class BackgroundTaskService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  final Map<String, Timer> _pollingTimers = {};
  final Map<String, _WiroCredentials> _credentials = {};

  /// Prepare generation - deduct credits and get API credentials
  Future<PrepareGenerationResult> prepareGeneration({
    required String modelType,
    required String effectType,
    required String videoMode,
  }) async {
    try {
      final callable = _functions.httpsCallable('prepareGeneration');
      final result = await callable.call<Map<String, dynamic>>({
        'modelType': modelType,
        'effectType': effectType,
        'videoMode': videoMode,
      });

      final data = result.data;
      
      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Failed to prepare generation');
      }

      // Store credentials for this task
      final tempTaskId = data['tempTaskId'] as String;
      _credentials[tempTaskId] = _WiroCredentials(
        apiKey: data['apiKey'] as String,
        apiSecret: data['apiSecret'] as String,
      );

      return PrepareGenerationResult(
        success: true,
        tempTaskId: tempTaskId,
        creditCost: (data['creditCost'] as num).toInt(),
        creditsRemaining: (data['creditsRemaining'] as num).toInt(),
      );
    } on FirebaseFunctionsException catch (e) {
      return PrepareGenerationResult(
        success: false,
        error: e.message ?? 'Failed to prepare generation',
      );
    }
  }

  /// Start generation by calling Wiro API directly
  Future<StartGenerationResult> startGeneration({
    required String tempTaskId,
    required String modelType,
    required String effectType,
    required String videoMode,
    Uint8List? productImage,
    Uint8List? logoImage,
    String? caption,
  }) async {
    final creds = _credentials[tempTaskId];
    if (creds == null) {
      return StartGenerationResult(
        success: false,
        error: 'No credentials found for task',
      );
    }

    try {
      // Generate auth headers
      final nonce = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final signatureData = creds.apiSecret + nonce;
      final signature = Hmac(sha256, utf8.encode(creds.apiKey))
          .convert(utf8.encode(signatureData))
          .toString();

      // Build request based on model type
      final endpoint = _getEndpoint(modelType);
      final request = http.MultipartRequest('POST', Uri.parse(endpoint));
      
      request.headers.addAll({
        'x-api-key': creds.apiKey,
        'x-nonce': nonce,
        'x-signature': signature,
      });

      // Add fields based on model type
      request.fields['effectType'] = effectType;
      request.fields['videoMode'] = videoMode;

      if (caption != null) {
        request.fields['caption'] = caption;
      }

      if (productImage != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'inputImage',
          productImage,
          filename: 'product.jpg',
        ));
      }

      if (logoImage != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'inputImage',
          logoImage,
          filename: 'logo.png',
        ));
      }

      debugPrint('🚀 Starting Wiro generation: $endpoint');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Wiro response: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('❌ Wiro error: ${response.body}');
        // Refund credits on failure
        await _refundCredits(tempTaskId);
        return StartGenerationResult(
          success: false,
          error: 'Wiro API error: ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (data['result'] != true) {
        await _refundCredits(tempTaskId);
        return StartGenerationResult(
          success: false,
          error: (data['errors'] as List?)?.join(', ') ?? 'Unknown error',
        );
      }

      final wiroTaskId = data['taskid'] as String;
      final socketToken = data['socketaccesstoken'] as String;

      // Update Firestore with real task ID
      await _updateTaskWithWiroId(tempTaskId, wiroTaskId, socketToken);

      // Start polling
      _startPolling(wiroTaskId, creds);

      debugPrint('✅ Generation started: $wiroTaskId');

      return StartGenerationResult(
        success: true,
        taskId: wiroTaskId,
        socketToken: socketToken,
      );
    } catch (e) {
      debugPrint('❌ Generation error: $e');
      await _refundCredits(tempTaskId);
      return StartGenerationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Start polling for a task
  void _startPolling(String taskId, _WiroCredentials creds) {
    // Cancel existing timer if any
    _pollingTimers[taskId]?.cancel();

    // Store credentials for polling
    _credentials[taskId] = creds;

    // Start polling every 3 seconds
    _pollingTimers[taskId] = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _pollTask(taskId),
    );

    // Do initial poll immediately
    _pollTask(taskId);
  }

  /// Poll task status
  Future<void> _pollTask(String taskId) async {
    final creds = _credentials[taskId];
    if (creds == null) {
      _pollingTimers[taskId]?.cancel();
      return;
    }

    try {
      // Generate auth headers
      final nonce = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final signatureData = creds.apiSecret + nonce;
      final signature = Hmac(sha256, utf8.encode(creds.apiKey))
          .convert(utf8.encode(signatureData))
          .toString();

      final response = await http.post(
        Uri.parse('https://api.wiro.ai/v1/Task/Detail'),
        headers: {
          'x-api-key': creds.apiKey,
          'x-nonce': nonce,
          'x-signature': signature,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'taskid': taskId}),
      );

      if (response.statusCode != 200) {
        debugPrint('⚠️ Poll error: ${response.statusCode}');
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final taskList = data['tasklist'] as List?;
      
      if (taskList == null || taskList.isEmpty) {
        return;
      }

      final task = taskList[0] as Map<String, dynamic>;
      final status = task['status'] as String?;
      final outputs = task['outputs'] as List?;

      debugPrint('📊 Task status: $status');

      // Update Firestore
      String firestoreStatus = 'processing';
      String? videoUrl;

      if (status == 'task_postprocess_end') {
        firestoreStatus = 'completed';
        if (outputs != null && outputs.isNotEmpty) {
          videoUrl = (outputs[0] as Map<String, dynamic>)['url'] as String?;
        }
        _stopPolling(taskId);
      } else if (status == 'task_cancel') {
        firestoreStatus = 'cancelled';
        _stopPolling(taskId);
      }

      await _updateTaskStatus(taskId, firestoreStatus, outputs, videoUrl);

    } catch (e) {
      debugPrint('⚠️ Poll error: $e');
    }
  }

  /// Stop polling for a task
  void _stopPolling(String taskId) {
    _pollingTimers[taskId]?.cancel();
    _pollingTimers.remove(taskId);
    _credentials.remove(taskId);
  }

  /// Cancel a task
  Future<void> cancelTask(String taskId) async {
    final creds = _credentials[taskId];
    if (creds == null) return;

    try {
      final nonce = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final signatureData = creds.apiSecret + nonce;
      final signature = Hmac(sha256, utf8.encode(creds.apiKey))
          .convert(utf8.encode(signatureData))
          .toString();

      await http.post(
        Uri.parse('https://api.wiro.ai/v1/Task/Cancel'),
        headers: {
          'x-api-key': creds.apiKey,
          'x-nonce': nonce,
          'x-signature': signature,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'taskid': taskId}),
      );

      await _updateTaskStatus(taskId, 'cancelled', null, null);
      await _refundCredits(taskId);
      _stopPolling(taskId);
    } catch (e) {
      debugPrint('⚠️ Cancel error: $e');
    }
  }

  /// Update task with real Wiro ID
  Future<void> _updateTaskWithWiroId(
    String tempTaskId,
    String wiroTaskId,
    String socketToken,
  ) async {
    try {
      final callable = _functions.httpsCallable('updateTaskWithWiroId');
      await callable.call<Map<String, dynamic>>({
        'tempTaskId': tempTaskId,
        'wiroTaskId': wiroTaskId,
        'socketToken': socketToken,
      });
    } catch (e) {
      debugPrint('⚠️ Update task ID error: $e');
    }
  }

  /// Update task status in Firestore
  Future<void> _updateTaskStatus(
    String taskId,
    String status,
    List<dynamic>? outputs,
    String? videoUrl,
  ) async {
    try {
      final callable = _functions.httpsCallable('updateTaskStatus2');
      await callable.call<Map<String, dynamic>>({
        'taskId': taskId,
        'status': status,
        if (outputs != null) 'outputs': outputs,
        if (videoUrl != null) 'videoUrl': videoUrl,
      });
    } catch (e) {
      debugPrint('⚠️ Update status error: $e');
    }
  }

  /// Refund credits for a failed task
  Future<void> _refundCredits(String taskId) async {
    try {
      final callable = _functions.httpsCallable('refundTaskCredits');
      await callable.call<Map<String, dynamic>>({'taskId': taskId});
    } catch (e) {
      debugPrint('⚠️ Refund error: $e');
    }
  }

  /// Get Wiro API endpoint for model type
  String _getEndpoint(String modelType) {
    switch (modelType) {
      case 'wiro/3d-text-animations':
        return 'https://api.wiro.ai/v1/Run/wiro/3d-text-animations';
      case 'wiro/product-ads':
        return 'https://api.wiro.ai/v1/Run/wiro/product-ads';
      case 'wiro/product-ads-with-caption':
        return 'https://api.wiro.ai/v1/Run/wiro/product-ads-with-caption';
      case 'wiro/product-ads-with-logo':
        return 'https://api.wiro.ai/v1/Run/wiro/product-ads-with-logo';
      default:
        throw ArgumentError('Unknown model type: $modelType');
    }
  }

  /// Dispose all timers
  void dispose() {
    for (final timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();
    _credentials.clear();
  }
}

/// Wiro API credentials
class _WiroCredentials {
  _WiroCredentials({required this.apiKey, required this.apiSecret});
  final String apiKey;
  final String apiSecret;
}

/// Result of prepareGeneration
class PrepareGenerationResult {
  PrepareGenerationResult({
    required this.success,
    this.tempTaskId,
    this.creditCost,
    this.creditsRemaining,
    this.error,
  });

  final bool success;
  final String? tempTaskId;
  final int? creditCost;
  final int? creditsRemaining;
  final String? error;
}

/// Result of startGeneration
class StartGenerationResult {
  StartGenerationResult({
    required this.success,
    this.taskId,
    this.socketToken,
    this.error,
  });

  final bool success;
  final String? taskId;
  final String? socketToken;
  final String? error;
}

