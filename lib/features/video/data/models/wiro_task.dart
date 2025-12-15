import 'wiro_effect_type.dart';

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
}

/// Request model for running a Wiro task
class WiroRunTaskRequest {
  WiroRunTaskRequest({
    required this.inputImageUrl,
    required this.effectType,
    this.videoMode = WiroVideoMode.standard,
    this.callbackUrl,
  });

  final String inputImageUrl;
  final WiroEffectType effectType;
  final WiroVideoMode videoMode;
  final String? callbackUrl;

  Map<String, dynamic> toJson() {
    return {
      'inputImage': inputImageUrl,
      'effectType': effectType.value,
      'videoMode': videoMode.value,
      if (callbackUrl != null) 'callbackUrl': callbackUrl,
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
  });

  factory WiroRunTaskResponse.fromJson(Map<String, dynamic> json) {
    return WiroRunTaskResponse(
      taskId: json['taskid'] as String? ?? '',
      socketAccessToken: json['socketaccesstoken'] as String? ?? '',
      result: json['result'] as bool? ?? false,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  final String taskId;
  final String socketAccessToken;
  final bool result;
  final List<String> errors;

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
      contentType: json['contenttype'] as String? ?? '',
      url: json['url'] as String? ?? '',
      size: int.tryParse(json['size']?.toString() ?? '0') ?? 0,
    );
  }

  final String id;
  final String name;
  final String contentType;
  final String url;
  final int size;

  bool get isVideo => contentType.startsWith('video/') || name.endsWith('.mp4');

  bool get isImage =>
      contentType.startsWith('image/') ||
      name.endsWith('.png') ||
      name.endsWith('.jpg');
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
      socketAccessToken: json['socketaccesstoken'] as String? ?? '',
      status: WiroTaskStatus.fromValue(json['status'] as String? ?? ''),
      outputs: outputsList
          .map((e) => WiroTaskOutput.fromJson(e as Map<String, dynamic>))
          .toList(),
      elapsedSeconds: double.tryParse(json['elapsedseconds']?.toString() ?? ''),
      startTime: _parseTimestamp(json['starttime']),
      endTime: _parseTimestamp(json['endtime']),
      debugError: json['debugerror'] as String?,
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
