import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/video_cache_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/optimized_video_cover.dart';
import '../../../video/data/models/wiro_effect_type.dart';
import '../../../video/data/models/wiro_model_type.dart';

/// Home Screen - Effect Discovery & Spotlight
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Curated effect collections with badges
  late final List<_EffectCollection> _collections;
  late final List<_FeaturedEffect> _heroEffects;
  
  final PageController _heroPageController = PageController(viewportFraction: 0.92);

  @override
  void initState() {
    super.initState();
    _collections = _buildCollections();
    _heroEffects = _buildHeroEffects();
    
    // Preload videos in the background for smooth playback
    _preloadVideos();
  }

  /// Preload hero and first collection videos
  Future<void> _preloadVideos() async {
    final urlsToPreload = <String>[];

    // Add hero effect URLs
    for (final featured in _heroEffects) {
      final url = _getEffectCoverUrl(featured);
      if (url != null) {
        urlsToPreload.add(url);
      }
    }

    // Add first two collections' effect URLs
    for (var i = 0; i < 2 && i < _collections.length; i++) {
      for (final featured in _collections[i].effects.take(5)) {
        final url = _getEffectCoverUrl(featured);
        if (url != null) {
          urlsToPreload.add(url);
        }
      }
    }

    // Preload in background
    VideoPreloader.preloadAll(urlsToPreload);
  }

  String? _getEffectCoverUrl(_FeaturedEffect featured) {
    final effect = featured.effect;
    final model = featured.model;

    String effectValue;
    if (effect is WiroProductAdsEffect) {
      effectValue = effect.value;
    } else if (effect is WiroTextAnimationEffect) {
      effectValue = effect.value;
    } else if (effect is WiroProductCaptionEffect) {
      effectValue = effect.value;
    } else if (effect is WiroProductLogoEffect) {
      effectValue = effect.value;
    } else {
      return null;
    }

    return model.getCoverUrl(effectValue);
  }

  List<_FeaturedEffect> _buildHeroEffects() {
    return [
      const _FeaturedEffect(
        effect: WiroProductAdsEffect.smokyPedestal,
        model: WiroModelType.productAds,
        badge: EffectBadge.viral,
      ),
      const _FeaturedEffect(
        effect: WiroProductAdsEffect.liquidGold,
        model: WiroModelType.productAds,
        badge: EffectBadge.trending,
      ),
      const _FeaturedEffect(
        effect: WiroTextAnimationEffect.shopWindowNeon,
        model: WiroModelType.textAnimations,
        badge: EffectBadge.hot,
      ),
      const _FeaturedEffect(
        effect: WiroProductAdsEffect.helicopterToCity,
        model: WiroModelType.productAds,
        badge: EffectBadge.viral,
      ),
      const _FeaturedEffect(
        effect: WiroProductCaptionEffect.blackFridayClawMachine,
        model: WiroModelType.productAdsWithCaption,
        badge: EffectBadge.trending,
      ),
    ];
  }

  List<_EffectCollection> _buildCollections() {
    return [
      // Featured / Hero Section
      const _EffectCollection(
        title: '🔥 Trending Now',
        subtitle: 'Most popular effects this week',
        effects: [
          _FeaturedEffect(
            effect: WiroProductAdsEffect.smokyPedestal,
            model: WiroModelType.productAds,
            badge: EffectBadge.viral,
          ),
          _FeaturedEffect(
            effect: WiroProductAdsEffect.liquidGold,
            model: WiroModelType.productAds,
            badge: EffectBadge.trending,
          ),
          _FeaturedEffect(
            effect: WiroTextAnimationEffect.shopWindowNeon,
            model: WiroModelType.textAnimations,
            badge: EffectBadge.hot,
          ),
          _FeaturedEffect(
            effect: WiroProductAdsEffect.goldenFireworks,
            model: WiroModelType.productAds,
            badge: EffectBadge.trending,
          ),
          _FeaturedEffect(
            effect: WiroProductCaptionEffect.blackFridayClawMachine,
            model: WiroModelType.productAdsWithCaption,
            badge: EffectBadge.viral,
          ),
        ],
      ),

      // New arrivals
      const _EffectCollection(
        title: '✨ New This Week',
        subtitle: 'Fresh effects just added',
        effects: [
          _FeaturedEffect(
            effect: WiroProductAdsEffect.clawMachine,
            model: WiroModelType.productAds,
            badge: EffectBadge.newBadge,
          ),
          _FeaturedEffect(
            effect: WiroProductLogoEffect.goldenStorefrontLogo,
            model: WiroModelType.productAdsWithLogo,
            badge: EffectBadge.newBadge,
          ),
          _FeaturedEffect(
            effect: WiroTextAnimationEffect.candyLand,
            model: WiroModelType.textAnimations,
            badge: EffectBadge.newBadge,
          ),
          _FeaturedEffect(
            effect: WiroProductAdsEffect.veniceBoat,
            model: WiroModelType.productAds,
            badge: EffectBadge.newBadge,
          ),
        ],
      ),

      // Scene Morphs collection
      const _EffectCollection(
        title: '🎬 Cinematic Morphs',
        subtitle: 'Transform your product into epic scenes',
        effects: [
          _FeaturedEffect(
            effect: WiroProductAdsEffect.helicopterToCity,
            model: WiroModelType.productAds,
            badge: EffectBadge.hot,
          ),
          _FeaturedEffect(
            effect: WiroProductAdsEffect.fireAndIce,
            model: WiroModelType.productAds,
            badge: EffectBadge.viral,
          ),
          _FeaturedEffect(
            effect: WiroProductAdsEffect.rocketToSpace,
            model: WiroModelType.productAds,
          ),
          _FeaturedEffect(
            effect: WiroProductAdsEffect.underwaterToSky,
            model: WiroModelType.productAds,
          ),
          _FeaturedEffect(
            effect: WiroProductAdsEffect.desertToJungleMorph,
            model: WiroModelType.productAds,
          ),
        ],
      ),

      // 3D Text collection
      const _EffectCollection(
        title: '🔤 3D Text Magic',
        subtitle: 'Stunning animated text effects',
        effects: [
          _FeaturedEffect(
            effect: WiroTextAnimationEffect.glossyHeliumBalloons,
            model: WiroModelType.textAnimations,
            badge: EffectBadge.trending,
          ),
          _FeaturedEffect(
            effect: WiroTextAnimationEffect.goldenBalloonsConfetti,
            model: WiroModelType.textAnimations,
            badge: EffectBadge.hot,
          ),
          _FeaturedEffect(
            effect: WiroTextAnimationEffect.rainyCityStreet,
            model: WiroModelType.textAnimations,
          ),
          _FeaturedEffect(
            effect: WiroTextAnimationEffect.dreamyCloudsGradientSky,
            model: WiroModelType.textAnimations,
          ),
          _FeaturedEffect(
            effect: WiroTextAnimationEffect.redNeonStreetNight,
            model: WiroModelType.textAnimations,
          ),
        ],
      ),

      // Surreal staging
      const _EffectCollection(
        title: '🌈 Surreal & Creative',
        subtitle: 'Make your product stand out',
        effects: [
          _FeaturedEffect(
            effect: WiroProductAdsEffect.makeItBig,
            model: WiroModelType.productAds,
            badge: EffectBadge.viral,
          ),
          _FeaturedEffect(
            effect: WiroProductAdsEffect.tinyProductHeld,
            model: WiroModelType.productAds,
            badge: EffectBadge.trending,
          ),
          _FeaturedEffect(
            effect: WiroProductAdsEffect.productInABottle,
            model: WiroModelType.productAds,
          ),
          _FeaturedEffect(
            effect: WiroProductAdsEffect.objectCarousel,
            model: WiroModelType.productAds,
          ),
          _FeaturedEffect(
            effect: WiroProductAdsEffect.balloonsProduct,
            model: WiroModelType.productAds,
          ),
        ],
      ),

      // Seasonal - Christmas
      const _EffectCollection(
        title: '🎄 Holiday Specials',
        subtitle: 'Perfect for the festive season',
        effects: [
          _FeaturedEffect(
            effect: WiroProductAdsEffect.christmasSnowGlobe,
            model: WiroModelType.productAds,
            badge: EffectBadge.hot,
          ),
          _FeaturedEffect(
            effect: WiroProductAdsEffect.christmasTrain,
            model: WiroModelType.productAds,
          ),
          _FeaturedEffect(
            effect: WiroProductCaptionEffect.holidayCard,
            model: WiroModelType.productAdsWithCaption,
          ),
          _FeaturedEffect(
            effect: WiroProductAdsEffect.winterChariot,
            model: WiroModelType.productAds,
          ),
          _FeaturedEffect(
            effect: WiroProductCaptionEffect.lettersToSanta,
            model: WiroModelType.productAdsWithCaption,
          ),
        ],
      ),

      // Logo effects
      const _EffectCollection(
        title: '🏷️ Brand & Logo',
        subtitle: 'Showcase your brand identity',
        effects: [
          _FeaturedEffect(
            effect: WiroProductLogoEffect.billboardPanelInUrbanStreetWithLogo,
            model: WiroModelType.productAdsWithLogo,
            badge: EffectBadge.trending,
          ),
          _FeaturedEffect(
            effect: WiroProductLogoEffect.massiveProductWithSkyPlaneBanner,
            model: WiroModelType.productAdsWithLogo,
          ),
          _FeaturedEffect(
            effect: WiroProductLogoEffect.surrealObjectLogoOnBus,
            model: WiroModelType.productAdsWithLogo,
          ),
          _FeaturedEffect(
            effect: WiroProductLogoEffect.logoInCappuccinoWithObject,
            model: WiroModelType.productAdsWithLogo,
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _heroPageController.dispose();
    super.dispose();
  }

  void _onEffectTap(_FeaturedEffect featured) {
    final effectValue = _getEffectValue(featured.effect);
    final effectLabel = _getEffectLabel(featured.effect);

    context.push(
      '/effect-detail',
      extra: {
        'modelType': featured.model,
        'effectType': effectValue,
        'effectLabel': effectLabel,
      },
    );
  }

  String _getEffectValue(dynamic effect) {
    if (effect is WiroProductAdsEffect) return effect.value;
    if (effect is WiroTextAnimationEffect) return effect.value;
    if (effect is WiroProductCaptionEffect) return effect.value;
    if (effect is WiroProductLogoEffect) return effect.value;
    return '';
  }

  String _getEffectLabel(dynamic effect) {
    if (effect is WiroProductAdsEffect) return effect.label;
    if (effect is WiroTextAnimationEffect) return effect.label;
    if (effect is WiroProductCaptionEffect) return effect.label;
    if (effect is WiroProductLogoEffect) return effect.label;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.backgroundDark,
            elevation: 0,
            toolbarHeight: 70,
            title: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF00D9FF), // Electric Cyan
                  Color(0xFF00FF88), // Neon Green
                ],
              ).createShader(bounds),
              child: Text(
                'ProdVid',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
              ),
            ),
            actions: const [
              // Credits badge
              _CreditsBadge(credits: 150),
              SizedBox(width: 16),
            ],
          ),

          // Hero section
          SliverToBoxAdapter(
            child: _buildHeroSection(),
          ),

          // Effect collections
          ..._collections.asMap().entries.map((entry) {
            final index = entry.key;
            final collection = entry.value;
            return SliverToBoxAdapter(
              child: _buildCollectionSection(collection, index),
            );
          }),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
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
            'Create Video',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Bottom navigation
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            context.go('/templates');
          } else if (index == 2) {
            context.go('/profile');
          }
        },
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
      child: SizedBox(
        height: 230,
        child: PageView.builder(
          controller: _heroPageController,
          clipBehavior: Clip.none,
          itemCount: _heroEffects.length,
          itemBuilder: (context, index) {
            final featured = _heroEffects[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(3, 0, 3, 10),
              child: _HeroEffectCard(
                key: ValueKey('hero_${_getEffectValue(featured.effect)}'),
                featured: featured,
                onTap: () => _onEffectTap(featured),
              ),
            );
          },
        ),
      ).animate().fadeIn(duration: 400.ms).scale(
            begin: const Offset(0.95, 0.95),
          ),
    );
  }

  Widget _buildCollectionSection(_EffectCollection collection, int sectionIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      collection.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.go('/templates'),
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 100 * sectionIndex),
                duration: 400.ms,
              ),

          const SizedBox(height: 6),

          // Horizontal carousel
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: collection.effects.length,
              itemBuilder: (context, index) {
                final featured = collection.effects[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < collection.effects.length - 1 ? 6 : 0,
                  ),
                  child: _EffectCarouselCard(
                    key: ValueKey('${collection.title}_${_getEffectValue(featured.effect)}'),
                    featured: featured,
                    onTap: () => _onEffectTap(featured),
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 100 * sectionIndex + 50 * index),
                      duration: 400.ms,
                    )
                    .slideX(begin: 0.2);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MODELS
// =============================================================================

enum EffectBadge {
  viral('VIRAL', Color(0xFFFF4757), Icons.local_fire_department),
  trending('TREND', Color(0xFFFFBE0B), Icons.trending_up),
  hot('HOT', Color(0xFFFF6B6B), Icons.whatshot),
  newBadge('NEW', Color(0xFF00D9FF), Icons.auto_awesome);

  const EffectBadge(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;
}

/// Credits badge widget for app bar
class _CreditsBadge extends StatelessWidget {
  const _CreditsBadge({required this.credits});

  final int credits;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to credits/subscription page
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFD700).withValues(alpha: 0.15),
              const Color(0xFFFFAA00).withValues(alpha: 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Coin icon with glow
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFD700), Color(0xFFFFAA00)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '⚡',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$credits',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFFD700),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.add_circle,
              size: 16,
              color: const Color(0xFFFFD700).withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _EffectCollection {
  const _EffectCollection({
    required this.title,
    required this.subtitle,
    required this.effects,
  });

  final String title;
  final String subtitle;
  final List<_FeaturedEffect> effects;
}

class _FeaturedEffect {
  const _FeaturedEffect({
    required this.effect,
    required this.model,
    this.badge,
  });

  final dynamic effect;
  final WiroModelType model;
  final EffectBadge? badge;
}

// =============================================================================
// WIDGETS
// =============================================================================

/// Hero card for featured effect - OPTIMIZED
class _HeroEffectCard extends StatelessWidget {
  const _HeroEffectCard({
    required this.featured,
    required this.onTap,
    super.key,
  });

  final _FeaturedEffect featured;
  final VoidCallback onTap;

  String? _getCoverUrl() {
    final effect = featured.effect;
    final model = featured.model;

    String effectValue;
    if (effect is WiroProductAdsEffect) {
      effectValue = effect.value;
    } else if (effect is WiroTextAnimationEffect) {
      effectValue = effect.value;
    } else if (effect is WiroProductCaptionEffect) {
      effectValue = effect.value;
    } else if (effect is WiroProductLogoEffect) {
      effectValue = effect.value;
    } else {
      return null;
    }

    return model.getCoverUrl(effectValue);
  }

  String _getEffectLabel() {
    final effect = featured.effect;
    if (effect is WiroProductAdsEffect) return effect.label;
    if (effect is WiroTextAnimationEffect) return effect.label;
    if (effect is WiroProductCaptionEffect) return effect.label;
    if (effect is WiroProductLogoEffect) return effect.label;
    return '';
  }

  String _getEffectValue() {
    final effect = featured.effect;
    if (effect is WiroProductAdsEffect) return effect.value;
    if (effect is WiroTextAnimationEffect) return effect.value;
    if (effect is WiroProductCaptionEffect) return effect.value;
    if (effect is WiroProductLogoEffect) return effect.value;
    return '';
  }

  List<Color> _getNeonGradient() {
    switch (featured.model) {
      case WiroModelType.textAnimations:
        return [const Color(0xFF00D9FF), const Color(0xFF00FF88)];
      case WiroModelType.productAds:
        return [const Color(0xFFFF6B6B), const Color(0xFFFFBE0B)];
      case WiroModelType.productAdsWithCaption:
        return [const Color(0xFF00D9FF), const Color(0xFF4FACFE)];
      case WiroModelType.productAdsWithLogo:
        return [const Color(0xFF00FF88), const Color(0xFF00D9FF)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = _getCoverUrl();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D9FF).withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Optimized video background
              if (coverUrl != null)
                OptimizedVideoCover(
                  videoUrl: coverUrl,
                  uniqueId: 'hero_${featured.model.name}_${_getEffectValue()}',
                  fallbackGradient: _getNeonGradient(),
                  borderRadius: 0,
                )
              else
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _getNeonGradient(),
                    ),
                  ),
                ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),

              // Badge
              if (featured.badge != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: featured.badge!.color,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: featured.badge!.color.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          featured.badge!.icon,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          featured.badge!.label,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Content
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        featured.model.label,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getEffectLabel(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00D9FF), Color(0xFF00FF88)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00D9FF).withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow, size: 18, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Try Now',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
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
    );
  }
}

/// Carousel card for effect - OPTIMIZED to use VideoPlayerManager
class _EffectCarouselCard extends StatelessWidget {
  const _EffectCarouselCard({
    required this.featured,
    required this.onTap,
    super.key,
  });

  final _FeaturedEffect featured;
  final VoidCallback onTap;

  String? _getCoverUrl() {
    final effect = featured.effect;
    final model = featured.model;

    String effectValue;
    if (effect is WiroProductAdsEffect) {
      effectValue = effect.value;
    } else if (effect is WiroTextAnimationEffect) {
      effectValue = effect.value;
    } else if (effect is WiroProductCaptionEffect) {
      effectValue = effect.value;
    } else if (effect is WiroProductLogoEffect) {
      effectValue = effect.value;
    } else {
      return null;
    }

    return model.getCoverUrl(effectValue);
  }

  String _getEffectLabel() {
    final effect = featured.effect;
    if (effect is WiroProductAdsEffect) return effect.label;
    if (effect is WiroTextAnimationEffect) return effect.label;
    if (effect is WiroProductCaptionEffect) return effect.label;
    if (effect is WiroProductLogoEffect) return effect.label;
    return '';
  }

  String _getEffectValue() {
    final effect = featured.effect;
    if (effect is WiroProductAdsEffect) return effect.value;
    if (effect is WiroTextAnimationEffect) return effect.value;
    if (effect is WiroProductCaptionEffect) return effect.value;
    if (effect is WiroProductLogoEffect) return effect.value;
    return '';
  }

  List<Color> _getGradient() {
    switch (featured.model) {
      case WiroModelType.textAnimations:
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
      case WiroModelType.productAds:
        return [const Color(0xFFf093fb), const Color(0xFFf5576c)];
      case WiroModelType.productAdsWithCaption:
        return [const Color(0xFF4facfe), const Color(0xFF00f2fe)];
      case WiroModelType.productAdsWithLogo:
        return [const Color(0xFF43e97b), const Color(0xFF38f9d7)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = _getCoverUrl();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
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
              // Optimized video cover using global player pool
              if (coverUrl != null)
                OptimizedVideoCover(
                  videoUrl: coverUrl,
                  uniqueId: 'carousel_${featured.model.name}_${_getEffectValue()}',
                  fallbackGradient: _getGradient(),
                  borderRadius: 0,
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
                ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),

              // Badge
              if (featured.badge != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: featured.badge!.color,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: featured.badge!.color.withValues(alpha: 0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          featured.badge!.icon,
                          size: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          featured.badge!.label,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Title
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Text(
                  _getEffectLabel(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Play icon hint
              Positioned(
                left: 10,
                bottom: 42,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

