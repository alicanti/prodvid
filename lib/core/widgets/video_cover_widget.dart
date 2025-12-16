import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../services/video_cache_service.dart';
import '../theme/app_colors.dart';

/// A widget that displays a video as a cover/thumbnail
/// Auto-plays muted, loops, and shows gradient fallback on error
/// Uses cached video player for optimal performance
class VideoCoverWidget extends StatefulWidget {
  const VideoCoverWidget({
    required this.videoUrl, super.key,
    this.fallbackGradient,
    this.fallbackIcon,
    this.borderRadius = 16,
  });

  final String videoUrl;
  final List<Color>? fallbackGradient;
  final IconData? fallbackIcon;
  final double borderRadius;

  @override
  State<VideoCoverWidget> createState() => _VideoCoverWidgetState();
}

class _VideoCoverWidgetState extends State<VideoCoverWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(VideoCoverWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      // Use cached video player for better performance
      _controller = await CachedVideoPlayerController.create(widget.videoUrl);

      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.setVolume(0);
      _controller!.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _hasError = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  List<Color> get _defaultGradient =>
      widget.fallbackGradient ??
      [const Color(0xFF667eea), const Color(0xFF764ba2)];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: _hasError || !_isInitialized
          ? _buildFallback()
          : AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
    );
  }

  Widget _buildFallback() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _defaultGradient,
        ),
      ),
      child: Center(
        child: _isInitialized
            ? const SizedBox.shrink()
            : widget.fallbackIcon != null
                ? Icon(
                    widget.fallbackIcon,
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.5),
                  )
                : SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
      ),
    );
  }
}

/// Simpler thumbnail version that just shows first frame
/// Uses cached video player for optimal performance
class VideoThumbnailWidget extends StatefulWidget {
  const VideoThumbnailWidget({
    required this.videoUrl, super.key,
    this.fallbackGradient,
    this.fallbackIcon,
    this.borderRadius = 16,
    this.playOnHover = false,
  });

  final String videoUrl;
  final List<Color>? fallbackGradient;
  final IconData? fallbackIcon;
  final double borderRadius;
  final bool playOnHover;

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(VideoThumbnailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      // Use cached video player for better performance
      _controller = await CachedVideoPlayerController.create(widget.videoUrl);

      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.setVolume(0);
      // Don't auto-play, just show first frame

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _hasError = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _onHover(bool hovering) {
    if (!widget.playOnHover || !_isInitialized) return;

    if (hovering) {
      _controller?.play();
    } else {
      _controller?.pause();
      _controller?.seekTo(Duration.zero);
    }
  }

  List<Color> get _defaultGradient =>
      widget.fallbackGradient ??
      [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)];

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTapDown: (_) => _onHover(true),
        onTapUp: (_) => _onHover(false),
        onTapCancel: () => _onHover(false),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_hasError || !_isInitialized)
                _buildFallback()
              else
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _defaultGradient,
        ),
      ),
      child: Center(
        child: _hasError
            ? Icon(
                widget.fallbackIcon ?? Icons.play_circle_outline,
                size: 40,
                color: Colors.white.withValues(alpha: 0.6),
              )
            : SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
      ),
    );
  }
}
