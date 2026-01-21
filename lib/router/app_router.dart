import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core/theme/app_colors.dart';

import '../core/services/auth_service.dart';
import '../core/services/video_cache_service.dart';
import '../core/widgets/bottom_nav_bar.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/onboarding/presentation/screens/welcome_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/video/data/models/wiro_model_type.dart';
import '../features/video/presentation/screens/effect_detail_screen.dart';
import '../features/video/presentation/screens/effect_gallery_screen.dart';
import '../features/video/presentation/screens/template_selection_screen.dart';
import '../features/video/presentation/screens/video_creation_screen.dart';
import '../features/video/presentation/screens/video_export_screen.dart';
import '../features/video/presentation/screens/video_processing_screen.dart';

/// Route names
abstract class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String create = '/create';
  static const String templates = '/templates';
  static const String effectDetail = '/effect-detail';
  static const String effectGallery = '/effect-gallery';
  static const String videoProcessing = '/video-processing';
  static const String videoExport = '/video-export';
  static const String videos = '/videos';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

/// Navigation shell key for persistent bottom nav
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Router configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen (no nav bar)
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Welcome Screen (no nav bar)
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Onboarding (no nav bar)
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main app shell with persistent bottom nav bar
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(currentPath: state.uri.path, child: child);
        },
        routes: [
          // Home / Dashboard
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreenContent()),
          ),

          // Template Selection (Effects)
          GoRoute(
            path: AppRoutes.templates,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: TemplateSelectionScreenContent()),
          ),

          // My Videos
          GoRoute(
            path: AppRoutes.videos,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MyVideosScreen()),
          ),

          // Profile
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreenContent()),
          ),
        ],
      ),

      // Video Creation Flow (no nav bar - full screen)
      GoRoute(
        path: AppRoutes.create,
        builder: (context, state) => const VideoCreationScreen(),
      ),

      // Effect Detail (no nav bar - full screen)
      GoRoute(
        path: AppRoutes.effectDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return EffectDetailScreen(
            modelType:
                extra?['modelType'] as WiroModelType? ??
                WiroModelType.productAds,
            effectType: extra?['effectType'] as String? ?? '',
            effectLabel: extra?['effectLabel'] as String? ?? 'Effect',
          );
        },
      ),

      // Effect Gallery (no nav bar - full screen swipe)
      GoRoute(
        path: AppRoutes.effectGallery,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return EffectGalleryScreen(
            modelType:
                extra?['modelType'] as WiroModelType? ??
                WiroModelType.productAds,
            initialEffectIndex: extra?['initialIndex'] as int? ?? 0,
          );
        },
      ),

      // Video Processing (no nav bar - generation progress)
      GoRoute(
        path: AppRoutes.videoProcessing,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return VideoProcessingScreen(
            taskId: extra?['taskId'] as String? ?? '',
            socketToken: extra?['socketToken'] as String? ?? '',
            modelType:
                extra?['modelType'] as WiroModelType? ??
                WiroModelType.productAds,
            effectType: extra?['effectType'] as String? ?? '',
            effectLabel: extra?['effectLabel'] as String? ?? 'Effect',
          );
        },
      ),

      // Video Export (no nav bar - full screen)
      GoRoute(
        path: AppRoutes.videoExport,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return VideoExportScreen(
            videoUrl: extra?['videoUrl'] as String?,
            taskId: extra?['taskId'] as String?,
          );
        },
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),

    // Redirect logic
    redirect: (context, state) {
      return null;
    },
  );
});

/// Main shell with persistent bottom navigation
class MainShell extends StatelessWidget {
  const MainShell({required this.currentPath, required this.child, super.key});

  final String currentPath;
  final Widget child;

  int _getSelectedIndex() {
    if (currentPath.startsWith('/home')) return 0;
    if (currentPath.startsWith('/templates')) return 1;
    if (currentPath.startsWith('/videos')) return 2;
    if (currentPath.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: child,
      extendBody: true, // Allow content to extend behind nav bar
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _getSelectedIndex(),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.home);
            case 1:
              context.go(AppRoutes.templates);
            case 2:
              context.go(AppRoutes.videos);
            case 3:
              context.go(AppRoutes.profile);
          }
        },
        onCreateTap: () => context.push(AppRoutes.templates),
      ),
    );
  }
}

/// Home screen content (without Scaffold/nav bar)
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

/// Template selection content (without Scaffold/nav bar)
class TemplateSelectionScreenContent extends StatelessWidget {
  const TemplateSelectionScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const TemplateSelectionScreen();
  }
}

/// Profile screen content (without Scaffold/nav bar)
class ProfileScreenContent extends StatelessWidget {
  const ProfileScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}

/// My Videos Screen - Shows user's generated videos from Firestore
class MyVideosScreen extends ConsumerWidget {
  const MyVideosScreen({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    ref.invalidate(userVideosProvider);
    // Wait for the provider to reload
    await ref.read(userVideosProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(userVideosProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00D9FF), Color(0xFF00FF88)],
                  ).createShader(bounds),
                  child: Text(
                    'My Videos',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: videosAsync.when(
              data: (videos) {
                if (videos.isEmpty) {
                  return _buildEmptyState(context, ref);
                }
                return _buildVideoGrid(context, ref, videos);
              },
              loading: () => _buildSkeletonGrid(),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load videos',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.invalidate(userVideosProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 9 / 16,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _SkeletonCard()
            .animate(onPlay: (c) => c.repeat())
            .shimmer(
              duration: 1500.ms,
              color: Colors.white.withValues(alpha: 0.1),
            );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(ref),
      color: const Color(0xFF00D9FF),
      backgroundColor: AppColors.surfaceCard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.video_library_rounded,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No videos yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your generated videos will appear here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pull down to refresh',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go(AppRoutes.templates);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D9FF), Color(0xFF00FF88)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D9FF).withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Create Your First Video',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Extra padding for nav bar
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoGrid(
    BuildContext context,
    WidgetRef ref,
    List<VideoProject> videos,
  ) {
    return RefreshIndicator(
      onRefresh: () => _onRefresh(ref),
      color: const Color(0xFF00D9FF),
      backgroundColor: AppColors.surfaceCard,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 9 / 16,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return _VideoCard(video: video)
              .animate()
              .fadeIn(delay: Duration(milliseconds: 50 * index))
              .scale(begin: const Offset(0.95, 0.95));
        },
      ),
    );
  }
}

/// Skeleton card for loading state
class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Video placeholder
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
          // Info placeholder
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Video card widget for displaying a single video project
/// Only plays video when visible on screen to save memory
class _VideoCard extends StatefulWidget {
  const _VideoCard({required this.video});

  final VideoProject video;

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  void _disposeVideo() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final wasVisible = _isVisible;
    _isVisible = info.visibleFraction > 0.5; // At least 50% visible

    if (_isVisible && !wasVisible) {
      // Became visible - load and play video
      _initializeVideo();
    } else if (!_isVisible && wasVisible) {
      // Became invisible - dispose video to free memory
      if (mounted) {
        setState(() {
          _disposeVideo();
        });
      }
    }
  }

  Future<void> _initializeVideo() async {
    if (_isLoading || _isInitialized) return;
    if (widget.video.videoUrl == null || widget.video.videoUrl!.isEmpty) return;
    if (!_isVisible) return;

    _isLoading = true;

    try {
      // Try cached file first, then fall back to network
      try {
        final file = await VideoCacheManager.instance.getSingleFile(
          widget.video.videoUrl!,
        );
        _controller = VideoPlayerController.file(file);
      } catch (_) {
        // Fall back to network (will also cache)
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.video.videoUrl!),
        );
      }

      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.setVolume(0);

      if (mounted && _isVisible) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.play();
      } else {
        // Widget disposed or became invisible during loading
        _controller?.dispose();
        _controller = null;
      }
    } catch (e) {
      debugPrint('Failed to load video: $e');
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video-card-${widget.video.taskId}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: GestureDetector(
        onTap: () {
          if (widget.video.isCompleted && widget.video.videoUrl != null) {
            // Navigate to video export screen
            context.push(
              AppRoutes.videoExport,
              extra: {
                'videoUrl': widget.video.videoUrl,
                'effectLabel': widget.video.displayName,
              },
            );
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(color: const Color(0xFF0A1628)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video or placeholder
                if (_isInitialized && _controller != null)
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  )
                else
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.video.isPending
                            ? [const Color(0xFF0A1628), const Color(0xFF0D2137)]
                            : [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.black.withValues(alpha: 0.5),
                              ],
                      ),
                    ),
                    child: Center(
                      child: widget.video.isPending
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF00D9FF),
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.video.status == 'preparing'
                                      ? 'Starting...'
                                      : 'Creating video...',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          : Icon(
                              widget.video.isFailed
                                  ? Icons.error_outline
                                  : Icons.play_circle_outline,
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                    ),
                  ),

                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),

                // Status badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        widget.video.status,
                      ).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusText(widget.video.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Video mode badge (PRO/STD)
                if (widget.video.videoMode == 'pro')
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                // Title and date
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.video.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (widget.video.createdAt != null)
                        Text(
                          _formatDate(widget.video.createdAt!),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF00FF88);
      case 'pending':
      case 'processing':
      case 'preparing':
        return const Color(0xFF00D9FF);
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'READY';
      case 'preparing':
        return 'STARTING';
      case 'pending':
        return 'QUEUED';
      case 'processing':
        return 'CREATING';
      case 'failed':
        return 'FAILED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Error Screen
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
