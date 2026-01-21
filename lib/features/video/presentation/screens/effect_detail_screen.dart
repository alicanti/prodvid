import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/background_task_service.dart';
import '../../../../core/services/rate_service.dart';
import '../../../../core/services/revenuecat_service.dart';
import '../../../../core/services/video_cache_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../router/app_router.dart';
import '../../data/models/wiro_effect_type.dart';
import '../../data/models/wiro_model_type.dart';

/// Effect detail screen for configuring and generating videos
class EffectDetailScreen extends ConsumerStatefulWidget {
  const EffectDetailScreen({
    required this.modelType, required this.effectType, required this.effectLabel, super.key,
  });

  final WiroModelType modelType;
  final String effectType;
  final String effectLabel;

  @override
  ConsumerState<EffectDetailScreen> createState() => _EffectDetailScreenState();
}

class _EffectDetailScreenState extends ConsumerState<EffectDetailScreen> {
  final _captionController = TextEditingController();
  File? _productImage;
  File? _logoImage;
  WiroVideoMode _videoMode = WiroVideoMode.standard;
  bool _isGenerating = false;

  final ImagePicker _picker = ImagePicker();

  // Video preview
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;

  /// Get the cover URL for this effect
  String get _coverUrl => widget.modelType.getCoverUrl(widget.effectType);

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _captionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      // Try cached file first, then fall back to network
      try {
        final file = await VideoCacheManager.instance.getSingleFile(_coverUrl);
        _videoController = VideoPlayerController.file(file);
      } catch (_) {
        // Fall back to network
        _videoController = VideoPlayerController.networkUrl(Uri.parse(_coverUrl));
      }
      
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.setVolume(0);
      _videoController!.play();

      if (mounted) {
        setState(() => _isVideoInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasVideoError = true);
      }
    }
  }

  /// Open full-screen effect gallery
  void _openGallery() {
    // Find current effect index
    final effects = WiroEffects.getEffectsForModel(widget.modelType);
    final currentIndex = effects.indexWhere((e) => e.value == widget.effectType);

    context.push('/effect-gallery', extra: {
      'modelType': widget.modelType,
      'initialIndex': currentIndex >= 0 ? currentIndex : 0,
    });
  }

  bool get _canGenerate {
    switch (widget.modelType.inputType) {
      case WiroInputType.textOnly:
        return _captionController.text.trim().isNotEmpty;
      case WiroInputType.imageOnly:
        return _productImage != null;
      case WiroInputType.imageAndText:
        return _productImage != null &&
            _captionController.text.trim().isNotEmpty;
      case WiroInputType.imageAndLogo:
        return _productImage != null && _logoImage != null;
    }
  }

  Future<void> _pickProductImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );
    if (image != null) {
      setState(() {
        _productImage = File(image.path);
      });
    }
  }

  Future<void> _pickLogoImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );
    if (image != null) {
      setState(() {
        _logoImage = File(image.path);
      });
    }
  }

  Future<void> _generate() async {
    if (!_canGenerate) return;

    // Get credit info for confirmation dialog
    final credits = ref.read(userCreditsProvider).valueOrNull ?? 0;
    final requiredCredits = _videoMode == WiroVideoMode.pro ? 210 : 70;

    // Show credit confirmation dialog
    final confirmed = await _showCreditConfirmationDialog(credits, requiredCredits);
    if (!confirmed) return;

    // Haptic feedback when generation starts
    HapticFeedback.mediumImpact();

    setState(() {
      _isGenerating = true;
    });

    try {
      // Ensure user is authenticated
      final authService = ref.read(authServiceProvider);
      if (!authService.isSignedIn) {
        debugPrint('🔐 User not signed in, signing in anonymously...');
        await authService.signInAnonymously();
      }
      
      // Client-side credit check before API request
      final isSubscribed = ref.read(userSubscriptionProvider).valueOrNull ?? false;
      
      if (credits < requiredCredits) {
        // Show appropriate paywall
        final service = ref.read(revenueCatServiceProvider);
        final result = isSubscribed
            ? await service.presentCreditsPaywall()
            : await service.presentSubscriptionPaywall();
        
        if (result != PaywallResult.purchased && result != PaywallResult.restored) {
          // User cancelled - stop generation
          setState(() => _isGenerating = false);
          return;
        }
        
        // Wait for webhook to process credits
        await Future<void>.delayed(const Duration(seconds: 2));
        ref.invalidate(userCreditsProvider);
        
        // Re-check credits after purchase
        final newCredits = ref.read(userCreditsProvider).valueOrNull ?? 0;
        if (newCredits < requiredCredits) {
          setState(() => _isGenerating = false);
          _showErrorDialog('Insufficient credits. Please purchase more.');
          return;
        }
      }
      
      final taskService = ref.read(backgroundTaskServiceProvider);
      final videoModeStr = _videoMode == WiroVideoMode.pro ? 'pro' : 'std';
      
      // Step 1: Prepare generation (check credits, deduct, get API credentials)
      final prepareResult = await taskService.prepareGeneration(
        modelType: widget.modelType.endpoint.replaceFirst('https://api.wiro.ai/v1/Run/', ''),
        effectType: widget.effectType,
        videoMode: videoModeStr,
      );

      if (!mounted) return;

      if (!prepareResult.success) {
        setState(() => _isGenerating = false);
        _showErrorDialog(prepareResult.error ?? 'Failed to prepare generation');
        return;
      }

      // Log analytics: generation started
      await AnalyticsService().logVideoGenerationStarted(
        effectType: widget.effectType,
        videoMode: videoModeStr,
      );

      // Step 2: Read image bytes
      final productBytes = _productImage != null 
          ? await _productImage!.readAsBytes() 
          : null;
      final logoBytes = _logoImage != null 
          ? await _logoImage!.readAsBytes() 
          : null;

      // Step 3: Start generation (calls Wiro API directly)
      final startResult = await taskService.startGeneration(
        tempTaskId: prepareResult.tempTaskId!,
        modelType: widget.modelType.endpoint.replaceFirst('https://api.wiro.ai/v1/Run/', ''),
        effectType: widget.effectType,
        videoMode: videoModeStr,
        productImage: productBytes,
        logoImage: logoBytes,
        caption: _captionController.text.trim().isNotEmpty 
            ? _captionController.text.trim() 
            : null,
      );

      if (!mounted) return;

      if (!startResult.success) {
        setState(() => _isGenerating = false);
        // Log analytics: generation failed
        await AnalyticsService().logVideoGenerationFailed(
          effectType: widget.effectType,
          error: startResult.error ?? 'Unknown error',
        );
        _showErrorDialog(startResult.error ?? 'Failed to start generation');
        return;
      }

      // Log analytics: generation success
      await AnalyticsService().logVideoGenerationSuccess(
        effectType: widget.effectType,
        videoMode: videoModeStr,
      );

      // Show rate dialog after first successful generation
      await RateService().checkAndShowRateDialog();

      // Success! Haptic feedback and show success message
      HapticFeedback.heavyImpact();
      setState(() => _isGenerating = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Video generation started! Check My Videos for progress.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () => context.go(AppRoutes.videos),
            ),
          ),
        );
        
        // Navigate back or to My Videos
        context.go(AppRoutes.videos);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        // Log analytics: generation failed
        await AnalyticsService().logVideoGenerationFailed(
          effectType: widget.effectType,
          error: e.toString(),
        );
        _showErrorDialog(e.toString());
      }
    }
  }

  Future<bool> _showCreditConfirmationDialog(int currentCredits, int requiredCredits) async {
    HapticFeedback.lightImpact();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Confirm Generation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cost',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                      ),
                      Text(
                        '$requiredCredits credits',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your balance',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                      ),
                      Text(
                        '$currentCredits credits',
                        style: TextStyle(
                          color: currentCredits >= requiredCredits 
                              ? AppColors.success 
                              : AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (currentCredits >= requiredCredits) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'After generation',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                        ),
                        Text(
                          '${currentCredits - requiredCredits} credits',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (currentCredits < requiredCredits) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Not enough credits. You\'ll be prompted to purchase.',
                        style: TextStyle(
                          color: AppColors.error.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context, false);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context, true);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  void _showErrorDialog(String message) {
    HapticFeedback.heavyImpact();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Generation Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Column(
        children: [
          // App Bar
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withValues(alpha: 0.95),
                border: const Border(bottom: BorderSide(color: AppColors.borderDark)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      widget.effectLabel,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Effect Preview Card (tappable to open gallery)
                  GestureDetector(
                    onTap: _openGallery,
                    child: _buildEffectPreview(),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.1, end: 0),

                  const SizedBox(height: 24),

                  // Model Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.modelType.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input Fields based on model type
                  ..._buildInputFields(),

                  const SizedBox(height: 24),

                  // Video Mode Selection
                  _buildVideoModeSelector(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Generate Button
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildEffectPreview() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getEffectGradient().first.withValues(alpha: 0.4),
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
            // Video or gradient fallback
            if (_isVideoInitialized && !_hasVideoError && _videoController != null)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              )
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getEffectGradient(),
                  ),
                ),
                child: Stack(
                  children: [
                    // Pattern overlay
                    CustomPaint(
                      size: Size.infinite,
                      painter: _PatternPainter(),
                    ),
                    // Loading or icon
                    Center(
                      child: _hasVideoError
                          ? Icon(
                              _getModelIcon(),
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.8),
                            )
                          : SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

            // Bottom gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),

            // Effect name at bottom
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                widget.effectLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),

            // Video playing indicator
            if (_isVideoInitialized && !_hasVideoError)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Preview',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Expand icon (tap to open gallery)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildInputFields() {
    final widgets = <Widget>[];

    // Product Image (for all except text-only)
    if (widget.modelType.requiresImage) {
      widgets.add(_buildSectionTitle('Product Image', Icons.image));
      widgets.add(const SizedBox(height: 12));
      widgets.add(_buildImagePicker(
        image: _productImage,
        onPick: _pickProductImage,
        hint: 'Tap to select product image',
      ));
      widgets.add(const SizedBox(height: 24));
    }

    // Logo Image (for logo model)
    if (widget.modelType.requiresLogo) {
      widgets.add(_buildSectionTitle('Logo Image', Icons.branding_watermark));
      widgets.add(const SizedBox(height: 12));
      widgets.add(_buildImagePicker(
        image: _logoImage,
        onPick: _pickLogoImage,
        hint: 'Tap to select logo image',
        aspectRatio: 1,
      ));
      widgets.add(const SizedBox(height: 24));
    }

    // Caption (for text and caption models)
    if (widget.modelType.requiresCaption) {
      widgets.add(_buildSectionTitle('Caption Text', Icons.text_fields));
      widgets.add(const SizedBox(height: 12));
      widgets.add(_buildCaptionInput());
    }

    return widgets;
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        if (_isRequiredField(title))
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
      ],
    );
  }

  bool _isRequiredField(String title) {
    if (title.contains('Product') && widget.modelType.requiresImage) {
      return true;
    }
    if (title.contains('Logo') && widget.modelType.requiresLogo) return true;
    if (title.contains('Caption') && widget.modelType.requiresCaption) {
      return true;
    }
    return false;
  }

  Widget _buildImagePicker({
    required File? image,
    required VoidCallback onPick,
    required String hint,
    double aspectRatio = 1.5,
  }) {
    return GestureDetector(
      onTap: onPick,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: image != null ? AppColors.primary : AppColors.borderDark,
            width: image != null ? 2 : 1,
          ),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      image,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onPick,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hint,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCaptionInput() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: TextField(
        controller: _captionController,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        maxLines: 3,
        maxLength: 50,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          hintText: 'Enter short text (1-2 words recommended)\ne.g., SALE, New Arrival, 50% OFF',
          hintStyle: TextStyle(
            color: AppColors.textSecondaryDark,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          counterStyle: TextStyle(color: AppColors.textSecondaryDark),
        ),
      ),
    );
  }

  Widget _buildVideoModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Video Quality', Icons.high_quality),
        const SizedBox(height: 12),
        Row(
          children: WiroVideoMode.values.map((mode) {
            final isSelected = _videoMode == mode;
            final isStandard = mode == WiroVideoMode.standard;
            final credits = isStandard ? 120 : 210;
            
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: isStandard ? 8 : 0,
                  left: isStandard ? 0 : 8,
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _videoMode = mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderDark,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Icon(
                          isStandard ? Icons.sd : Icons.hd,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondaryDark,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        // Label
                        Text(
                          mode.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Description
                        Text(
                          isStandard ? 'Good quality' : 'Best quality',
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected
                                ? Colors.white70
                                : AppColors.textSecondaryDark.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Credits badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.2)
                                : AppColors.backgroundDark,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt,
                                size: 14,
                                color: isSelected
                                    ? Colors.amber
                                    : AppColors.textSecondaryDark,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$credits',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: AppColors.borderDark)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _canGenerate && !_isGenerating ? _generate : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: _canGenerate ? 8 : 0,
              shadowColor: AppColors.primary.withValues(alpha: 0.5),
            ),
            child: _isGenerating
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Generating...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Generate Video',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  List<Color> _getEffectGradient() {
    final effectValue = widget.effectType.toLowerCase();

    if (effectValue.contains('balloon')) {
      return [const Color(0xFFfa709a), const Color(0xFFfee140)];
    }
    if (effectValue.contains('neon')) {
      return [const Color(0xFF00f2fe), const Color(0xFF4facfe)];
    }
    if (effectValue.contains('water') || effectValue.contains('splash')) {
      return [const Color(0xFF667eea), const Color(0xFF764ba2)];
    }
    if (effectValue.contains('fire') || effectValue.contains('hot')) {
      return [const Color(0xFFf5af19), const Color(0xFFf12711)];
    }
    if (effectValue.contains('snow') || effectValue.contains('winter')) {
      return [const Color(0xFF74ebd5), const Color(0xFFACB6E5)];
    }
    if (effectValue.contains('christmas') || effectValue.contains('santa')) {
      return [const Color(0xFF11998e), const Color(0xFF38ef7d)];
    }
    if (effectValue.contains('gold')) {
      return [const Color(0xFFf5af19), const Color(0xFFf12711)];
    }
    if (effectValue.contains('smoke') || effectValue.contains('mist')) {
      return [const Color(0xFF2c3e50), const Color(0xFF4ca1af)];
    }
    if (effectValue.contains('black') || effectValue.contains('friday')) {
      return [const Color(0xFF232526), const Color(0xFF414345)];
    }

    // Default based on model type
    switch (widget.modelType) {
      case WiroModelType.textAnimations:
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
      case WiroModelType.productAds:
        return [const Color(0xFF00f2fe), const Color(0xFF4facfe)];
      case WiroModelType.productAdsWithCaption:
        return [const Color(0xFFfa709a), const Color(0xFFfee140)];
      case WiroModelType.productAdsWithLogo:
        return [const Color(0xFF2c3e50), const Color(0xFF4ca1af)];
    }
  }

  IconData _getModelIcon() {
    switch (widget.modelType) {
      case WiroModelType.textAnimations:
        return Icons.text_fields;
      case WiroModelType.productAds:
        return Icons.image;
      case WiroModelType.productAdsWithCaption:
        return Icons.subtitles;
      case WiroModelType.productAdsWithLogo:
        return Icons.branding_watermark;
    }
  }
}

/// Custom painter for pattern overlay
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const spacing = 30.0;
    for (var i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

