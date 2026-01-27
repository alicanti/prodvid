import 'dart:async';

import 'package:video_player/video_player.dart';

/// Queue-based video loading to limit concurrent video initializations
/// This prevents memory spikes when scrolling through many video covers
class VideoLoadingQueue {
  VideoLoadingQueue._();
  
  static final VideoLoadingQueue instance = VideoLoadingQueue._();

  /// Maximum number of concurrent video loads
  static const int maxConcurrent = 8;
  
  int _currentLoading = 0;
  final List<_QueuedTask> _queue = [];
  
  /// Track active controllers for lifecycle management
  final Set<VideoPlayerController> _activeControllers = {};

  /// Enqueue a video load task
  /// If under the limit, executes immediately
  /// Otherwise waits in queue
  Future<void> enqueue(Future<void> Function() loadFunction) async {
    if (_currentLoading < maxConcurrent) {
      _currentLoading++;
      try {
        await loadFunction();
      } finally {
        _currentLoading--;
        _processQueue();
      }
    } else {
      final completer = Completer<void>();
      _queue.add(_QueuedTask(loadFunction, completer));
      return completer.future;
    }
  }

  /// Process queued tasks when a slot becomes available
  void _processQueue() {
    while (_queue.isNotEmpty && _currentLoading < maxConcurrent) {
      final task = _queue.removeAt(0);
      _currentLoading++;
      
      task.loadFunction().then((_) {
        task.completer.complete();
      }).catchError((Object e) {
        task.completer.completeError(e);
      }).whenComplete(() {
        _currentLoading--;
        _processQueue();
      });
    }
  }

  /// Register an active controller (call when video starts playing)
  void registerController(VideoPlayerController controller) {
    _activeControllers.add(controller);
  }

  /// Unregister a controller (call when disposing)
  void unregisterController(VideoPlayerController controller) {
    _activeControllers.remove(controller);
  }

  /// Pause all active video controllers (for app lifecycle)
  Future<void> pauseAll() async {
    for (final controller in _activeControllers) {
      try {
        await controller.pause();
      } catch (_) {
        // Controller might be disposed
      }
    }
  }

  /// Cancel all pending tasks (useful when navigating away)
  void cancelAll() {
    for (final task in _queue) {
      task.completer.completeError(Exception('Cancelled'));
    }
    _queue.clear();
  }

  /// Clear all tracking (for app termination)
  void disposeAll() {
    cancelAll();
    _activeControllers.clear();
  }

  /// Get current queue status for debugging
  int get currentlyLoading => _currentLoading;
  int get queueLength => _queue.length;
  int get activeControllerCount => _activeControllers.length;
}

class _QueuedTask {
  _QueuedTask(this.loadFunction, this.completer);
  
  final Future<void> Function() loadFunction;
  final Completer<void> completer;
}
