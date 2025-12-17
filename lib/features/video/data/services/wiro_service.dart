import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';

/// Wiro service provider
final wiroServiceProvider = Provider<WiroService>((ref) {
  return WiroService();
});

/// Service for interacting with Wiro API through Cloud Functions
///
/// All API calls are made through Firebase Cloud Functions to keep
/// API keys secure on the server side.
class WiroService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Cloud Function references
  HttpsCallable get _runTaskFunction => _functions.httpsCallable(
        'runWiroTask',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 120)),
      );
  HttpsCallable get _getTaskDetailFunction =>
      _functions.httpsCallable('getWiroTaskDetail');
  HttpsCallable get _killTaskFunction =>
      _functions.httpsCallable('killWiroTask');
  HttpsCallable get _cancelTaskFunction =>
      _functions.httpsCallable('cancelWiroTask');
  HttpsCallable get _getUserCreditsFunction =>
      _functions.httpsCallable('getUserCredits');

  /// Convert File to base64 string
  Future<String> _fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  /// Get user's current credit balance
  Future<int> getUserCredits() async {
    try {
      final result = await _getUserCreditsFunction.call<Map<String, dynamic>>();
      return (result.data['credits'] as num?)?.toInt() ?? 0;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Failed to get credits');
    }
  }

  /// Start a 3D Text Animation task
  Future<WiroRunTaskResponse> runTextAnimation({
    required String caption,
    required String effectType,
    WiroVideoMode videoMode = WiroVideoMode.standard,
  }) async {
    return _runTask(
      modelType: 'wiro/3d-text-animations',
      effectType: effectType,
      videoMode: videoMode,
      caption: caption,
    );
  }

  /// Start a Product Ads task (image only)
  Future<WiroRunTaskResponse> runProductAds({
    required File inputImage,
    required String effectType,
    WiroVideoMode videoMode = WiroVideoMode.standard,
  }) async {
    final imageBase64 = await _fileToBase64(inputImage);
    
    return _runTask(
      modelType: 'wiro/product-ads',
      effectType: effectType,
      videoMode: videoMode,
      inputImage: imageBase64,
    );
  }

  /// Start a Product Ads with Caption task
  Future<WiroRunTaskResponse> runProductAdsWithCaption({
    required File inputImage,
    required String caption,
    required String effectType,
    WiroVideoMode videoMode = WiroVideoMode.standard,
  }) async {
    final imageBase64 = await _fileToBase64(inputImage);
    
    return _runTask(
      modelType: 'wiro/product-ads-with-caption',
      effectType: effectType,
      videoMode: videoMode,
      inputImage: imageBase64,
      caption: caption,
    );
  }

  /// Start a Product Ads with Logo task
  Future<WiroRunTaskResponse> runProductAdsWithLogo({
    required File productImage,
    required File logoImage,
    required String effectType,
    WiroVideoMode videoMode = WiroVideoMode.standard,
  }) async {
    final productBase64 = await _fileToBase64(productImage);
    final logoBase64 = await _fileToBase64(logoImage);
    
    return _runTask(
      modelType: 'wiro/product-ads-with-logo',
      effectType: effectType,
      videoMode: videoMode,
      inputImage: productBase64,
      logoImage: logoBase64,
    );
  }

  /// Generic method to run any Wiro task
  Future<WiroRunTaskResponse> _runTask({
    required String modelType,
    required String effectType,
    required WiroVideoMode videoMode,
    String? inputImage,
    String? logoImage,
    String? caption,
  }) async {
    try {
      final result = await _runTaskFunction.call<Map<String, dynamic>>({
        'modelType': modelType,
        'effectType': effectType,
        'videoMode': videoMode == WiroVideoMode.pro ? 'pro' : 'std',
        if (inputImage != null) 'inputImage': inputImage,
        if (logoImage != null) 'logoImage': logoImage,
        if (caption != null) 'caption': caption,
      });

      final data = result.data;
      
      return WiroRunTaskResponse(
        taskId: data['taskId'] as String? ?? '',
        socketAccessToken: data['socketToken'] as String? ?? '',
        result: data['success'] as bool? ?? false,
        errors: [],
        creditsUsed: (data['creditsUsed'] as num?)?.toInt() ?? 0,
        creditsRemaining: (data['creditsRemaining'] as num?)?.toInt() ?? 0,
      );
    } on FirebaseFunctionsException catch (e) {
      return WiroRunTaskResponse(
        taskId: '',
        socketAccessToken: '',
        result: false,
        errors: [e.message ?? 'Unknown error'],
      );
    }
  }

  /// Get task detail/status
  ///
  /// Can be called with either [taskId] or [socketToken]
  Future<WiroTaskDetail?> getTaskDetail({
    String? taskId,
    String? socketToken,
  }) async {
    assert(
      taskId != null || socketToken != null,
      'Either taskId or socketToken must be provided',
    );

    try {
      final result = await _getTaskDetailFunction.call<Map<String, dynamic>>({
        if (taskId != null) 'taskId': taskId,
        if (socketToken != null) 'socketToken': socketToken,
      });

      return WiroTaskDetail.fromJson(result.data);
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Failed to get task detail');
    }
  }

  /// Kill a running task
  Future<bool> killTask({String? taskId, String? socketToken}) async {
    assert(
      taskId != null || socketToken != null,
      'Either taskId or socketToken must be provided',
    );

    try {
      final result = await _killTaskFunction.call<Map<String, dynamic>>({
        if (taskId != null) 'taskId': taskId,
        if (socketToken != null) 'socketToken': socketToken,
      });

      return result.data['success'] == true;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Failed to kill task');
    }
  }

  /// Cancel a queued task
  Future<bool> cancelTask({required String taskId}) async {
    try {
      final result = await _cancelTaskFunction.call<Map<String, dynamic>>({
        'taskId': taskId,
      });

      return result.data['success'] == true;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Failed to cancel task');
    }
  }

  /// Poll for task completion
  ///
  /// Polls the task status every [pollInterval] until completed or timeout
  Stream<WiroTaskDetail> pollTaskStatus({
    required String taskId,
    Duration pollInterval = const Duration(seconds: 3),
    Duration timeout = const Duration(minutes: 10),
  }) async* {
    final startTime = DateTime.now();

    while (true) {
      // Check timeout
      if (DateTime.now().difference(startTime) > timeout) {
        throw Exception('Task polling timeout');
      }

      // Get task detail
      final task = await getTaskDetail(taskId: taskId);

      if (task == null) {
        throw Exception('Task not found');
      }

      yield task;

      // Check if completed
      if (task.isCompleted) {
        break;
      }

      // Wait before next poll
      await Future<void>.delayed(pollInterval);
    }
  }
}
