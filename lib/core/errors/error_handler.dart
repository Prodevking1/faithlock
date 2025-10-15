import 'dart:async';
import 'dart:isolate';

import 'package:faithlock/services/sentry/sentry_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ErrorHandler {
  static void initialize() {
    FlutterError.onError = _handleFlutterError;
    PlatformDispatcher.instance.onError = _handlePlatformError;
    _setupIsolateErrorCapture();
  }

  static void _handleFlutterError(FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }

    // Skip reporting network errors to avoid spam
    if (!_isNetworkError(details.exception)) {
      _reportError(details.exception, details.stack, 'flutter_error');
    }

    // Show user-friendly error message instead of default error widget
    _showUserFriendlyError(details.exception);
  }

  static bool _handlePlatformError(Object error, StackTrace stack) {
    _reportError(error, stack, 'platform_error');

    return false;
  }

  static void _setupIsolateErrorCapture() {
    Isolate.current.addErrorListener(RawReceivePort((pair) {
      final errorAndStacktrace = pair as List<dynamic>;
      final error = errorAndStacktrace[0];
      final stackTrace = StackTrace.fromString(errorAndStacktrace[1] as String);

      _reportError(error, stackTrace, 'isolate_error');
    }).sendPort);
  }

  static void _reportError(
      dynamic error, StackTrace? stackTrace, String source) {
    try {
      if (Get.isRegistered<SentryService>()) {
        final sentryService = Get.find<SentryService>();
        sentryService.captureException(
          error,
          stackTrace: stackTrace,
          logger: source,
          level: SentryLevel.fatal,
        );
      } else {
        debugPrint(
            '⚠️ SentryService not registered, error not captured: $error');
      }
    } catch (e) {
      debugPrint('❌ Failed to report error to Sentry: $e');
      debugPrint('Original error: $error');
      if (stackTrace != null) {
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }

  static bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('clientexception');
  }

  static void _showUserFriendlyError(dynamic error) {
    // Only show snackbar for user-facing errors, avoid dialogs
    if (_isNetworkError(error)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          Get.showSnackbar(
            GetSnackBar(
              title: 'Connection Error',
              message: 'Please check your internet connection',
              icon: const Icon(Icons.wifi_off, color: Colors.white),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.orange,
              snackPosition: SnackPosition.TOP,
            ),
          );
        }
      });
    }
  }

  static Future<T> wrap<T>(Future<T> Function() callback) async {
    try {
      return await callback();
    } catch (error, stackTrace) {
      _reportError(error, stackTrace, 'wrapped_error');
      rethrow;
    }
  }

  static Widget wrapWidget(Widget widget, {Key? key}) {
    return ErrorBoundary(
      key: key,
      child: widget,
    );
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({Key? key, required this.child}) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Material(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'somethingWentWrong'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'unexpectedError'.tr,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                    });
                  },
                  child: Text('retry'.tr),
                ),
              ],
            ),
          ),
        ),
      );
    }

    ErrorWidget.builder = (FlutterErrorDetails details) {
      ErrorHandler._reportError(
        details.exception,
        details.stack,
        'widget_error',
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });

      return const SizedBox();
    };

    return widget.child;
  }
}
