import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Handles initialization, configuration, and provides a clean API for error reporting.
class SentryService extends GetxService {
  final String _dsn;
  final SentryLevel _minLevel;
  bool _isInitialized = false;
  String? _appVersion;
  String? _packageName;
  Map<String, dynamic>? _deviceInfo;

  SentryService({
    required String dsn,
    SentryLevel minLevel = SentryLevel.error,
  })  : _dsn = dsn,
        _minLevel = minLevel;

  Future<SentryService> init() async {
    if (_isInitialized) return this;

    try {
      await _loadAppInfo();
      await _loadDeviceInfo();

      await SentryFlutter.init(
        (options) {
          options.dsn = _dsn;
          options.tracesSampleRate =
              1.0;
          options.enableAutoPerformanceTracing = true;



          options.enableAutoSessionTracking = true;
          options.autoSessionTrackingInterval = const Duration(minutes: 30);

          options.sendDefaultPii = false;
          options.environment = kDebugMode ? 'development' : 'production';
          options.debug = kDebugMode;

          Sentry.configureScope((scope) {
            scope.setTag('app.version', _appVersion ?? 'unknown');
            scope.setTag('app.package', _packageName ?? 'unknown');
            scope.setTag('device.platform', Platform.operatingSystem);
            scope.setTag('device.os_version', Platform.operatingSystemVersion);

            if (_deviceInfo != null) {
              _deviceInfo!.forEach((key, value) {
                scope.setTag(key, value.toString());
              });
            }
          });

          options.beforeSend = _beforeSendCallback;
        },
      );

      _isInitialized = true;
      debugPrint('✅ SentryService initialized successfully');

      return this;
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to initialize SentryService: $e');
      debugPrintStack(stackTrace: stackTrace);
      return this;
    }
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      _packageName = packageInfo.packageName;
    } catch (e) {
      debugPrint('❌ Failed to load app info: $e');
    }
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      _deviceInfo = <String, dynamic>{};

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        _deviceInfo = {
          'device.manufacturer': androidInfo.manufacturer,
          'device.model': androidInfo.model,
          'device.sdk_int': androidInfo.version.sdkInt.toString(),
          'device.brand': androidInfo.brand,
          'device.product': androidInfo.product,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        _deviceInfo = {
          'device.model': iosInfo.model,
          'device.system_name': iosInfo.systemName,
          'device.system_version': iosInfo.systemVersion,
          'device.name': iosInfo.name,
          'device.is_physical': iosInfo.isPhysicalDevice.toString(),
        };
      }
    } catch (e) {
      debugPrint('❌ Failed to load device info: $e');
    }
  }

  SentryEvent? _beforeSendCallback(SentryEvent event, dynamic hint) {
    if (_shouldIgnoreError(event)) {
      return null;
    }

    final enrichedEvent = event.copyWith(
      tags: {...event.tags ?? {}, ..._deviceInfo ?? {}},
    );

    return enrichedEvent;
  }

  bool _shouldIgnoreError(SentryEvent event) {
    final ignoredErrors = [
      'HttpException: Connection closed before full header was received',
      'SocketException: OS Error: Connection reset by peer',
      'PlatformException: Error performing getAll, OS message: The operation could\'t be completed.',
    ];

    final errorMessage = event.message?.formatted ??
        event.throwable?.toString() ??
        (event.exceptions?.isNotEmpty == true
            ? event.exceptions!.first.value
            : '') ??
        '';

    return ignoredErrors.any((ignored) => errorMessage.contains(ignored));
  }

  Future<SentryId> captureException(
    dynamic exception, {
    dynamic stackTrace,
    String? logger,
    Map<String, dynamic>? extra,
    List<String>? tags,
    SentryLevel? level,
    String? feature,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ SentryService not initialized, exception not captured');
      return SentryId.empty();
    }


    final Map<String, String> tagMap = {};

    if (feature != null) {
      tagMap['feature'] = feature;
    }

    if (tags != null) {
      for (int i = 0; i < tags.length; i += 2) {
        if (i + 1 < tags.length) {
          tagMap[tags[i]] = tags[i + 1];
        }
      }
    }

    try {
      final currentLevel = level ?? _minLevel;

      // Configure scope
      await Sentry.configureScope((scope) {
        scope.level = currentLevel;

        tagMap.forEach((key, value) {
          scope.setTag(key, value);
        });

        if (extra != null) {
          extra.forEach((key, value) {
            scope.contexts[key] = value;
          });
        }

        if (logger != null) {
          scope.contexts['logger'] = logger;
        }
      });

      return await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    } catch (e) {
      debugPrint('❌ Failed to capture exception: $e');
      return SentryId.empty();
    }
  }

  Future<SentryId> captureMessage(
    String message, {
    SentryLevel? level,
    String? logger,
    Map<String, dynamic>? extra,
    List<String>? tags,
    String? feature,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ SentryService not initialized, message not captured');
      return SentryId.empty();
    }


    final Map<String, String> tagMap = {};

    if (feature != null) {
      tagMap['feature'] = feature;
    }

    if (tags != null) {
      for (int i = 0; i < tags.length; i += 2) {
        if (i + 1 < tags.length) {
          tagMap[tags[i]] = tags[i + 1];
        }
      }
    }

    try {
      final currentLevel = level ?? _minLevel;

      await Sentry.configureScope((scope) {
        scope.level = currentLevel;

        tagMap.forEach((key, value) {
          scope.setTag(key, value);
        });

        if (extra != null) {
          extra.forEach((key, value) {
            scope.contexts['key'] = value;
          });
        }

        if (logger != null) {
          scope.contexts['logger'] = logger;
        }
      });

      return await Sentry.captureMessage(message);
    } catch (e) {
      debugPrint('❌ Failed to capture message: $e');
      return SentryId.empty();
    }
  }

  Future<ISentrySpan?> startTransaction(
    String name,
    String operation, {
    Map<String, dynamic>? tags,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ SentryService not initialized, transaction not started');
      return null;
    }

    try {
      await Sentry.configureScope((scope) {
        if (tags != null) {
          tags.forEach((key, value) {
            scope.setTag(key, value.toString());
          });
        }

        if (data != null) {
          data.forEach((key, value) {
            scope.contexts[key] = value;
          });
        }
      });

      return Sentry.startTransaction(name, operation);
    } catch (e) {
      debugPrint('❌ Failed to start transaction: $e');
      return null;
    }
  }

  void setUserContext({
    String? id,
    String? email,
    String? username,
    Map<String, dynamic>? data,
  }) {
    if (!_isInitialized) {
      debugPrint('⚠️ SentryService not initialized, user context not set');
      return;
    }

    try {
      Sentry.configureScope((scope) {
        scope.setUser(SentryUser(
          id: id,
          email: email,
          username: username,
          data: data,
        ));
      });
    } catch (e) {
      debugPrint('❌ Failed to set user context: $e');
    }
  }

  /// Clear user context
  void clearUserContext() {
    if (!_isInitialized) return;

    try {
      Sentry.configureScope((scope) {
        scope.setUser(null);
      });
    } catch (e) {
      debugPrint('❌ Failed to clear user context: $e');
    }
  }

  /// Add breadcrumb to track user actions
  void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) {
    if (!_isInitialized) return;

    try {
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          category: category,
          data: data,
          level: level,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to add breadcrumb: $e');
    }
  }

  /// Wrap async function with Sentry error reporting
  Future<T> capture<T>(
    Future<T> Function() callback, {
    String? feature,
    List<String>? tags,
  }) async {
    try {
      return await callback();
    } catch (exception, stackTrace) {
      await captureException(
        exception,
        stackTrace: stackTrace,
        feature: feature,
        tags: tags,
      );
      rethrow;
    }
  }
}
