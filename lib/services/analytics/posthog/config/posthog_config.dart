import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class PostHogConfigManager {
  // Default configuration variables (replace with your actual keys)
  static const String _defaultApiKey = 'phc_1tqWknWtFLqb1o4xYOqgShNe0MhhZsfyaVVkRtAvMHY';
  static const String _defaultHost = 'https://us.i.posthog.com';

  static PostHogConfig createConfig({
    String? apiKey,
    String? host,
  }) {
    final config = PostHogConfig(apiKey ?? _defaultApiKey);

    // General configuration
    config.debug = kDebugMode;
    config.captureApplicationLifecycleEvents = true;
    config.host = host ?? _defaultHost;

    // Session replay configuration
    config.sessionReplay = true;

    // Event configuration
    config.flushAt = 20;
    config.maxBatchSize = 100;
    config.maxQueueSize = 1000;

    // Feature flag configuration
    config.sendFeatureFlagEvents = true;
    config.preloadFeatureFlags = true;

    return config;
  }

  // Test configuration
  static PostHogConfig createTestConfig() {
    final config = PostHogConfig('test-api-key');
    config.debug = true;
    config.captureApplicationLifecycleEvents = false;
    config.flushAt = 1;
    return config;
  }

  // Offline configuration
  static PostHogConfig createOfflineConfig() {
    final config = createConfig();
    config.flushAt = 100;
    config.maxQueueSize = 5000;
    return config;
  }
}

// Environment configuration
extension PostHogEnvironment on PostHogConfig {
  void configureForEnvironment(String environment) {
    switch (environment.toLowerCase()) {
      case 'development':
        debug = true;
        flushAt = 1;
        break;
      case 'staging':
        debug = true;
        flushAt = 10;
        break;
      case 'production':
        debug = false;
        flushAt = 20;
        break;
    }
  }
}
