import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../services/video_player_manager.dart';

/// An optimized video cover widget that:
/// - Only loads video when visible on screen
/// - Uses global video player pool with max concurrent limit
/// - Shows gradient fallback while loading
/// - Automatically releases when off-screen
class OptimizedVideoCover extends StatefulWidget {
  const OptimizedVideoCover({
    required this.videoUrl,
    required this.uniqueId,
    super.key,
    this.fallbackGradient,
    this.fallbackIcon,
    this.borderRadius = 16,
    this.visibilityThreshold = 0.3,
    this.autoPlay = true,
  });

  final String videoUrl;
  final String uniqueId; // Unique ID for visibility detector
  final List<Color>? fallbackGradient;
  final IconData? fallbackIcon;
  final double borderRadius;
  final double visibilityThreshold;
  final bool autoPlay;

  @override
  State<OptimizedVideoCover> createState() => _OptimizedVideoCoverState();
}

class _OptimizedVideoCoverState extends State<OptimizedVideoCover> {
  VideoPlayerController? _controller;
  bool _isVisible = false;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void dispose() {
    _releaseVideo();
    super.dispose();
  }

  @override
  void didUpdateWidget(OptimizedVideoCover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _releaseVideo();
      if (_isVisible) {
        _loadVideo();
      }
    }
  }

  /// Check if the current controller is still valid
  bool get _isControllerValid {
    return _controller != null &&
        VideoPlayerManager.instance.isControllerValid(widget.videoUrl);
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;

    final wasVisible = _isVisible;
    _isVisible = info.visibleFraction >= widget.visibilityThreshold;

    if (_isVisible && !wasVisible) {
      // Became visible - load video
      _loadVideo();
    } else if (!_isVisible && wasVisible) {
      // Became invisible - pause but don't dispose
      _safePause();
    }
  }

  /// Safely pause the controller if it's still valid
  void _safePause() {
    if (_isControllerValid) {
      try {
        _controller?.pause();
      } catch (e) {
        // Controller was disposed, clear reference
        _clearController();
      }
    } else {
      _clearController();
    }
  }

  /// Safely play the controller if it's still valid
  void _safePlay() {
    if (_isControllerValid) {
      try {
        _controller?.play();
      } catch (e) {
        // Controller was disposed, clear reference
        _clearController();
      }
    } else {
      _clearController();
    }
  }

  void _clearController() {
    if (mounted) {
      setState(() {
        _controller = null;
      });
    } else {
      _controller = null;
    }
  }

  Future<void> _loadVideo() async {
    if (!mounted) return;

    // If we have a valid controller, just play it
    if (_isControllerValid) {
      _safePlay();
      return;
    }

    // Controller is gone, need to get a new one
    if (_controller != null) {
      _clearController();
    }

    if (_isLoading) return;

    _isLoading = true;

    try {
      final controller =
          await VideoPlayerManager.instance.getController(widget.videoUrl);

      if (!mounted) return;

      if (controller != null) {
        setState(() {
          _controller = controller;
          _hasError = false;
        });

        if (widget.autoPlay && _isVisible) {
          _safePlay();
        }
      } else {
        setState(() => _hasError = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    } finally {
      _isLoading = false;
    }
  }

  void _releaseVideo() {
    if (_controller != null) {
      VideoPlayerManager.instance.release(widget.videoUrl);
      _controller = null;
    }
  }

  List<Color> get _gradient =>
      widget.fallbackGradient ??
      [const Color(0xFF667eea), const Color(0xFF764ba2)];

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video_${widget.uniqueId}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // Check if controller is ready AND still valid
    final isReady = _isControllerValid &&
        _controller!.value.isInitialized &&
        !_hasError;

    if (isReady) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Video
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
          // Subtle overlay for better text readability
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

    return _buildFallback();
  }

  Widget _buildFallback() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradient,
        ),
      ),
      child: Center(
        child: _hasError
            ? Icon(
                widget.fallbackIcon ?? Icons.play_circle_outline,
                size: 40,
                color: Colors.white.withValues(alpha: 0.5),
              )
            : _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.5),
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
}

/// A simpler static thumbnail that shows gradient until tapped
/// Much more RAM efficient for grids
class StaticEffectCard extends StatelessWidget {
  const StaticEffectCard({
    required this.gradient,
    required this.icon,
    super.key,
    this.borderRadius = 16,
    this.child,
  });

  final List<Color> gradient;
  final IconData icon;
  final double borderRadius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Icon background
            Center(
              child: Icon(
                icon,
                size: 48,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            // Child content overlay
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

