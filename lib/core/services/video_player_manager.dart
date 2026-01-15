import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import 'video_cache_service.dart';

/// Manages video player instances globally to limit RAM usage
/// Only allows a maximum number of concurrent video players
class VideoPlayerManager {
  VideoPlayerManager._();

  static final VideoPlayerManager instance = VideoPlayerManager._();

  /// Maximum number of concurrent video players
  /// Balance between smooth UX and memory usage
  static const int maxConcurrentPlayers = 6;

  /// Active video controllers (URL -> Controller)
  final LinkedHashMap<String, _ManagedController> _controllers =
      LinkedHashMap();

  /// Pending video requests
  final Map<String, Completer<VideoPlayerController?>> _pending = {};

  /// Disposed URLs tracking - to prevent using disposed controllers
  final Set<String> _disposedUrls = {};

  /// Get or create a video controller for a URL
  /// Returns null if too many players are active and this one can't be prioritized
  Future<VideoPlayerController?> getController(
    String url, {
    bool highPriority = false,
  }) async {
    // Clear from disposed tracking since we're requesting it fresh
    _disposedUrls.remove(url);

    // If already pending, wait for it
    if (_pending.containsKey(url)) {
      return _pending[url]!.future;
    }

    // If already active, move to end (most recently used) and return
    if (_controllers.containsKey(url)) {
      final managed = _controllers.remove(url)!;
      _controllers[url] = managed..lastUsed = DateTime.now();
      return managed.controller;
    }

    // Need to create new controller
    final completer = Completer<VideoPlayerController?>();
    _pending[url] = completer;

    try {
      // If at capacity, dispose oldest
      while (_controllers.length >= maxConcurrentPlayers) {
        final oldestKey = _controllers.keys.first;
        await _disposeController(oldestKey);
      }

      // Create new controller
      final controller = await CachedVideoPlayerController.create(url);
      await controller.initialize();
      controller
        ..setLooping(true)
        ..setVolume(0);

      _controllers[url] = _ManagedController(
        controller: controller,
        lastUsed: DateTime.now(),
      );

      completer.complete(controller);
      return controller;
    } catch (e) {
      completer.complete(null);
      return null;
    } finally {
      _pending.remove(url);
    }
  }

  /// Release a controller (called when widget disposes or goes off-screen)
  /// Doesn't immediately dispose - keeps for reuse
  void release(String url) {
    // Just mark as not high priority
    // The controller stays in pool for potential reuse
    if (_controllers.containsKey(url)) {
      _controllers[url]!.isActive = false;
    }
  }

  /// Check if a controller for the given URL is still valid (not disposed)
  bool isControllerValid(String url) {
    return _controllers.containsKey(url) && !_disposedUrls.contains(url);
  }

  /// Dispose a specific controller
  Future<void> _disposeController(String url) async {
    final managed = _controllers.remove(url);
    if (managed != null) {
      // Mark as disposed BEFORE actually disposing
      _disposedUrls.add(url);
      try {
        await managed.controller.pause();
        await managed.controller.dispose();
      } catch (e) {
        // Ignore errors during disposal
        if (kDebugMode) {
          print('VideoPlayerManager: Error disposing controller for $url: $e');
        }
      }
    }
  }

  /// Dispose all controllers
  Future<void> disposeAll() async {
    final urls = _controllers.keys.toList();
    for (final url in urls) {
      await _disposeController(url);
    }
    _controllers.clear();
  }

  /// Get current number of active players
  int get activeCount => _controllers.length;

  /// Check if a URL has an active controller
  bool hasController(String url) => _controllers.containsKey(url);

  /// Pause all videos (useful when app goes to background)
  Future<void> pauseAll() async {
    for (final entry in _controllers.entries) {
      try {
        await entry.value.controller.pause();
      } catch (e) {
        // Ignore errors - controller might be disposed
      }
    }
  }

  /// Debug info
  void printDebugInfo() {
    if (kDebugMode) {
      print('VideoPlayerManager: ${_controllers.length} active controllers');
      for (final entry in _controllers.entries) {
        print('  - ${entry.key.split('/').last}');
      }
    }
  }
}

class _ManagedController {
  _ManagedController({
    required this.controller,
    required this.lastUsed,
  });

  final VideoPlayerController controller;
  DateTime lastUsed;
  bool isActive = true;
}
