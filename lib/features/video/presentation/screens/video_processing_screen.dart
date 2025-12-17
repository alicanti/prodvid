import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/wiro_model_type.dart';
import '../../data/models/wiro_task.dart';
import '../../data/services/wiro_service.dart';

/// Screen shown during video generation
class VideoProcessingScreen extends ConsumerStatefulWidget {
  const VideoProcessingScreen({
    required this.taskId,
    required this.socketToken,
    required this.modelType,
    required this.effectType,
    required this.effectLabel,
    super.key,
  });

  final String taskId;
  final String socketToken;
  final WiroModelType modelType;
  final String effectType;
  final String effectLabel;

  @override
  ConsumerState<VideoProcessingScreen> createState() =>
      _VideoProcessingScreenState();
}

class _VideoProcessingScreenState extends ConsumerState<VideoProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  StreamSubscription<WiroTaskDetail>? _statusSubscription;

  String _statusMessage = 'Starting...';
  double _progress = 0;
  bool _isComplete = false;
  bool _hasError = false;
  String? _errorMessage;
  String? _videoUrl;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _startPolling();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _statusSubscription?.cancel();
    super.dispose();
  }

  void _startPolling() {
    final wiroService = ref.read(wiroServiceProvider);

    _statusSubscription = wiroService
        .pollTaskStatus(taskId: widget.taskId)
        .listen(_onStatusUpdate, onError: _onError);
  }

  void _onStatusUpdate(WiroTaskDetail task) {
    setState(() {
      _statusMessage = task.status?.displayMessage ?? 'Processing...';
      _progress = _calculateProgress(task.status);

      if (task.isCompleted) {
        _isComplete = true;
        _pulseController.stop();

        if (task.isSuccess) {
          _videoUrl = task.videoUrl;
          if (_videoUrl == null) {
            _hasError = true;
            _errorMessage = 'No video output found';
          }
        } else {
          _hasError = true;
          _errorMessage = task.debugError ?? 'Video generation was cancelled';
        }
      }
    });
  }

  double _calculateProgress(WiroTaskStatus? status) {
    if (status == null) return 0;
    switch (status) {
      case WiroTaskStatus.queue:
        return 0.1;
      case WiroTaskStatus.accept:
        return 0.2;
      case WiroTaskStatus.assign:
        return 0.25;
      case WiroTaskStatus.preprocessStart:
        return 0.35;
      case WiroTaskStatus.preprocessEnd:
        return 0.45;
      case WiroTaskStatus.start:
        return 0.6;
      case WiroTaskStatus.output:
        return 0.85;
      case WiroTaskStatus.postprocessEnd:
        return 1;
      case WiroTaskStatus.cancel:
        return 0;
    }
  }

  void _onError(Object error) {
    setState(() {
      _hasError = true;
      _errorMessage = error.toString();
      _pulseController.stop();
    });
  }

  Future<void> _cancelTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Cancel Generation?'),
        content: const Text(
          'Are you sure you want to cancel the video generation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        final wiroService = ref.read(wiroServiceProvider);
        await wiroService.cancelTask(taskId: widget.taskId);
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        // Try kill if cancel fails
        try {
          final wiroService = ref.read(wiroServiceProvider);
          await wiroService.killTask(taskId: widget.taskId);
          if (mounted) {
            context.pop();
          }
        } catch (e2) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed to cancel: $e2')));
          }
        }
      }
    }
  }

  void _viewResult() {
    if (_videoUrl != null) {
      context.pushReplacement(
        '/video-export',
        extra: {'videoUrl': _videoUrl, 'taskId': widget.taskId},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isComplete ? () => context.pop() : _cancelTask,
        ),
        title: Text(
          _isComplete ? 'Complete!' : 'Generating...',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon
              _buildAnimatedIcon(),
              const SizedBox(height: 40),

              // Effect info
              Text(
                widget.effectLabel,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.modelType.label,
                style: const TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),

              // Progress
              _buildProgressSection(),
              const SizedBox(height: 40),

              // Action buttons
              if (_isComplete) _buildCompleteActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    if (_hasError) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.error.withValues(alpha: 0.1),
        ),
        child: const Icon(
          Icons.error_outline,
          size: 60,
          color: AppColors.error,
        ),
      ).animate().shake();
    }

    if (_isComplete && !_hasError) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.2),
              AppColors.cyan.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: const Icon(
          Icons.check_circle,
          size: 60,
          color: AppColors.primary,
        ),
      ).animate().scale(duration: 300.ms);
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.1);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.cyan.withValues(alpha: 0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: 0.3 * _pulseController.value,
                  ),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 50,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        // Status message
        Text(
          _hasError ? (_errorMessage ?? 'An error occurred') : _statusMessage,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _hasError ? AppColors.error : Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Progress bar
        if (!_hasError) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceCard,
              valueColor: AlwaysStoppedAnimation<Color>(
                _isComplete ? AppColors.primary : AppColors.cyan,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(_progress * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompleteActions() {
    if (_hasError) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceCard,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Go Back'),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _viewResult,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow),
                SizedBox(width: 8),
                Text(
                  'View Video',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
          ),
        ).animate().fadeIn().slideY(begin: 0.2),
      ],
    );
  }
}
