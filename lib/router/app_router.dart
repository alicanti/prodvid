import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          return MainShell(
            currentPath: state.uri.path,
            child: child,
          );
        },
        routes: [
          // Home / Dashboard
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreenContent(),
            ),
          ),

          // Template Selection (Effects)
          GoRoute(
            path: AppRoutes.templates,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TemplateSelectionScreenContent(),
            ),
          ),

          // My Videos
          GoRoute(
            path: AppRoutes.videos,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MyVideosScreen(),
            ),
          ),

          // Profile
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreenContent(),
            ),
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
            modelType: extra?['modelType'] as WiroModelType? ??
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
            modelType: extra?['modelType'] as WiroModelType? ??
                WiroModelType.productAds,
            initialEffectIndex: extra?['initialIndex'] as int? ?? 0,
          );
        },
      ),

      // Video Export (no nav bar - full screen)
      GoRoute(
        path: AppRoutes.videoExport,
        builder: (context, state) => const VideoExportScreen(),
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
  const MainShell({
    required this.currentPath,
    required this.child,
    super.key,
  });

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

/// My Videos Screen
class MyVideosScreen extends StatelessWidget {
  const MyVideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

          // Empty state
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.video_library_rounded,
                      size: 64,
                      color: Colors.white.withOpacity(0.3),
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
                          color: Colors.white.withOpacity(0.5),
                        ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.templates),
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
                            color: const Color(0xFF00D9FF).withOpacity(0.4),
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
        ],
      ),
    );
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
