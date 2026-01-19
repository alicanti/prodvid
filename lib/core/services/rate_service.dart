import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling in-app review/rating prompts
class RateService {
  static final RateService _instance = RateService._internal();
  factory RateService() => _instance;
  RateService._internal();

  static const String _firstGenerationDoneKey = 'first_generation_done';
  static const String _hasRequestedReviewKey = 'has_requested_review';

  final InAppReview _inAppReview = InAppReview.instance;

  /// Check if this is the first successful generation and show rate dialog
  Future<void> checkAndShowRateDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if we've already requested a review
      final hasRequestedReview = prefs.getBool(_hasRequestedReviewKey) ?? false;
      if (hasRequestedReview) {
        debugPrint('📊 Rate dialog already shown before');
        return;
      }

      // Check if this is the first generation
      final firstGenDone = prefs.getBool(_firstGenerationDoneKey) ?? false;
      
      if (!firstGenDone) {
        // Mark first generation as done
        await prefs.setBool(_firstGenerationDoneKey, true);
        
        // Show rate dialog
        if (await _inAppReview.isAvailable()) {
          debugPrint('📊 Showing rate dialog after first generation');
          await _inAppReview.requestReview();
          await prefs.setBool(_hasRequestedReviewKey, true);
        } else {
          debugPrint('📊 In-app review not available');
        }
      }
    } catch (e) {
      debugPrint('📊 Error showing rate dialog: $e');
    }
  }

  /// Force show the app store page (for manual "Rate Us" button)
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing(
        appStoreId: '6756788605', // ProdVid App Store ID
      );
    } catch (e) {
      debugPrint('📊 Error opening store listing: $e');
    }
  }

  /// Reset rate dialog state (for testing)
  Future<void> resetRateState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstGenerationDoneKey);
    await prefs.remove(_hasRequestedReviewKey);
    debugPrint('📊 Rate state reset');
  }
}

