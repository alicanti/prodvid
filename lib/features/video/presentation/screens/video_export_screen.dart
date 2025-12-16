import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

/// Video export/share screen matching Stitch design - video_export/share
class VideoExportScreen extends StatelessWidget {
  const VideoExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          // App Bar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      'Generated Ad',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Video preview
                  Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.45,
                        ),
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Video thumbnail placeholder
                                  DecoratedBox(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF667eea),
                                          Color(0xFF764ba2),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.play_circle_filled,
                                        size: 80,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Overlay
                                  Container(
                                    color: Colors.black.withValues(alpha: 0.2),
                                  ),

                                  // Play button
                                  Center(
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          9999,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),

                                  // Progress bar
                                  Positioned(
                                    left: 16,
                                    right: 16,
                                    bottom: 16,
                                    child: Column(
                                      children: [
                                        // Seekbar
                                        Container(
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.3,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              9999,
                                            ),
                                          ),
                                          child: FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: 0.33,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius:
                                                    BorderRadius.circular(9999),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Time
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '0:05',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '0:15',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 24),

                  // Success text
                  Text(
                    'Video generated!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 4),

                  const Text(
                    'Your product video is ready to be shared with the world.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryDark,
                    ),
                  ).animate().fadeIn(delay: 250.ms),

                  const SizedBox(height: 24),

                  // Action buttons
                  PrimaryButton(
                    text: 'Save to Gallery',
                    icon: Icons.download,
                    onPressed: () {},
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                  const SizedBox(height: 12),

                  // Re-generate button
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      side: const BorderSide(color: AppColors.borderDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.autorenew, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Re-generate',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // Export settings card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: const Icon(
                            Icons.videocam_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Export Settings',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '1080p • 60fps • MP4',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 24),

                  // Share section
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(
                        'Share directly',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Social share buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _ShareButton(
                          icon: Icons.camera_alt,
                          label: 'Instagram',
                          gradient: AppColors.instagramGradient,
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
                        _ShareButton(
                          icon: Icons.music_note,
                          label: 'TikTok',
                          color: Colors.black,
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
                        _ShareButton(
                          icon: Icons.smart_display,
                          label: 'Shorts',
                          color: Colors.red,
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
                        _ShareButton(
                          icon: Icons.chat,
                          label: 'Message',
                          color: AppColors.success,
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
                        _ShareButton(
                          icon: Icons.more_horiz,
                          label: 'More',
                          color: AppColors.slate400,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 24),

                  // Copy link
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.link,
                            color: AppColors.slate400,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'https://app.video/v/x83920s...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Copy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 100), // Space for nav bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom navigation
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border(top: BorderSide(color: AppColors.borderDark)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.grid_view,
                  label: 'Projects',
                  isSelected: false,
                  onTap: () => context.go('/home'),
                ),
                _NavItem(
                  icon: Icons.auto_fix_high,
                  label: 'Effects',
                  isSelected: true,
                  onTap: () {},
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  isSelected: false,
                  onTap: () => context.push('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.gradient,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              gradient: gradient,
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: gradient != null
                ? Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  )
                : Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.slate400,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected ? AppColors.primary : AppColors.slate400,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.slate400,
            ),
          ),
        ],
      ),
    );
  }
}
