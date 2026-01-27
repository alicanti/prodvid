import 'package:flutter/material.dart';

import 'looping_video_thumbnail.dart';

/// An optimized video cover widget that wraps LoopingVideoThumbnail
/// with a consistent API for backward compatibility.
///
/// Features:
/// - Only loads video when visible on screen (30% threshold)
/// - Queue-based loading (max 5 concurrent)
/// - Full dispose when off-screen for memory optimization
/// - Retry mechanism with exponential backoff
/// - 12 second timeout protection
/// - Cache support via flutter_cache_manager
class OptimizedVideoCover extends StatelessWidget {
  const OptimizedVideoCover({
    required this.videoUrl,
    required this.uniqueId,
    super.key,
    this.fallbackGradient,
    this.fallbackIcon,
    this.borderRadius = 16,
    this.visibilityThreshold = 0.3,
    this.autoPlay = true,
    this.showRetryButton = false,
  });

  final String videoUrl;
  final String uniqueId; // Used for visibility detector key
  final List<Color>? fallbackGradient;
  final IconData? fallbackIcon;
  final double borderRadius;
  final double visibilityThreshold;
  final bool autoPlay;
  final bool showRetryButton;

  @override
  Widget build(BuildContext context) {
    return LoopingVideoThumbnail(
      // Use uniqueId to create a more specific key
      key: ValueKey('cover_$uniqueId'),
      videoUrl: videoUrl,
      autoPlay: autoPlay,
      visibilityThreshold: visibilityThreshold,
      fallbackGradient: fallbackGradient,
      fallbackIcon: fallbackIcon,
      borderRadius: borderRadius,
      showRetryButton: showRetryButton,
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
