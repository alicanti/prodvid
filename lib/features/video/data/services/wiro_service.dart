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
  /// Start a video generation task
  ///
  /// Returns [WiroRunTaskResponse] containing the task ID and socket token
  Future<WiroRunTaskResponse> runTask({
    required String inputImageUrl,
    required WiroEffectType effectType,
    WiroVideoMode videoMode = WiroVideoMode.standard,
  }) async {
    // TODO: Call Firebase Cloud Function 'wiro-runTask'
    // The Cloud Function will:
    // 1. Get Wiro API credentials from Secret Manager
    // 2. Generate HMAC signature
    // 3. Make POST request to https://api.wiro.ai/v1/Run/wiro/product-ads
    // 4. Return the response

    throw UnimplementedError('Cloud Function not yet implemented');
  }

  /// Get task detail/status
  ///
  /// Can be called with either [taskId] or [socketToken]
  Future<WiroTaskDetailResponse> getTaskDetail({
    String? taskId,
    String? socketToken,
  }) async {
    assert(
      taskId != null || socketToken != null,
      'Either taskId or socketToken must be provided',
    );

    // TODO: Call Firebase Cloud Function 'wiro-getTaskDetail'
    // The Cloud Function will:
    // 1. Get Wiro API credentials from Secret Manager
    // 2. Generate HMAC signature
    // 3. Make POST request to https://api.wiro.ai/v1/Task/Detail
    // 4. Return the response

    throw UnimplementedError('Cloud Function not yet implemented');
  }

  /// Kill a running task
  Future<void> killTask({
    String? taskId,
    String? socketToken,
  }) async {
    assert(
      taskId != null || socketToken != null,
      'Either taskId or socketToken must be provided',
    );

    // TODO: Call Firebase Cloud Function 'wiro-killTask'
    throw UnimplementedError('Cloud Function not yet implemented');
  }

  /// Cancel a queued task
  Future<void> cancelTask({required String taskId}) async {
    // TODO: Call Firebase Cloud Function 'wiro-cancelTask'
    throw UnimplementedError('Cloud Function not yet implemented');
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
      final response = await getTaskDetail(taskId: taskId);

      if (response.hasError) {
        throw Exception(response.errors.join(', '));
      }

      final task = response.firstTask;
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

