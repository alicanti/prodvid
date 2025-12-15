import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

/// Product media upload screen matching Stitch design - product_media_upload
class VideoCreationScreen extends StatefulWidget {
  const VideoCreationScreen({super.key});

  @override
  State<VideoCreationScreen> createState() => _VideoCreationScreenState();
}

class _VideoCreationScreenState extends State<VideoCreationScreen> {
  String? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Upload Product Image',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _selectedImage != null
                        ? () => context.push('/templates')
                        : null,
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _selectedImage != null
                            ? AppColors.primary
                            : AppColors.textTertiaryDark,
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                    child: Text(
                      'Select a high-quality photo of your product. This will be used as the input for AI generation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 8),

                  // Image preview area
                  Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderDark),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(19),
                              child: _selectedImage != null
                                  ? _ImagePreview(
                                      imageUrl: _selectedImage!,
                                      onRemove: () {
                                        setState(() {
                                          _selectedImage = null;
                                        });
                                      },
                                    )
                                  : _EmptyState(
                                      onSelectImage: () {
                                        // Simulate image selection
                                        setState(() {
                                          _selectedImage =
                                              'https://lh3.googleusercontent.com/aida-public/AB6AXuD4gWelxJZFwLfKIgFO2q6BZOeuaL2g5BC42X31aKI2JgnBrkLLxDXEmiyA6P96bjWVz7aZTkUOsgbFZVBwRSkckxIprSzTNi4mhGnqcU-WzXwmQXUYRIicK87vkRWurPKKqf4rVzfy55d7LopHEycftPkAGaXSdL_DdDQydEwJxCPlvLOCzT6FetpSOglGE9BZFdhrxzmwV_UbW8pu4oQYcf-rvbBWrV1lZAmXBnTu2UmI4M6YD5WtKYt80I54zxTM83Xjoi97i5E';
                                        });
                                      },
                                    ),
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 500.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 32),

                  // Action buttons
                  ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.photo_library,
                                label: 'Gallery',
                                iconColor: AppColors.purple,
                                iconBgColor: AppColors.purple.withValues(
                                  alpha: 0.1,
                                ),
                                onTap: () {
                                  // Simulate selecting from gallery
                                  setState(() {
                                    _selectedImage =
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuD4gWelxJZFwLfKIgFO2q6BZOeuaL2g5BC42X31aKI2JgnBrkLLxDXEmiyA6P96bjWVz7aZTkUOsgbFZVBwRSkckxIprSzTNi4mhGnqcU-WzXwmQXUYRIicK87vkRWurPKKqf4rVzfy55d7LopHEycftPkAGaXSdL_DdDQydEwJxCPlvLOCzT6FetpSOglGE9BZFdhrxzmwV_UbW8pu4oQYcf-rvbBWrV1lZAmXBnTu2UmI4M6YD5WtKYt80I54zxTM83Xjoi97i5E';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.photo_camera,
                                label: 'Camera',
                                iconColor: AppColors.primary,
                                iconBgColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                onTap: () {
                                  // Open camera
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideY(begin: 0.2),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border(top: BorderSide(color: AppColors.borderDark)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.folder_open,
                  label: 'Projects',
                  isSelected: false,
                  onTap: () => context.go('/home'),
                ),
                _NavItem(
                  icon: Icons.auto_fix_high,
                  label: 'Effects',
                  isSelected: true,
                  showBadge: true,
                  onTap: () {},
                ),
                _NavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  isSelected: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageUrl, required this.onRemove});

  final String imageUrl;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                Icons.broken_image_outlined,
                color: AppColors.textSecondaryDark,
                size: 48,
              ),
            );
          },
        ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
              stops: const [0.6, 1.0],
            ),
          ),
        ),

        // Remove button
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),

        // Selected badge
        Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Text(
              'IMAGE SELECTED',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSelectImage});

  final VoidCallback onSelectImage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelectImage,
      child: Container(
        color: AppColors.surfaceCard,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap to select image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'or use the buttons below',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
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
    this.showBadge = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondaryDark,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondaryDark,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (showBadge)
            Positioned(
              top: -4,
              right: 8,
              child:
                  Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.5, 1.5),
                        duration: 1000.ms,
                      )
                      .fadeOut(duration: 1000.ms),
            ),
        ],
      ),
    );
  }
}
