import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/screens/home_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/onboarding/presentation/screens/welcome_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/video/data/models/wiro_model_type.dart';
import '../features/video/presentation/screens/effect_detail_screen.dart';
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
  static const String videoExport = '/video-export';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

/// Router configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Welcome Screen
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Home / Dashboard
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Profile
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),

      // Video Creation Flow
      GoRoute(
        path: AppRoutes.create,
        builder: (context, state) => const VideoCreationScreen(),
      ),

      // Template Selection
      GoRoute(
        path: AppRoutes.templates,
        builder: (context, state) => const TemplateSelectionScreen(),
      ),

      // Effect Detail
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

      // Video Export
      GoRoute(
        path: AppRoutes.videoExport,
        builder: (context, state) => const VideoExportScreen(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),

    // Redirect logic - anonymous auth handled in splash
    redirect: (context, state) {
      return null;
    },
  );
});

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
