import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';

/// Video template selection screen matching Stitch design - video_template_selection
class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Motion', 'Background', 'Lighting', '3D'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          // App Bar
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withValues(alpha: 0.95),
                border: Border(
                  bottom: BorderSide(color: AppColors.borderDark),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      'Select AI Effect',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: AppColors.textSecondaryDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search effects...',
                        hintStyle: TextStyle(color: AppColors.textSecondaryDark),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.tune, color: AppColors.textSecondaryDark),
                  ),
                ],
              ),
            ),
          ),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _filters.asMap().entries.map((entry) {
                final isSelected = entry.key == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = entry.key;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(9999),
                        border: isSelected ? null : Border.all(color: Colors.transparent),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Templates grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return _TemplateCard(
                  template: template,
                  onTap: () {
                    // Navigate to creation with selected template
                    context.push('/create', extra: template);
                  },
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 100 * index),
                  duration: 400.ms,
                ).scale(begin: const Offset(0.95, 0.95));
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 2) context.push('/profile');
        },
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.onTap,
  });

  final EffectTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      template.imageUrl,
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
                    
                    // Hover overlay
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                    
                    // Badge
                    if (template.badge != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: template.badge == 'Hot'
                                ? AppColors.primary.withValues(alpha: 0.9)
                                : Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            template.badge!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    
                    // Magic icon on hover
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Title
          Text(
            template.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          // Description
          Text(
            template.description,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryDark,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class EffectTemplate {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? badge;
  final String aspectRatio;

  const EffectTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.badge,
    this.aspectRatio = '9:16',
  });
}

final List<EffectTemplate> _templates = [
  EffectTemplate(
    id: '1',
    title: 'Pop Art Burst',
    description: 'Vibrant colors & energetic motion',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCL6LERr702l_JwUxOTR2_DAt-BWJ_P2pFHZF_1PG3d5N7-ilAfRyptXclbgeQ7KvOkbX55bFz5Dj2gJxZwtCgmNw2gRzfJ1_xcqLkgAco6Qbgv1gBUlH4h00n019AjqiwrbmHTEkdfGyYusnTO5dLeDHGzcagBW0YVdv7t3Wgd3wzsZ0QnqQhQtP_d21M7GH0Dpv36SE_OAq4r6njxLJn_hxYj3o7wACIrRMMNz6fC7zjegFrzFYnxrdnz7Zrzb_JwXSgZFLEUWxM',
    badge: 'New',
  ),
  EffectTemplate(
    id: '2',
    title: 'Clean Studio',
    description: 'Professional white backdrop focus',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCYjVAdmHwiXImqbQ2oPayYJxRnt3CIzILFGbSoIXKhgzhgA5_U0Jnk22Rt9yjuA24eMkKzJna7eTDiE5qv8NFLyAbLmXSaejnyqvKowzVB_xSEezL2xm-wL2hFjKIdUWM94YqaCe6OYx7xM4yOFBKQ2_DiM5g7TeprYQ0siH310cy7Dvl6GA4TOrsSiTRcUkn6OaaRiTvRsJh34t1KtU4BI-yTQ3AzKny76ZN2G7EBfO3lZwsJ0Yt_REO6tlxitTiL-qU9DVE8wAE',
    aspectRatio: '1:1',
  ),
  EffectTemplate(
    id: '3',
    title: 'Glitch Motion',
    description: 'Modern digital distortion effect',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuATDM-6OnWxPee_NRMFZobId3-Tdza2L6O776Mu2YeRG4RNyRDbq3snlHd9QJIKOQlIwFb9c3eJe5JQkd6xq3w888-X67DDsoF2KZdHwjcuhyHYkit6rTwr_Bu_CRxcb7pCVZAh_tbjoIVpbWLgh4eb80QCsDp1rVLc8xU6m7NQxa1zSIBxrifhk51Trkb9b7adkYRQsVybRMkCnVTeYnklB7v-S6W3_uYBVau6QuNglQoZw1Bxn4DxlcdoQf1zuuweFPoFrbyN8T0',
    badge: 'Hot',
  ),
  EffectTemplate(
    id: '4',
    title: 'Moody Shadows',
    description: 'Cinematic dark lighting setup',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDSUfi8Do35DzsUJnAAcXcxGFrzfIWwcccD1NpWhxUti9EDnU48HkcrAE2-4jWTRAzqdme4Zmljdd0XswYxE-NH-9eevmu1Qqprh6pShmzBo6DV-To1dbNz1d1lo81K4Fz2DAsW7n0BTqQJwhKKHsY5uVXRNwnuYWHqyDu3dvShEXWQnOCwuCi50hXFD166_U3eHe8kGL7doS6JuOTOcLt3zcMjiNs8VhP1p81JcLSXLkSr8O4LJ9bhj2KvTb6woO-WOBdBSo2PM2A',
    aspectRatio: '4:5',
  ),
  EffectTemplate(
    id: '5',
    title: 'Neon Cyber',
    description: 'Futuristic glowing edge outlines',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCRHETGWhJH4X3FoIEkpnk0UdDVjHk40NWq7m1o3FW0ByCeRF6jwztOmFl0fZtwxf1EokulLu7ZHApHCm3Wt6uaKWNDzC9j9EP5RClcoWMX-vI2QSNUFnVPXIepEugp-ZWMCALxRg91RUDCBq-DLckHw6rEtwJqDSzEALPzGmDdbDLpKqgffdX4J5Z5WIwhIkgbtDLBbf9Dn2ejMKKcVhz6_vCCm-QiYwtjsTc9NEgYKQrSRPXJojrJ1iV43tYub4LM3OBJrJjUIAs',
  ),
  EffectTemplate(
    id: '6',
    title: 'Sunlight Beam',
    description: 'Warm natural lighting overlay',
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDzl2rcD2JCrAJ9SEES2bs1Vl0MrqPnNSgcImfAUlLbccsFDd72R0UW5t-xe9ZziTZvKnTXzeBgfjXhNOwKKkCRWUjEHMdupDSdtH9ceUBFxNHZVWOedhAVzTJUW7IgLJgcggWRLbkixipynppvEEz-nzAGCWgjJ52VZUm17CtASD1B12rQP5KwZV2YgmjA_a-yH2Qkkcw-amJqnipS5Dzfd6KPkoBX3CAENTMuP_Ejn8AgKNDQW1-iMRI5E3vowlyvGAnd2b2E3kw',
    aspectRatio: '1:1',
  ),
];

