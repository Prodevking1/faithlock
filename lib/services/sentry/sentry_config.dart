import 'package:faithlock/config/env.dart';
import 'package:faithlock/config/logger.dart';
import 'package:faithlock/services/sentry/sentry_service.dart';
import 'package:get/get.dart';

class SentryConfig {
  static Future<void> initialize() async {
    String dsn = '';
    try {
      dsn = '';
    } catch (e) {
      logger.error('Failed to initialize Sentry: $e');
      rethrow;
    }

    final sentryService = SentryService(dsn: dsn);
    await sentryService.init();

    Get.put<SentryService>(sentryService, permanent: true);
  }
}
