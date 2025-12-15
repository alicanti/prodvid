import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import 'wiro_service.dart';

/// Video generation service provider
final videoGenerationServiceProvider = Provider<VideoGenerationService>((ref) {
  return VideoGenerationService(
    wiroService: ref.watch(wiroServiceProvider),
  );
});

/// High-level service for video generation workflow
class VideoGenerationService {
  VideoGenerationService({
    required WiroService wiroService,
  }) : _wiroService = wiroService;

  final WiroService _wiroService;
  final _uuid = const Uuid();

  /// Create a new video project
  VideoProject createProject({
    required String userId,
    String? title,
  }) {
    return VideoProject(
      id: _uuid.v4(),
      userId: userId,
      title: title ?? 'Untitled Video',
      status: VideoProjectStatus.draft,
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

  /// Start video generation
  Future<VideoProject> startVideoGeneration({
    required VideoProject project,
    required WiroEffectType effectType,
    WiroVideoMode videoMode = WiroVideoMode.standard,
  }) async {
    if (project.inputImageUrl == null) {
      throw Exception('No input image uploaded');
    }

    // Update project status
    var updatedProject = project.copyWith(
      status: VideoProjectStatus.processing,
      effectType: effectType,
      videoMode: videoMode,
      updatedAt: DateTime.now(),
    );

    // Start Wiro task
    final response = await _wiroService.runTask(
      inputImageUrl: project.inputImageUrl!,
      effectType: effectType,
      videoMode: videoMode,
    );

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

  /// Check and update video generation status
  Future<VideoProject> checkStatus(VideoProject project) async {
    if (project.wiroTaskId == null) {
      return project;
    }

    final response = await _wiroService.getTaskDetail(
      taskId: project.wiroTaskId,
    );

    if (response.hasError) {
      return project.copyWith(
        status: VideoProjectStatus.failed,
        errorMessage: response.errors.join(', '),
      );
    }

    final task = response.firstTask;
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
          updatedAt: DateTime.now(),
        );
      } else if (task.status == WiroTaskStatus.cancel) {
        yield project.copyWith(
          status: VideoProjectStatus.failed,
          errorMessage: 'Task was cancelled',
          updatedAt: DateTime.now(),
        );
      } else {
        // Still processing - emit progress update
        yield project.copyWith(
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

