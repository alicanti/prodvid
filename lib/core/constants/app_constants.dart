/// App-wide constants
abstract class AppConstants {
  // App Info
  static const String appName = 'ProdVid';
  static const String appVersion = '1.0.0';
  
  // RevenueCat Product IDs
  static const String weeklySubscriptionId = 'prodvid_weekly_subscription';
  static const String yearlySubscriptionId = 'prodvid_yearly_subscription';
  static const String credits2000Id = 'prodvid_credits_2000';
  static const String credits7000Id = 'prodvid_credits_7000';
  static const String credits15000Id = 'prodvid_credits_15000';
  
  // RevenueCat Entitlement
  static const String premiumEntitlement = 'premium';
  
  // Credits
  static const int weeklyCredits = 500;
  static const int yearlyCredits = 4000;
  static const int credits2000Amount = 2000;
  static const int credits7000Amount = 7000;
  static const int credits15000Amount = 15000;
  
  // Pricing (USD)
  static const double weeklyPrice = 19.99;
  static const double yearlyPrice = 199.99;
  static const double credits2000Price = 39.99;
  static const double credits7000Price = 99.99;
  static const double credits15000Price = 199;
  
  // Video Aspect Ratios
  static const String aspectRatio9x16 = '9:16';
  static const String aspectRatio16x9 = '16:9';
  static const String aspectRatio1x1 = '1:1';
  
  // Storage paths
  static const String userProductsPath = 'users/{userId}/products/{productId}';
  static const String userVideosPath = 'users/{userId}/videos/{videoId}';
  
  // Limits
  static const int maxProductImages = 10;
  static const int maxProductTitleLength = 100;
  static const int maxProductDescriptionLength = 500;
  static const int maxProductFeatures = 5;
  
  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration videoGenerationTimeout = Duration(minutes: 10);
}


