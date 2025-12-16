import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import 'wiro_service.dart';

/// Video generation service provider
final videoGenerationServiceProvider = Provider<VideoGenerationService>((ref) {
  return VideoGenerationService(wiroService: ref.watch(wiroServiceProvider));
});

/// High-level service for video generation workflow
class VideoGenerationService {
  VideoGenerationService({required WiroService wiroService})
    : _wiroService = wiroService;

  final WiroService _wiroService;
  final _uuid = const Uuid();

  /// Create a new video project
  VideoProject createProject({
    required String userId,
    required WiroModelType modelType,
    String? title,
  }) {
    return VideoProject(
      id: _uuid.v4(),
      userId: userId,
      title: title ?? 'Untitled Video',
      status: VideoProjectStatus.draft,
      modelType: modelType,
      createdAt: DateTime.now(),
    );
  }

  /// Upload product image and update project
  Future<VideoProject> uploadProductImage({
    required VideoProject project,
    required File imageFile,
  }) async {
    // TODO: Upload image to Firebase Storage
    // 1. Upload to gs://bucket/users/{userId}/projects/{projectId}/input.jpg
    // 2. Get download URL
    // 3. Return updated project with inputImageUrl

    throw UnimplementedError('Firebase Storage upload not yet implemented');
  }

  /// Upload logo image and update project (for Product Ads with Logo)
  Future<VideoProject> uploadLogoImage({
    required VideoProject project,
    required File imageFile,
  }) async {
    // TODO: Upload image to Firebase Storage
    // 1. Upload to gs://bucket/users/{userId}/projects/{projectId}/logo.jpg
    // 2. Get download URL
    // 3. Return updated project with logoImageUrl

    throw UnimplementedError('Firebase Storage upload not yet implemented');
  }

  /// Start video generation based on model type
  Future<VideoProject> startVideoGeneration({
    required VideoProject project,
    required String effectType,
    WiroVideoMode videoMode = WiroVideoMode.standard,
  }) async {
    // Validate inputs based on model type
    _validateProjectInputs(project);

    // Update project status
    var updatedProject = project.copyWith(
      status: VideoProjectStatus.processing,
      effectType: effectType,
      videoMode: videoMode,
      updatedAt: DateTime.now(),
    );

    // Start appropriate Wiro task based on model type
    WiroRunTaskResponse response;

    switch (project.modelType) {
      case WiroModelType.textAnimations:
        response = await _wiroService.runTextAnimation(
          caption: project.caption!,
          effectType: effectType,
          videoMode: videoMode,
        );
        break;

      case WiroModelType.productAds:
        response = await _wiroService.runProductAds(
          inputImageUrl: project.inputImageUrl!,
          effectType: effectType,
          videoMode: videoMode,
        );
        break;

      case WiroModelType.productAdsWithCaption:
        response = await _wiroService.runProductAdsWithCaption(
          inputImageUrl: project.inputImageUrl!,
          caption: project.caption!,
          effectType: effectType,
          videoMode: videoMode,
        );
        break;

      case WiroModelType.productAdsWithLogo:
        response = await _wiroService.runProductAdsWithLogo(
          productImageUrl: project.inputImageUrl!,
          logoImageUrl: project.logoImageUrl!,
          effectType: effectType,
          videoMode: videoMode,
        );
        break;

      case null:
        throw Exception('Model type not specified');
    }

    if (response.hasError) {
      return updatedProject.copyWith(
        status: VideoProjectStatus.failed,
        errorMessage: response.errors.join(', '),
      );
    }

    // Update project with task info
    updatedProject = updatedProject.copyWith(
      wiroTaskId: response.taskId,
      wiroSocketToken: response.socketAccessToken,
    );

    // TODO: Save project to Firestore

    return updatedProject;
  }

  /// Validate project inputs based on model type
  void _validateProjectInputs(VideoProject project) {
    switch (project.modelType) {
      case WiroModelType.textAnimations:
        if (project.caption == null || project.caption!.isEmpty) {
          throw Exception('Caption is required for 3D Text Animations');
        }
        break;

      case WiroModelType.productAds:
        if (project.inputImageUrl == null) {
          throw Exception('Product image is required for Product Ads');
        }
        break;

      case WiroModelType.productAdsWithCaption:
        if (project.inputImageUrl == null) {
          throw Exception(
              'Product image is required for Product Ads with Caption');
        }
        if (project.caption == null || project.caption!.isEmpty) {
          throw Exception('Caption is required for Product Ads with Caption');
        }
        break;

      case WiroModelType.productAdsWithLogo:
        if (project.inputImageUrl == null) {
          throw Exception(
              'Product image is required for Product Ads with Logo');
        }
        if (project.logoImageUrl == null) {
          throw Exception('Logo image is required for Product Ads with Logo');
        }
        break;

      case null:
        throw Exception('Model type not specified');
    }
  }

  /// Check and update video generation status
  Future<VideoProject> checkStatus(VideoProject project) async {
    if (project.wiroTaskId == null) {
      return project;
    }

    final task = await _wiroService.getTaskDetail(
      taskId: project.wiroTaskId,
    );

    if (task == null) {
      return project.copyWith(
        status: VideoProjectStatus.failed,
        errorMessage: 'Task not found',
      );
    }

    // Update project based on task status
    if (task.isSuccess) {
      return project.copyWith(
        status: VideoProjectStatus.completed,
        outputVideoUrl: task.videoUrl,
        thumbnailUrl: task.thumbnailUrl,
        updatedAt: DateTime.now(),
      );
    } else if (task.status == WiroTaskStatus.cancel) {
      return project.copyWith(
        status: VideoProjectStatus.failed,
        errorMessage: 'Task was cancelled',
        updatedAt: DateTime.now(),
      );
    }

    // Still processing
    return project;
  }

  /// Watch video generation progress
  Stream<VideoProject> watchProgress(VideoProject project) async* {
    if (project.wiroTaskId == null) {
      yield project;
      return;
    }

    await for (final task in _wiroService.pollTaskStatus(
      taskId: project.wiroTaskId!,
    )) {
      if (task.isSuccess) {
        yield project.copyWith(
          status: VideoProjectStatus.completed,
          outputVideoUrl: task.videoUrl,
          thumbnailUrl: task.thumbnailUrl,
          updatedAt: DateTime.now(),
        );
      } else if (task.status == WiroTaskStatus.cancel) {
        yield project.copyWith(
          status: VideoProjectStatus.failed,
          errorMessage: 'Task was cancelled',
          updatedAt: DateTime.now(),
        );
      } else {
        // Still processing - emit progress update with status message
        yield project.copyWith(
          statusMessage: task.status?.displayMessage,
          updatedAt: DateTime.now(),
        );
      }
    }
  }

  /// Cancel a video generation
  Future<VideoProject> cancelGeneration(VideoProject project) async {
    if (project.wiroTaskId == null) {
      return project.copyWith(
        status: VideoProjectStatus.failed,
        errorMessage: 'No task to cancel',
      );
    }

    await _wiroService.killTask(taskId: project.wiroTaskId);

    return project.copyWith(
      status: VideoProjectStatus.failed,
      errorMessage: 'Cancelled by user',
      updatedAt: DateTime.now(),
    );
  }
}
