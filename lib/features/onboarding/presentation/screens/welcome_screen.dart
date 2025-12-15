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
                  Icon(Icons.video_camera_front, color: Colors.white, size: 36),
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
                              children: [
                                const _StepCard(
                                  index: 0,
                                  title: '1. Upload Image',
                                  icon: Icons.add_photo_alternate_rounded,
                                  gradientColors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2),
                                  ],
                                  showUploadBadge: true,
                                ),
                                const SizedBox(width: 16),
                                const _StepCard(
                                  index: 1,
                                  title: '2. Select AI Effect',
                                  icon: Icons.auto_awesome,
                                  gradientColors: [
                                    Color(0xFF4facfe),
                                    Color(0xFF00f2fe),
                                  ],
                                  isHighlighted: true,
                                  showMagicIcon: true,
                                ),
                                const SizedBox(width: 16),
                                const _StepCard(
                                  index: 2,
                                  title: '3. Get Video Ad',
                                  icon: Icons.play_circle_filled_rounded,
                                  gradientColors: [
                                    Color(0xFFfa709a),
                                    Color(0xFFfee140),
                                  ],
                                  showPlayButton: true,
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
    required this.icon,
    required this.gradientColors,
    this.isHighlighted = false,
    this.showUploadBadge = false,
    this.showMagicIcon = false,
    this.showPlayButton = false,
  });

  final int index;
  final String title;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isHighlighted;
  final bool showUploadBadge;
  final bool showMagicIcon;
  final bool showPlayButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card with gradient
        Container(
          width: 160,
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            border: isHighlighted
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    width: 2,
                  )
                : null,
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Center icon
              Center(
                child: Icon(
                  icon,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),

              // Upload badge
              if (showUploadBadge)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Icon(
                      Icons.upload_file,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),

              // Magic sparkle overlay
              if (showMagicIcon)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Icon(Icons.auto_awesome, color: Colors.white, size: 24)
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.2, 1.2),
                        duration: 1000.ms,
                      ),
                ),

              // Play button overlay
              if (showPlayButton)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
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
