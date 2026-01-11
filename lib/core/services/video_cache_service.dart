import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

/// Custom cache manager for video files
class VideoCacheManager {
  static const key = 'prodvid_video_cache';

  static final CacheManager _instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7), // Keep videos longer
      maxNrOfCacheObjects: 50, // More cache storage (disk is cheap, RAM is not)
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  static CacheManager get instance => _instance;

  /// Get cached video file or download it
  static Future<File?> getCachedVideo(String url) async {
    try {
      final fileInfo = await _instance.getFileFromCache(url);
      if (fileInfo != null) {
        return fileInfo.file;
      }

      // Download and cache
      final file = await _instance.getSingleFile(url);
      return file;
    } catch (e) {
      return null;
    }
  }

  /// Preload video to cache
  static Future<void> preloadVideo(String url) async {
    try {
      await _instance.getSingleFile(url);
    } catch (_) {
      // Ignore preload failures
    }
  }

  /// Preload multiple videos
  static Future<void> preloadVideos(List<String> urls) async {
    await Future.wait(
      urls.map(preloadVideo),
    );
  }

  /// Check if video is cached
  static Future<bool> isVideoCached(String url) async {
    final fileInfo = await _instance.getFileFromCache(url);
    return fileInfo != null;
  }

  /// Clear all cached videos
  static Future<void> clearCache() async {
    await _instance.emptyCache();
  }

  /// Get cache size
  static Future<int> getCacheSize() async {
    // Note: This is a simplified implementation
    // For accurate size, you'd need to iterate through cached files
    return 0;
  }
}

/// Provider for video cache manager
final videoCacheManagerProvider = Provider<CacheManager>((ref) {
  return VideoCacheManager.instance;
});

/// Cached video player controller
/// Creates a VideoPlayerController from cached file if available
class CachedVideoPlayerController {
  CachedVideoPlayerController._();

  /// Create a video player controller with caching support
  static Future<VideoPlayerController> create(String url) async {
    try {
      // Try to get from cache
      final cachedFile = await VideoCacheManager.getCachedVideo(url);

      if (cachedFile != null && await cachedFile.exists()) {
        return VideoPlayerController.file(cachedFile);
      }

      // Fallback to network
      return VideoPlayerController.networkUrl(Uri.parse(url));
    } catch (e) {
      // Fallback to network on any error
      return VideoPlayerController.networkUrl(Uri.parse(url));
    }
  }

  /// Create and initialize a video player controller with caching
  static Future<VideoPlayerController?> createAndInitialize(
    String url, {
    bool looping = true,
    double volume = 0,
    bool autoPlay = true,
  }) async {
    try {
      final controller = await create(url);

      await controller.initialize();
      controller.setLooping(looping);
      controller.setVolume(volume);

      if (autoPlay) {
        controller.play();
      }

      return controller;
    } catch (e) {
      return null;
    }
  }
}

/// Video preloader service
/// Preloads videos in the background for better UX
class VideoPreloader {
  static final Set<String> _preloadingUrls = {};
  static final Set<String> _preloadedUrls = {};

  /// Preload a video if not already preloaded or preloading
  static Future<void> preload(String url) async {
    if (_preloadedUrls.contains(url) || _preloadingUrls.contains(url)) {
      return;
    }

    _preloadingUrls.add(url);

    try {
      await VideoCacheManager.preloadVideo(url);
      _preloadedUrls.add(url);
    } finally {
      _preloadingUrls.remove(url);
    }
  }

  /// Preload multiple videos
  static Future<void> preloadAll(List<String> urls) async {
    final urlsToPreload = urls
        .where((url) =>
            !_preloadedUrls.contains(url) && !_preloadingUrls.contains(url))
        .toList();

    await Future.wait(
      urlsToPreload.map(preload),
    );
  }

  /// Check if a URL is preloaded
  static bool isPreloaded(String url) => _preloadedUrls.contains(url);

  /// Clear preload tracking (not the actual cache)
  static void clearTracking() {
    _preloadingUrls.clear();
    _preloadedUrls.clear();
  }
}

