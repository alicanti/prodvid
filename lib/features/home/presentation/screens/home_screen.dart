import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/services/video_cache_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
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
  int _currentHeroPage = 0;

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
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover Effects',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                const SizedBox(height: 4),
                Text(
                  'Turn your products into viral videos',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: -0.1),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Hero Slider - with extra padding for glow effect
          SizedBox(
            height: 240, // Extra height for glow
            child: PageView.builder(
              controller: _heroPageController,
              clipBehavior: Clip.none, // Allow glow to overflow
              itemCount: _heroEffects.length,
              onPageChanged: (index) {
                setState(() {
                  _currentHeroPage = index;
                });
              },
              itemBuilder: (context, index) {
                final featured = _heroEffects[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 20), // Bottom padding for glow
                  child: _HeroEffectCard(
                    key: ValueKey('hero_${_getEffectValue(featured.effect)}'),
                    featured: featured,
                    onTap: () => _onEffectTap(featured),
                  ),
                );
              },
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms).scale(
                begin: const Offset(0.95, 0.95),
              ),

          const SizedBox(height: 16),

          // Page indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _heroEffects.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentHeroPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentHeroPage == index
                      ? const Color(0xFF00D9FF)
                      : AppColors.slate700,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: _currentHeroPage == index
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00D9FF).withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildCollectionSection(_EffectCollection collection, int sectionIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
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
                    const SizedBox(height: 2),
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

          const SizedBox(height: 12),

          // Horizontal carousel
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: collection.effects.length,
              itemBuilder: (context, index) {
                final featured = collection.effects[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < collection.effects.length - 1 ? 12 : 0,
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

/// Hero card for featured effect
class _HeroEffectCard extends StatefulWidget {
  const _HeroEffectCard({
    required this.featured, required this.onTap, super.key,
  });

  final _FeaturedEffect featured;
  final VoidCallback onTap;

  @override
  State<_HeroEffectCard> createState() => _HeroEffectCardState();
}

class _HeroEffectCardState extends State<_HeroEffectCard> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    final coverUrl = _getCoverUrl();
    if (coverUrl == null) return;

    try {
      // Use cached video player for better performance
      _controller = await CachedVideoPlayerController.create(coverUrl);
      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.setVolume(0);
      _controller!.play();

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Error initializing hero video: $e');
    }
  }

  String? _getCoverUrl() {
    final effect = widget.featured.effect;
    final model = widget.featured.model;

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
    final effect = widget.featured.effect;
    if (effect is WiroProductAdsEffect) return effect.label;
    if (effect is WiroTextAnimationEffect) return effect.label;
    if (effect is WiroProductCaptionEffect) return effect.label;
    if (effect is WiroProductLogoEffect) return effect.label;
    return '';
  }

  // Neon gradient for loading state
  List<Color> _getNeonGradient() {
    switch (widget.featured.model) {
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
    return GestureDetector(
      onTap: widget.onTap,
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
              // Video background
              if (_isInitialized && _controller != null)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
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
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size.infinite,
                        painter: _GridPatternPainter(),
                      ),
                      Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
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
              if (widget.featured.badge != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.featured.badge!.color,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: widget.featured.badge!.color.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.featured.badge!.icon,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.featured.badge!.label,
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
                    // Model type chip
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
                        widget.featured.model.label,
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

/// Carousel card for effect
class _EffectCarouselCard extends StatefulWidget {
  const _EffectCarouselCard({
    required this.featured, required this.onTap, super.key,
  });

  final _FeaturedEffect featured;
  final VoidCallback onTap;

  @override
  State<_EffectCarouselCard> createState() => _EffectCarouselCardState();
}

class _EffectCarouselCardState extends State<_EffectCarouselCard> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    final coverUrl = _getCoverUrl();
    if (coverUrl == null) {
      setState(() => _hasError = true);
      return;
    }

    try {
      // Use cached video player for better performance
      _controller = await CachedVideoPlayerController.create(coverUrl);
      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.setVolume(0);
      _controller!.play();

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  String? _getCoverUrl() {
    final effect = widget.featured.effect;
    final model = widget.featured.model;

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
    final effect = widget.featured.effect;
    if (effect is WiroProductAdsEffect) return effect.label;
    if (effect is WiroTextAnimationEffect) return effect.label;
    if (effect is WiroProductCaptionEffect) return effect.label;
    if (effect is WiroProductLogoEffect) return effect.label;
    return '';
  }

  List<Color> _getGradient() {
    final model = widget.featured.model;
    switch (model) {
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

  IconData _getIcon() {
    switch (widget.featured.model) {
      case WiroModelType.textAnimations:
        return Icons.text_fields;
      case WiroModelType.productAds:
        return Icons.shopping_bag;
      case WiroModelType.productAdsWithCaption:
        return Icons.subtitles;
      case WiroModelType.productAdsWithLogo:
        return Icons.branding_watermark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
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
              // Video or gradient background
              if (_isInitialized && !_hasError && _controller != null)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
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
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size.infinite,
                        painter: _GridPatternPainter(),
                      ),
                      Center(
                        child: _hasError
                            ? Icon(
                                _getIcon(),
                                size: 36,
                                color: Colors.white.withValues(alpha: 0.8),
                              )
                            : SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                      ),
                    ],
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
              if (widget.featured.badge != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: widget.featured.badge!.color,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: widget.featured.badge!.color.withValues(alpha: 0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.featured.badge!.icon,
                          size: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.featured.badge!.label,
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

/// Grid pattern painter for gradient backgrounds
class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    const double gridSize = 20;

    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
