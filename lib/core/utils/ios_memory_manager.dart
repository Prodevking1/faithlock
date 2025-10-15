import 'dart:async';

import 'package:flutter/material.dart';

/// Memory management utility for iOS performance optimization
class IOSMemoryManager {
  static final IOSMemoryManager _instance = IOSMemoryManager._internal();
  factory IOSMemoryManager() => _instance;
  IOSMemoryManager._internal();

  // Track active controllers and listeners
  final Set<ScrollController> _activeScrollControllers = {};
  final Set<AnimationController> _activeAnimationControllers = {};
  final Set<StreamSubscription> _activeSubscriptions = {};
  final Map<String, VoidCallback> _activeListeners = {};

  // Memory pressure monitoring
  Timer? _memoryCheckTimer;
  bool _isLowMemory = false;

  /// Initialize memory management
  void initialize() {
    _startMemoryMonitoring();
  }

  /// Register a scroll controller for memory management
  void registerScrollController(ScrollController controller, {String? id}) {
    _activeScrollControllers.add(controller);

    // Add automatic cleanup when controller is disposed
    controller.addListener(() {
      if (!controller.hasClients) {
        _activeScrollControllers.remove(controller);
      }
    });
  }

  /// Register an animation controller for memory management
  void registerAnimationController(AnimationController controller,
      {String? id}) {
    _activeAnimationControllers.add(controller);
  }

  /// Register a stream subscription for memory management
  void registerSubscription(StreamSubscription subscription, {String? id}) {
    _activeSubscriptions.add(subscription);
  }

  /// Register a listener callback for memory management
  void registerListener(String id, VoidCallback listener) {
    _activeListeners[id] = listener;
  }

  /// Unregister and dispose a scroll controller
  void unregisterScrollController(ScrollController controller) {
    _activeScrollControllers.remove(controller);
    if (!controller.hasClients) {
      controller.dispose();
    }
  }

  /// Unregister and dispose an animation controller
  void unregisterAnimationController(AnimationController controller) {
    _activeAnimationControllers.remove(controller);
    controller.dispose();
  }

  /// Unregister and cancel a subscription
  void unregisterSubscription(StreamSubscription subscription) {
    _activeSubscriptions.remove(subscription);
    subscription.cancel();
  }

  /// Unregister a listener
  void unregisterListener(String id) {
    _activeListeners.remove(id);
  }

  /// Clean up unused resources
  void cleanupUnusedResources() {
    // Clean up scroll controllers without clients
    final unusedScrollControllers = _activeScrollControllers
        .where((controller) => !controller.hasClients)
        .toList();

    for (final controller in unusedScrollControllers) {
      _activeScrollControllers.remove(controller);
      controller.dispose();
    }

    // Clean up disposed animation controllers
    final disposedAnimationControllers = _activeAnimationControllers
        .where(
            (controller) => controller.isCompleted && !controller.isAnimating)
        .toList();

    for (final controller in disposedAnimationControllers) {
      _activeAnimationControllers.remove(controller);
      // Don't dispose here as they might be reused
    }
  }

  /// Handle low memory situations
  void handleLowMemory() {
    _isLowMemory = true;

    // Aggressive cleanup
    cleanupUnusedResources();

    // Pause non-essential animations
    for (final controller in _activeAnimationControllers) {
      if (controller.isAnimating && !controller.isDismissed) {
        controller.stop();
      }
    }

    // Clear image cache if available
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    debugPrint('IOSMemoryManager: Low memory situation handled');
  }

  /// Handle memory recovery
  void handleMemoryRecovery() {
    _isLowMemory = false;
    debugPrint('IOSMemoryManager: Memory pressure relieved');
  }

  /// Start memory monitoring
  void _startMemoryMonitoring() {
    _memoryCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkMemoryUsage();
    });
  }

  /// Check current memory usage and take action if needed
  void _checkMemoryUsage() {
    final int activeControllers =
        _activeScrollControllers.length + _activeAnimationControllers.length;
    final int activeSubscriptions = _activeSubscriptions.length;
    final int activeListeners = _activeListeners.length;

    // Simple heuristic for memory pressure
    if (activeControllers > 50 ||
        activeSubscriptions > 100 ||
        activeListeners > 200) {
      if (!_isLowMemory) {
        handleLowMemory();
      }
    } else if (_isLowMemory) {
      handleMemoryRecovery();
    }

    // Regular cleanup
    cleanupUnusedResources();
  }

  /// Get memory statistics
  Map<String, int> getMemoryStats() {
    return {
      'activeScrollControllers': _activeScrollControllers.length,
      'activeAnimationControllers': _activeAnimationControllers.length,
      'activeSubscriptions': _activeSubscriptions.length,
      'activeListeners': _activeListeners.length,
      'isLowMemory': _isLowMemory ? 1 : 0,
    };
  }

  /// Dispose all resources
  void dispose() {
    _memoryCheckTimer?.cancel();

    // Dispose all controllers
    for (final controller in _activeScrollControllers) {
      if (controller.hasClients) {
        controller.dispose();
      }
    }
    _activeScrollControllers.clear();

    for (final controller in _activeAnimationControllers) {
      controller.dispose();
    }
    _activeAnimationControllers.clear();

    // Cancel all subscriptions
    for (final subscription in _activeSubscriptions) {
      subscription.cancel();
    }
    _activeSubscriptions.clear();

    _activeListeners.clear();
  }
}

/// Mixin for automatic memory management in widgets
mixin IOSMemoryManagementMixin<T extends StatefulWidget> on State<T> {
  final List<ScrollController> _managedScrollControllers = [];
  final List<AnimationController> _managedAnimationControllers = [];
  final List<StreamSubscription> _managedSubscriptions = [];
  final Map<String, VoidCallback> _managedListeners = {};

  /// Create and register a scroll controller
  ScrollController createManagedScrollController() {
    final controller = ScrollController();
    _managedScrollControllers.add(controller);
    IOSMemoryManager().registerScrollController(controller);
    return controller;
  }

  /// Create and register an animation controller
  AnimationController createManagedAnimationController({
    required Duration duration,
    Duration? reverseDuration,
    String? debugLabel,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
    TickerProvider? vsync,
  }) {
    final controller = AnimationController(
      duration: duration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
      lowerBound: lowerBound,
      upperBound: upperBound,
      animationBehavior: animationBehavior,
      vsync: vsync ?? this as TickerProvider,
    );
    _managedAnimationControllers.add(controller);
    IOSMemoryManager().registerAnimationController(controller);
    return controller;
  }

  /// Register a stream subscription for automatic cleanup
  void registerManagedSubscription(StreamSubscription subscription) {
    _managedSubscriptions.add(subscription);
    IOSMemoryManager().registerSubscription(subscription);
  }

  /// Register a listener for automatic cleanup
  void registerManagedListener(String id, VoidCallback listener) {
    _managedListeners[id] = listener;
    IOSMemoryManager().registerListener(id, listener);
  }

  @override
  void dispose() {
    // Clean up all managed resources
    for (final controller in _managedScrollControllers) {
      IOSMemoryManager().unregisterScrollController(controller);
    }

    for (final controller in _managedAnimationControllers) {
      IOSMemoryManager().unregisterAnimationController(controller);
    }

    for (final subscription in _managedSubscriptions) {
      IOSMemoryManager().unregisterSubscription(subscription);
    }

    for (final entry in _managedListeners.entries) {
      IOSMemoryManager().unregisterListener(entry.key);
    }

    super.dispose();
  }
}

/// Widget that provides automatic memory management for its children
class IOSMemoryManagedWidget extends StatefulWidget {
  final Widget child;
  final bool enableAutoCleanup;

  const IOSMemoryManagedWidget({
    required this.child,
    super.key,
    this.enableAutoCleanup = true,
  });

  @override
  State<IOSMemoryManagedWidget> createState() => _IOSMemoryManagedWidgetState();
}

class _IOSMemoryManagedWidgetState extends State<IOSMemoryManagedWidget>
    with IOSMemoryManagementMixin {
  @override
  void initState() {
    super.initState();
    if (widget.enableAutoCleanup) {
      // Schedule periodic cleanup
      Timer.periodic(const Duration(minutes: 1), (timer) {
        if (mounted) {
          IOSMemoryManager().cleanupUnusedResources();
        } else {
          timer.cancel();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
