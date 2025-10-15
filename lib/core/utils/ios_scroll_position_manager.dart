import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// Manager for maintaining scroll positions in iOS list-to-detail flows
class IOSScrollPositionManager extends GetxController {
  static IOSScrollPositionManager get instance =>
      Get.find<IOSScrollPositionManager>();

  // Map to store scroll positions by route/list identifier
  final Map<String, double> _scrollPositions = {};
  final Map<String, ScrollController> _controllers = {};

  /// Save scroll position for a specific list
  void saveScrollPosition(String listId, double position) {
    _scrollPositions[listId] = position;
  }

  /// Get saved scroll position for a specific list
  double? getScrollPosition(String listId) {
    return _scrollPositions[listId];
  }

  /// Create or get a scroll controller for a specific list
  ScrollController getController(String listId) {
    if (!_controllers.containsKey(listId)) {
      final controller = ScrollController();
      _controllers[listId] = controller;

      // Add listener to save position automatically
      controller.addListener(() {
        if (controller.hasClients) {
          saveScrollPosition(listId, controller.position.pixels);
        }
      });
    }
    return _controllers[listId]!;
  }

  /// Restore scroll position for a specific list
  Future<void> restoreScrollPosition(String listId) async {
    final controller = _controllers[listId];
    final position = _scrollPositions[listId];

    if (controller != null && position != null && controller.hasClients) {
      // Wait for the list to be built
      await Future.delayed(const Duration(milliseconds: 100));

      if (controller.hasClients) {
        await controller.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  /// Clear scroll position for a specific list
  void clearScrollPosition(String listId) {
    _scrollPositions.remove(listId);
    final controller = _controllers.remove(listId);
    controller?.dispose();
  }

  /// Clear all scroll positions
  void clearAllScrollPositions() {
    _scrollPositions.clear();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }

  @override
  void onClose() {
    clearAllScrollPositions();
    super.onClose();
  }
}

/// Mixin for widgets that need scroll position management
mixin IOSScrollPositionMixin<T extends StatefulWidget> on State<T> {
  late String _listId;
  ScrollController? _scrollController;

  /// Initialize scroll position management
  void initializeScrollPosition(String listId) {
    _listId = listId;
    _scrollController = IOSScrollPositionManager.instance.getController(listId);
  }

  /// Get the scroll controller
  ScrollController get scrollController => _scrollController!;

  /// Restore scroll position when returning to this list
  Future<void> restoreScrollPosition() async {
    await IOSScrollPositionManager.instance.restoreScrollPosition(_listId);
  }

  /// Clear scroll position when leaving permanently
  void clearScrollPosition() {
    IOSScrollPositionManager.instance.clearScrollPosition(_listId);
  }
}

/// Widget that automatically manages scroll position for iOS list-to-detail flows
class IOSScrollPositionWrapper extends StatefulWidget {
  final String listId;
  final Widget child;
  final bool autoRestore;

  const IOSScrollPositionWrapper({
    required this.listId,
    required this.child,
    super.key,
    this.autoRestore = true,
  });

  @override
  State<IOSScrollPositionWrapper> createState() =>
      _IOSScrollPositionWrapperState();
}

class _IOSScrollPositionWrapperState extends State<IOSScrollPositionWrapper>
    with IOSScrollPositionMixin {
  @override
  void initState() {
    super.initState();
    initializeScrollPosition(widget.listId);

    if (widget.autoRestore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        restoreScrollPosition();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Navigation helper for iOS list-to-detail flows with scroll position management
class IOSNavigationHelper {
  /// Navigate to detail page while maintaining scroll position
  static Future<T?> pushDetail<T extends Object?>(
    BuildContext context,
    Widget page, {
    String? listId,
    bool maintainScrollPosition = true,
  }) async {
    // Save current scroll position if listId is provided
    if (listId != null && maintainScrollPosition) {
      final manager = IOSScrollPositionManager.instance;
      final controller = manager._controllers[listId];
      if (controller != null && controller.hasClients) {
        manager.saveScrollPosition(listId, controller.position.pixels);
      }
    }

    // Navigate to detail page
    final result = await Navigator.of(context).push<T>(
      CupertinoPageRoute<T>(
        builder: (context) => page,
      ),
    );

    // Restore scroll position when returning
    if (listId != null && maintainScrollPosition) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        IOSScrollPositionManager.instance.restoreScrollPosition(listId);
      });
    }

    return result;
  }

  /// Navigate and replace current page
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    TO? result,
    String? listId,
  }) async {
    // Clear scroll position since we're replacing
    if (listId != null) {
      IOSScrollPositionManager.instance.clearScrollPosition(listId);
    }

    return Navigator.of(context).pushReplacement<T, TO>(
      CupertinoPageRoute<T>(
        builder: (context) => page,
      ),
      result: result,
    );
  }
}

/// Extension on BuildContext for easier navigation
extension IOSNavigationExtension on BuildContext {
  /// Navigate to detail page with scroll position management
  Future<T?> pushIOSDetail<T extends Object?>(
    Widget page, {
    String? listId,
    bool maintainScrollPosition = true,
  }) {
    return IOSNavigationHelper.pushDetail<T>(
      this,
      page,
      listId: listId,
      maintainScrollPosition: maintainScrollPosition,
    );
  }
}
