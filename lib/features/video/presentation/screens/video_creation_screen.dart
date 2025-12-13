import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class VideoCreationScreen extends StatefulWidget {
  const VideoCreationScreen({super.key});

  @override
  State<VideoCreationScreen> createState() => _VideoCreationScreenState();
}

class _VideoCreationScreenState extends State<VideoCreationScreen> {
  int _currentStep = 0;
  final List<String> _steps = ['Photos', 'Details', 'Template', 'Create'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Video'),
      ),
      body: Column(
        children: [
          // Step Indicator
          _StepIndicator(
            steps: _steps,
            currentStep: _currentStep,
          ),
          
          // Step Content
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _PhotosStep(onNext: () => _goToStep(1)),
                _DetailsStep(
                  onNext: () => _goToStep(2),
                  onBack: () => _goToStep(0),
                ),
                _TemplateStep(
                  onNext: () => _goToStep(3),
                  onBack: () => _goToStep(1),
                ),
                _CreateStep(onBack: () => _goToStep(2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.steps,
    required this.currentStep,
  });

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final stepIndex = index ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepIndex < currentStep
                    ? AppColors.primary
                    : AppColors.surfaceLight,
              ),
            );
          }
          
          // Step circle
          final stepIndex = index ~/ 2;
          final isActive = stepIndex == currentStep;
          final isCompleted = stepIndex < currentStep;
          
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted || isActive
                      ? AppColors.primary
                      : AppColors.surfaceLight,
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(color: AppColors.primaryLight, width: 2)
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.white : AppColors.textTertiary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
              ),
              AppSpacing.verticalXxs,
              Text(
                steps[stepIndex],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// Step 1: Photos
class _PhotosStep extends StatelessWidget {
  const _PhotosStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Product Photos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          AppSpacing.verticalXs,
          Text(
            'Upload up to 10 photos of your product',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          AppSpacing.verticalXl,
          
          // Photo upload area
          Expanded(
            child: GestureDetector(
              onTap: () {
                // TODO: Open image picker
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    AppSpacing.verticalMd,
                    Text(
                      'Tap to add photos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppSpacing.verticalXs,
                    Text(
                      'or drag and drop',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          AppSpacing.verticalLg,
          
          ElevatedButton(
            onPressed: onNext,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

// Step 2: Details
class _DetailsStep extends StatelessWidget {
  const _DetailsStep({required this.onNext, required this.onBack});

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          AppSpacing.verticalXs,
          Text(
            'Tell us about your product',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          AppSpacing.verticalXl,
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Product Title',
                      hintText: 'e.g., Premium Wireless Headphones',
                    ),
                  ),
                  
                  AppSpacing.verticalMd,
                  
                  TextFormField(
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe your product features and benefits...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  
                  AppSpacing.verticalMd,
                  
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price (Optional)',
                      hintText: r'$99.99',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          AppSpacing.verticalLg,
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  child: const Text('Back'),
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onNext,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Step 3: Template
class _TemplateStep extends StatefulWidget {
  const _TemplateStep({required this.onNext, required this.onBack});

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<_TemplateStep> createState() => _TemplateStepState();
}

class _TemplateStepState extends State<_TemplateStep> {
  int? _selectedTemplate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Template',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          AppSpacing.verticalXs,
          Text(
            'Select a style for your video',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          AppSpacing.verticalXl,
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 9 / 16,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                final isSelected = _selectedTemplate == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedTemplate = index);
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.play_circle_outline,
                                size: 48,
                                color: AppColors.textTertiary,
                              ),
                              AppSpacing.verticalSm,
                              Text(
                                'Template ${index + 1}',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          AppSpacing.verticalLg,
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  child: const Text('Back'),
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _selectedTemplate != null ? widget.onNext : null,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Step 4: Create
class _CreateStep extends StatelessWidget {
  const _CreateStep({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Video Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          AppSpacing.verticalXs,
          Text(
            'Choose aspect ratio and create your video',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          
          AppSpacing.verticalXl,
          
          // Aspect Ratio Selection
          Text(
            'Aspect Ratio',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          AppSpacing.verticalMd,
          
          Row(
            children: [
              _AspectRatioOption(
                label: '9:16',
                subtitle: 'Stories/Reels',
                isSelected: true,
                onTap: () {},
              ),
              AppSpacing.horizontalMd,
              _AspectRatioOption(
                label: '16:9',
                subtitle: 'YouTube',
                isSelected: false,
                onTap: () {},
              ),
              AppSpacing.horizontalMd,
              _AspectRatioOption(
                label: '1:1',
                subtitle: 'Feed',
                isSelected: false,
                onTap: () {},
              ),
            ],
          ),
          
          AppSpacing.verticalXl,
          
          // Credit info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: AppColors.warning),
                AppSpacing.horizontalMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This video will cost 50 credits',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        'You have 500 credits available',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  child: const Text('Back'),
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Start video creation
                  },
                  icon: const Icon(Icons.auto_awesome, color: Colors.white),
                  label: const Text('Create Video'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AspectRatioOption extends StatelessWidget {
  const _AspectRatioOption({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isSelected ? AppColors.primary : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.verticalXxs,
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


