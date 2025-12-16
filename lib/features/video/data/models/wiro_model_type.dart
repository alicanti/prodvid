/// Wiro API model types (endpoints)
enum WiroModelType {
  textAnimations(
    'wiro/3d-text-animations',
    '3D Text Animations',
    'Create stunning 3D animated text videos with 22+ creative presets.',
    WiroInputType.textOnly,
    'https://cdn.wiro.ai/uploads/models/wiro-3d-text-animations-cover.mp4',
  ),
  productAds(
    'wiro/product-ads',
    'Product Ads',
    'Transform product images into stunning animated video ads with 100+ creative presets.',
    WiroInputType.imageOnly,
    'https://cdn.wiro.ai/uploads/models/wiro-product-ads-cover.mp4',
  ),
  productAdsWithCaption(
    'wiro/product-ads-with-caption',
    'Product Ads with Caption',
    'Combine product images with custom captions into stunning animated video ads.',
    WiroInputType.imageAndText,
    'https://cdn.wiro.ai/uploads/models/wiro-product-ads-with-caption-cover.mp4',
  ),
  productAdsWithLogo(
    'wiro/product-ads-with-logo',
    'Product Ads with Logo',
    'Combine product images with logos into stunning animated video ads.',
    WiroInputType.imageAndLogo,
    'https://cdn.wiro.ai/uploads/models/wiro-product-ads-with-logo-cover.mp4',
  );

  const WiroModelType(
    this.endpoint,
    this.label,
    this.description,
    this.inputType,
    this.coverUrl,
  );

  final String endpoint;
  final String label;
  final String description;
  final WiroInputType inputType;
  final String coverUrl;

  /// Get the full API URL for running this model
  String get runUrl => 'https://api.wiro.ai/v1/Run/$endpoint';

  /// Check if this model requires an image
  bool get requiresImage => inputType != WiroInputType.textOnly;

  /// Check if this model requires a caption
  bool get requiresCaption =>
      inputType == WiroInputType.textOnly ||
      inputType == WiroInputType.imageAndText;

  /// Check if this model requires a logo
  bool get requiresLogo => inputType == WiroInputType.imageAndLogo;

  static WiroModelType? fromEndpoint(String endpoint) {
    try {
      return WiroModelType.values.firstWhere((e) => e.endpoint == endpoint);
    } catch (_) {
      return null;
    }
  }
}

/// Input types for Wiro models
enum WiroInputType {
  textOnly('Text Only'),
  imageOnly('Image Only'),
  imageAndText('Image + Text'),
  imageAndLogo('Image + Logo');

  const WiroInputType(this.label);

  final String label;
}

