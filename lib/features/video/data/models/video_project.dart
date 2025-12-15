import 'wiro_effect_type.dart';

/// Video project status
enum VideoProjectStatus {
  draft,
  uploading,
  processing,
  completed,
  failed;

  bool get isTerminal => this == completed || this == failed;
}

/// Video project model representing a user's video generation project
class VideoProject {
  VideoProject({
    required this.id,
    required this.userId,
    required this.title,
    required this.status,
    required this.createdAt,
    this.inputImageUrl,
    this.effectType,
    this.videoMode,
    this.wiroTaskId,
    this.wiroSocketToken,
    this.outputVideoUrl,
    this.thumbnailUrl,
    this.duration,
    this.creditsUsed,
    this.updatedAt,
    this.errorMessage,
  });

  factory VideoProject.fromJson(Map<String, dynamic> json) {
    return VideoProject(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String? ?? 'Untitled',
      status: VideoProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VideoProjectStatus.draft,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      inputImageUrl: json['inputImageUrl'] as String?,
      effectType: json['effectType'] != null
          ? WiroEffectType.fromValue(json['effectType'] as String)
          : null,
      videoMode: json['videoMode'] != null
          ? WiroVideoMode.values.firstWhere(
              (e) => e.value == json['videoMode'],
              orElse: () => WiroVideoMode.standard,
            )
          : null,
      wiroTaskId: json['wiroTaskId'] as String?,
      wiroSocketToken: json['wiroSocketToken'] as String?,
      outputVideoUrl: json['outputVideoUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      duration: json['duration'] as int?,
      creditsUsed: json['creditsUsed'] as int?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  final String id;
  final String userId;
  final String title;
  final VideoProjectStatus status;
  final DateTime createdAt;
  final String? inputImageUrl;
  final WiroEffectType? effectType;
  final WiroVideoMode? videoMode;
  final String? wiroTaskId;
  final String? wiroSocketToken;
  final String? outputVideoUrl;
  final String? thumbnailUrl;
  final int? duration;
  final int? creditsUsed;
  final DateTime? updatedAt;
  final String? errorMessage;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      if (inputImageUrl != null) 'inputImageUrl': inputImageUrl,
      if (effectType != null) 'effectType': effectType!.value,
      if (videoMode != null) 'videoMode': videoMode!.value,
      if (wiroTaskId != null) 'wiroTaskId': wiroTaskId,
      if (wiroSocketToken != null) 'wiroSocketToken': wiroSocketToken,
      if (outputVideoUrl != null) 'outputVideoUrl': outputVideoUrl,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (duration != null) 'duration': duration,
      if (creditsUsed != null) 'creditsUsed': creditsUsed,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  VideoProject copyWith({
    String? id,
    String? userId,
    String? title,
    VideoProjectStatus? status,
    DateTime? createdAt,
    String? inputImageUrl,
    WiroEffectType? effectType,
    WiroVideoMode? videoMode,
    String? wiroTaskId,
    String? wiroSocketToken,
    String? outputVideoUrl,
    String? thumbnailUrl,
    int? duration,
    int? creditsUsed,
    DateTime? updatedAt,
    String? errorMessage,
  }) {
    return VideoProject(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      inputImageUrl: inputImageUrl ?? this.inputImageUrl,
      effectType: effectType ?? this.effectType,
      videoMode: videoMode ?? this.videoMode,
      wiroTaskId: wiroTaskId ?? this.wiroTaskId,
      wiroSocketToken: wiroSocketToken ?? this.wiroSocketToken,
      outputVideoUrl: outputVideoUrl ?? this.outputVideoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      creditsUsed: creditsUsed ?? this.creditsUsed,
      updatedAt: updatedAt ?? this.updatedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

