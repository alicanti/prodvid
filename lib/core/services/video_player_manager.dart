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
  /// Reduced to 3 for better RAM optimization
  static const int maxConcurrentPlayers = 3;

  /// Active video controllers (URL -> Controller)
  final LinkedHashMap<String, _ManagedController> _controllers =
      LinkedHashMap();

  /// Pending video requests
  final Map<String, Completer<VideoPlayerController?>> _pending = {};

  /// Get or create a video controller for a URL
  /// Returns null if too many players are active and this one can't be prioritized
  Future<VideoPlayerController?> getController(
    String url, {
    bool highPriority = false,
  }) async {
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

  /// Dispose a specific controller
  Future<void> _disposeController(String url) async {
    final managed = _controllers.remove(url);
    if (managed != null) {
      await managed.controller.pause();
      await managed.controller.dispose();
    }
  }

  /// Dispose all controllers
  Future<void> disposeAll() async {
    for (final managed in _controllers.values) {
      await managed.controller.pause();
      await managed.controller.dispose();
    }
    _controllers.clear();
  }

  /// Get current number of active players
  int get activeCount => _controllers.length;

  /// Check if a URL has an active controller
  bool hasController(String url) => _controllers.containsKey(url);

  /// Pause all videos (useful when app goes to background)
  Future<void> pauseAll() async {
    for (final managed in _controllers.values) {
      await managed.controller.pause();
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
    this.isActive = true,
  });

  final VideoPlayerController controller;
  DateTime lastUsed;
  bool isActive;
}

