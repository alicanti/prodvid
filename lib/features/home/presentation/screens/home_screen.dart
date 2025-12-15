import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';

/// Project Dashboard matching Stitch design - project_dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedFilter = 0;
  int _currentNavIndex = 0;

  final List<String> _filters = ['All', 'Drafts', 'Rendering', 'Completed'];

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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  // Profile avatar
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Stack(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuCfGEXsVVWigx04nz0c9bGR1yOiVLK0GJA3ixDAmWS_eIvKkkFPOQOUxhI1QrU4tMmE8nVEIodRU55rACVOgeu52LlArNvppE1sDn6FkvKBJLFLsIKxRGhrQEdkoLzjXV26xZwukoRCABIJFjm3swh3nJgPGI6h0h24tIjPjTWa0YrS75zyC0mK_ZIOF12BzCHPisz5KE8pBUDecwLZksAXJrqyZVv6KObouuoZYJSq5UTNONhRMbJc2bQIYCexSKnRJlpw4iEPrfE',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.surfaceCard,
                                  child: const Icon(
                                    Icons.person,
                                    color: AppColors.textSecondaryDark,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Online indicator
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.backgroundDark,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Title
                  Text(
                    'AI Video Projects',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Search button
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.asMap().entries.map((entry) {
                  final isSelected = entry.key == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _FilterChip(
                      label: entry.value,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedFilter = entry.key;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Projects list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Generating project
                _ProjectCard(
                  title: 'Smart Watch Ad',
                  status: ProjectStatus.generating,
                  progress: 0.45,
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDEzuVykiStzWh3JAXa71PjAo8FrszXQA6czP_gUWmGSQScAVfNDuIaXshS-YmPL53TD0Z4FragQj_zMZYu1qngu7mWQID5opdz6M8ucQ57WrPJcXX4feYHE7tMh_6F8h7h_qwYxcAq_C3ZqK7AeQN0DC520FAiH7tJ9mHlkNW70D7qdhAvUHclEdmLuzuz_ULurhN2yStwFsx29WFa39thGZ-TAB5_aJ2vVMYZ-eqW8-rf77l3Jjjn8Vu-5aXFh3LTWDy5eh9Lais',
                  statusText: 'Applying effect...',
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 16),
                
                // Draft project
                _ProjectCard(
                  title: 'Summer Shoe Promo',
                  status: ProjectStatus.draft,
                  duration: '00:15',
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD6yFff5XhGmkpew-PrN_B_S3EwmPTKrleFTFJWhxdN2gh_a1N9k9z9bI9zKucZs-hsLc5K-UEe1iifkXjzCNY7A1pS6zwsxhlYeDh5aDpcXfFNoSykK0UZV4k2BW9qbfsBmu9qC5n5el08xOTyFqz5DjGUODvKXUlH7AuIvr_Ifeg0WGfT8LjKBY41h1P_6iwv_boy66y0SxnzXhwyzzlE0dpIkPs_uau-IRiY1NCtSfNnwEq6GBEEsHROWu-w6D0XuwHTpaZmMTM',
                  statusText: 'Edited 2h ago',
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 16),
                
                // Completed project
                _ProjectCard(
                  title: 'Gym Wear Campaign',
                  status: ProjectStatus.completed,
                  duration: '01:30',
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCS7XnHudi2oqIuObAf5MWdXZ0ezMICLHHzbxpW4yEhEwqgq7ZZyL6w4TdXoJFsi5OJCGbh-HcmQU1Na8ioy6aDdRcx6LNWdqwP4XQ39xNXAXv4tDjkMgpUtT5t_8YFwEGYl60dsL7LQ2pG2XAZH0jYvW-bqYXghhmoCqcUJYAiKrlORvNybkAvypqiKwvJ_WsAA69YWBNo6w3aM8prJv99pG-GSUwg6GhZjoDvf44dSN2IpEEtnFg2X41Rf_tNUOfUNNi_jmPMkOo',
                  statusText: '3 days ago',
                  showShareButton: true,
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 16),
                
                // Another draft
                _ProjectCard(
                  title: 'Abstract Art Reel',
                  status: ProjectStatus.draft,
                  duration: '00:45',
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBssbbLdRbW9jWUUtapKtvVSO5tLxnZE6RFx2z7bRpToB69CsZfY3HblNdGWN120IzDWzU-aDuYqAMqF9_aw4wyJPRwRvuebrhWvDEafq-nIkaz8qf_0D08fgQP2CY-gVAwntbtQFhqNSq7MApU32-3yzf8HA5SEamS7KWXAk9LgB44Vlm6L-qJXjWcbYV4J1aYHksJB9-GN3AfH0k7mnGjs-kwPt0te-ClQC24qygHC0kbaOzNTqm5mKkSPQjvGZgxGHaAzfs',
                  statusText: 'Edited 1 week ago',
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ],
      ),
      
      // Floating action button
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/create'),
          backgroundColor: AppColors.primary,
          elevation: 8,
          icon: const Icon(Icons.add_circle, color: Colors.white),
          label: const Text(
            'Create New AI Video',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      
      // Bottom navigation
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          if (index == 2) {
            context.push('/profile');
          }
        },
      ),
    );
  }
}

enum ProjectStatus { draft, generating, completed }

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.borderDark,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.slate400,
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.title,
    required this.status,
    required this.imageUrl,
    required this.statusText,
    this.progress,
    this.duration,
    this.showShareButton = false,
  });

  final String title;
  final ProjectStatus status;
  final String imageUrl;
  final String statusText;
  final double? progress;
  final String? duration;
  final bool showShareButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          // Thumbnail
          SizedBox(
            width: 120,
            height: 120,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surfaceCard,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.textSecondaryDark,
                        ),
                      );
                    },
                  ),
                  
                  // Overlay for generating status
                  if (status == ProjectStatus.generating)
                    Container(
                      color: Colors.black.withValues(alpha: 0.4),
                      child: Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ),
                  
                  // Play button for completed
                  if (status == ProjectStatus.completed)
                    Container(
                      color: Colors.black.withValues(alpha: 0.2),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
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
                    ),
                  
                  // Duration badge
                  if (duration != null)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          duration!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge & menu
                  Row(
                    children: [
                      _StatusBadge(status: status),
                      const Spacer(),
                      Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondaryDark,
                        size: 20,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Progress bar or status text
                  if (status == ProjectStatus.generating && progress != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        Text(
                          '${(progress! * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.slate700,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(
                          status == ProjectStatus.completed
                              ? Icons.calendar_today
                              : Icons.schedule,
                          size: 14,
                          color: AppColors.textSecondaryDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        if (showShareButton) ...[
                          const Spacer(),
                          Icon(
                            Icons.share,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String text;
    bool showPulse = false;

    switch (status) {
      case ProjectStatus.generating:
        bgColor = AppColors.primary.withValues(alpha: 0.2);
        textColor = AppColors.primary;
        text = 'Generating';
        showPulse = true;
      case ProjectStatus.draft:
        bgColor = AppColors.slate700;
        textColor = AppColors.slate300;
        text = 'Draft';
      case ProjectStatus.completed:
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        text = 'Completed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPulse) ...[
            _PulseDot(),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 8,
      height: 8,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(2, 2),
                duration: 1000.ms,
              )
              .fadeOut(duration: 1000.ms),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
