import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/optimized_video_cover.dart';
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

  // Get effects for the selected model
  List<EffectOption> get _filteredEffects {
    var effects = WiroEffects.getEffectsForModel(_selectedModel);

    // Filter by category if selected
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      effects =
          effects.where((e) => e.category == _selectedCategory).toList();
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF00D9FF), Color(0xFF00FF88)],
                          ).createShader(bounds),
                          child: Text(
                            'Effects',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          '${_filteredEffects.length} templates available',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Model Type Tabs
          _buildModelTabs(),

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
                  style: const TextStyle(
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
                            key: ValueKey('${_selectedModel.name}_${effect.value}'),
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
      // Nav bar provided by MainShell
      extendBody: true,
    );
  }

  Widget _buildModelTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: WiroModelType.values.map((model) {
          final isSelected = model == _selectedModel;
          final colors = _getModelColors(model);
          final isLast = model == WiroModelType.values.last;
          
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedModel = model;
                  _selectedCategory = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: colors,
                        )
                      : null,
                  color: isSelected ? null : const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? colors.first.withOpacity(0.5)
                        : Colors.white.withOpacity(0.08),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.first.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon container
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white.withOpacity(0.2)
                            : colors.first.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getModelIcon(model),
                        color: isSelected
                            ? Colors.white
                            : colors.first,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Text
                    Text(
                      _getModelShortName(model),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Color> _getModelColors(WiroModelType model) {
    switch (model) {
      case WiroModelType.textAnimations:
        return [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]; // Red-Orange
      case WiroModelType.productAds:
        return [const Color(0xFF00D9FF), const Color(0xFF00FF88)]; // Cyan-Green
      case WiroModelType.productAdsWithCaption:
        return [const Color(0xFFBB86FC), const Color(0xFF6C63FF)]; // Purple
      case WiroModelType.productAdsWithLogo:
        return [const Color(0xFFFFBE0B), const Color(0xFFFF9500)]; // Yellow-Orange
    }
  }

  String _getModelEffectCount(WiroModelType model) {
    final count = WiroEffects.getEffectsForModel(model).length;
    return '$count effects';
  }

  Widget _buildCategoryChips() {
    final colors = _getModelColors(_selectedModel);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category ||
              (category == 'All' && _selectedCategory == null);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
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
                  gradient: isSelected
                      ? LinearGradient(colors: colors)
                      : null,
                  color: isSelected ? null : const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? colors.first.withOpacity(0.5)
                        : Colors.white.withOpacity(0.1),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors.first.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.6),
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
          const Text(
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
    // Navigate to effect detail page
    context.push('/effect-detail', extra: {
      'modelType': _selectedModel,
      'effectType': effect.value,
      'effectLabel': effect.label,
    });
  }
}

/// Optimized effect card that only loads video when visible
/// Uses global video player pool to limit RAM usage
class _EffectCard extends StatelessWidget {
  const _EffectCard({
    required this.effect,
    required this.index,
    required this.modelType,
    required this.onTap,
    super.key,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Effect Preview - uses optimized video cover
          Expanded(
            child: DecoratedBox(
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
                    // Optimized video cover with visibility detection
                    if (effect.coverUrl != null)
                      OptimizedVideoCover(
                        videoUrl: effect.coverUrl!,
                        uniqueId: '${modelType.name}_${effect.value}',
                        fallbackGradient: _getGradient(),
                        borderRadius: 0, // Already clipped by parent
                      )
                    else
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _getGradient(),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.auto_awesome,
                            size: 36,
                            color: Colors.white.withValues(alpha: 0.6),
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
                            color: Colors.black.withValues(alpha: 0.6),
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
}
