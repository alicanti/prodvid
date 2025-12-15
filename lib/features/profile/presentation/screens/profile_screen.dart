import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

/// User profile screen matching Stitch design - prodvid_user_profile
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Edit',
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
                        Stack(
                              children: [
                                Container(
                                  width: 112,
                                  height: 112,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.surfaceDark,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCpBLLwJKuQndaCAkz5FKVtldPUW_d0ZfbsWWjSti9enqXSCfcv8Jmg5yv94k_oJ3stU5SCv4NwPDOeXwliuugHjd82DaZ81VSftMvbyyRFMF-ycrxZJL4cI6sWB2pr-AtoKpvJEeLFw8C4GJL5EPcep1r5kon7md2P8vxn3wB7mSJqPRshwqwi3z4UZuLzIyVFzr3LlRJp7cRp93G9Tll--YrvkUJhhEjyZHTiMvS8VAsaXtVJ1-_30X72cVBV5flFCx7NSfx8kUk',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: AppColors.surfaceCard,
                                              child: const Icon(
                                                Icons.person,
                                                size: 48,
                                                color:
                                                    AppColors.textSecondaryDark,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                                // Edit badge
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.backgroundDark,
                                        width: 4,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .scale(begin: const Offset(0.9, 0.9)),

                        const SizedBox(height: 16),

                        // Name
                        Text(
                          'Alex Johnson',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ).animate().fadeIn(delay: 100.ms),

                        const SizedBox(height: 4),

                        // Email
                        Text(
                          'alex.j@example.com',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondaryDark,
                          ),
                        ).animate().fadeIn(delay: 150.ms),

                        const SizedBox(height: 8),

                        // Pro badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            'PRO MEMBER',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 1,
                            ),
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Usage Statistics
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Usage Statistics',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),

                        const SizedBox(height: 12),

                        // Credits card
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CURRENT PLAN',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondaryDark,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Monthly Credits',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Progress
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '85',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          child: Text(
                                            '/ 100 Used',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  AppColors.textSecondaryDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Progress bar
                                    Container(
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceCard,
                                        borderRadius: BorderRadius.circular(
                                          9999,
                                        ),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: 0.85,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(
                                              9999,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.5),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      'Resets in 5 days',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.slate500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Upgrade banner
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.05,
                                  ),
                                  border: Border(
                                    top: BorderSide(
                                      color: AppColors.borderDark,
                                    ),
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Need more credits?',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.slate400,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // TODO: Navigate to paywall when designed
                                      },
                                      child: Text(
                                        'Upgrade Plan',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
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
                          'Account',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: Column(
                            children: [
                              _SettingsItem(
                                icon: Icons.credit_card,
                                iconColor: AppColors.primary,
                                iconBgColor: const Color(0xFF222B3D),
                                title: 'Subscription',
                                subtitle: 'Manage plan & billing',
                                onTap: () {
                                  // TODO: Navigate to paywall when designed
                                },
                              ),
                              _SettingsItem(
                                icon: Icons.movie_filter,
                                iconColor: AppColors.purple,
                                iconBgColor: const Color(0xFF222B3D),
                                title: 'History',
                                subtitle: 'View past generations',
                                onTap: () {},
                              ),
                              _SettingsItem(
                                icon: Icons.notifications,
                                iconColor: AppColors.orange,
                                iconBgColor: const Color(0xFF222B3D),
                                title: 'Notifications',
                                subtitle: 'Email & push preferences',
                                onTap: () {},
                              ),
                              _SettingsItem(
                                icon: Icons.support_agent,
                                iconColor: AppColors.teal,
                                iconBgColor: const Color(0xFF222B3D),
                                title: 'Support',
                                subtitle: 'Get help & FAQs',
                                onTap: () {},
                                showDivider: false,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Logout button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Handle logout
                          context.go('/welcome');
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: AppColors.error),
                              const SizedBox(width: 8),
                              Text(
                                'Log Out',
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
                    ).animate().fadeIn(delay: 500.ms),
                  ),

                  const SizedBox(height: 16),

                  // Version
                  Text(
                    'ProdVid v2.4.0',
                    style: TextStyle(fontSize: 12, color: AppColors.slate600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          border: Border(top: BorderSide(color: AppColors.borderDark)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  icon: Icons.home,
                  label: 'Home',
                  isSelected: false,
                  onTap: () => context.go('/home'),
                ),
                GestureDetector(
                  onTap: () => context.push('/create'),
                  child: Container(
                    width: 56,
                    height: 56,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                ),
                _NavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  isSelected: true,
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
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slate400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.slate400),
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
