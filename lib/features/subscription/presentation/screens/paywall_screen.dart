import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/services/revenuecat_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Paywall Screen - Shows subscription options and credit packs
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = false;
  String? _selectedPackageId;

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(offeringsProvider);
    final isProAsync = ref.watch(isProSubscriberProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.transparent,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Get Credits',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              TextButton(
                onPressed: _restorePurchases,
                child: const Text(
                  'Restore',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pro Status Banner
                  isProAsync.when(
                    data: (isPro) => isPro
                        ? _buildProBanner()
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 16),

                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.cyan],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.diamond,
                            size: 40,
                            color: Colors.white,
                          ),
                        ).animate().scale(delay: 100.ms),
                        const SizedBox(height: 16),
                        const Text(
                          'Power Your Creativity',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 8),
                        const Text(
                          'Get credits to generate amazing product videos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondaryDark,
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Offerings
                  offeringsAsync.when(
                    data: (offerings) => offerings != null
                        ? _buildOfferings(offerings)
                        : _buildNoOfferings(),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => _buildError(e.toString()),
                  ),

                  const SizedBox(height: 24),

                  // Features
                  _buildFeatures(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Purchase Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark,
          border: Border(
            top: BorderSide(
              color: AppColors.borderDark.withValues(alpha: 0.5),
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedPackageId != null && !_isLoading
                      ? _purchaseSelected
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: AppColors.slate700,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Secure payment powered by Apple',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1a2f1a), Color(0xFF0f1f0f)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00FF88).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00FF88), Color(0xFF00D9FF)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You\'re a Pro!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00FF88),
                  ),
                ),
                Text(
                  'Your subscription is active',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildOfferings(Offerings offerings) {
    final current = offerings.current;
    if (current == null) return _buildNoOfferings();

    // Separate subscriptions and consumables
    final subscriptions = <Package>[];
    final consumables = <Package>[];

    for (final package in current.availablePackages) {
      if (package.packageType == PackageType.weekly ||
          package.packageType == PackageType.monthly ||
          package.packageType == PackageType.annual ||
          package.packageType == PackageType.twoMonth ||
          package.packageType == PackageType.threeMonth ||
          package.packageType == PackageType.sixMonth) {
        subscriptions.add(package);
      } else {
        consumables.add(package);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subscriptions Section
        if (subscriptions.isNotEmpty) ...[
          _buildSectionHeader('Subscriptions', 'Best value • Credits reset on renewal'),
          const SizedBox(height: 12),
          ...subscriptions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPackageCard(entry.value, entry.key),
            );
          }),
          const SizedBox(height: 24),
        ],

        // Credit Packs Section
        if (consumables.isNotEmpty) ...[
          _buildSectionHeader('Credit Packs', 'One-time purchase • Never expires'),
          const SizedBox(height: 12),
          ...consumables.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPackageCard(
                entry.value,
                subscriptions.length + entry.key,
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(Package package, int index) {
    final isSelected = _selectedPackageId == package.identifier;
    final product = package.storeProduct;
    final credits = RevenueCatConfig.productCredits[product.identifier] ?? 0;
    
    // Determine if this is a subscription
    final isSubscription = package.packageType == PackageType.weekly ||
        package.packageType == PackageType.monthly ||
        package.packageType == PackageType.annual;

    // Badge text
    String? badge;
    if (package.packageType == PackageType.annual) {
      badge = 'BEST VALUE';
    } else if (package.packageType == PackageType.weekly) {
      badge = 'POPULAR';
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedPackageId = package.identifier);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDark,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.slate500,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        product.title.replaceAll(' (ProdVid)', ''),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$credits credits${isSubscription ? ' / ${_getDurationText(package.packageType)}' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.priceString,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (isSubscription)
                  Text(
                    _getDurationText(package.packageType),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().slideX(begin: 0.1);
  }

  String _getDurationText(PackageType type) {
    switch (type) {
      case PackageType.weekly:
        return 'week';
      case PackageType.monthly:
        return 'month';
      case PackageType.annual:
        return 'year';
      case PackageType.twoMonth:
        return '2 months';
      case PackageType.threeMonth:
        return '3 months';
      case PackageType.sixMonth:
        return '6 months';
      default:
        return '';
    }
  }

  Widget _buildFeatures() {
    final features = [
      ('⚡', 'Instant video generation'),
      ('🎬', 'Professional quality outputs'),
      ('🔒', 'Secure & private'),
      ('💳', 'Credits never expire'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What you get',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(f.$1, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Text(
                f.$2,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildNoOfferings() {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: AppColors.slate500,
          ),
          const SizedBox(height: 16),
          const Text(
            'No products available',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.refresh(offeringsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading products',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.error.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.refresh(offeringsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseSelected() async {
    if (_selectedPackageId == null) return;

    final offerings = ref.read(offeringsProvider).value;
    if (offerings?.current == null) return;

    final package = offerings!.current!.availablePackages.firstWhere(
      (p) => p.identifier == _selectedPackageId,
    );

    setState(() => _isLoading = true);

    try {
      final service = ref.read(revenueCatServiceProvider);
      final result = await service.purchasePackage(package);

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase successful! 🎉'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.message}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);

    try {
      final service = ref.read(revenueCatServiceProvider);
      final customerInfo = await service.restorePurchases();

      if (mounted) {
        if (customerInfo != null &&
            customerInfo.entitlements.active.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchases restored successfully! 🎉'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No purchases to restore'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

