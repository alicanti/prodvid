import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/video_cache_service.dart';
import '../../../../core/theme/app_colors.dart';
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
  
  final PageController _heroPageController = PageController();
  Timer? _autoScrollTimer;
  int _currentHeroPage = 0;

  @override
  void initState() {
    super.initState();
    _collections = _buildCollections();
    _heroEffects = _buildHeroEffects();
    
    // Preload videos in the background for smooth playback
    _preloadVideos();
    
    // Start auto-scroll timer (every 2 seconds)
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_heroPageController.hasClients) {
        _currentHeroPage = (_currentHeroPage + 1) % _heroEffects.length;
        _heroPageController.animateToPage(
          _currentHeroPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _heroPageController.dispose();
    super.dispose();
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
    // Calculate hero height as half of screen height
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = screenHeight * 0.5;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const overlapHeight = 30.0; // 10px padding below slider

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Hero Slider as Sliver
          SliverToBoxAdapter(
            child: SizedBox(
              height: heroHeight,
              child: _buildHeroSlider(heroHeight),
            ),
          ),
        ],
        body: Transform.translate(
          offset: const Offset(0, -overlapHeight),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 28),
                  ..._collections.map((collection) {
                    final index = _collections.indexOf(collection);
                    return _buildCollectionSection(collection, index);
                  }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
      // Fixed AppBar overlay
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          padding: EdgeInsets.only(
            top: statusBarHeight + 8,
            left: 16,
            right: 16,
            bottom: 8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF00D9FF),
                    Color(0xFF00FF88),
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
              const _CreditsBadge(credits: 150),
            ],
          ),
        ),
      ),

      // Nav bar provided by MainShell
      extendBody: true,
    );
  }

  Widget _buildHeroSlider(double height) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: PageView.builder(
        controller: _heroPageController,
        itemCount: _heroEffects.length,
        itemBuilder: (context, index) {
          final featured = _heroEffects[index];
          return _FullscreenHeroCard(
            key: ValueKey('hero_${_getEffectValue(featured.effect)}'),
            featured: featured,
            onTap: () => _onEffectTap(featured),
          );
        },
      ),
    );
  }

  Widget _buildCollectionSection(_EffectCollection collection, int sectionIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header - title only, no subtitle
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 8, 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  collection.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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

/// Fullscreen hero card for slider - covers entire top half
class _FullscreenHeroCard extends StatelessWidget {
  const _FullscreenHeroCard({
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
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fullscreen video background
          if (coverUrl != null)
            OptimizedVideoCover(
              videoUrl: coverUrl,
              uniqueId: 'hero_fullscreen_${featured.model.name}_${_getEffectValue()}',
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

          // Top gradient for ProdVid logo area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Content at bottom - as low as possible
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Model type tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    featured.model.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Effect name
                Text(
                  _getEffectLabel(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 14),
                // Try Now button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00D9FF), Color(0xFF00FF88)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D9FF).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow, size: 22, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Try Now',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ],
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

