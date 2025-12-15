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
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _StepCard(
                          index: 0,
                          title: '1. Upload Image',
                          imageUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDauY37YdFKworcYS5B2sSQQG1SB8u_xJBmZCQ5qm08_yTYEWAdR7vcgAo-rQKtSvHxNJfgk5udbI5tPoeCKwfUb9bVeoPC7ZHh7SxMEc-chfEUZYSz1CqyXa3l0BAE_9-N_MgcBbXIqcVi_L1a_otgPXimJF-RliLPakV65kWmfNqNYJIWQfqO3BiH9nq35CiupMaAt_S2YM8hrfxtycC4EktAo_mHzHl9McXkZyDS6ckqnuWlJ1ARmVCYhiPhjYgsKnxwCSTNfMA',
                          showUploadBadge: true,
                        ),
                        const SizedBox(width: 16),
                        _StepCard(
                          index: 1,
                          title: '2. Select AI Effect',
                          imageUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAnfr-2sxocBfSzkK1D_LIe38c1Aco8S_K_tu5vrA00LmdN0IvGsxLVuuLQdXFt9Nfo4ZeorEAsrwJU1DkVdpAOykFF3Zc6snblNfc2DxMXMliu5S27ADl6iisyfzrDoNingCA53cYsgVomzWK6RYSNLgZ4OdAzei6t2JAI_MIqnVItsYgS6vt87th7UjAHHV6E4ECyJICZWC9EzG_aGTYTyeZF-0r5uvt_6xpXQ3Qqb7djfh5GUZfTm2DXLA9z2fhJ6meO_edL6PE',
                          isHighlighted: true,
                          showMagicIcon: true,
                        ),
                        const SizedBox(width: 16),
                        _StepCard(
                          index: 2,
                          title: '3. Get Video Ad',
                          imageUrl:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDq9LGp7LyHtLZqmCvTS540RhdQVd-UTqa3v0T3ZnMsmZfv7Rnck192mHG5DlBog7-yQGeo1ehd8p22ESFWzUQLqJuJ9jh46x_OLJ8UQEdyE8Eam3ONORzSEPuTFLqHzOMCrNMm_bDapT_LPa_mc8AydRNMQqkVWiClBz0gjWVtkrlH2P4bRlBbLTPKQCsQ8z9-76ZR-Q4b8MvdHICVvSQM0YGlr5zk5lDNBVHNn5HxgCgLZ-ottvyscN-tbHxlvhBr2djM7ltbyow',
                          showPlayButton: true,
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideX(begin: 0.1),
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
    required this.imageUrl,
    this.isHighlighted = false,
    this.showUploadBadge = false,
    this.showMagicIcon = false,
    this.showPlayButton = false,
  });

  final int index;
  final String title;
  final String imageUrl;
  final bool isHighlighted;
  final bool showUploadBadge;
  final bool showMagicIcon;
  final bool showPlayButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card image
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
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surfaceCard,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textSecondaryDark,
                        size: 48,
                      ),
                    );
                  },
                ),

                // Upload badge
                if (showUploadBadge)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: const Icon(
                        Icons.upload_file,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),

                // Magic icon overlay
                if (showMagicIcon)
                  Container(
                    color: Colors.black.withValues(alpha: 0.2),
                    child: Center(
                      child:
                          Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 40,
                              )
                              .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true),
                              )
                              .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.1, 1.1),
                                duration: 1000.ms,
                              ),
                    ),
                  ),

                // Play button
                if (showPlayButton)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
              ],
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
