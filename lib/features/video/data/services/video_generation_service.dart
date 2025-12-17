// This service is deprecated and no longer used.
// Video generation is now handled directly in effect_detail_screen.dart
// which calls WiroService with File objects.
//
// Keeping this file for backwards compatibility but it should not be used.

// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'wiro_service.dart';

/// Video generation service provider (DEPRECATED)
@Deprecated('Use wiroServiceProvider directly')
final videoGenerationServiceProvider = Provider<VideoGenerationService>((ref) {
  return VideoGenerationService(wiroService: ref.watch(wiroServiceProvider));
});

/// High-level service for video generation workflow (DEPRECATED)
///
/// This service is no longer used. Video generation is handled directly
/// in effect_detail_screen.dart which calls WiroService with File objects.
@Deprecated('Use WiroService directly from effect_detail_screen.dart')
class VideoGenerationService {
  @Deprecated('Use WiroService directly from effect_detail_screen.dart')
  VideoGenerationService({required WiroService wiroService})
    : _wiroService = wiroService;

  // ignore: unused_field
  final WiroService _wiroService;
}
