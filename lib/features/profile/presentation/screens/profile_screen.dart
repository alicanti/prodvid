import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';

/// User profile screen matching Stitch design - prodvid_user_profile
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _copyUserId(BuildContext context, String userId) {
    Clipboard.setData(ClipboardData(text: userId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User ID copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final userId = authService.userId ?? 'Unknown';
    final creditsAsync = ref.watch(userCreditsProvider);

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
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Profile',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  // Profile header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surfaceDark,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const ClipOval(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2),
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms).scale(
                              begin: const Offset(0.9, 0.9),
                            ),

                        const SizedBox(height: 16),

                        // Anonymous User label
                        Text(
                          'Anonymous User',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ).animate().fadeIn(delay: 100.ms),

                        const SizedBox(height: 12),

                        // User ID with copy button
                        GestureDetector(
                          onTap: () => _copyUserId(context, userId),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderDark),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.fingerprint,
                                  size: 18,
                                  color: AppColors.textSecondaryDark,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  userId.length > 16
                                      ? '${userId.substring(0, 8)}...${userId.substring(userId.length - 6)}'
                                      : userId,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'monospace',
                                    color: AppColors.textSecondaryDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.copy,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 150.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Credits Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Credits',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),

                        const SizedBox(height: 12),

                        // Credits card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1a1f2e),
                                Color(0xFF0f1318),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: Row(
                            children: [
                              // Credit icon
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.cyan,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.diamond,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Available Credits',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondaryDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    creditsAsync.when(
                                      data: (credits) => Text(
                                        '$credits',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                      ),
                                      loading: () => const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      error: (_, __) => const Text(
                                        '—',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Buy credits button
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Buy',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                        const SizedBox(height: 12),

                        // Credit info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: AppColors.textSecondaryDark,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Standard video: 45 credits • Pro video: 80 credits',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 250.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Account settings
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),

                        const SizedBox(height: 12),

                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: Column(
                            children: [
                              _SettingsItem(
                                icon: Icons.movie_filter,
                                iconColor: AppColors.purple,
                                iconBgColor: const Color(0xFF222B3D),
                                title: 'My Videos',
                                subtitle: 'View past generations',
                                onTap: () => context.go('/videos'),
                              ),
                              _SettingsItem(
                                icon: Icons.notifications,
                                iconColor: AppColors.orange,
                                iconBgColor: const Color(0xFF222B3D),
                                title: 'Notifications',
                                subtitle: 'Push preferences',
                                onTap: () {},
                              ),
                              _SettingsItem(
                                icon: Icons.support_agent,
                                iconColor: AppColors.teal,
                                iconBgColor: const Color(0xFF222B3D),
                                title: 'Support',
                                subtitle: 'Get help & FAQs',
                                onTap: () {},
                              ),
                              _SettingsItem(
                                icon: Icons.privacy_tip_outlined,
                                iconColor: AppColors.slate400,
                                iconBgColor: const Color(0xFF222B3D),
                                title: 'Privacy Policy',
                                subtitle: 'Terms and conditions',
                                onTap: () {},
                                showDivider: false,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Delete account button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.surfaceCard,
                              title: const Text('Delete Account?'),
                              content: const Text(
                                'This will permanently delete your account and all data. This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm ?? false) {
                            await authService.deleteAccount();
                            if (context.mounted) {
                              context.go('/welcome');
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_forever, color: AppColors.error),
                              SizedBox(width: 8),
                              Text(
                                'Delete Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                  ),

                  const SizedBox(height: 16),

                  // Version
                  const Text(
                    'ProdVid v1.0.0',
                    style: TextStyle(fontSize: 12, color: AppColors.slate600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Nav bar provided by MainShell
      extendBody: true,
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.slate400),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 72,
            color: AppColors.borderDark.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}
