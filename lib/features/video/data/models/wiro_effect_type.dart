import 'wiro_model_type.dart';

// =============================================================================
// 3D TEXT ANIMATIONS EFFECTS
// =============================================================================

/// Effect types for 3D Text Animations model
enum WiroTextAnimationEffect {
  silverBalloonsParis('titles-silver-balloons-paris', 'Silver Balloons Paris'),
  bubblegumLetters('titles-bubblegum-letters', 'Bubblegum Letters'),
  rainyCityStreet('titles-rainy-city-street', 'Rainy City Street'),
  inflatableLettersPool(
    'titles-inflatable-letters-pool',
    'Inflatable Letters Pool',
  ),
  shopWindowNeon('titles-shop-window-neon', 'Shop Window Neon'),
  glossyHeliumBalloons(
    'titles-glossy-helium-balloons',
    'Glossy Helium Balloons',
  ),
  goldenBalloonsConfetti(
    'titles-golden-balloons-confetti',
    'Golden Balloons Confetti',
  ),
  giftBox('titles-gift-box', 'Gift Box'),
  islandShapedText('titles-island-shaped-text', 'Island Shaped Text'),
  enveloppeBloomingFlowers(
    'titles-enveloppe-blooming-flowers',
    'Enveloppe Blooming Flowers',
  ),
  colorfulToyBlocks('titles-colorful-toy-blocks', 'Colorful Toy Blocks'),
  hangingTags('titles-hanging-tags', 'Hanging Tags'),
  watermelonSplash('titles-watermelon-splash', 'Watermelon Splash'),
  cookingIngredientsRusticTable(
    'titles-cooking-ingredients-rustic-table',
    'Cooking Ingredients Rustic Table',
  ),
  inflatedPastelLettersConfetti(
    'titles-inflated-pastel-letters-confetti',
    'Inflated Pastel Letters Confetti',
  ),
  birthdayCake('titles-birthday-cake', 'Birthday Cake'),
  goldScript('titles-gold-script', 'Gold Script'),
  pinkFurFloweredField(
    'titles-pink-fur-flowered-field',
    'Pink Fur Flowered Field',
  ),
  candyLand('titles-candy-land', 'Candy Land'),
  rockLettersBeachWaves(
    'titles-rock-letters-beach-waves',
    'Rock Letters Beach Waves',
  ),
  dreamyCloudsGradientSky(
    'titles-dreamy-clouds-gradient-sky',
    'Dreamy Clouds Gradient Sky',
  ),
  redNeonStreetNight('titles-red-neon-street-night', 'Red Neon Street Night');

  const WiroTextAnimationEffect(this.value, this.label);

  final String value;
  final String label;

  static WiroTextAnimationEffect? fromValue(String value) {
    try {
      return WiroTextAnimationEffect.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  static List<WiroTextAnimationEffect> get all =>
      WiroTextAnimationEffect.values.toList();
}

// =============================================================================
// PRODUCT ADS EFFECTS (also used by Product Ads with Caption/Logo)
// =============================================================================

/// All available Wiro Product Ads effect types
enum WiroProductAdsEffect {
  // Animate Products
  smokyPedestal(
    'animate-products-smoky-pedestal',
    'Smoky Pedestal',
    WiroProductAdsCategory.animateProducts,
  ),
  waterPetals(
    'animate-products-water-petals',
    'Water Petals',
    WiroProductAdsCategory.animateProducts,
  ),
  waterDarkElectricHues(
    'animate-products-water-dark-electric-hues',
    'Water Dark Electric Hues',
    WiroProductAdsCategory.animateProducts,
  ),
  snow('animate-products-snow', 'Snow', WiroProductAdsCategory.animateProducts),
  glitterSilver(
    'animate-products-glitter-silver',
    'Glitter Silver',
    WiroProductAdsCategory.animateProducts,
  ),
  rosesSmoke(
    'animate-products-roses-smoke',
    'Roses Smoke',
    WiroProductAdsCategory.animateProducts,
  ),
  carWarehouse(
    'animate-products-car-warehouse',
    'Car Warehouse',
    WiroProductAdsCategory.animateProducts,
  ),
  waterSplashesLight(
    'animate-products-water-splashes-light',
    'Water Splashes Light',
    WiroProductAdsCategory.animateProducts,
  ),
  fallingPetals(
    'animate-products-falling-petals',
    'Falling Petals',
    WiroProductAdsCategory.animateProducts,
  ),
  liquidGold(
    'animate-products-liquid-gold',
    'Liquid Gold',
    WiroProductAdsCategory.animateProducts,
  ),
  oilBubbles(
    'animate-products-oil-bubbles',
    'Oil Bubbles',
    WiroProductAdsCategory.animateProducts,
  ),
  goldenFireworks(
    'animate-products-golden-fireworks',
    'Golden Fireworks',
    WiroProductAdsCategory.animateProducts,
  ),
  ledStrips(
    'animate-products-led-strips',
    'Led Strips',
    WiroProductAdsCategory.animateProducts,
  ),
  waterFruitsSplash(
    'animate-products-water-fruits-splash',
    'Water Fruits Splash',
    WiroProductAdsCategory.animateProducts,
  ),
  smokeReveal(
    'animate-products-smoke-reveal',
    'Smoke Reveal',
    WiroProductAdsCategory.animateProducts,
  ),
  rosePetals(
    'animate-products-rose-petals',
    'Rose Petals',
    WiroProductAdsCategory.animateProducts,
  ),
  ledStripsColorful(
    'animate-products-led-strips-colorful',
    'Led Strips Colorful',
    WiroProductAdsCategory.animateProducts,
  ),
  waterCinematic(
    'animate-products-water-cinematic',
    'Water Cinematic',
    WiroProductAdsCategory.animateProducts,
  ),
  rosesCandles(
    'animate-products-roses-candles',
    'Roses Candles',
    WiroProductAdsCategory.animateProducts,
  ),
  carRoadSeaside(
    'animate-products-car-road-seaside',
    'Car Road Seaside',
    WiroProductAdsCategory.animateProducts,
  ),
  carRoadCityNight(
    'animate-products-car-road-city-night',
    'Car Road City Night',
    WiroProductAdsCategory.animateProducts,
  ),
  barPeople(
    'animate-products-bar-people',
    'Bar People',
    WiroProductAdsCategory.animateProducts,
  ),
  carRoadForest(
    'animate-products-car-road-forest',
    'Car Road Forest',
    WiroProductAdsCategory.animateProducts,
  ),
  carRoadSnow(
    'animate-products-car-road-snow',
    'Car Road Snow',
    WiroProductAdsCategory.animateProducts,
  ),
  rusticTableFireplace(
    'animate-products-rustic-table-fireplace',
    'Rustic Table Fireplace',
    WiroProductAdsCategory.animateProducts,
  ),
  heatFumesCountertop(
    'animate-products-heat-fumes-countertop',
    'Heat Fumes Countertop',
    WiroProductAdsCategory.animateProducts,
  ),
  waterRain(
    'animate-products-water-rain',
    'Water Rain',
    WiroProductAdsCategory.animateProducts,
  ),
  inkClouds(
    'animate-products-ink-clouds',
    'Ink Clouds',
    WiroProductAdsCategory.animateProducts,
  ),
  beachPalm(
    'animate-products-beach-palm',
    'Beach Palm',
    WiroProductAdsCategory.animateProducts,
  ),
  seaPlatform(
    'animate-products-sea-platform',
    'Sea Platform',
    WiroProductAdsCategory.animateProducts,
  ),
  mistRibbonsPetals(
    'animate-products-mist-ribbons-petals',
    'Mist Ribbons Petals',
    WiroProductAdsCategory.animateProducts,
  ),
  confetti(
    'animate-products-confetti',
    'Confetti',
    WiroProductAdsCategory.animateProducts,
  ),
  waterfall(
    'animate-products-waterfall',
    'Waterfall',
    WiroProductAdsCategory.animateProducts,
  ),
  satinFabric(
    'animate-products-satin-fabric',
    'Satin Fabric',
    WiroProductAdsCategory.animateProducts,
  ),
  pinkRibbons(
    'animate-products-pink-ribbons',
    'Pink Ribbons',
    WiroProductAdsCategory.animateProducts,
  ),

  // Scene Morphs
  studioToCafe(
    'scene-morphs-studio-to-cafe',
    'Studio To Cafe',
    WiroProductAdsCategory.sceneMorphs,
  ),
  productJumpsBillboards(
    'scene-morphs-product-jumps-billboards',
    'Product Jumps Billboards',
    WiroProductAdsCategory.sceneMorphs,
  ),
  luminousStudio(
    'scene-morphs-luminous-studio',
    'Luminous Studio',
    WiroProductAdsCategory.sceneMorphs,
  ),
  bubbleToFlowerField(
    'scene-morphs-bubble-to-flower-field',
    'Bubble To Flower Field',
    WiroProductAdsCategory.sceneMorphs,
  ),
  helicopterToCity(
    'scene-morphs-helicopter-to-city',
    'Helicopter To City',
    WiroProductAdsCategory.sceneMorphs,
  ),
  fireAndIce(
    'scene-morphs-fire-and-ice',
    'Fire And Ice',
    WiroProductAdsCategory.sceneMorphs,
  ),
  factoryToDelivery(
    'scene-morphs-factory-to-delivery',
    'Factory To Delivery',
    WiroProductAdsCategory.sceneMorphs,
  ),
  winterToSummerInGrassField(
    'scene-morphs-winter-to-summer-in-grass-field',
    'Winter To Summer In Grass Field',
    WiroProductAdsCategory.sceneMorphs,
  ),
  desertToJungleMorph(
    'scene-morphs-desert-to-jungle-morph',
    'Desert To Jungle Morph',
    WiroProductAdsCategory.sceneMorphs,
  ),
  skyToEiffelTower(
    'scene-morphs-sky-to-eiffel-tower',
    'Sky To Eiffel Tower',
    WiroProductAdsCategory.sceneMorphs,
  ),
  productCrystals(
    'scene-morphs-product-crystals',
    'Product Crystals',
    WiroProductAdsCategory.sceneMorphs,
  ),
  waiterHandToBarCounter(
    'scene-morphs-waiter-hand-to-bar-counter',
    'Waiter Hand To Bar Counter',
    WiroProductAdsCategory.sceneMorphs,
  ),
  underwaterToSky(
    'scene-morphs-underwater-to-sky',
    'Underwater To Sky',
    WiroProductAdsCategory.sceneMorphs,
  ),
  rocketToSpace(
    'scene-morphs-rocket-to-space',
    'Rocket To Space',
    WiroProductAdsCategory.sceneMorphs,
  ),

  // Surreal Product Staging
  clawMachine(
    'surreal-product-staging-claw-machine',
    'Claw Machine',
    WiroProductAdsCategory.surrealStaging,
  ),
  waterfall3dBillboard(
    'surreal-product-staging-3d-waterfall-billboard',
    '3D Waterfall Billboard',
    WiroProductAdsCategory.surrealStaging,
  ),
  truckSpringProduct(
    'surreal-product-staging-truck-spring-product',
    'Truck Spring Product',
    WiroProductAdsCategory.surrealStaging,
  ),
  productSimpleClouds(
    'surreal-product-staging-product-simple-clouds',
    'Product Simple Clouds',
    WiroProductAdsCategory.surrealStaging,
  ),
  helicopterCityProduct(
    'surreal-product-staging-helicopter-city-product',
    'Helicopter City Product',
    WiroProductAdsCategory.surrealStaging,
  ),
  domeProduct(
    'surreal-product-staging-dome-product',
    'Dome Product',
    WiroProductAdsCategory.surrealStaging,
  ),
  makeItBig(
    'surreal-product-staging-make_it_big',
    'Make It Big',
    WiroProductAdsCategory.surrealStaging,
  ),
  objectOnWheelsFair(
    'surreal-product-staging-object-on-wheels-fair',
    'Object On Wheels Fair',
    WiroProductAdsCategory.surrealStaging,
  ),
  oversizedBillboard(
    'surreal-product-staging-oversized-billboard',
    'Oversized Billboard',
    WiroProductAdsCategory.surrealStaging,
  ),
  toyPackagingLuxuryProduct(
    'surreal-product-staging-toy-packaging-luxury-product',
    'Toy Packaging Luxury Product',
    WiroProductAdsCategory.surrealStaging,
  ),
  parachuteCloudsProduct(
    'surreal-product-staging-parachute-clouds-product',
    'Parachute Clouds Product',
    WiroProductAdsCategory.surrealStaging,
  ),
  commercialWithSplash(
    'surreal-product-staging-commerial-with-splash',
    'Commercial With Splash',
    WiroProductAdsCategory.surrealStaging,
  ),
  tinyProductHeld(
    'surreal-product-staging-tiny-product-held',
    'Tiny Product Held',
    WiroProductAdsCategory.surrealStaging,
  ),
  objectCarousel(
    'surreal-product-staging-object-carousel',
    'Object Carousel',
    WiroProductAdsCategory.surrealStaging,
  ),
  balloonLandscapeProduct(
    'surreal-product-staging-balloon-landscape-product',
    'Balloon Landscape Product',
    WiroProductAdsCategory.surrealStaging,
  ),
  rockFloatingProduct(
    'surreal-product-staging-rock-floating-product',
    'Rock Floating Product',
    WiroProductAdsCategory.surrealStaging,
  ),
  goldenWaterfall(
    'surreal-product-staging-golden-waterfall',
    'Golden Waterfall',
    WiroProductAdsCategory.surrealStaging,
  ),
  paragliderJungleProduct(
    'surreal-product-staging-paraglider-jungle-product',
    'Paraglider Jungle Product',
    WiroProductAdsCategory.surrealStaging,
  ),
  surrealProductCrystals(
    'surreal-product-staging-product-crystals',
    'Product Crystals',
    WiroProductAdsCategory.surrealStaging,
  ),
  productInABottle(
    'surreal-product-staging-product-in-a-bottle',
    'Product In A Bottle',
    WiroProductAdsCategory.surrealStaging,
  ),
  floatingItems(
    'surreal-product-staging-floating-items',
    'Floating Items',
    WiroProductAdsCategory.surrealStaging,
  ),
  toyPackagingProduct(
    'surreal-product-staging-toy-packaging-product',
    'Toy Packaging Product',
    WiroProductAdsCategory.surrealStaging,
  ),
  productInCalm(
    'surreal-product-staging-product-in-calm',
    'Product In Calm',
    WiroProductAdsCategory.surrealStaging,
  ),
  receiptToFloating(
    'surreal-product-staging-receipt-to-floating',
    'Receipt To Floating',
    WiroProductAdsCategory.surrealStaging,
  ),
  productInFlowerBlooming(
    'surreal-product-staging-product-in-flower-blooming',
    'Product In Flower Blooming',
    WiroProductAdsCategory.surrealStaging,
  ),
  cupcakeBalloonPlane(
    'surreal-product-staging-cupcake-balloons-plane',
    'Cupcake Balloons Plane',
    WiroProductAdsCategory.surrealStaging,
  ),
  magicPortalDispelled(
    'surreal-product-staging-magic-portal-dispelled',
    'Magic Portal Dispelled',
    WiroProductAdsCategory.surrealStaging,
  ),
  balloonsProduct(
    'surreal-product-staging-balloons-product',
    'Balloons Product',
    WiroProductAdsCategory.surrealStaging,
  ),
  donutOnIce(
    'surreal-product-staging-donut-on-ice',
    'Donut On Ice',
    WiroProductAdsCategory.surrealStaging,
  ),
  airplaneWindowClouds(
    'surreal-product-staging-airplane-window-clouds',
    'Airplane Window Clouds',
    WiroProductAdsCategory.surrealStaging,
  ),
  veniceBoat(
    'surreal-product-staging-venice-boat',
    'Venice Boat',
    WiroProductAdsCategory.surrealStaging,
  ),

  // Product on Model
  objectStudioHeldModel(
    'product-on-model-object-studio-held-model',
    'Object Studio Held Model',
    WiroProductAdsCategory.productOnModel,
  ),
  oversizedObjectWithModel(
    'product-on-model-oversized-object-with-model',
    'Oversized Object With Model',
    WiroProductAdsCategory.productOnModel,
  ),
  modelWearingProductBeach(
    'product-on-model-model-wearing-product-beach',
    'Model Wearing Product Beach',
    WiroProductAdsCategory.productOnModel,
  ),
  modelWearingProductJungle(
    'product-on-model-model-wearing-product-jungle',
    'Model Wearing Product Jungle',
    WiroProductAdsCategory.productOnModel,
  ),
  productHeelsOnFeet(
    'product-on-model-product-heels-on-feet',
    'Product Heels On Feet',
    WiroProductAdsCategory.productOnModel,
  ),
  productWoreByModelInStudio(
    'product-on-model-product-wore-by-model-in-studio',
    'Product Wore By Model In Studio',
    WiroProductAdsCategory.productOnModel,
  ),
  productWoreByModelInMirror(
    'product-on-model-product-wore-by-model-in-mirror',
    'Product Wore By Model In Mirror',
    WiroProductAdsCategory.productOnModel,
  ),
  modelProductEditorialPortrait(
    'product-on-model-model-product-editorial-portrait',
    'Model Product Editorial Portrait',
    WiroProductAdsCategory.productOnModel,
  ),
  objectHeldByModelInStudio(
    'product-on-model-object-held-by-model-in-studio',
    'Object Held By Model In Studio',
    WiroProductAdsCategory.productOnModel,
  ),
  productWoreByModelInParis(
    'product-on-model-product-wore-by-model-in-paris',
    'Product Wore By Model In Paris',
    WiroProductAdsCategory.productOnModel,
  ),

  // Christmas Presets
  christmasSnowGlobe(
    'christmas-presets-christmas-snow-globe2',
    'Christmas Snow Globe',
    WiroProductAdsCategory.christmas,
  ),
  productAsOrnaments(
    'christmas-presets-product-as-ornaments',
    'Product As Ornaments',
    WiroProductAdsCategory.christmas,
  ),
  cableCarMiniature(
    'christmas-presets-cable-car-miniture',
    'Cable Car Miniature',
    WiroProductAdsCategory.christmas,
  ),
  christmasSantaChimney(
    'christmas-presets-christmas-santa-chimney',
    'Christmas Santa Chimney',
    WiroProductAdsCategory.christmas,
  ),
  christmasTrain(
    'christmas-presets-christmas-train',
    'Christmas Train',
    WiroProductAdsCategory.christmas,
  ),
  christmasSnowmanSkating(
    'christmas-presets-christmas-snowman-skating',
    'Christmas Snowman Skating',
    WiroProductAdsCategory.christmas,
  ),
  merryGoRoundToElves(
    'christmas-presets-merry-go-round-to-elves',
    'Merry Go Round To Elves',
    WiroProductAdsCategory.christmas,
  ),
  merryGoRoundChristmas(
    'christmas-presets-merry-go-round-christmas',
    'Merry Go Round Christmas',
    WiroProductAdsCategory.christmas,
  ),
  winterChariot(
    'christmas-presets-winter-chariot',
    'Winter Chariot',
    WiroProductAdsCategory.christmas,
  ),

  // ==========================================================================
  // NEW: Valentines & Romance
  // ==========================================================================
  productOnLiquidGold(
    'product-on-liquid-gold',
    'Liquid Gold',
    WiroProductAdsCategory.valentinesRomance,
  ),
  productOnValentinesGlassGlow(
    'product-on-valentines-glass-glow',
    'Valentines Glass Glow',
    WiroProductAdsCategory.valentinesRomance,
  ),
  productOnVelvetHeart(
    'product-on-velvet-heart',
    'Velvet Heart',
    WiroProductAdsCategory.valentinesRomance,
  ),
  productOnMartiniHeart(
    'product-on-martini-heart',
    'Martini Heart',
    WiroProductAdsCategory.valentinesRomance,
  ),
  productOnSnowfallRomance(
    'product-on-snowfall-romance',
    'Snowfall Romance',
    WiroProductAdsCategory.valentinesRomance,
  ),
  productOnLoveRoyale(
    'product-on-love-royale',
    'LOVE Royale',
    WiroProductAdsCategory.valentinesRomance,
  ),
  productOnBlushBalloon(
    'product-on-blush-balloon',
    'Blush Balloon',
    WiroProductAdsCategory.valentinesRomance,
  ),

  // ==========================================================================
  // NEW: Premium Staging
  // ==========================================================================
  productOnWaterNStone(
    'product-on-water-n-stone',
    'Water n Stone',
    WiroProductAdsCategory.premiumStaging,
  ),
  productOnZeroGravityStudio(
    'product-on-zero-gravity-studio',
    'Zero-gravity Studio',
    WiroProductAdsCategory.premiumStaging,
  ),
  productOnExplosion(
    'product-on-explosion',
    'Explosion',
    WiroProductAdsCategory.premiumStaging,
  ),
  productOnFoamyWater(
    'product-on-foamy-water',
    'Foamy Water',
    WiroProductAdsCategory.premiumStaging,
  ),
  productOnBeamOfLight(
    'product-on-beam-of-light',
    'Beam of Light',
    WiroProductAdsCategory.premiumStaging,
  ),
  productOnFloralAscension(
    'product-on-floral-ascension',
    'Floral Ascension',
    WiroProductAdsCategory.premiumStaging,
  ),
  productOnGoldenSuspension(
    'product-on-golden-suspension',
    'Golden Suspension',
    WiroProductAdsCategory.premiumStaging,
  ),
  productOnNatureLuxe(
    'product-on-nature-luxe',
    'Nature Luxe',
    WiroProductAdsCategory.premiumStaging,
  ),
  productOnPinkWonderland(
    'product-on-pink-wonderland',
    'Pink Wonderland',
    WiroProductAdsCategory.premiumStaging,
  ),
  productOnRedPedestalVelvetCurtains(
    'product-on-red-pedestal-velvet-curtains',
    'Red Pedestal Velvet Curtains',
    WiroProductAdsCategory.premiumStaging,
  ),
  productOnSteelCableSuspended(
    'product-on-steel-cable-suspended',
    'Steel Cable Suspended',
    WiroProductAdsCategory.premiumStaging,
  ),
  productOnSurrealAbstractTextures(
    'product-on-surreal-abstract-textures',
    'Surreal Abstract Textures',
    WiroProductAdsCategory.premiumStaging,
  ),

  // ==========================================================================
  // NEW: Bag & Fashion
  // ==========================================================================
  productOnBagIceBlockWinter(
    'product-on-bag-ice-block-winter',
    'Bag Ice Block Winter',
    WiroProductAdsCategory.bagFashion,
  ),
  productOnBagStoneStructureArchitectural(
    'product-on-bag-stone-structure-architectural',
    'Bag Stone Structure Architectural',
    WiroProductAdsCategory.bagFashion,
  ),
  productOnBagModelBentLegStudio(
    'product-on-bag-model-bent-leg-studio',
    'Bag Model Bent Leg Studio',
    WiroProductAdsCategory.bagFashion,
  ),
  productOnBagGrassReflectiveSurface(
    'product-on-bag-grass-reflective-surface',
    'Bag Grass Reflective Surface',
    WiroProductAdsCategory.bagFashion,
  ),
  productOnBagMultipleHeldSeatedModel(
    'product-on-bag-multiple-held-seated-model',
    'Bag Multiple Held Seated Model',
    WiroProductAdsCategory.bagFashion,
  ),
  productOnBagMultipleSymmetricalSeated(
    'product-on-bag-multiple-symmetrical-seated',
    'Bag Multiple Symmetrical Seated',
    WiroProductAdsCategory.bagFashion,
  ),
  productOnBagStoneFormationMountains(
    'product-on-bag-stone-formation-mountains',
    'Bag Stone Formation Mountains',
    WiroProductAdsCategory.bagFashion,
  ),

  // ==========================================================================
  // NEW: Candle & Lifestyle
  // ==========================================================================
  productOnCoffeePouringLifestyle(
    'product-on-coffee-pouring-lifestyle',
    'Coffee Pouring Lifestyle',
    WiroProductAdsCategory.candleLifestyle,
  ),
  productOnTulleGlovedHandsCandle(
    'product-on-tulle-gloved-hands-candle',
    'Tulle Gloved Hands Candle',
    WiroProductAdsCategory.candleLifestyle,
  ),
  productOnWoodenPedestalCandle(
    'product-on-wooden-pedestal-candle',
    'Wooden Pedestal Candle',
    WiroProductAdsCategory.candleLifestyle,
  ),
  productOnFoodElementsPlayful(
    'product-on-food-elements-playful',
    'Food Elements Playful',
    WiroProductAdsCategory.candleLifestyle,
  ),
  productOnCandlesFabricMultiple(
    'product-on-candles-fabric-multiple',
    'Candles Fabric Multiple',
    WiroProductAdsCategory.candleLifestyle,
  ),
  productOnCitrusFruitsCandle(
    'product-on-citrus-fruits-candle',
    'Citrus Fruits Candle',
    WiroProductAdsCategory.candleLifestyle,
  ),
  productOnGreenFoliageBotanical(
    'product-on-green-foliage-botanical',
    'Green Foliage Botanical',
    WiroProductAdsCategory.candleLifestyle,
  ),
  productOnCandleMatchLightingIntimate(
    'product-on-candle-match-lighting-intimate',
    'Match Lighting Intimate',
    WiroProductAdsCategory.candleLifestyle,
  ),

  // ==========================================================================
  // NEW: Perfume & Beauty
  // ==========================================================================
  productOnWaterFloatingPool(
    'product-on-water-floating-pool',
    'Water Floating Pool',
    WiroProductAdsCategory.perfumeBeauty,
  ),
  productOnWhiteLedgeFlowers(
    'product-on-white-ledge-flowers',
    'White Ledge Flowers',
    WiroProductAdsCategory.perfumeBeauty,
  ),
  productOnModelCloseFacePortrait(
    'product-on-model-close-face-portrait',
    'Model Close Face Portrait',
    WiroProductAdsCategory.perfumeBeauty,
  ),
  productOnRopeCoastalWater(
    'product-on-rope-coastal-water',
    'Rope Coastal Water',
    WiroProductAdsCategory.perfumeBeauty,
  ),
  productOnPinkCloudsDreamy(
    'product-on-pink-clouds-dreamy',
    'Pink Clouds Dreamy',
    WiroProductAdsCategory.perfumeBeauty,
  ),
  productOnPerfumeSnowySkiSlope(
    'product-on-perfume-snowy-ski-slope',
    'Perfume Snowy Ski Slope',
    WiroProductAdsCategory.perfumeBeauty,
  ),
  productOnSnowMountainReflection(
    'product-on-snow-mountain-reflection',
    'Snow Mountain Reflection',
    WiroProductAdsCategory.perfumeBeauty,
  ),
  productOnPerfumeSkiSlopeSkiers(
    'product-on-perfume-ski-slope-skiers',
    'Perfume Ski Slope Skiers',
    WiroProductAdsCategory.perfumeBeauty,
  ),
  productOnGlassOrnamentSphere(
    'product-on-glass-ornament-sphere',
    'Glass Ornament Sphere',
    WiroProductAdsCategory.perfumeBeauty,
  ),
  productOnChristmasTreeBranches(
    'product-on-christmas-tree-branches',
    'Christmas Tree Branches',
    WiroProductAdsCategory.perfumeBeauty,
  ),
  productOnSnowCandyCanes(
    'product-on-snow-candy-canes',
    'Snow Candy Canes',
    WiroProductAdsCategory.perfumeBeauty,
  ),
  productOnWinterFlatlayTopdown(
    'product-on-winter-flatlay-topdown',
    'Winter Flatlay Topdown',
    WiroProductAdsCategory.perfumeBeauty,
  ),

  // ==========================================================================
  // NEW: Earrings & Jewelry
  // ==========================================================================
  productOnEarringsMartiniGlass(
    'product-on-earrings-martini-glass',
    'Earrings Martini Glass',
    WiroProductAdsCategory.earringsJewelry,
  ),
  productOnEaringsTwoHandsSymmetrical(
    'product-on-earings-two-hands-symmetrical',
    'Earings Two Hands Symmetrical',
    WiroProductAdsCategory.earringsJewelry,
  ),
  productOnEarringsModelEarProfile(
    'product-on-earrings-model-ear-profile',
    'Earrings Model Ear Profile',
    WiroProductAdsCategory.earringsJewelry,
  ),
  productOnEarringsBlondeModelOne(
    'product-on-earrings-blonde-model-one',
    'Earrings Blonde Model One',
    WiroProductAdsCategory.earringsJewelry,
  ),
  productOnEarringsBlondeModelTwo(
    'product-on-earrings-blonde-model-two',
    'Earrings Blonde Model Two',
    WiroProductAdsCategory.earringsJewelry,
  );

  const WiroProductAdsEffect(this.value, this.label, this.category);

  final String value;
  final String label;
  final WiroProductAdsCategory category;

  static WiroProductAdsEffect? fromValue(String value) {
    try {
      return WiroProductAdsEffect.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  static List<WiroProductAdsEffect> byCategory(
    WiroProductAdsCategory category,
  ) {
    return WiroProductAdsEffect.values
        .where((e) => e.category == category)
        .toList();
  }
}

// =============================================================================
// PRODUCT ADS WITH CAPTION EFFECTS
// =============================================================================

/// Effect types specific to Product Ads with Caption model
enum WiroProductCaptionEffect {
  // Christmas
  productWithSantaHat(
    'christmas-presets-product-with-santa-hat',
    'Product With Santa Hat',
    WiroProductCaptionCategory.christmas,
  ),
  christmasSnowGlobeMountains(
    'christmas-presets-christmas-snow-globe-mountains',
    'Christmas Snow Globe Mountains',
    WiroProductCaptionCategory.christmas,
  ),
  polaroidWithSanta(
    'christmas-presets-polaroid-with-santa',
    'Polaroid With Santa',
    WiroProductCaptionCategory.christmas,
  ),
  holidayCard(
    'christmas-presets-holiday-card',
    'Holiday Card',
    WiroProductCaptionCategory.christmas,
  ),
  lettersToSanta(
    'christmas-presets-letters-to-santa',
    'Letters To Santa',
    WiroProductCaptionCategory.christmas,
  ),

  // Scene Morphs
  storefrontToDisplay(
    'scene-morphs-storefront-to-display',
    'Storefront To Display',
    WiroProductCaptionCategory.sceneMorphs,
  ),
  packageToProductWithConfetti(
    'scene-morphs-package-to-product-with-confetti',
    'Package To Product With Confetti',
    WiroProductCaptionCategory.sceneMorphs,
  ),

  // Black Friday Sales
  blackFridayClawMachine(
    'black-friday-sales-black-friday-claw-machine',
    'Black Friday Claw Machine',
    WiroProductCaptionCategory.blackFriday,
  ),
  blackCoverToWhiteSpotlightsBlackFriday(
    'black-friday-sales-black-cover-to-white-spotlights-black-friday',
    'Black Cover To White Spotlights Black Friday',
    WiroProductCaptionCategory.blackFriday,
  ),
  blackFridayElevator(
    'black-friday-sales-black-friday-elevator',
    'Black Friday Elevator',
    WiroProductCaptionCategory.blackFriday,
  ),
  giftToProductWithConfettiBlack(
    'black-friday-sales-gift-to-product-with-confetti-black',
    'Gift To Product With Confetti Black',
    WiroProductCaptionCategory.blackFriday,
  ),
  snowBlackFriday(
    'black-friday-sales-snow-black-friday',
    'Snow Black Friday',
    WiroProductCaptionCategory.blackFriday,
  ),
  planeCityProductBlackFriday(
    'black-friday-sales-plane-city-product-black-friday',
    'Plane City Product Black Friday',
    WiroProductCaptionCategory.blackFriday,
  ),
  blackBackgroundRedNeonText(
    'black-friday-sales-black-background-red-neon-text',
    'Black Background Red Neon Text',
    WiroProductCaptionCategory.blackFriday,
  ),
  blackFridayVendingMachine(
    'black-friday-sales-black-friday-vending-machine',
    'Black Friday Vending Machine',
    WiroProductCaptionCategory.blackFriday,
  ),
  domeProductBlackFriday(
    'black-friday-sales-dome-product-black-friday',
    'Dome Product Black Friday',
    WiroProductCaptionCategory.blackFriday,
  ),
  blackFridayDisplayWindow(
    'black-friday-sales-black-friday-display-window',
    'Black Friday Display Window',
    WiroProductCaptionCategory.blackFriday,
  ),
  giftStorefrontToProduct(
    'black-friday-sales-gift-storefront-to-product',
    'Gift Storefront To Product',
    WiroProductCaptionCategory.blackFriday,
  ),
  blackPedestalSmokeRedNeonText(
    'black-friday-sales-black-pedestal-smoke-red-neon-text',
    'Black Pedestal Smoke Red Neon Text',
    WiroProductCaptionCategory.blackFriday,
  ),

  // Product With Text
  packageConfettiProductText(
    'product-with-text-package-confetti-product-text',
    'Package Confetti Product Text',
    WiroProductCaptionCategory.productWithText,
  ),
  productBeachBanner(
    'product-with-text-product-beach-banner',
    'Product Beach Banner',
    WiroProductCaptionCategory.productWithText,
  ),
  mojitoHappyHour(
    'product-with-text-mojito-happy-hour',
    'Mojito Happy Hour',
    WiroProductCaptionCategory.productWithText,
  ),
  blackPedestalSmokeNeonText(
    'product-with-text-black-pedestal-smoke-neon-text',
    'Black Pedestal Smoke Neon Text',
    WiroProductCaptionCategory.productWithText,
  ),
  rusticTableMenuItemText(
    'product-with-text-rustic-table-menu-item-text',
    'Rustic Table Menu Item Text',
    WiroProductCaptionCategory.productWithText,
  ),
  cloudFontProductPedestal(
    'product-with-text-3d-cloud-font-product-pedestal',
    '3D Cloud Font Product Pedestal',
    WiroProductCaptionCategory.productWithText,
  ),
  chromeFontProductInSky(
    'product-with-text-chrome-font-product-in-sky',
    'Chrome Font Product In Sky',
    WiroProductCaptionCategory.productWithText,
  ),
  spaceOrbitProductSale(
    'product-with-text-space-orbit-product-sale',
    'Space Orbit Product Sale',
    WiroProductCaptionCategory.productWithText,
  ),
  productSlicedToJello(
    'product-with-text-product-sliced-to-jello',
    'Product Sliced To Jello',
    WiroProductCaptionCategory.productWithText,
  ),
  animalCoilingAroundProduct(
    'product-with-text-animal-coiling-around-product',
    'Animal Coiling Around Product',
    WiroProductCaptionCategory.productWithText,
  ),
  conveyorBeltNeonTextProduct(
    'product-with-text-conveyor-belt-neon-text-product',
    'Conveyor Belt Neon Text Product',
    WiroProductCaptionCategory.productWithText,
  ),
  productInGreekHeaven(
    'product-with-text-product-in-greek-heaven',
    'Product In Greek Heaven',
    WiroProductCaptionCategory.productWithText,
  ),
  colorfulBalloonsTextProduct(
    'product-with-text-colorful-balloons-text-product',
    'Colorful Balloons Text Product',
    WiroProductCaptionCategory.productWithText,
  ),
  productInMeltingIceCube(
    'product-with-text-product-in-melting-ice-cube',
    'Product In Melting Ice Cube',
    WiroProductCaptionCategory.productWithText,
  ),
  waterdropInGrassyField(
    'product-with-text-3d-waterdrop-in-grassy-field',
    '3D Waterdrop In Grassy Field',
    WiroProductCaptionCategory.productWithText,
  ),
  waterdropProductInBubble(
    'product-with-text-3d-waterdrop-product-in-bubble',
    '3D Waterdrop Product In Bubble',
    WiroProductCaptionCategory.productWithText,
  ),
  lipstickOnSaleToday(
    'product-with-text-lipstick-on-sale-today',
    'Lipstick On Sale Today',
    WiroProductCaptionCategory.productWithText,
  ),
  iceCreamCosmetics(
    'product-with-text-ice-cream-cosmetics',
    'Ice Cream Cosmetics',
    WiroProductCaptionCategory.productWithText,
  ),
  productInGoo(
    'product-with-text-product-in-goo',
    'Product In Goo',
    WiroProductCaptionCategory.productWithText,
  ),
  productInClearCapsule(
    'product-with-text-product-in-clear-capsule',
    'Product In Clear Capsule',
    WiroProductCaptionCategory.productWithText,
  ),
  handbagSkyscraperSunset(
    'product-with-text-handbag-skyscraper-sunset',
    'Handbag Skyscraper Sunset',
    WiroProductCaptionCategory.productWithText,
  ),
  butterflyHoldingProductIridescentText(
    'product-with-text-butterfly-holding-product-iridescent-text',
    'Butterfly Holding Product Iridescent Text',
    WiroProductCaptionCategory.productWithText,
  ),
  hotDealLavaProduct(
    'product-with-text-hot-deal-lava-product',
    'Hot Deal Lava Product',
    WiroProductCaptionCategory.productWithText,
  );

  const WiroProductCaptionEffect(this.value, this.label, this.category);

  final String value;
  final String label;
  final WiroProductCaptionCategory category;

  static WiroProductCaptionEffect? fromValue(String value) {
    try {
      return WiroProductCaptionEffect.values.firstWhere(
        (e) => e.value == value,
      );
    } catch (_) {
      return null;
    }
  }

  static List<WiroProductCaptionEffect> byCategory(
    WiroProductCaptionCategory category,
  ) {
    return WiroProductCaptionEffect.values
        .where((e) => e.category == category)
        .toList();
  }
}

// =============================================================================
// PRODUCT ADS WITH LOGO EFFECTS
// =============================================================================

/// Effect types specific to Product Ads with Logo model
enum WiroProductLogoEffect {
  productHangingCityMatchingBanners(
    'logo-and-product-product-hanging-city-matching-banners',
    'Product Hanging City Matching Banners',
  ),
  goldenStorefrontLogo(
    'logo-and-product-golden-storefront-logo',
    'Golden Storefront Logo',
  ),
  oversizedObjectOnCart3dLogo(
    'logo-and-product-oversized-object-on-cart-3d-logo',
    'Oversized Object On Cart 3D Logo',
  ),
  productLogoDesert(
    'logo-and-product-product-logo-desert',
    'Product Logo Desert',
  ),
  logoInCappuccinoWithObject(
    'logo-and-product-logo-in-cappuccino-with-object',
    'Logo In Cappuccino With Object',
  ),
  productHangingOnParachuteWheatField(
    'logo-and-product-product-hanging-on-parachute-wheat-field',
    'Product Hanging On Parachute Wheat Field',
  ),
  bigProductCarSeatLogoOnBag(
    'logo-and-product-big-product-car-seat-logo-on-bag',
    'Big Product Car Seat Logo On Bag',
  ),
  pillCapsuleLogoAndProduct(
    'logo-and-product-pill-capsule-logo-and-product',
    'Pill Capsule Logo And Product',
  ),
  productFloatingCoffeeLogoOnNapkin(
    'logo-and-product-product-floating-coffee-logo-on-napkin',
    'Product Floating Coffee Logo On Napkin',
  ),
  surrealObjectLogoOnBus(
    'logo-and-product-surreal-object-logo-on-bus',
    'Surreal Object Logo On Bus',
  ),
  massiveProductWithSkyPlaneBanner(
    'logo-and-product-massive-product-with-sky-plane-banner',
    'Massive Product With Sky Plane Banner',
  ),
  billboardPanelInUrbanStreetWithLogo(
    'logo-and-product-billboard-panel-in-urban-street-with-logo',
    'Billboard Panel In Urban Street With Logo',
  );

  const WiroProductLogoEffect(this.value, this.label);

  final String value;
  final String label;

  static WiroProductLogoEffect? fromValue(String value) {
    try {
      return WiroProductLogoEffect.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  static List<WiroProductLogoEffect> get all =>
      WiroProductLogoEffect.values.toList();
}

// =============================================================================
// CATEGORIES
// =============================================================================

/// Categories for Product Ads effects
enum WiroProductAdsCategory {
  animateProducts('Animate Products'),
  sceneMorphs('Scene Morphs'),
  surrealStaging('Surreal Staging'),
  productOnModel('Product on Model'),
  christmas('Christmas'),
  // New categories
  valentinesRomance('Valentines & Romance'),
  premiumStaging('Premium Staging'),
  bagFashion('Bag & Fashion'),
  candleLifestyle('Candle & Lifestyle'),
  perfumeBeauty('Perfume & Beauty'),
  earringsJewelry('Earrings & Jewelry');

  const WiroProductAdsCategory(this.label);

  final String label;
}

/// Categories for Product Ads with Caption effects
enum WiroProductCaptionCategory {
  christmas('Christmas'),
  sceneMorphs('Scene Morphs'),
  blackFriday('Black Friday Sales'),
  productWithText('Product With Text');

  const WiroProductCaptionCategory(this.label);

  final String label;
}

// =============================================================================
// VIDEO MODE
// =============================================================================

/// Video mode options
enum WiroVideoMode {
  standard('std', 'Standard'),
  pro('pro', 'Pro');

  const WiroVideoMode(this.value, this.label);

  final String value;
  final String label;
}

// =============================================================================
// HELPER CLASS FOR EFFECT SELECTION
// =============================================================================

/// Helper class to get effects for a specific model type
class WiroEffects {
  /// Get all effects for a given model type
  static List<EffectOption> getEffectsForModel(WiroModelType model) {
    switch (model) {
      case WiroModelType.textAnimations:
        return WiroTextAnimationEffect.values
            .map(
              (e) => EffectOption(
                value: e.value,
                label: e.label,
                coverUrl: model.getCoverUrl(e.value),
              ),
            )
            .toList();
      case WiroModelType.productAds:
        return WiroProductAdsEffect.values
            .map(
              (e) => EffectOption(
                value: e.value,
                label: e.label,
                category: e.category.label,
                coverUrl: model.getCoverUrl(e.value),
              ),
            )
            .toList();
      case WiroModelType.productAdsWithCaption:
        return WiroProductCaptionEffect.values
            .map(
              (e) => EffectOption(
                value: e.value,
                label: e.label,
                category: e.category.label,
                coverUrl: model.getCoverUrl(e.value),
              ),
            )
            .toList();
      case WiroModelType.productAdsWithLogo:
        return WiroProductLogoEffect.values
            .map(
              (e) => EffectOption(
                value: e.value,
                label: e.label,
                coverUrl: model.getCoverUrl(e.value),
              ),
            )
            .toList();
    }
  }

  /// Get default effect for a given model type
  static String getDefaultEffect(WiroModelType model) {
    switch (model) {
      case WiroModelType.textAnimations:
        return WiroTextAnimationEffect.bubblegumLetters.value;
      case WiroModelType.productAds:
        return WiroProductAdsEffect.smokyPedestal.value;
      case WiroModelType.productAdsWithCaption:
        return WiroProductCaptionEffect.productBeachBanner.value;
      case WiroModelType.productAdsWithLogo:
        return WiroProductLogoEffect.goldenStorefrontLogo.value;
    }
  }
}

/// Generic effect option for UI display
class EffectOption {
  const EffectOption({
    required this.value,
    required this.label,
    this.category,
    this.coverUrl,
  });

  final String value;
  final String label;
  final String? category;
  final String? coverUrl;

  /// Get the preview video URL for this effect
  /// Format: https://cdn.wiro.ai/uploads/effects/{effect-value}.mp4
  String get previewVideoUrl =>
      'https://cdn.wiro.ai/uploads/effects/$value.mp4';

  /// Get cover URL or fallback to preview
  String get effectCoverUrl =>
      coverUrl ?? 'https://cdn.wiro.ai/uploads/effects/$value.mp4';
}
