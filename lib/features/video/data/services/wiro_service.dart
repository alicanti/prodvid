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
  HttpsCallable get _runTaskFunction => _functions.httpsCallable('runWiroTask');
  HttpsCallable get _getTaskDetailFunction =>
      _functions.httpsCallable('getWiroTaskDetail');
  HttpsCallable get _killTaskFunction =>
      _functions.httpsCallable('killWiroTask');
  HttpsCallable get _cancelTaskFunction =>
      _functions.httpsCallable('cancelWiroTask');

  /// Start a 3D Text Animation task
  Future<WiroRunTaskResponse> runTextAnimation({
    required String caption,
    required String effectType,
    WiroVideoMode videoMode = WiroVideoMode.standard,
  }) async {
    return _runTask(
      WiroTextAnimationsRequest(
        caption: caption,
        effectType: effectType,
        videoMode: videoMode,
      ),
    );
  }

  /// Start a Product Ads task (image only)
  Future<WiroRunTaskResponse> runProductAds({
    required String inputImageUrl,
    required String effectType,
    WiroVideoMode videoMode = WiroVideoMode.standard,
  }) async {
    return _runTask(
      WiroProductAdsRequest(
        inputImageUrl: inputImageUrl,
        effectType: effectType,
        videoMode: videoMode,
      ),
    );
  }

  /// Start a Product Ads with Caption task
  Future<WiroRunTaskResponse> runProductAdsWithCaption({
    required String inputImageUrl,
    required String caption,
    required String effectType,
    WiroVideoMode videoMode = WiroVideoMode.standard,
  }) async {
    return _runTask(
      WiroProductAdsCaptionRequest(
        inputImageUrl: inputImageUrl,
        caption: caption,
        effectType: effectType,
        videoMode: videoMode,
      ),
    );
  }

  /// Start a Product Ads with Logo task
  Future<WiroRunTaskResponse> runProductAdsWithLogo({
    required String productImageUrl,
    required String logoImageUrl,
    required String effectType,
    WiroVideoMode videoMode = WiroVideoMode.standard,
  }) async {
    return _runTask(
      WiroProductAdsLogoRequest(
        productImageUrl: productImageUrl,
        logoImageUrl: logoImageUrl,
        effectType: effectType,
        videoMode: videoMode,
      ),
    );
  }

  /// Generic method to run any Wiro task
  Future<WiroRunTaskResponse> _runTask(WiroRunTaskRequest request) async {
    try {
      final result = await _runTaskFunction.call<Map<String, dynamic>>(
        request.toJson(),
      );

      return WiroRunTaskResponse.fromJson(result.data);
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
