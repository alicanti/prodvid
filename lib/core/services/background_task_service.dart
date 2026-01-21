import 'dart:async';
import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'notification_service.dart';

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
  final Map<String, String> _lastKnownStatus = {};

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
      final receivedApiKey = data['apiKey'] as String;
      final receivedApiSecret = data['apiSecret'] as String;
      
      debugPrint('📦 prepareGeneration response:');
      debugPrint('📦 tempTaskId: $tempTaskId');
      debugPrint('📦 apiKey length: ${receivedApiKey.length}');
      debugPrint('📦 apiSecret length: ${receivedApiSecret.length}');
      
      _credentials[tempTaskId] = _WiroCredentials(
        apiKey: receivedApiKey,
        apiSecret: receivedApiSecret,
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
      // Trim credentials to remove any whitespace/newlines
      final apiKey = creds.apiKey.trim();
      final apiSecret = creds.apiSecret.trim();
      
      debugPrint('🔑 API Key length: ${apiKey.length}, first 8 chars: ${apiKey.substring(0, 8)}');
      debugPrint('🔑 API Secret length: ${apiSecret.length}, first 8 chars: ${apiSecret.substring(0, 8)}');
      
      // Generate auth headers
      final nonce = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final signatureData = apiSecret + nonce;
      final signature = Hmac(sha256, utf8.encode(apiKey))
          .convert(utf8.encode(signatureData))
          .toString();
      
      debugPrint('🔑 Nonce: $nonce');
      debugPrint('🔑 Signature: $signature');

      // Build request based on model type
      final endpoint = _getEndpoint(modelType);
      final request = http.MultipartRequest('POST', Uri.parse(endpoint));
      
      request.headers.addAll({
        'x-api-key': apiKey,
        'x-nonce': nonce,
        'x-signature': signature,
      });

      // Add fields based on model type
      request.fields['effectType'] = effectType;
      request.fields['videoMode'] = videoMode;

      if (caption != null && caption.isNotEmpty) {
        request.fields['caption'] = caption;
      }

      // Add images based on model type
      if (productImage != null && logoImage != null) {
        // For product-ads-with-logo: both images as inputImage array
        request.files.add(http.MultipartFile.fromBytes(
          'inputImage',
          productImage,
          filename: 'product.jpg',
        ));
        request.files.add(http.MultipartFile.fromBytes(
          'inputImage',
          logoImage,
          filename: 'logo.png',
        ));
      } else if (productImage != null) {
        // For product-ads and product-ads-with-caption: single image
        request.files.add(http.MultipartFile.fromBytes(
          'inputImage',
          productImage,
          filename: 'product.jpg',
        ));
      }

      debugPrint('🚀 Starting Wiro generation: $endpoint');
      debugPrint('📋 Model: $modelType, Effect: $effectType, Mode: $videoMode');
      debugPrint('📋 Fields: ${request.fields}');
      debugPrint('📋 Files: ${request.files.map((f) => '${f.field}:${f.filename}:${f.length}bytes').toList()}');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Wiro response status: ${response.statusCode}');
      debugPrint('📥 Wiro response headers: ${response.headers}');
      debugPrint('📥 Wiro response body: ${response.body}');

      if (response.statusCode != 200) {
        debugPrint('❌ Wiro HTTP error: ${response.statusCode}');
        debugPrint('❌ Wiro error body: ${response.body}');
        // Refund credits on failure
        await _refundCredits(tempTaskId);
        return StartGenerationResult(
          success: false,
          error: 'Wiro API error: ${response.statusCode} - ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('📥 Wiro parsed response: $data');
      
      if (data['result'] != true) {
        debugPrint('❌ Wiro result false');
        debugPrint('❌ Wiro errors: ${data['errors']}');
        debugPrint('❌ Full Wiro response: $data');
        await _refundCredits(tempTaskId);
        return StartGenerationResult(
          success: false,
          error: (data['errors'] as List?)?.join(', ') ?? 'Unknown error',
        );
      }

      final wiroTaskId = data['taskid'] as String;
      final socketToken = data['socketaccesstoken'] as String;

      debugPrint('✅ Generation started: $wiroTaskId');

      // Update Firestore with real task ID
      await _updateTaskWithWiroId(tempTaskId, wiroTaskId, socketToken);

      // Start polling
      _startPolling(wiroTaskId, creds);

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
      // Trim credentials
      final apiKey = creds.apiKey.trim();
      final apiSecret = creds.apiSecret.trim();
      
      // Generate auth headers
      final nonce = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final signatureData = apiSecret + nonce;
      final signature = Hmac(sha256, utf8.encode(apiKey))
          .convert(utf8.encode(signatureData))
          .toString();

      final response = await http.post(
        Uri.parse('https://api.wiro.ai/v1/Task/Detail'),
        headers: {
          'x-api-key': apiKey,
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
        debugPrint('⚠️ Poll: no task found');
        return;
      }

      final task = taskList[0] as Map<String, dynamic>;
      final status = task['status'] as String?;
      final outputs = task['outputs'] as List?;

      // Only log if status changed
      final lastStatus = _lastKnownStatus[taskId];
      if (status != lastStatus) {
        debugPrint('📊 Task $taskId status: $status');
        _lastKnownStatus[taskId] = status ?? 'unknown';
      }

      // Determine Firestore status
      String firestoreStatus = 'processing';
      String? videoUrl;
      bool shouldUpdateFirestore = false;

      if (status == 'task_postprocess_end') {
        firestoreStatus = 'completed';
        if (outputs != null && outputs.isNotEmpty) {
          final output = outputs[0] as Map<String, dynamic>;
          videoUrl = output['url'] as String?;
          debugPrint('✅ Video completed! URL: $videoUrl');
          
          // Send local notification
          NotificationService().showVideoCompletedNotification(
            videoId: taskId,
            effectName: 'Your video',
          );
        }
        shouldUpdateFirestore = true;
        _stopPolling(taskId);
      } else if (status == 'task_cancel') {
        firestoreStatus = 'cancelled';
        debugPrint('🚫 Task cancelled');
        shouldUpdateFirestore = true;
        _stopPolling(taskId);
      }

      // Only update Firestore when status changes to completed or cancelled
      if (shouldUpdateFirestore) {
        await _updateTaskStatus(taskId, firestoreStatus, outputs, videoUrl);
      }

    } catch (e) {
      debugPrint('⚠️ Poll error: $e');
    }
  }

  /// Stop polling for a task
  void _stopPolling(String taskId) {
    _pollingTimers[taskId]?.cancel();
    _pollingTimers.remove(taskId);
    _credentials.remove(taskId);
    _lastKnownStatus.remove(taskId);
  }

  /// Cancel a task
  Future<void> cancelTask(String taskId) async {
    final creds = _credentials[taskId];
    if (creds == null) return;

    try {
      final apiKey = creds.apiKey.trim();
      final apiSecret = creds.apiSecret.trim();
      
      final nonce = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final signatureData = apiSecret + nonce;
      final signature = Hmac(sha256, utf8.encode(apiKey))
          .convert(utf8.encode(signatureData))
          .toString();

      await http.post(
        Uri.parse('https://api.wiro.ai/v1/Task/Cancel'),
        headers: {
          'x-api-key': apiKey,
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
    debugPrint('📝 Updating Firestore: taskId=$taskId, status=$status, videoUrl=$videoUrl');
    try {
      final callable = _functions.httpsCallable('updateTaskStatus2');
      await callable.call<Map<String, dynamic>>({
        'taskId': taskId,
        'status': status,
        if (outputs != null) 'outputs': outputs,
        if (videoUrl != null) 'videoUrl': videoUrl,
      });
      debugPrint('✅ Firestore updated successfully');
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

