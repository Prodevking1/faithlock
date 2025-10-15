# 🚀 PostHog Analytics Integration - Fast App Boilerplate

## 📋 Overview

Fast App comes with a **fully integrated PostHog analytics service** that provides comprehensive tracking capabilities for your mobile application. This enterprise-grade integration is designed to give you immediate insights into user behavior, conversion metrics, and business KPIs.

## 🎯 Key Features

### Complete Analytics Suite
- ✅ **Event Tracking** - Automatic and custom event capture
- ✅ **User Analytics** - Identity management and user properties
- ✅ **Screen Tracking** - Automatic navigation analytics
- ✅ **Feature Flags** - A/B testing and gradual rollouts
- ✅ **Session Recording** - User session replay capabilities
- ✅ **Conversion Funnels** - Multi-step conversion tracking
- ✅ **Marketing Campaigns** - Campaign attribution and ROI
- ✅ **Surveys & NPS** - In-app feedback collection

### Business-Ready Features
- 📊 **Marketing Attribution** - Multi-touch attribution tracking
- 💰 **Revenue Analytics** - Transaction and CLV tracking
- 📈 **Cohort Analysis** - User retention and engagement
- 🎯 **Campaign ROI** - Marketing spend effectiveness
- 🔒 **GDPR Compliant** - Privacy-first implementation

## 🛠️ Quick Setup

### 1. Get Your PostHog API Key

1. Sign up at [PostHog.com](https://posthog.com)
2. Create a new project
3. Copy your **Project API Key** (starts with `phc_`)

### 2. Configure the Service

In `lib/main.dart`, replace the placeholder with your API key:

```dart
// Initialize PostHog Analytics
final PostHogService postHog = PostHogService.instance;
await postHog.init(
  customApiKey: 'phc_your_actual_api_key_here', // ⚠️ Replace this
  environment: kDebugMode ? 'development' : 'production',
  enableDebug: kDebugMode,
);
```

That's it! PostHog is now tracking your app automatically.

## 📱 Implementation Examples

### Basic Event Tracking

```dart
import 'package:faithlock/services/analytics/posthog/export.dart';

// Track a simple event
await PostHogService.instance.events.track(
  PostHogEventType.featureUsed,
  {'feature_name': 'premium_export', 'file_type': 'pdf'}
);

// Track custom event
await PostHogService.instance.events.trackCustom(
  'subscription_upgraded',
  {
    'from_plan': 'basic',
    'to_plan': 'premium',
    'monthly_value': 29.99
  }
);
```

### User Identification

```dart
// Identify user after login
await PostHogService.instance.users.identify(
  'user_${userId}',
  {
    'email': userEmail,
    'name': userName,
    'plan': 'premium',
    'created_at': signupDate,
  }
);

// Update user properties
await PostHogService.instance.users.setUserProperties({
  'total_purchases': 5,
  'last_purchase_date': DateTime.now().toIso8601String(),
  'preferred_language': 'en',
});
```

### Feature Flags for A/B Testing

```dart
// Check feature flag
final showNewUI = await PostHogService.instance.featureFlags.isEnabled('new_checkout_ui');

if (showNewUI) {
  return NewCheckoutScreen();
} else {
  return ClassicCheckoutScreen();
}

// Get variant for multivariate test
final buttonColor = await PostHogService.instance.featureFlags.getFlagValue('cta_color');
// Returns: 'blue', 'green', 'red', etc.
```

### Conversion Tracking

```dart
// Start conversion funnel
await PostHogService.instance.conversions.startFunnel(
  'purchase_flow',
  {'entry_point': 'product_page', 'product_id': productId}
);

// Track funnel steps
await PostHogService.instance.conversions.trackFunnelStep(
  'purchase_flow',
  'add_to_cart',
  {'quantity': 2, 'total_value': 59.99}
);

// Track conversion
await PostHogService.instance.conversions.trackConversion(
  conversionName: 'purchase_completed',
  conversionType: 'purchase',
  conversionValue: 59.99,
  currency: 'USD',
);
```

## 🎯 Marketing Team Features

The boilerplate includes a dedicated marketing helper module with pre-built tracking methods:

```dart
import 'package:faithlock/services/analytics/posthog/utils/marketing_helpers.dart';

// Track user acquisition
await PostHogMarketingHelpers.trackUserAcquisition(
  source: 'google_ads',
  medium: 'cpc',
  campaign: 'summer_sale_2024',
  term: 'productivity_app',
);

// Track campaign ROI
await PostHogMarketingHelpers.trackCampaignROI(
  campaignId: 'fb_summer_2024',
  spent: 1000.0,
  revenue: 3500.0,
  currency: 'USD',
  conversions: 45,
);

// Track customer lifetime value
await PostHogMarketingHelpers.trackCustomerLifetimeValue(
  userId: 'user_123',
  totalRevenue: 299.95,
  currency: 'USD',
  totalOrders: 8,
  customerLifespan: Duration(days: 365),
);
```

## 📊 Available Modules

### 1. Event Tracking Module
- Custom and predefined events
- Automatic property enrichment
- Performance metrics tracking
- Error tracking with context

### 2. User Analytics Module
- User identification
- Property management
- Segmentation support
- Anonymous tracking

### 3. Screen Tracking Module
- Automatic screen views
- Navigation flow tracking
- Screen duration metrics
- User journey mapping

### 4. Feature Flags Module
- Boolean and multivariate flags
- Caching for performance
- Variant tracking
- Gradual rollout support

### 5. Session Recording Module
- User session replay
- Custom event markers
- Error context capture
- Privacy-safe recording

### 6. Conversion Module
- Multi-step funnels
- Revenue tracking
- Goal completion
- Attribution modeling

### 7. Campaign Module
- Email campaign tracking
- Ad performance metrics
- Social media campaigns
- Referral tracking

### 8. Surveys Module
- In-app surveys
- NPS scoring
- CSAT tracking
- Custom feedback forms

## 🔒 Privacy & Compliance

### GDPR Compliance

```dart
import 'package:faithlock/services/analytics/posthog/utils/privacy_manager.dart';

// Check consent status
final hasConsent = PostHogPrivacyManager.instance.consentStatus == ConsentStatus.granted;

// Update consent
await PostHogPrivacyManager.instance.setConsent(ConsentStatus.granted);

// Handle opt-out
await PostHogPrivacyManager.instance.setOptOut(true);

// Export user data (GDPR right)
final userData = PostHogPrivacyManager.instance.exportUserData();

// Delete all user data
await PostHogPrivacyManager.instance.deleteAllUserData();
```

### Data Sanitization
- Automatic PII masking
- Sensitive data filtering
- Configurable retention policies
- Anonymous tracking options

## 📈 What You Can Track

### User Metrics
- Daily/Monthly Active Users
- User retention (D1, D7, D30)
- Session duration and frequency
- Feature adoption rates

### Business Metrics
- Revenue and transactions
- Conversion rates
- Customer lifetime value
- Churn prediction

### Marketing Metrics
- Campaign performance
- Attribution by channel
- Cost per acquisition
- Return on ad spend

### Product Metrics
- Feature usage
- User flows
- Error rates
- Performance metrics

## 🎮 Advanced Features

### Custom Properties
Every tracking method supports custom properties:

```dart
await postHog.events.track(
  PostHogEventType.purchaseCompleted,
  {
    // Standard properties
    'product_id': '123',
    'price': 29.99,
    'currency': 'USD',

    // Custom properties
    'coupon_used': 'SUMMER20',
    'payment_method': 'apple_pay',
    'shipping_speed': 'express',
    'gift_purchase': false,
  }
);
```

### Batch Operations
Events are automatically batched for performance:
- Development: Sends after 1 event
- Production: Sends after 20 events or 30 seconds
- Configurable queue sizes

### Offline Support
- Events queued when offline
- Automatic retry on connection
- Persistent storage
- No data loss

## 🚨 Debugging

### Enable Debug Mode

```dart
await postHog.init(
  customApiKey: 'your_key',
  enableDebug: true, // Enables console logging
);
```

### Check Service Status

```dart
// Get service statistics
final stats = PostHogService.instance.getStats();
print('PostHog Status: ${stats['enabled']}');
print('Events Queued: ${stats['queued_events']}');
```

### Common Issues

| Issue | Solution |
|-------|----------|
| Events not appearing | Check API key and network connection |
| Feature flags empty | Call `refreshFlags()` after init |
| User not identified | Ensure `identify()` called after login |
| High memory usage | Reduce `maxQueueSize` in config |

## 🏆 Best Practices

### ✅ DO
- Initialize PostHog early in app lifecycle
- Use predefined event types when available
- Add meaningful properties to events
- Test with debug mode first
- Respect user privacy choices

### ❌ DON'T
- Track sensitive information (passwords, SSN)
- Call init() multiple times
- Ignore error handling
- Track events in tight loops
- Forget GDPR compliance

## 📚 Resources

- [PostHog Documentation](https://posthog.com/docs)
- [PostHog Dashboard](https://app.posthog.com)
- [Flutter SDK Reference](https://posthog.com/docs/libraries/flutter)
- [Feature Flags Guide](https://posthog.com/docs/feature-flags)
- [Session Recording Setup](https://posthog.com/docs/session-replay)

## 💡 Why PostHog?

- **All-in-one platform** - Analytics, feature flags, session recording
- **Privacy-first** - Self-hosting option available
- **Developer-friendly** - Great SDK and documentation
- **Cost-effective** - Generous free tier
- **Open source** - Transparent and extensible

---

🎉 **Your PostHog integration is ready to use!** Start tracking events and gaining insights into your users immediately.
