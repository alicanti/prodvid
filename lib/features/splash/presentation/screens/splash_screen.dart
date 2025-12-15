import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

/// Splash screen matching Stitch design - prodvid_splash_screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  Future<void> _startLoading() async {
    // Simulate loading progress
    for (int i = 0; i <= 100; i += 5) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {
          _progress = i / 100;
        });
      }
    }

    // Navigate to welcome/onboarding
    if (mounted) {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          // Ambient background glow
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // Logo & Title
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo container
                      Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 32,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  // Gradient background
                                  Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF1a237e),
                                          Color(0xFF311b92),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Overlay
                                  Container(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                  // Icon
                                  const Center(
                                    child: Icon(
                                      Icons.smart_display_rounded,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .scale(begin: const Offset(0.8, 0.8)),

                      const SizedBox(height: 24),

                      // App name
                      Text(
                        'ProdVid',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                      const SizedBox(height: 4),

                      // Tagline
                      Text(
                        'AI Video Generation',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondaryDark,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                    ],
                  ),
                ),

                // Bottom progress section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 68),
                  child: Column(
                    children: [
                      // Loading text
                      Text(
                        'INITIALIZING',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiaryDark,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Progress bar
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Stack(
                          children: [
                            AnimatedFractionallySizedBox(
                              duration: const Duration(milliseconds: 100),
                              alignment: Alignment.centerLeft,
                              widthFactor: _progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                            ),
                            // Shimmer effect
                            if (_progress > 0 && _progress < 1)
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9999),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _progress,
                                    child:
                                        Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.white.withValues(
                                                      alpha: 0.2,
                                                    ),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            )
                                            .animate(
                                              onPlay: (controller) =>
                                                  controller.repeat(),
                                            )
                                            .shimmer(duration: 1500.ms),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Version
                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiaryDark.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
