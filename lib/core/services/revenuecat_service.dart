import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import 'analytics_service.dart';

/// RevenueCat API Keys
class RevenueCatConfig {
  // Production Apple API Key from RevenueCat
  static const String appleApiKey = 'appl_zgkeTghRVLdzNruXoZMrdLDBNup';

  // TODO: Add Google Play API key when ready
  static const String googleApiKey = '';

  /// Entitlement ID for Pro subscription
  static const String proEntitlementId = 'Prodvid Pro';

  /// Product IDs
  static const String creditsSmall = 'credits_3000';
  static const String creditsMedium = 'credits_7500';
  static const String creditsLarge = 'credits_15000';
  static const String proWeekly = 'weekly.prodvid.app';
  static const String proYearly = 'yearly.prodvid.app';

  /// Credit amounts for each product
  static const Map<String, int> productCredits = {
    creditsSmall: 3000,
    creditsMedium: 7500,
    creditsLarge: 15000,
    proWeekly: 1500,
    proYearly: 10000,
  };
}

/// RevenueCat Service Provider
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService(FirebaseAuth.instance, FirebaseFirestore.instance);
});

/// Customer info stream provider
final customerInfoProvider = StreamProvider<CustomerInfo?>((ref) {
  final service = ref.watch(revenueCatServiceProvider);
  return service.customerInfoStream;
});

/// Pro subscription status provider
final isProSubscriberProvider = StreamProvider<bool>((ref) {
  final customerInfo = ref.watch(customerInfoProvider);
  return customerInfo.when(
    data: (info) => Stream.value(
      info?.entitlements.active.containsKey(
            RevenueCatConfig.proEntitlementId,
          ) ??
          false,
    ),
    loading: () => Stream.value(false),
    error: (_, __) => Stream.value(false),
  );
});

/// Offerings provider
final offeringsProvider = FutureProvider<Offerings?>((ref) async {
  final service = ref.watch(revenueCatServiceProvider);
  return service.getOfferings();
});

/// RevenueCat Service
class RevenueCatService {
  RevenueCatService(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  final _customerInfoController = StreamController<CustomerInfo?>.broadcast();
  Stream<CustomerInfo?> get customerInfoStream =>
      _customerInfoController.stream;

  bool _isInitialized = false;

  /// Initialize RevenueCat SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Enable debug logging in debug mode
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }

      // Configure based on platform
      final configuration = PurchasesConfiguration(RevenueCatConfig.appleApiKey)
        ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat()
        ..shouldShowInAppMessagesAutomatically = true;

      await Purchases.configure(configuration);

      // Set up customer info listener
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      // Login with Firebase user ID if available
      final user = _auth.currentUser;
      if (user != null) {
        await loginUser(user.uid);
      }

      _isInitialized = true;
      debugPrint('✅ RevenueCat initialized successfully');
    } catch (e) {
      debugPrint('❌ RevenueCat initialization error: $e');
    }
  }

  /// Handle customer info updates
  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    debugPrint('📱 Customer info updated');
    _customerInfoController.add(customerInfo);

    // Sync subscription status with Firestore
    _syncSubscriptionStatus(customerInfo);
  }

  /// Sync subscription status with Firestore
  Future<void> _syncSubscriptionStatus(CustomerInfo customerInfo) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final isPro = customerInfo.entitlements.active.containsKey(
      RevenueCatConfig.proEntitlementId,
    );

    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userRef.get();
      
      if (userDoc.exists) {
        // Document exists, just update subscription status
        await userRef.update({
          'isSubscribed': isPro,
          'subscriptionExpiry': isPro
              ? customerInfo
                    .entitlements
                    .active[RevenueCatConfig.proEntitlementId]
                    ?.expirationDate
              : null,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        // Document doesn't exist, create without free credits (users must purchase)
        await userRef.set({
          'credits': 0, // No free credits - users must purchase
          'isSubscribed': isPro,
          'subscriptionExpiry': isPro
              ? customerInfo
                    .entitlements
                    .active[RevenueCatConfig.proEntitlementId]
                    ?.expirationDate
              : null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('📝 Created new user document with 100 initial credits');
      }
      debugPrint('✅ Subscription status synced to Firestore: isPro=$isPro');
    } catch (e) {
      debugPrint('❌ Error syncing subscription status: $e');
    }
  }

  /// Login user with RevenueCat
  Future<CustomerInfo?> loginUser(String userId) async {
    try {
      final result = await Purchases.logIn(userId);
      debugPrint('✅ RevenueCat user logged in: $userId');
      _customerInfoController.add(result.customerInfo);
      return result.customerInfo;
    } catch (e) {
      debugPrint('❌ RevenueCat login error: $e');
      return null;
    }
  }

  /// Logout user from RevenueCat
  Future<void> logoutUser() async {
    try {
      await Purchases.logOut();
      _customerInfoController.add(null);
      debugPrint('✅ RevenueCat user logged out');
    } catch (e) {
      debugPrint('❌ RevenueCat logout error: $e');
    }
  }

  /// Get current customer info
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('❌ Error getting customer info: $e');
      return null;
    }
  }

  /// Check if user has Pro entitlement
  Future<bool> isProSubscriber() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(
        RevenueCatConfig.proEntitlementId,
      );
    } catch (e) {
      debugPrint('❌ Error checking Pro status: $e');
      return false;
    }
  }

  /// Get available offerings
  Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      debugPrint('✅ Loaded ${offerings.all.length} offerings');
      return offerings;
    } catch (e) {
      debugPrint('❌ Error fetching offerings: $e');
      return null;
    }
  }

  /// Purchase a package
  /// Note: Credits are added via RevenueCat webhook, not client-side
  Future<PurchaseResult?> purchasePackage(Package package) async {
    try {
      final params = PurchaseParams.package(package);
      final result = await Purchases.purchase(params);

      debugPrint('✅ Purchase successful: ${package.identifier}');
      debugPrint('📡 Credits will be added via webhook');

      // Credits are now handled by RevenueCat webhook (revenuecatWebhook Cloud Function)
      // This ensures credits are added even if the app crashes after purchase

      return result;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('⚠️ User cancelled purchase');
        return null;
      }
      debugPrint('❌ Purchase error: ${e.message}');
      rethrow;
    }
  }

  // ==========================================================================
  // DEPRECATED: Credit handling is now done via RevenueCat webhooks
  // These methods are kept for reference but not actively used
  // ==========================================================================

  /// @deprecated Use RevenueCat webhook instead (revenuecatWebhook Cloud Function)
  /// Add credits to user account for consumable purchases
  @Deprecated('Credits are now handled via RevenueCat webhook')
  Future<void> addCreditsForPurchase(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final credits = RevenueCatConfig.productCredits[productId];
    if (credits == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'credits': FieldValue.increment(credits),
      });
      debugPrint('✅ Added $credits credits for $productId');
    } catch (e) {
      debugPrint('❌ Error adding credits: $e');
    }
  }

  /// @deprecated Use RevenueCat webhook instead (revenuecatWebhook Cloud Function)
  /// Handle subscription renewal - reset credits
  @Deprecated('Renewals are now handled via RevenueCat webhook')
  Future<void> handleSubscriptionRenewal(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final credits = RevenueCatConfig.productCredits[productId];
    if (credits == null) return;

    try {
      // For subscriptions, reset credits to the subscription amount
      await _firestore.collection('users').doc(user.uid).update({
        'credits': credits,
        'lastRenewal': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Reset credits to $credits for subscription renewal');
    } catch (e) {
      debugPrint('❌ Error handling renewal: $e');
    }
  }

  /// Restore purchases
  Future<CustomerInfo?> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      debugPrint('✅ Purchases restored');
      _customerInfoController.add(customerInfo);

      // Sync with Firestore
      await _syncSubscriptionStatus(customerInfo);

      return customerInfo;
    } catch (e) {
      debugPrint('❌ Error restoring purchases: $e');
      return null;
    }
  }

  /// Present RevenueCat Paywall
  Future<PaywallResult> presentPaywall({Offering? offering, String paywallType = 'default'}) async {
    try {
      // Log analytics: paywall view
      await AnalyticsService().logPaywallView(paywallType: paywallType);

      final result = await RevenueCatUI.presentPaywall(
        offering: offering,
        displayCloseButton: true,
      );

      debugPrint('📱 Paywall result: $result');

      if (result == PaywallResult.purchased ||
          result == PaywallResult.restored) {
        // Log analytics: subscription/credit purchase
        if (paywallType == 'subscription') {
          await AnalyticsService().logSubscriptionPurchase(
            productId: offering?.availablePackages.first.storeProduct.identifier ?? 'unknown',
            offeringId: offering?.identifier ?? 'unknown',
          );
        } else if (paywallType == 'credits') {
          await AnalyticsService().logCreditsPurchase(
            productId: offering?.availablePackages.first.storeProduct.identifier ?? 'unknown',
            credits: 0, // Credits determined by webhook
          );
        }

        // Refresh customer info
        final customerInfo = await getCustomerInfo();
        if (customerInfo != null) {
          await _syncSubscriptionStatus(customerInfo);
        }
      }

      return result;
    } catch (e) {
      debugPrint('❌ Paywall error: $e');
      return PaywallResult.error;
    }
  }

  /// Present subscription paywall (default offering)
  Future<PaywallResult> presentSubscriptionPaywall() async {
    try {
      final offerings = await getOfferings();
      return presentPaywall(offering: offerings?.current, paywallType: 'subscription');
    } catch (e) {
      debugPrint('❌ Subscription paywall error: $e');
      return PaywallResult.error;
    }
  }

  /// Present credits paywall
  Future<PaywallResult> presentCreditsPaywall() async {
    try {
      final offerings = await getOfferings();
      return presentPaywall(offering: offerings?.getOffering('credits'), paywallType: 'credits');
    } catch (e) {
      debugPrint('❌ Credits paywall error: $e');
      return PaywallResult.error;
    }
  }

  /// Present Paywall if user doesn't have Pro entitlement
  Future<PaywallResult> presentPaywallIfNeeded() async {
    try {
      final result = await RevenueCatUI.presentPaywallIfNeeded(
        RevenueCatConfig.proEntitlementId,
        displayCloseButton: true,
      );

      debugPrint('📱 Paywall if needed result: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Paywall error: $e');
      return PaywallResult.error;
    }
  }

  /// Present Customer Center
  Future<void> presentCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter(
        onRestoreCompleted: (customerInfo) {
          debugPrint('✅ Restore completed from Customer Center');
          _customerInfoController.add(customerInfo);
          _syncSubscriptionStatus(customerInfo);
        },
        onRefundRequestCompleted: (productId, status) {
          debugPrint('📱 Refund request completed: $productId - $status');
        },
      );
    } catch (e) {
      debugPrint('❌ Customer Center error: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _customerInfoController.close();
  }
}
