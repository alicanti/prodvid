import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/revenuecat_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../router/app_router.dart';

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
                  // Profile header - compact
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surfaceDark,
                              width: 3,
                            ),
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
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 300.ms),
                        const SizedBox(width: 16),
                        // Name and ID
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Anonymous User',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () => _copyUserId(context, userId),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        userId,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                          color: AppColors.textSecondaryDark,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.copy,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Credits Card - compact
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1a1f2e), Color(0xFF0f1318)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Row(
                        children: [
                          // Credit icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.cyan],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.diamond,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Available Credits',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondaryDark,
                                  ),
                                ),
                                creditsAsync.when(
                                  data: (credits) => Text(
                                    '$credits',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  loading: () => const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  error: (_, __) => const Text(
                                    '—',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Buy credits button
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.paywall),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Buy',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                  ),

                  const SizedBox(height: 10),

                  // Subscription Status
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SubscriptionStatusCard(),
                  ),

                  const SizedBox(height: 16),

                  // Account settings
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: Theme.of(context).textTheme.titleLarge
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
                                icon: Icons.credit_card,
                                iconColor: AppColors.primary,
                                iconBgColor: const Color(0xFF222B3D),
                                title: 'Manage Subscription',
                                subtitle: 'Billing & subscription',
                                onTap: () {
                                  final service = ref.read(
                                    revenueCatServiceProvider,
                                  );
                                  service.presentCustomerCenter();
                                },
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
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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
                              Icon(
                                Icons.delete_forever,
                                color: AppColors.error,
                              ),
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

/// Subscription status card widget - compact version
class _SubscriptionStatusCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionAsync = ref.watch(userSubscriptionProvider);

    return subscriptionAsync.when(
      data: (isSubscribed) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSubscribed
                ? [const Color(0xFF1a2f1a), const Color(0xFF0f1f0f)]
                : [const Color(0xFF1a1f2e), const Color(0xFF0f1318)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSubscribed
                ? const Color(0xFF00FF88).withValues(alpha: 0.3)
                : AppColors.borderDark,
          ),
        ),
        child: Row(
          children: [
            // Status icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSubscribed
                      ? [const Color(0xFF00FF88), const Color(0xFF00D9FF)]
                      : [AppColors.slate600, AppColors.slate700],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSubscribed ? Icons.verified : Icons.star_border,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subscription',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSubscribed
                              ? const Color(0xFF00FF88)
                              : AppColors.slate500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isSubscribed ? 'Active' : 'Passive',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isSubscribed
                              ? const Color(0xFF00FF88)
                              : AppColors.textSecondaryDark,
                        ),
                      ),
                      if (isSubscribed) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
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
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Upgrade/Manage button
            GestureDetector(
              onTap: () {
                if (isSubscribed) {
                  ref.read(revenueCatServiceProvider).presentCustomerCenter();
                } else {
                  context.push(AppRoutes.paywall);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSubscribed
                      ? const Color(0xFF00FF88).withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isSubscribed ? 'Manage' : 'Upgrade',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSubscribed
                        ? const Color(0xFF00FF88)
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 150.ms),
      loading: () => const SizedBox(
        height: 72,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
