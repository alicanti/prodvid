import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../services/video_cache_service.dart';
import '../services/video_loading_queue.dart';

/// An optimized looping video thumbnail widget with:
/// - Visibility-based loading (only loads when visible)
/// - Queue-based initialization (max 5 concurrent)
/// - Full dispose when not visible (memory optimization)
/// - Retry mechanism with exponential backoff
/// - Timeout protection
/// - Cache support via flutter_cache_manager
class LoopingVideoThumbnail extends StatefulWidget {
  const LoopingVideoThumbnail({
    required this.videoUrl,
    super.key,
    this.autoPlay = true,
    this.visibilityThreshold = 0.3,
    this.fallbackGradient,
    this.fallbackIcon,
    this.borderRadius = 0,
    this.showRetryButton = true,
  });

  final String videoUrl;
  final bool autoPlay;
  final double visibilityThreshold;
  final List<Color>? fallbackGradient;
  final IconData? fallbackIcon;
  final double borderRadius;
  final bool showRetryButton;

  @override
  State<LoopingVideoThumbnail> createState() => _LoopingVideoThumbnailState();
}

class _LoopingVideoThumbnailState extends State<LoopingVideoThumbnail> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;
  bool _isVisible = false;
  bool _isLoading = false;
  int _retryCount = 0;

  static const int _maxRetries = 2;
  static const Duration _timeout = Duration(seconds: 12);

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  void didUpdateWidget(LoopingVideoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _retryCount = 0;
      _hasError = false;
      if (_isVisible) {
        _startVideoLoad();
      }
    }
  }

  void _disposeController() {
    if (_controller != null) {
      // Unregister from lifecycle management
      VideoLoadingQueue.instance.unregisterController(_controller!);
      _controller!.removeListener(_videoListener);
      try {
        _controller!.pause();
        _controller!.dispose();
      } catch (_) {
        // Ignore errors during disposal
      }
    }
    _controller = null;
    _initialized = false;
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final wasVisible = _isVisible;
    _isVisible = info.visibleFraction >= widget.visibilityThreshold;

    if (_isVisible && !wasVisible) {
      // Became visible - load or resume
      if (!_initialized && !_isLoading && !_hasError) {
        _startVideoLoad();
      } else if (_initialized && _controller != null) {
        try {
          _controller!.play();
        } catch (_) {
          // Controller might be disposed
          _disposeController();
          _startVideoLoad();
        }
      }
    } else if (!_isVisible && wasVisible) {
      // Became invisible - pause and dispose (memory optimization)
      if (_controller != null) {
        try {
          _controller!.pause();
        } catch (_) {}
      }
      // Dispose to free memory
      if (_initialized) {
        _disposeController();
        if (mounted) setState(() {});
      }
    }
  }

  void _startVideoLoad() {
    if (_isLoading || _initialized || !mounted) return;
    
    setState(() => _isLoading = true);

    VideoLoadingQueue.instance.enqueue(() => _initVideo()).then((_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }).catchError((e) {
      if (mounted && !_initialized) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    });
  }

  Future<void> _initVideo() async {
    if (!mounted || !_isVisible) return;

    try {
      _disposeController();

      // Try cached file first
      File? cachedFile;
      try {
        cachedFile = await VideoCacheManager.getCachedVideo(widget.videoUrl);
      } catch (_) {}

      if (!mounted || !_isVisible) return;

      // Create controller from cache or network
      if (cachedFile != null && await cachedFile.exists()) {
        _controller = VideoPlayerController.file(
          cachedFile,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        );
      } else {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: false,
          ),
        );
      }

      if (_controller == null || !mounted || !_isVisible) {
        _disposeController();
        return;
      }

      _controller!.addListener(_videoListener);

      // Initialize with timeout
      await _controller!.initialize().timeout(
        _timeout,
        onTimeout: () => throw Exception('Video initialization timeout'),
      );

      if (!mounted || !_isVisible) {
        _disposeController();
        return;
      }

      // Configure and play
      if (widget.autoPlay) {
        await _controller!.setLooping(true);
        await _controller!.setVolume(0.0);
        await _controller!.play();
      }

      // Register for lifecycle management
      VideoLoadingQueue.instance.registerController(_controller!);

      if (mounted) {
        setState(() {
          _initialized = true;
          _hasError = false;
          _retryCount = 0;
        });

        // Cache in background if it wasn't cached
        if (cachedFile == null) {
          VideoCacheManager.preloadVideo(widget.videoUrl);
        }
      }
    } catch (e) {
      debugPrint('LoopingVideoThumbnail error: $e');
      
      // Retry with exponential backoff
      if (_retryCount < _maxRetries && mounted && _isVisible) {
        _retryCount++;
        await Future<void>.delayed(Duration(milliseconds: 500 * _retryCount));
        if (mounted && _isVisible) {
          await _initVideo();
        }
      } else if (mounted) {
        setState(() {
          _hasError = true;
          _initialized = false;
        });
      }
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;
    
    try {
      if (_controller!.value.hasError && !_hasError) {
        // Video error - attempt retry
        if (_retryCount < _maxRetries && _isVisible) {
          _retryCount++;
          _isLoading = false;
          _initialized = false;
          
          Future<void>.delayed(Duration(milliseconds: 500 * _retryCount), () {
            if (mounted && _isVisible && !_hasError) {
              _startVideoLoad();
            }
          });
        } else {
          setState(() => _hasError = true);
        }
      }
    } catch (_) {
      // Controller might be disposed
    }
  }

  void _retry() {
    setState(() {
      _retryCount = 0;
      _hasError = false;
      _isLoading = false;
      _initialized = false;
    });
    _startVideoLoad();
  }

  List<Color> get _gradient =>
      widget.fallbackGradient ??
      [const Color(0xFF667eea), const Color(0xFF764ba2)];

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('looping_video_${widget.videoUrl.hashCode}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // Error state
    if (_hasError) {
      return _buildErrorState();
    }

    // Video ready
    if (_initialized && _controller != null) {
      try {
        final value = _controller!.value;
        if (value.isInitialized) {
          return Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: value.size.width,
                  height: value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
              // Subtle gradient overlay for better text readability
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      } catch (_) {
        // Controller disposed during build
      }
    }

    // Loading / default state
    return _buildLoadingState();
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradient,
        ),
      ),
      child: Center(
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              )
            : Icon(
                widget.fallbackIcon ?? Icons.play_circle_outline,
                size: 40,
                color: Colors.white.withValues(alpha: 0.4),
              ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradient,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.videocam_off_rounded,
              size: 32,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            if (widget.showRetryButton) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _retry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

