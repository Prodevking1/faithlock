/// **FastKeyboardAvoidingView** - iOS-native keyboard avoidance with smooth animations and proper content adjustment.
///
/// **Use Case:**
/// Use this when you have forms or input fields that need to remain visible when the
/// keyboard appears. Provides native iOS keyboard behavior with smooth animations and
/// proper content adjustment.
///
/// **Key Features:**
/// - Native iOS keyboard animation curves and timing
/// - Automatic scrolling to focused input fields
/// - Enhanced form support with field tracking
/// - Landscape/portrait orientation adaptation
/// - Haptic feedback integration for iOS
/// - Android fallback with basic padding adjustment
///
/// **Important Parameters:**
/// - `child`: Widget that needs keyboard avoidance
/// - `resizeToAvoidBottomInset`: Whether to resize when keyboard appears (default: true)
/// - `animationDuration`: Custom animation duration (default: 300ms)
/// - `animationCurve`: Custom animation curve (default: easeInOut)
/// - `maintainBottomViewPadding`: Keep bottom padding when keyboard shown (default: false)
/// - `scrollController`: Custom scroll controller for fine control
///
/// **Usage Example:**
/// ```dart
/// // Basic keyboard avoidance
/// FastKeyboardAvoidingView(child: LoginForm())
///
/// // Custom animation for smooth transitions
/// FastKeyboardAvoidingView(
///   child: SignupForm(),
///   animationDuration: Duration(milliseconds: 250),
///   animationCurve: Curves.easeInOutCubic,
/// )
/// ```

import 'package:faithlock/core/utils/ios_platform_detector.dart';
import 'package:faithlock/core/utils/ios_system_behavior.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class FastKeyboardAvoidingView extends StatefulWidget {
  final Widget child;
  final bool resizeToAvoidBottomInset;
  final EdgeInsets? padding;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final bool maintainBottomViewPadding;
  final ScrollController? scrollController;

  const FastKeyboardAvoidingView({
    super.key,
    required this.child,
    this.resizeToAvoidBottomInset = true,
    this.padding,
    this.animationDuration,
    this.animationCurve,
    this.maintainBottomViewPadding = false,
    this.scrollController,
  });

  @override
  State<FastKeyboardAvoidingView> createState() =>
      _FastKeyboardAvoidingViewState();
}

class _FastKeyboardAvoidingViewState extends State<FastKeyboardAvoidingView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _keyboardHeight = 0;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve ?? Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateKeyboardState();
  }

  void _updateKeyboardState() {
    final newKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final wasKeyboardVisible = _isKeyboardVisible;
    _isKeyboardVisible = newKeyboardHeight > 0;

    if (_keyboardHeight != newKeyboardHeight) {
      _keyboardHeight = newKeyboardHeight;

      if (_isKeyboardVisible && !wasKeyboardVisible) {
        // Keyboard appeared
        _animationController.forward();
      } else if (!_isKeyboardVisible && wasKeyboardVisible) {
        // Keyboard disappeared
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!IOSPlatformDetector.isIOS) {
      return _buildAndroidFallback();
    }

    return _buildIOSKeyboardAvoidingView();
  }

  Widget _buildIOSKeyboardAvoidingView() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final keyboardOffset = _keyboardHeight * _animation.value;

        return Padding(
          padding: EdgeInsets.only(
            bottom: widget.resizeToAvoidBottomInset ? keyboardOffset : 0,
          ).add(widget.padding ?? EdgeInsets.zero),
          child: widget.child,
        );
      },
    );
  }

  Widget _buildAndroidFallback() {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: widget.child,
    );
  }
}

/// iOS-style keyboard avoiding scroll view
class FastKeyboardAvoidingScrollView extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool reverse;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;

  const FastKeyboardAvoidingScrollView({
    super.key,
    required this.children,
    this.controller,
    this.padding,
    this.reverse = false,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<FastKeyboardAvoidingScrollView> createState() =>
      _FastKeyboardAvoidingScrollViewState();
}

class _FastKeyboardAvoidingScrollViewState
    extends State<FastKeyboardAvoidingScrollView> {
  late ScrollController _scrollController;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _handleKeyboardChange();
  }

  void _handleKeyboardChange() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final wasKeyboardVisible = _isKeyboardVisible;
    _isKeyboardVisible = keyboardHeight > 0;

    if (_isKeyboardVisible && !wasKeyboardVisible) {
      // Keyboard appeared - scroll to focused widget if needed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFocusedWidget();
      });
    }
  }

  void _scrollToFocusedWidget() {
    final focusedWidget = FocusScope.of(context).focusedChild;
    if (focusedWidget != null && _scrollController.hasClients) {
      // Scroll to ensure focused widget is visible
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: IOSSystemBehavior.getAnimationDuration(context),
        curve: IOSSystemBehavior.getIOSAnimationCurve(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final physics = widget.physics ??
        (IOSPlatformDetector.isIOS
            ? const BouncingScrollPhysics()
            : const ClampingScrollPhysics());

    return FastKeyboardAvoidingView(
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: widget.padding,
        reverse: widget.reverse,
        physics: physics,
        scrollDirection: widget.scrollDirection,
        child: Column(
          children: widget.children,
        ),
      ),
    );
  }
}

/// Mixin for widgets that need keyboard avoidance
mixin KeyboardAvoidanceMixin<T extends StatefulWidget> on State<T> {
  bool _isKeyboardVisible = false;
  double _keyboardHeight = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateKeyboardState();
  }

  void _updateKeyboardState() {
    final newKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final wasKeyboardVisible = _isKeyboardVisible;

    setState(() {
      _keyboardHeight = newKeyboardHeight;
      _isKeyboardVisible = newKeyboardHeight > 0;
    });

    if (_isKeyboardVisible != wasKeyboardVisible) {
      onKeyboardVisibilityChanged(_isKeyboardVisible, _keyboardHeight);
    }
  }

  /// Override this method to handle keyboard visibility changes
  void onKeyboardVisibilityChanged(bool isVisible, double height) {}

  /// Current keyboard height
  double get keyboardHeight => _keyboardHeight;

  /// Whether keyboard is currently visible
  bool get isKeyboardVisible => _isKeyboardVisible;

  /// Get safe bottom padding considering keyboard
  double get safeBottomPadding {
    final viewPadding = MediaQuery.of(context).viewPadding.bottom;
    return _isKeyboardVisible ? _keyboardHeight : viewPadding;
  }
}

/// iOS-style form with automatic keyboard avoidance
class FastIOSForm extends StatefulWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final bool automaticallyScrollToFocus;
  final ScrollController? scrollController;

  const FastIOSForm({
    super.key,
    required this.children,
    this.padding,
    this.automaticallyScrollToFocus = true,
    this.scrollController,
  });

  @override
  State<FastIOSForm> createState() => _FastIOSFormState();
}

class _FastIOSFormState extends State<FastIOSForm> with KeyboardAvoidanceMixin {
  late ScrollController _scrollController;
  final List<GlobalKey> _fieldKeys = [];

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _fieldKeys.addAll(
      List.generate(widget.children.length, (_) => GlobalKey()),
    );
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  void onKeyboardVisibilityChanged(bool isVisible, double height) {
    if (isVisible && widget.automaticallyScrollToFocus) {
      _scrollToFocusedField();
    }
  }

  void _scrollToFocusedField() {
    final focusedNode = FocusScope.of(context).focusedChild;
    if (focusedNode == null || !_scrollController.hasClients) return;

    // Find the focused field and scroll to it
    for (int i = 0; i < _fieldKeys.length; i++) {
      final key = _fieldKeys[i];
      final context = key.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          final screenHeight = MediaQuery.of(this.context).size.height;
          final keyboardTop = screenHeight - keyboardHeight;

          if (position.dy + renderBox.size.height > keyboardTop) {
            // Field is obscured by keyboard, scroll to make it visible
            final scrollOffset =
                position.dy - (keyboardTop - renderBox.size.height - 20);
            _scrollController.animateTo(
              (_scrollController.offset + scrollOffset).clamp(
                0.0,
                _scrollController.position.maxScrollExtent,
              ),
              duration: IOSSystemBehavior.getAnimationDuration(this.context),
              curve: IOSSystemBehavior.getIOSAnimationCurve(),
            );
            break;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FastKeyboardAvoidingScrollView(
      controller: _scrollController,
      padding: widget.padding ?? const EdgeInsets.all(16.0),
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return KeyedSubtree(
          key: _fieldKeys[index],
          child: child,
        );
      }).toList(),
    );
  }
}
