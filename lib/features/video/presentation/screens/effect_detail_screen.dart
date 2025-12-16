import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/video_cache_service.dart';
import '../../data/models/wiro_effect_type.dart';
import '../../data/models/wiro_model_type.dart';

/// Effect detail screen for configuring and generating videos
class EffectDetailScreen extends StatefulWidget {
  const EffectDetailScreen({
    super.key,
    required this.modelType,
    required this.effectType,
    required this.effectLabel,
  });

  final WiroModelType modelType;
  final String effectType;
  final String effectLabel;

  @override
  State<EffectDetailScreen> createState() => _EffectDetailScreenState();
}

class _EffectDetailScreenState extends State<EffectDetailScreen> {
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
      // Use cached video player for better performance
      _videoController = await CachedVideoPlayerController.create(_coverUrl);
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
    final XFile? image = await _picker.pickImage(
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
    final XFile? image = await _picker.pickImage(
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

    setState(() {
      _isGenerating = true;
    });

    // TODO: Implement actual generation with WiroService
    // For now, simulate and navigate to export
    await Future<void>.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isGenerating = false;
      });

      // Navigate to export/processing screen
      context.push('/video-export', extra: {
        'modelType': widget.modelType,
        'effectType': widget.effectType,
        'caption': _captionController.text,
        'videoMode': _videoMode,
      });
    }
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
                border: Border(bottom: BorderSide(color: AppColors.borderDark)),
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
                      style: TextStyle(
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
              Container(
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
        aspectRatio: 1.0,
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
          Text(
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
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hint,
                    style: TextStyle(
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
    return Container(
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
        decoration: InputDecoration(
          hintText: 'Enter short text (1-2 words recommended)\ne.g., SALE, New Arrival, 50% OFF',
          hintStyle: TextStyle(
            color: AppColors.textSecondaryDark,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
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
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: mode == WiroVideoMode.standard ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _videoMode = mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderDark,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          mode == WiroVideoMode.standard
                              ? Icons.sd
                              : Icons.hd,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondaryDark,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mode.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                        if (mode == WiroVideoMode.pro) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Better quality',
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? Colors.white70
                                  : AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
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
      decoration: BoxDecoration(
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
                ? Row(
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
                      const SizedBox(width: 12),
                      const Text(
                        'Generating...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
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
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
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

