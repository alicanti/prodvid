import 'wiro_effect_type.dart';
import 'wiro_model_type.dart';

/// Wiro task status values
enum WiroTaskStatus {
  // Running statuses - continue polling
  queue('task_queue'),
  accept('task_accept'),
  assign('task_assign'),
  preprocessStart('task_preprocess_start'),
  preprocessEnd('task_preprocess_end'),
  start('task_start'),
  output('task_output'),

  // Completed statuses - stop polling
  postprocessEnd('task_postprocess_end'),
  cancel('task_cancel');

  const WiroTaskStatus(this.value);

  final String value;

  static WiroTaskStatus? fromValue(String value) {
    try {
      return WiroTaskStatus.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  bool get isCompleted =>
      this == WiroTaskStatus.postprocessEnd || this == WiroTaskStatus.cancel;

  bool get isSuccess => this == WiroTaskStatus.postprocessEnd;

  bool get isRunning => !isCompleted;

  /// Get a user-friendly status message
  String get displayMessage {
    switch (this) {
      case WiroTaskStatus.queue:
        return 'In queue...';
      case WiroTaskStatus.accept:
        return 'Task accepted';
      case WiroTaskStatus.assign:
        return 'Processing...';
      case WiroTaskStatus.preprocessStart:
        return 'Preparing...';
      case WiroTaskStatus.preprocessEnd:
        return 'Ready to generate';
      case WiroTaskStatus.start:
        return 'Generating video...';
      case WiroTaskStatus.output:
        return 'Finalizing...';
      case WiroTaskStatus.postprocessEnd:
        return 'Complete!';
      case WiroTaskStatus.cancel:
        return 'Cancelled';
    }
  }
}

/// Base request model for running a Wiro task
abstract class WiroRunTaskRequest {
  WiroRunTaskRequest({
    required this.modelType,
    required this.effectType,
    this.videoMode = WiroVideoMode.standard,
  });

  final WiroModelType modelType;
  final String effectType;
  final WiroVideoMode videoMode;

  Map<String, dynamic> toJson();
}

/// Request for 3D Text Animations (caption only)
class WiroTextAnimationsRequest extends WiroRunTaskRequest {
  WiroTextAnimationsRequest({
    required this.caption,
    required super.effectType,
    super.videoMode,
  }) : super(modelType: WiroModelType.textAnimations);

  final String caption;

  @override
  Map<String, dynamic> toJson() {
    return {
      'modelType': modelType.endpoint,
      'caption': caption,
      'effectType': effectType,
      'videoMode': videoMode.value,
    };
  }
}

/// Request for Product Ads (image only)
class WiroProductAdsRequest extends WiroRunTaskRequest {
  WiroProductAdsRequest({
    required this.inputImageUrl,
    required super.effectType,
    super.videoMode,
  }) : super(modelType: WiroModelType.productAds);

  final String inputImageUrl;

  @override
  Map<String, dynamic> toJson() {
    return {
      'modelType': modelType.endpoint,
      'inputImage': inputImageUrl,
      'effectType': effectType,
      'videoMode': videoMode.value,
    };
  }
}

/// Request for Product Ads with Caption (image + caption)
class WiroProductAdsCaptionRequest extends WiroRunTaskRequest {
  WiroProductAdsCaptionRequest({
    required this.inputImageUrl,
    required this.caption,
    required super.effectType,
    super.videoMode,
  }) : super(modelType: WiroModelType.productAdsWithCaption);

  final String inputImageUrl;
  final String caption;

  @override
  Map<String, dynamic> toJson() {
    return {
      'modelType': modelType.endpoint,
      'inputImage': inputImageUrl,
      'caption': caption,
      'effectType': effectType,
      'videoMode': videoMode.value,
    };
  }
}

/// Request for Product Ads with Logo (image + logo)
class WiroProductAdsLogoRequest extends WiroRunTaskRequest {
  WiroProductAdsLogoRequest({
    required this.productImageUrl,
    required this.logoImageUrl,
    required super.effectType,
    super.videoMode,
  }) : super(modelType: WiroModelType.productAdsWithLogo);

  final String productImageUrl;
  final String logoImageUrl;

  @override
  Map<String, dynamic> toJson() {
    return {
      'modelType': modelType.endpoint,
      'inputImage': productImageUrl,
      'logoImage': logoImageUrl,
      'effectType': effectType,
      'videoMode': videoMode.value,
    };
  }
}

/// Response model for run task
class WiroRunTaskResponse {
  WiroRunTaskResponse({
    required this.taskId,
    required this.socketAccessToken,
    required this.result,
    this.errors = const [],
    this.creditsUsed = 0,
    this.creditsRemaining = 0,
  });

  factory WiroRunTaskResponse.fromJson(Map<String, dynamic> json) {
    return WiroRunTaskResponse(
      taskId: json['taskId'] as String? ?? json['taskid'] as String? ?? '',
      socketAccessToken:
          json['socketAccessToken'] as String? ??
          json['socketaccesstoken'] as String? ??
          json['socketToken'] as String? ??
          '',
      result: json['result'] as bool? ?? json['success'] as bool? ?? false,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>() ?? [],
      creditsUsed: (json['creditsUsed'] as num?)?.toInt() ?? 0,
      creditsRemaining: (json['creditsRemaining'] as num?)?.toInt() ?? 0,
    );
  }

  final String taskId;
  final String socketAccessToken;
  final bool result;
  final List<String> errors;
  final int creditsUsed;
  final int creditsRemaining;

  bool get hasError => errors.isNotEmpty || !result;
}

/// Output file from a completed task
class WiroTaskOutput {
  WiroTaskOutput({
    required this.id,
    required this.name,
    required this.contentType,
    required this.url,
    required this.size,
  });

  factory WiroTaskOutput.fromJson(Map<String, dynamic> json) {
    return WiroTaskOutput(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      contentType:
          json['contentType'] as String? ??
          json['contenttype'] as String? ??
          '',
      url: json['url'] as String? ?? '',
      size: int.tryParse(json['size']?.toString() ?? '0') ?? 0,
    );
  }

  final String id;
  final String name;
  final String contentType;
  final String url;
  final int size;

  bool get isVideo =>
      contentType.startsWith('video/') ||
      name.endsWith('.mp4') ||
      name.endsWith('.webm');

  bool get isImage =>
      contentType.startsWith('image/') ||
      name.endsWith('.png') ||
      name.endsWith('.jpg') ||
      name.endsWith('.jpeg');
}

/// Task detail model
class WiroTaskDetail {
  WiroTaskDetail({
    required this.id,
    required this.uuid,
    required this.socketAccessToken,
    required this.status,
    required this.outputs,
    this.elapsedSeconds,
    this.startTime,
    this.endTime,
    this.debugError,
  });

  factory WiroTaskDetail.fromJson(Map<String, dynamic> json) {
    final outputsList = json['outputs'] as List<dynamic>? ?? [];

    return WiroTaskDetail(
      id: json['id'] as String? ?? '',
      uuid: json['uuid'] as String? ?? '',
      socketAccessToken:
          json['socketaccesstoken'] as String? ??
          json['socketAccessToken'] as String? ??
          '',
      status: WiroTaskStatus.fromValue(json['status'] as String? ?? ''),
      outputs: outputsList
          .map((e) => WiroTaskOutput.fromJson(e as Map<String, dynamic>))
          .toList(),
      elapsedSeconds:
          double.tryParse(json['elapsedSeconds']?.toString() ?? '') ??
          double.tryParse(json['elapsedseconds']?.toString() ?? ''),
      startTime: _parseTimestamp(json['starttime']),
      endTime: _parseTimestamp(json['endtime']),
      debugError:
          json['debugerror'] as String? ?? json['debugError'] as String?,
    );
  }

  final String id;
  final String uuid;
  final String socketAccessToken;
  final WiroTaskStatus? status;
  final List<WiroTaskOutput> outputs;
  final double? elapsedSeconds;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? debugError;

  bool get isCompleted => status?.isCompleted ?? false;

  bool get isSuccess => status?.isSuccess ?? false;

  bool get isRunning => status?.isRunning ?? true;

  String? get videoUrl {
    try {
      return outputs.firstWhere((o) => o.isVideo).url;
    } catch (_) {
      // If no video, try to get any output URL
      return outputs.isNotEmpty ? outputs.first.url : null;
    }
  }

  String? get thumbnailUrl {
    try {
      return outputs.firstWhere((o) => o.isImage).url;
    } catch (_) {
      return null;
    }
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    final seconds = int.tryParse(value.toString());
    if (seconds == null || seconds == 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
}

/// Response model for task detail
class WiroTaskDetailResponse {
  WiroTaskDetailResponse({
    required this.tasks,
    required this.result,
    this.errors = const [],
  });

  factory WiroTaskDetailResponse.fromJson(Map<String, dynamic> json) {
    final taskList = json['tasklist'] as List<dynamic>? ?? [];

    return WiroTaskDetailResponse(
      tasks: taskList
          .map((e) => WiroTaskDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      result: json['result'] as bool? ?? false,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  final List<WiroTaskDetail> tasks;
  final bool result;
  final List<String> errors;

  WiroTaskDetail? get firstTask => tasks.isNotEmpty ? tasks.first : null;

  bool get hasError => errors.isNotEmpty || !result;
}
