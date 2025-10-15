enum PostHogEventType {
  // User events
  userSignup,
  userLogin,
  userLogout,
  userProfileUpdate,
  userSubscription,

  // Navigation events
  screenView,
  screenExit,
  navigationAction,
  deepLinkOpened,

  // Business events
  purchaseCompleted,
  subscriptionStarted,
  subscriptionCancelled,
  trialStarted,
  trialEnded,

  // Engagement events
  featureUsed,
  tutorialStarted,
  tutorialCompleted,
  onboardingCompleted,
  feedbackSubmitted,

  // Marketing events
  campaignViewed,
  adClicked,
  emailOpened,
  pushNotificationOpened,
  shareCompleted,

  // Technical events
  errorOccurred,
  performanceMetric,
  crashReported,
  apiCallMade,

  // Événements custom
  custom,
}

class PostHogEventTemplates {
  static const Map<PostHogEventType, String> eventNames = {
    // User events
    PostHogEventType.userSignup: 'user_signup',
    PostHogEventType.userLogin: 'user_login',
    PostHogEventType.userLogout: 'user_logout',
    PostHogEventType.userProfileUpdate: 'user_profile_update',
    PostHogEventType.userSubscription: 'user_subscription',

    // Navigation events
    PostHogEventType.screenView: 'screen_view',
    PostHogEventType.screenExit: 'screen_exit',
    PostHogEventType.navigationAction: 'navigation_action',
    PostHogEventType.deepLinkOpened: 'deep_link_opened',

    // Business events
    PostHogEventType.purchaseCompleted: 'purchase_completed',
    PostHogEventType.subscriptionStarted: 'subscription_started',
    PostHogEventType.subscriptionCancelled: 'subscription_cancelled',
    PostHogEventType.trialStarted: 'trial_started',
    PostHogEventType.trialEnded: 'trial_ended',

    // Engagement events
    PostHogEventType.featureUsed: 'feature_used',
    PostHogEventType.tutorialStarted: 'tutorial_started',
    PostHogEventType.tutorialCompleted: 'tutorial_completed',
    PostHogEventType.onboardingCompleted: 'onboarding_completed',
    PostHogEventType.feedbackSubmitted: 'feedback_submitted',

    // Marketing events
    PostHogEventType.campaignViewed: 'campaign_viewed',
    PostHogEventType.adClicked: 'ad_clicked',
    PostHogEventType.emailOpened: 'email_opened',
    PostHogEventType.pushNotificationOpened: 'push_notification_opened',
    PostHogEventType.shareCompleted: 'share_completed',

    // Technical events
    PostHogEventType.errorOccurred: 'error_occurred',
    PostHogEventType.performanceMetric: 'performance_metric',
    PostHogEventType.crashReported: 'crash_reported',
    PostHogEventType.apiCallMade: 'api_call_made',
  };

  // Default properties for each event type
  static Map<String, dynamic> getDefaultProperties(PostHogEventType type) {
    switch (type) {
      case PostHogEventType.userSignup:
        return {
          'signup_method': null,
          'utm_source': null,
          'utm_medium': null,
          'utm_campaign': null,
        };

      case PostHogEventType.screenView:
        return {
          'screen_name': null,
          'screen_class': null,
          'previous_screen': null,
          'session_id': null,
        };

      case PostHogEventType.purchaseCompleted:
        return {
          'product_id': null,
          'product_name': null,
          'price': null,
          'currency': 'EUR',
          'quantity': 1,
          'payment_method': null,
        };

      case PostHogEventType.featureUsed:
        return {
          'feature_name': null,
          'feature_category': null,
          'user_segment': null,
          'is_premium_feature': false,
        };

      case PostHogEventType.campaignViewed:
        return {
          'campaign_id': null,
          'campaign_name': null,
          'campaign_type': null,
          'channel': null,
          'creative_id': null,
        };

      case PostHogEventType.errorOccurred:
        return {
          'error_type': null,
          'error_message': null,
          'error_stack': null,
          'screen_name': null,
          'user_id': null,
        };

      default:
        return <String, dynamic>{};
    }
  }

  // Required properties for each event type
  static Map<String, List<String>> requiredProperties = {
    'user_signup': ['signup_method'],
    'screen_view': ['screen_name'],
    'purchase_completed': ['product_id', 'price', 'currency'],
    'feature_used': ['feature_name'],
    'campaign_viewed': ['campaign_id', 'campaign_name'],
    'error_occurred': ['error_type', 'error_message'],
  };

  // Validate an event
  static bool validateEvent(String eventName, Map<String, dynamic> properties) {
    final requiredPropertiesList = requiredProperties[eventName];
    if (requiredPropertiesList == null) return true;

    for (final property in requiredPropertiesList) {
      if (!properties.containsKey(property) || properties[property] == null) {
        return false;
      }
    }
    return true;
  }

  // Helper to create a validated event
  static Map<String, dynamic> createEvent(
    PostHogEventType type,
    Map<String, dynamic> customProperties,
  ) {
    final eventName = eventNames[type];
    if (eventName == null) {
      throw ArgumentError('Invalid event type: $type');
    }

    final defaultProps = getDefaultProperties(type);
    final properties = {...defaultProps, ...customProperties};

    if (!validateEvent(eventName, properties)) {
      throw ArgumentError('Missing required properties for event: $eventName');
    }

    return {
      'event_name': eventName,
      'properties': properties,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
