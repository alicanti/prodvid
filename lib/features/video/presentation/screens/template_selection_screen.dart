import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../data/models/wiro_effect_type.dart';
import '../../data/models/wiro_model_type.dart';

/// Video template selection screen with Wiro models and effects
class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});

  @override
  State<TemplateSelectionScreen> createState() =>
      _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  // Selected model type (top tabs)
  WiroModelType _selectedModel = WiroModelType.productAds;

  // Selected category within model (filter chips)
  String? _selectedCategory;

  // Search query
  String _searchQuery = '';

  // Get effects for the selected model
  List<EffectOption> get _filteredEffects {
    var effects = WiroEffects.getEffectsForModel(_selectedModel);

    // Filter by category if selected
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      effects =
          effects.where((e) => e.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      effects = effects
          .where(
            (e) => e.label.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return effects;
  }

  // Get unique categories for the selected model
  List<String> get _categories {
    final effects = WiroEffects.getEffectsForModel(_selectedModel);
    final categories = effects
        .where((e) => e.category != null)
        .map((e) => e.category!)
        .toSet()
        .toList();
    return ['All', ...categories];
  }

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
                border: Border(bottom: BorderSide(color: AppColors.borderDark)),
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
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Model Type Tabs
          _buildModelTabs(),

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
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search effects...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondaryDark,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: Icon(Icons.close, color: AppColors.textSecondaryDark),
                    ),
                ],
              ),
            ),
          ),

          // Category Filter Chips (only for models with categories)
          if (_categories.length > 1) _buildCategoryChips(),

          const SizedBox(height: 8),

          // Effect count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_filteredEffects.length} effects',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Effects grid
          Expanded(
            child: _filteredEffects.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _filteredEffects.length,
                    itemBuilder: (context, index) {
                      final effect = _filteredEffects[index];
                      return _EffectCard(
                            effect: effect,
                            index: index,
                            modelType: _selectedModel,
                            onTap: () => _onEffectSelected(effect),
                          )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: 50 * (index % 6)),
                            duration: 300.ms,
                          )
                          .scale(begin: const Offset(0.95, 0.95));
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1, // Effects tab
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 2) context.go('/profile');
        },
      ),
    );
  }

  Widget _buildModelTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: WiroModelType.values.map((model) {
            final isSelected = model == _selectedModel;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedModel = model;
                    _selectedCategory = null;
                    _searchQuery = '';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
                          )
                        : null,
                    color: isSelected ? null : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderDark,
                      width: isSelected ? 2 : 1,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getModelIcon(model),
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondaryDark,
                        size: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getModelShortName(model),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category ||
              (category == 'All' && _selectedCategory == null);
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category == 'All' ? null : category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primary : AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
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
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No effects found',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or category',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getModelIcon(WiroModelType model) {
    switch (model) {
      case WiroModelType.textAnimations:
        return Icons.text_fields;
      case WiroModelType.productAds:
        return Icons.image;
      case WiroModelType.productAdsWithCaption:
        return Icons.subtitles;
      case WiroModelType.productAdsWithLogo:
        return Icons.branding_watermark;
    }
  }

  String _getModelShortName(WiroModelType model) {
    switch (model) {
      case WiroModelType.textAnimations:
        return '3D Text';
      case WiroModelType.productAds:
        return 'Product';
      case WiroModelType.productAdsWithCaption:
        return 'Caption';
      case WiroModelType.productAdsWithLogo:
        return 'Logo';
    }
  }

  void _onEffectSelected(EffectOption effect) {
    // Navigate to creation with selected effect and model type
    context.push('/create', extra: {
      'modelType': _selectedModel,
      'effectType': effect.value,
      'effectLabel': effect.label,
    });
  }
}

class _EffectCard extends StatelessWidget {
  const _EffectCard({
    required this.effect,
    required this.index,
    required this.modelType,
    required this.onTap,
  });

  final EffectOption effect;
  final int index;
  final WiroModelType modelType;
  final VoidCallback onTap;

  // Gradients for different effect categories
  List<Color> _getGradient() {
    final category = effect.category ?? '';
    
    // Text Animations
    if (category.isEmpty && modelType == WiroModelType.textAnimations) {
      return [const Color(0xFF667eea), const Color(0xFF764ba2)];
    }
    
    // Product Ads categories
    if (category.contains('Animate')) {
      return [const Color(0xFF00f2fe), const Color(0xFF4facfe)];
    }
    if (category.contains('Scene')) {
      return [const Color(0xFFf5af19), const Color(0xFFf12711)];
    }
    if (category.contains('Surreal')) {
      return [const Color(0xFFa18cd1), const Color(0xFFfbc2eb)];
    }
    if (category.contains('Model')) {
      return [const Color(0xFF667eea), const Color(0xFF764ba2)];
    }
    if (category.contains('Christmas')) {
      return [const Color(0xFF11998e), const Color(0xFF38ef7d)];
    }
    if (category.contains('Black Friday')) {
      return [const Color(0xFF232526), const Color(0xFF414345)];
    }
    if (category.contains('Text')) {
      return [const Color(0xFFfa709a), const Color(0xFFfee140)];
    }
    
    // Logo effects
    if (modelType == WiroModelType.productAdsWithLogo) {
      return [const Color(0xFF2c3e50), const Color(0xFF4ca1af)];
    }

    // Default gradient based on index
    const gradients = [
      [Color(0xFFfa709a), Color(0xFFfee140)],
      [Color(0xFF00f2fe), Color(0xFF4facfe)],
      [Color(0xFF667eea), Color(0xFF764ba2)],
      [Color(0xFF2c3e50), Color(0xFF4ca1af)],
      [Color(0xFFffecd2), Color(0xFFfcb69f)],
      [Color(0xFF11998e), Color(0xFF38ef7d)],
    ];
    return gradients[index % gradients.length];
  }

  IconData _getIcon() {
    final label = effect.label.toLowerCase();
    
    if (label.contains('balloon')) return Icons.celebration;
    if (label.contains('neon')) return Icons.lightbulb;
    if (label.contains('water') || label.contains('splash')) return Icons.water_drop;
    if (label.contains('fire') || label.contains('hot')) return Icons.local_fire_department;
    if (label.contains('snow') || label.contains('winter')) return Icons.ac_unit;
    if (label.contains('christmas') || label.contains('santa')) return Icons.card_giftcard;
    if (label.contains('gold') || label.contains('golden')) return Icons.star;
    if (label.contains('smoke') || label.contains('mist')) return Icons.cloud;
    if (label.contains('car') || label.contains('road')) return Icons.directions_car;
    if (label.contains('city') || label.contains('urban')) return Icons.location_city;
    if (label.contains('beach') || label.contains('sea')) return Icons.beach_access;
    if (label.contains('model') || label.contains('studio')) return Icons.person;
    if (label.contains('text') || label.contains('font')) return Icons.text_fields;
    if (label.contains('logo') || label.contains('brand')) return Icons.branding_watermark;
    if (label.contains('billboard')) return Icons.dashboard;
    if (label.contains('confetti')) return Icons.celebration;
    if (label.contains('flower') || label.contains('petal')) return Icons.local_florist;
    
    return Icons.auto_awesome;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Effect Preview
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
                    // Gradient background
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _getGradient(),
                        ),
                      ),
                    ),

                    // Icon
                    Center(
                      child: Icon(
                        _getIcon(),
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),

                    // Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),

                    // Category badge
                    if (effect.category != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getCategoryShortName(effect.category!),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                    // Play icon overlay
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Effect title
          Text(
            effect.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getCategoryShortName(String category) {
    if (category.contains('Animate')) return 'ANIMATE';
    if (category.contains('Scene')) return 'SCENE';
    if (category.contains('Surreal')) return 'SURREAL';
    if (category.contains('Model')) return 'MODEL';
    if (category.contains('Christmas')) return 'XMAS';
    if (category.contains('Black Friday')) return 'SALE';
    if (category.contains('Text')) return 'TEXT';
    return category.toUpperCase().substring(0, category.length.clamp(0, 6));
  }
}
