/// All available Wiro Product Ads effect types
enum WiroEffectType {
  // Animate Products
  smokyPedestal('animate-products-smoky-pedestal', 'Smoky Pedestal', WiroEffectCategory.animateProducts),
  waterPetals('animate-products-water-petals', 'Water Petals', WiroEffectCategory.animateProducts),
  waterDarkElectricHues('animate-products-water-dark-electric-hues', 'Water Dark Electric Hues', WiroEffectCategory.animateProducts),
  snow('animate-products-snow', 'Snow', WiroEffectCategory.animateProducts),
  glitterSilver('animate-products-glitter-silver', 'Glitter Silver', WiroEffectCategory.animateProducts),
  rosesSmoke('animate-products-roses-smoke', 'Roses Smoke', WiroEffectCategory.animateProducts),
  carWarehouse('animate-products-car-warehouse', 'Car Warehouse', WiroEffectCategory.animateProducts),
  waterSplashesLight('animate-products-water-splashes-light', 'Water Splashes Light', WiroEffectCategory.animateProducts),
  fallingPetals('animate-products-falling-petals', 'Falling Petals', WiroEffectCategory.animateProducts),
  liquidGold('animate-products-liquid-gold', 'Liquid Gold', WiroEffectCategory.animateProducts),
  oilBubbles('animate-products-oil-bubbles', 'Oil Bubbles', WiroEffectCategory.animateProducts),
  goldenFireworks('animate-products-golden-fireworks', 'Golden Fireworks', WiroEffectCategory.animateProducts),
  ledStrips('animate-products-led-strips', 'Led Strips', WiroEffectCategory.animateProducts),
  waterFruitsSplash('animate-products-water-fruits-splash', 'Water Fruits Splash', WiroEffectCategory.animateProducts),
  smokeReveal('animate-products-smoke-reveal', 'Smoke Reveal', WiroEffectCategory.animateProducts),
  rosePetals('animate-products-rose-petals', 'Rose Petals', WiroEffectCategory.animateProducts),
  ledStripsColorful('animate-products-led-strips-colorful', 'Led Strips Colorful', WiroEffectCategory.animateProducts),
  waterCinematic('animate-products-water-cinematic', 'Water Cinematic', WiroEffectCategory.animateProducts),
  rosesCandles('animate-products-roses-candles', 'Roses Candles', WiroEffectCategory.animateProducts),
  carRoadSeaside('animate-products-car-road-seaside', 'Car Road Seaside', WiroEffectCategory.animateProducts),
  carRoadCityNight('animate-products-car-road-city-night', 'Car Road City Night', WiroEffectCategory.animateProducts),
  barPeople('animate-products-bar-people', 'Bar People', WiroEffectCategory.animateProducts),
  carRoadForest('animate-products-car-road-forest', 'Car Road Forest', WiroEffectCategory.animateProducts),
  carRoadSnow('animate-products-car-road-snow', 'Car Road Snow', WiroEffectCategory.animateProducts),
  rusticTableFireplace('animate-products-rustic-table-fireplace', 'Rustic Table Fireplace', WiroEffectCategory.animateProducts),
  heatFumesCountertop('animate-products-heat-fumes-countertop', 'Heat Fumes Countertop', WiroEffectCategory.animateProducts),
  waterRain('animate-products-water-rain', 'Water Rain', WiroEffectCategory.animateProducts),
  inkClouds('animate-products-ink-clouds', 'Ink Clouds', WiroEffectCategory.animateProducts),
  beachPalm('animate-products-beach-palm', 'Beach Palm', WiroEffectCategory.animateProducts),
  seaPlatform('animate-products-sea-platform', 'Sea Platform', WiroEffectCategory.animateProducts),
  mistRibbonsPetals('animate-products-mist-ribbons-petals', 'Mist Ribbons Petals', WiroEffectCategory.animateProducts),
  confetti('animate-products-confetti', 'Confetti', WiroEffectCategory.animateProducts),
  waterfall('animate-products-waterfall', 'Waterfall', WiroEffectCategory.animateProducts),
  satinFabric('animate-products-satin-fabric', 'Satin Fabric', WiroEffectCategory.animateProducts),
  pinkRibbons('animate-products-pink-ribbons', 'Pink Ribbons', WiroEffectCategory.animateProducts),

  // Scene Morphs
  studioToCafe('scene-morphs-studio-to-cafe', 'Studio To Cafe', WiroEffectCategory.sceneMorphs),
  productJumpsBillboards('scene-morphs-product-jumps-billboards', 'Product Jumps Billboards', WiroEffectCategory.sceneMorphs),
  luminousStudio('scene-morphs-luminous-studio', 'Luminous Studio', WiroEffectCategory.sceneMorphs),
  bubbleToFlowerField('scene-morphs-bubble-to-flower-field', 'Bubble To Flower Field', WiroEffectCategory.sceneMorphs),
  helicopterToCity('scene-morphs-helicopter-to-city', 'Helicopter To City', WiroEffectCategory.sceneMorphs),
  fireAndIce('scene-morphs-fire-and-ice', 'Fire And Ice', WiroEffectCategory.sceneMorphs),
  factoryToDelivery('scene-morphs-factory-to-delivery', 'Factory To Delivery', WiroEffectCategory.sceneMorphs),
  winterToSummerInGrassField('scene-morphs-winter-to-summer-in-grass-field', 'Winter To Summer In Grass Field', WiroEffectCategory.sceneMorphs),
  desertToJungleMorph('scene-morphs-desert-to-jungle-morph', 'Desert To Jungle Morph', WiroEffectCategory.sceneMorphs),
  skyToEiffelTower('scene-morphs-sky-to-eiffel-tower', 'Sky To Eiffel Tower', WiroEffectCategory.sceneMorphs),
  productCrystals('scene-morphs-product-crystals', 'Product Crystals', WiroEffectCategory.sceneMorphs),
  waiterHandToBarCounter('scene-morphs-waiter-hand-to-bar-counter', 'Waiter Hand To Bar Counter', WiroEffectCategory.sceneMorphs),
  underwaterToSky('scene-morphs-underwater-to-sky', 'Underwater To Sky', WiroEffectCategory.sceneMorphs),
  rocketToSpace('scene-morphs-rocket-to-space', 'Rocket To Space', WiroEffectCategory.sceneMorphs),

  // Surreal Product Staging
  clawMachine('surreal-product-staging-claw-machine', 'Claw Machine', WiroEffectCategory.surrealStaging),
  waterfall3dBillboard('surreal-product-staging-3d-waterfall-billboard', '3D Waterfall Billboard', WiroEffectCategory.surrealStaging),
  truckSpringProduct('surreal-product-staging-truck-spring-product', 'Truck Spring Product', WiroEffectCategory.surrealStaging),
  productSimpleClouds('surreal-product-staging-product-simple-clouds', 'Product Simple Clouds', WiroEffectCategory.surrealStaging),
  helicopterCityProduct('surreal-product-staging-helicopter-city-product', 'Helicopter City Product', WiroEffectCategory.surrealStaging),
  domeProduct('surreal-product-staging-dome-product', 'Dome Product', WiroEffectCategory.surrealStaging),
  makeItBig('surreal-product-staging-make_it_big', 'Make It Big', WiroEffectCategory.surrealStaging),
  objectOnWheelsFair('surreal-product-staging-object-on-wheels-fair', 'Object On Wheels Fair', WiroEffectCategory.surrealStaging),
  oversizedBillboard('surreal-product-staging-oversized-billboard', 'Oversized Billboard', WiroEffectCategory.surrealStaging),
  toyPackagingLuxuryProduct('surreal-product-staging-toy-packaging-luxury-product', 'Toy Packaging Luxury Product', WiroEffectCategory.surrealStaging),
  parachuteCloudsProduct('surreal-product-staging-parachute-clouds-product', 'Parachute Clouds Product', WiroEffectCategory.surrealStaging),
  commercialWithSplash('surreal-product-staging-commerial-with-splash', 'Commercial With Splash', WiroEffectCategory.surrealStaging),
  tinyProductHeld('surreal-product-staging-tiny-product-held', 'Tiny Product Held', WiroEffectCategory.surrealStaging),
  objectCarousel('surreal-product-staging-object-carousel', 'Object Carousel', WiroEffectCategory.surrealStaging),
  balloonLandscapeProduct('surreal-product-staging-balloon-landscape-product', 'Balloon Landscape Product', WiroEffectCategory.surrealStaging),
  rockFloatingProduct('surreal-product-staging-rock-floating-product', 'Rock Floating Product', WiroEffectCategory.surrealStaging),
  goldenWaterfall('surreal-product-staging-golden-waterfall', 'Golden Waterfall', WiroEffectCategory.surrealStaging),
  paragliderJungleProduct('surreal-product-staging-paraglider-jungle-product', 'Paraglider Jungle Product', WiroEffectCategory.surrealStaging),
  surrealProductCrystals('surreal-product-staging-product-crystals', 'Product Crystals', WiroEffectCategory.surrealStaging),
  productInABottle('surreal-product-staging-product-in-a-bottle', 'Product In A Bottle', WiroEffectCategory.surrealStaging),
  floatingItems('surreal-product-staging-floating-items', 'Floating Items', WiroEffectCategory.surrealStaging),
  toyPackagingProduct('surreal-product-staging-toy-packaging-product', 'Toy Packaging Product', WiroEffectCategory.surrealStaging),
  productInCalm('surreal-product-staging-product-in-calm', 'Product In Calm', WiroEffectCategory.surrealStaging),
  receiptToFloating('surreal-product-staging-receipt-to-floating', 'Receipt To Floating', WiroEffectCategory.surrealStaging),
  productInFlowerBlooming('surreal-product-staging-product-in-flower-blooming', 'Product In Flower Blooming', WiroEffectCategory.surrealStaging),
  cupcakeBalloonPlane('surreal-product-staging-cupcake-balloons-plane', 'Cupcake Balloons Plane', WiroEffectCategory.surrealStaging),
  magicPortalDispelled('surreal-product-staging-magic-portal-dispelled', 'Magic Portal Dispelled', WiroEffectCategory.surrealStaging),
  balloonsProduct('surreal-product-staging-balloons-product', 'Balloons Product', WiroEffectCategory.surrealStaging),
  donutOnIce('surreal-product-staging-donut-on-ice', 'Donut On Ice', WiroEffectCategory.surrealStaging),
  airplaneWindowClouds('surreal-product-staging-airplane-window-clouds', 'Airplane Window Clouds', WiroEffectCategory.surrealStaging),
  veniceBoat('surreal-product-staging-venice-boat', 'Venice Boat', WiroEffectCategory.surrealStaging),

  // Product on Model
  objectStudioHeldModel('product-on-model-object-studio-held-model', 'Object Studio Held Model', WiroEffectCategory.productOnModel),
  oversizedObjectWithModel('product-on-model-oversized-object-with-model', 'Oversized Object With Model', WiroEffectCategory.productOnModel),
  modelWearingProductBeach('product-on-model-model-wearing-product-beach', 'Model Wearing Product Beach', WiroEffectCategory.productOnModel),
  modelWearingProductJungle('product-on-model-model-wearing-product-jungle', 'Model Wearing Product Jungle', WiroEffectCategory.productOnModel),
  productHeelsOnFeet('product-on-model-product-heels-on-feet', 'Product Heels On Feet', WiroEffectCategory.productOnModel),
  productWoreByModelInStudio('product-on-model-product-wore-by-model-in-studio', 'Product Wore By Model In Studio', WiroEffectCategory.productOnModel),
  productWoreByModelInMirror('product-on-model-product-wore-by-model-in-mirror', 'Product Wore By Model In Mirror', WiroEffectCategory.productOnModel),
  modelProductEditorialPortrait('product-on-model-model-product-editorial-portrait', 'Model Product Editorial Portrait', WiroEffectCategory.productOnModel),
  objectHeldByModelInStudio('product-on-model-object-held-by-model-in-studio', 'Object Held By Model In Studio', WiroEffectCategory.productOnModel),
  productWoreByModelInParis('product-on-model-product-wore-by-model-in-paris', 'Product Wore By Model In Paris', WiroEffectCategory.productOnModel),

  // Christmas Presets
  christmasSnowGlobe('christmas-presets-christmas-snow-globe2', 'Christmas Snow Globe', WiroEffectCategory.christmas),
  productAsOrnaments('christmas-presets-product-as-ornaments', 'Product As Ornaments', WiroEffectCategory.christmas),
  cableCarMiniature('christmas-presets-cable-car-miniture', 'Cable Car Miniature', WiroEffectCategory.christmas),
  christmasSantaChimney('christmas-presets-christmas-santa-chimney', 'Christmas Santa Chimney', WiroEffectCategory.christmas),
  christmasTrain('christmas-presets-christmas-train', 'Christmas Train', WiroEffectCategory.christmas),
  christmasSnowmanSkating('christmas-presets-christmas-snowman-skating', 'Christmas Snowman Skating', WiroEffectCategory.christmas),
  merryGoRoundToElves('christmas-presets-merry-go-round-to-elves', 'Merry Go Round To Elves', WiroEffectCategory.christmas),
  merryGoRoundChristmas('christmas-presets-merry-go-round-christmas', 'Merry Go Round Christmas', WiroEffectCategory.christmas),
  winterChariot('christmas-presets-winter-chariot', 'Winter Chariot', WiroEffectCategory.christmas);

  const WiroEffectType(this.value, this.label, this.category);

  final String value;
  final String label;
  final WiroEffectCategory category;

  static WiroEffectType? fromValue(String value) {
    try {
      return WiroEffectType.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }
}

/// Categories for organizing effect types
enum WiroEffectCategory {
  animateProducts('Animate Products'),
  sceneMorphs('Scene Morphs'),
  surrealStaging('Surreal Staging'),
  productOnModel('Product on Model'),
  christmas('Christmas');

  const WiroEffectCategory(this.label);

  final String label;
}

/// Video mode options
enum WiroVideoMode {
  standard('std', 'Standard'),
  pro('pro', 'Pro');

  const WiroVideoMode(this.value, this.label);

  final String value;
  final String label;
}

