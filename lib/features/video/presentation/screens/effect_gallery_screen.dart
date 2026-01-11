import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/services/video_cache_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/wiro_effect_type.dart';
import '../../data/models/wiro_model_type.dart';

/// Full-screen effect gallery with vertical swipe navigation
class EffectGalleryScreen extends StatefulWidget {
  const EffectGalleryScreen({
    required this.modelType, required this.initialEffectIndex, super.key,
  });

  final WiroModelType modelType;
  final int initialEffectIndex;

  @override
  State<EffectGalleryScreen> createState() => _EffectGalleryScreenState();
}

class _EffectGalleryScreenState extends State<EffectGalleryScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late List<EffectOption> _effects;
  int _currentIndex = 0;
  bool _showSwipeHint = true;

  // Only keep ONE video controller at a time to save memory
  VideoPlayerController? _currentVideoController;
  int? _loadedVideoIndex;
  bool _isLoadingVideo = false;

  @override
  void initState() {
    super.initState();

    _effects = WiroEffects.getEffectsForModel(widget.modelType);
    _currentIndex = widget.initialEffectIndex.clamp(0, _effects.length - 1);
    _pageController = PageController(initialPage: _currentIndex);

    // Initialize only the current video
    _loadVideoForIndex(_currentIndex);

    // Hide swipe hint after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showSwipeHint = false);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentVideoController?.dispose();
    super.dispose();
  }

  Future<void> _loadVideoForIndex(int index) async {
    if (_isLoadingVideo || _loadedVideoIndex == index) return;
    if (index < 0 || index >= _effects.length) return;

    _isLoadingVideo = true;

    // Dispose previous video
    _currentVideoController?.dispose();
    _currentVideoController = null;
    _loadedVideoIndex = null;

    final effect = _effects[index];
    final coverUrl = widget.modelType.getCoverUrl(effect.value);

    try {
      VideoPlayerController controller;
      
      // Try cached file first, then fall back to network
      try {
        final file = await VideoCacheManager.instance.getSingleFile(coverUrl);
        controller = VideoPlayerController.file(file);
      } catch (_) {
        // Fall back to network
        controller = VideoPlayerController.networkUrl(Uri.parse(coverUrl));
      }
      
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(0);

      if (mounted && index == _currentIndex) {
        setState(() {
          _currentVideoController = controller;
          _loadedVideoIndex = index;
        });
        controller.play();
      } else {
        // Index changed while loading, dispose
        controller.dispose();
      }
    } catch (e) {
      debugPrint('Failed to load video: $e');
    } finally {
      _isLoadingVideo = false;
    }
  }

  void _onPageChanged(int index) {
    // Pause and dispose old video immediately
    _currentVideoController?.pause();
    _currentVideoController?.dispose();
    _currentVideoController = null;
    _loadedVideoIndex = null;

    setState(() {
      _currentIndex = index;
      _showSwipeHint = false;
    });

    // Load new video
    _loadVideoForIndex(index);
  }

  void _useTemplate() {
    final effect = _effects[_currentIndex];
    context.push('/effect-detail', extra: {
      'modelType': widget.modelType,
      'effectType': effect.value,
      'effectLabel': effect.label,
    });
  }

  List<Color> _getGradientForEffect(EffectOption effect) {
    final category = effect.category ?? '';

    if (category.contains('Animate')) {
      return [const Color(0xFF00f2fe), const Color(0xFF4facfe)];
    }
    if (category.contains('Scene')) {
      return [const Color(0xFFf5af19), const Color(0xFFf12711)];
    }
    if (category.contains('Surreal')) {
      return [const Color(0xFFa18cd1), const Color(0xFFfbc2eb)];
    }
    if (category.contains('Model')) {
      return [const Color(0xFF667eea), const Color(0xFF764ba2)];
    }
    if (category.contains('Christmas')) {
      return [const Color(0xFF11998e), const Color(0xFF38ef7d)];
    }
    if (category.contains('Black Friday')) {
      return [const Color(0xFF232526), const Color(0xFF414345)];
    }
    if (category.contains('Text')) {
      return [const Color(0xFFfa709a), const Color(0xFFfee140)];
    }

    return [const Color(0xFF667eea), const Color(0xFF764ba2)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vertical PageView for effects
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: _effects.length,
            itemBuilder: (context, index) {
              final effect = _effects[index];
              // Only show video for current index
              final isCurrentPage = index == _currentIndex;
              final hasVideo = isCurrentPage && 
                  _currentVideoController != null && 
                  _currentVideoController!.value.isInitialized;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Video or gradient
                  if (hasVideo)
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _currentVideoController!.value.size.width,
                        height: _currentVideoController!.value.size.height,
                        child: VideoPlayer(_currentVideoController!),
                      ),
                    )
                  else
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _getGradientForEffect(effect),
                        ),
                      ),
                      child: Center(
                        child: isCurrentPage && _isLoadingVideo
                            ? SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.play_circle_outline,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                      ),
                    ),

                  // Gradient overlays
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Top bar with close button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Close button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Counter
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${_effects.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom content
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category badge
                    if (_effects[_currentIndex].category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _effects[_currentIndex].category!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Effect name
                    Text(
                      _effects[_currentIndex].label,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Model type
                    Text(
                      widget.modelType.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Use Template button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _useTemplate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withValues(alpha: 0.5),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Use This Template',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Swipe hint animation
          if (_showSwipeHint)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated swipe icon
                      Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 40,
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .moveY(begin: 0, end: -15, duration: 800.ms)
                          .fadeOut(delay: 400.ms, duration: 400.ms)
                          .then()
                          .fadeIn(duration: 200.ms),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Swipe up for more effects',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ).animate().fadeIn(duration: 500.ms),
                    ],
                  ),
                ),
              ),
            ),

          // Side scroll indicator
          if (_effects.length > 1)
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 4,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Align(
                    alignment: Alignment(
                      0,
                      -1 + (2 * _currentIndex / (_effects.length - 1)),
                    ),
                    child: Container(
                      width: 4,
                      height: 100 / _effects.length.clamp(1, 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

