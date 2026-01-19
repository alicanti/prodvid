import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_indicator.dart';
import '../../../../core/widgets/primary_button.dart';

/// Welcome screen matching Stitch design - welcome_screen
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Logo header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.video_camera_front, color: Colors.white, size: 36),
                  const SizedBox(width: 8),
                  Text(
                    'ProdVid',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms),
            ),

            const SizedBox(height: 32),

            // Horizontal scroll cards
            Expanded(
              child: Column(
                children: [
                  // Card carousel
                  SizedBox(
                    height: 280,
                    child:
                        ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              children: const [
                                _StepCard(
                                  index: 0,
                                  title: '1. Upload Image',
                                  imagePath: 'assets/images/upload.jpeg',
                                ),
                                SizedBox(width: 16),
                                _StepCard(
                                  index: 1,
                                  title: '2. Select AI Effect',
                                  imagePath: 'assets/images/aieffect.jpeg',
                                  isHighlighted: true,
                                ),
                                SizedBox(width: 16),
                                _StepCard(
                                  index: 2,
                                  title: '3. Get Video Ad',
                                  imagePath: 'assets/images/getvideoad.jpeg',
                                ),
                              ],
                            )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 500.ms)
                            .slideX(begin: 0.1),
                  ),

                  const SizedBox(height: 32),

                  // Title & description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                            children: [
                              const TextSpan(
                                text: 'Create Stunning Video Ads ',
                              ),
                              TextSpan(
                                text: 'with ProdVid',
                                style: TextStyle(
                                  foreground: Paint()
                                    ..shader =
                                        const LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            Color(0xFF60A5FA),
                                          ],
                                        ).createShader(
                                          const Rect.fromLTWH(0, 0, 200, 40),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

                        const SizedBox(height: 12),

                        Text(
                          'Just upload a product photo, choose an effect, and let our AI generate high-converting video ads in seconds.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppColors.textSecondaryDark,
                                height: 1.5,
                              ),
                        ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Page indicator
                  const PageIndicator(
                    count: 3,
                    currentIndex: 1,
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                ],
              ),
            ),

            // Bottom button - Get Started
            Padding(
              padding: const EdgeInsets.all(24),
              child:
                  PrimaryButton(
                        text: 'Get Started',
                        onPressed: () => context.go('/onboarding'),
                      )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 400.ms)
                      .slideY(begin: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.title,
    required this.imagePath,
    this.isHighlighted = false,
  });

  final int index;
  final String title;
  final String imagePath;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card with image
        Container(
          width: 160,
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isHighlighted
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    width: 2,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: isHighlighted
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Title
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isHighlighted ? AppColors.primary : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
