import 'package:firebase_analytics/firebase_analytics.dart';

/// Service for tracking analytics events
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get the analytics observer for navigation tracking
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  /// Log when user completes onboarding
  Future<void> logOnboardingComplete() async {
    await _analytics.logEvent(name: 'onboarding_complete');
  }

  /// Log when user views a paywall
  Future<void> logPaywallView({required String paywallType}) async {
    await _analytics.logEvent(
      name: 'paywall_view',
      parameters: {'paywall_type': paywallType},
    );
  }

  /// Log when user purchases a subscription
  Future<void> logSubscriptionPurchase({
    required String productId,
    required String offeringId,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_purchase',
      parameters: {
        'product_id': productId,
        'offering_id': offeringId,
      },
    );
  }

  /// Log when user purchases credits
  Future<void> logCreditsPurchase({
    required String productId,
    required int credits,
  }) async {
    await _analytics.logEvent(
      name: 'credits_purchase',
      parameters: {
        'product_id': productId,
        'credits': credits,
      },
    );
  }

  /// Log when video generation starts
  Future<void> logVideoGenerationStarted({
    required String effectType,
    required String videoMode,
  }) async {
    await _analytics.logEvent(
      name: 'video_generation_started',
      parameters: {
        'effect_type': effectType,
        'video_mode': videoMode,
      },
    );
  }

  /// Log when video generation succeeds
  Future<void> logVideoGenerationSuccess({
    required String effectType,
    required String videoMode,
  }) async {
    await _analytics.logEvent(
      name: 'video_generation_success',
      parameters: {
        'effect_type': effectType,
        'video_mode': videoMode,
      },
    );
  }

  /// Log when video generation fails
  Future<void> logVideoGenerationFailed({
    required String effectType,
    required String error,
  }) async {
    await _analytics.logEvent(
      name: 'video_generation_failed',
      parameters: {
        'effect_type': effectType,
        'error': error,
      },
    );
  }

  /// Log when user has low credits
  Future<void> logCreditsLow({required int currentCredits}) async {
    await _analytics.logEvent(
      name: 'credits_low',
      parameters: {'current_credits': currentCredits},
    );
  }

  /// Log when user shares a video
  Future<void> logVideoShared() async {
    await _analytics.logEvent(name: 'video_shared');
  }

  /// Log when user downloads a video
  Future<void> logVideoDownloaded() async {
    await _analytics.logEvent(name: 'video_downloaded');
  }

  /// Log screen view
  Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}

