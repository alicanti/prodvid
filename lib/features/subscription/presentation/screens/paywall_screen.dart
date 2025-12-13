import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _selectedPlan = 'yearly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.pagePadding,
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: AppColors.premiumGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    
                    AppSpacing.verticalLg,
                    
                    Text(
                      'Unlock ProdVid Pro',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    AppSpacing.verticalSm,
                    
                    Text(
                      'Create unlimited professional videos',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    AppSpacing.verticalXl,
                    
                    // Features
                    const _FeatureItem(
                      icon: Icons.all_inclusive,
                      title: 'Access All Templates',
                      description: 'Premium templates for every style',
                    ),
                    const _FeatureItem(
                      icon: Icons.hd,
                      title: 'HD Video Export',
                      description: 'High quality without watermarks',
                    ),
                    const _FeatureItem(
                      icon: Icons.bolt,
                      title: 'Monthly Credits',
                      description: 'Credits refresh with your subscription',
                    ),
                    const _FeatureItem(
                      icon: Icons.support_agent,
                      title: 'Priority Support',
                      description: 'Get help when you need it',
                    ),
                    
                    AppSpacing.verticalXl,
                    
                    // Plan Selection
                    _PlanCard(
                      title: 'Yearly',
                      price: '\$${AppConstants.yearlyPrice.toStringAsFixed(2)}',
                      period: '/year',
                      credits: '${AppConstants.yearlyCredits} credits',
                      savings: 'Save 80%',
                      isSelected: _selectedPlan == 'yearly',
                      onTap: () => setState(() => _selectedPlan = 'yearly'),
                    ),
                    
                    AppSpacing.verticalMd,
                    
                    _PlanCard(
                      title: 'Weekly',
                      price: '\$${AppConstants.weeklyPrice.toStringAsFixed(2)}',
                      period: '/week',
                      credits: '${AppConstants.weeklyCredits} credits',
                      isSelected: _selectedPlan == 'weekly',
                      onTap: () => setState(() => _selectedPlan = 'weekly'),
                    ),
                    
                    AppSpacing.verticalXl,
                    
                    // Credit packs section
                    Text(
                      'Or buy credits',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    AppSpacing.verticalMd,
                    
                    Row(
                      children: [
                        Expanded(
                          child: _CreditPackCard(
                            credits: '${AppConstants.credits2000Amount}',
                            price: '\$${AppConstants.credits2000Price.toStringAsFixed(2)}',
                            onTap: () {},
                          ),
                        ),
                        AppSpacing.horizontalSm,
                        Expanded(
                          child: _CreditPackCard(
                            credits: '${AppConstants.credits7000Amount}',
                            price: '\$${AppConstants.credits7000Price.toStringAsFixed(2)}',
                            badge: '+40%',
                            onTap: () {},
                          ),
                        ),
                        AppSpacing.horizontalSm,
                        Expanded(
                          child: _CreditPackCard(
                            credits: '${AppConstants.credits15000Amount}',
                            price: '\$${AppConstants.credits15000Price.toStringAsFixed(0)}',
                            badge: '+50%',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Subscribe button
            Padding(
              padding: AppSpacing.pagePadding.copyWith(top: 0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Handle subscription purchase
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(
                      _selectedPlan == 'yearly'
                          ? 'Subscribe Yearly - \$${AppConstants.yearlyPrice}'
                          : 'Subscribe Weekly - \$${AppConstants.weeklyPrice}',
                    ),
                  ),
                  
                  AppSpacing.verticalSm,
                  
                  Text(
                    'Cancel anytime. Terms apply.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  
                  AppSpacing.verticalSm,
                  
                  TextButton(
                    onPressed: () {
                      // TODO: Restore purchases
                    },
                    child: const Text('Restore Purchases'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          AppSpacing.horizontalMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.credits,
    required this.isSelected,
    required this.onTap,
    this.savings,
  });

  final String title;
  final String price;
  final String period;
  final String credits;
  final String? savings;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (savings != null) ...[
                        AppSpacing.horizontalSm,
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            savings!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    credits,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  period,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditPackCard extends StatelessWidget {
  const _CreditPackCard({
    required this.credits,
    required this.price,
    required this.onTap,
    this.badge,
  });

  final String credits;
  final String price;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bolt, color: AppColors.warning, size: 16),
                Text(
                  credits,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              price,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


