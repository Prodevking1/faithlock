import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import '../posthog_service.dart';

/// Module for marketing campaign tracking
class CampaignModule {
  final PostHogService _postHogService;
  bool _isInitialized = false;
  String? _currentCampaign;
  Map<String, dynamic>? _currentCampaignData;
  final Map<String, DateTime> _campaignStartTimes = {};

  CampaignModule(this._postHogService);

  /// Initialize the campaign module
  Future<void> init() async {
    try {
      _isInitialized = true;
      debugPrint('CampaignModule: Initialized successfully');
    } catch (e) {
      debugPrint('CampaignModule: Failed to initialize - $e');
      rethrow;
    }
  }

  /// Shutdown the module
  Future<void> shutdown() async {
    try {
      _isInitialized = false;
      _currentCampaign = null;
      _currentCampaignData = null;
      _campaignStartTimes.clear();
      debugPrint('CampaignModule: Shutdown successfully');
    } catch (e) {
      debugPrint('CampaignModule: Failed to shutdown - $e');
    }
  }

  /// Reset the module
  Future<void> reset() async {
    try {
      _currentCampaign = null;
      _currentCampaignData = null;
      _campaignStartTimes.clear();
      debugPrint('CampaignModule: Reset successfully');
    } catch (e) {
      debugPrint('CampaignModule: Failed to reset - $e');
    }
  }

  /// Track campaign attribution
  Future<void> trackCampaignAttribution({
    required String campaignId,
    required String campaignName,
    String? campaignSource,
    String? campaignMedium,
    String? campaignContent,
    String? campaignTerm,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('CampaignModule: Cannot track attribution - module not initialized');
      return;
    }

    try {
      _currentCampaign = campaignId;
      _currentCampaignData = {
        'campaign_id': campaignId,
        'campaign_name': campaignName,
        'campaign_source': campaignSource,
        'campaign_medium': campaignMedium,
        'campaign_content': campaignContent,
        'campaign_term': campaignTerm,
        ...?properties,
      };
      _campaignStartTimes[campaignId] = DateTime.now();

      await Posthog().capture(
        eventName: 'campaign_attributed',
        properties: {
          ..._currentCampaignData!,
          'attribution_time': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('CampaignModule: Campaign attribution tracked - $campaignName');
    } catch (e) {
      debugPrint('CampaignModule: Failed to track campaign attribution - $e');
    }
  }

  /// Track campaign interaction
  Future<void> trackCampaignInteraction({
    required String interactionType,
    String? campaignId,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('CampaignModule: Cannot track interaction - module not initialized');
      return;
    }

    final effectiveCampaignId = campaignId ?? _currentCampaign;
    if (effectiveCampaignId == null) {
      debugPrint('CampaignModule: No active campaign for interaction tracking');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'campaign_interaction',
        properties: {
          'campaign_id': effectiveCampaignId,
          'interaction_type': interactionType,
          if (campaignId != null && _currentCampaignData != null)
            'campaign_data': _currentCampaignData!,
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('CampaignModule: Campaign interaction tracked - $interactionType');
    } catch (e) {
      debugPrint('CampaignModule: Failed to track campaign interaction - $e');
    }
  }

  /// Track campaign conversion
  Future<void> trackCampaignConversion({
    required String conversionType,
    String? campaignId,
    double? conversionValue,
    String? currency,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('CampaignModule: Cannot track conversion - module not initialized');
      return;
    }

    final effectiveCampaignId = campaignId ?? _currentCampaign;
    if (effectiveCampaignId == null) {
      debugPrint('CampaignModule: No active campaign for conversion tracking');
      return;
    }

    try {
      final startTime = _campaignStartTimes[effectiveCampaignId];

      await Posthog().capture(
        eventName: 'campaign_conversion',
        properties: {
          'campaign_id': effectiveCampaignId,
          'conversion_type': conversionType,
          'conversion_value': conversionValue?.toDouble() ?? 0,
          'currency': currency ?? 'USD',
          if (campaignId == null && _currentCampaignData != null)
            'campaign_data': _currentCampaignData!,
          if (startTime != null)
            'time_to_conversion': DateTime.now().difference(startTime).inSeconds.toDouble(),
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('CampaignModule: Campaign conversion tracked - $conversionType');
    } catch (e) {
      debugPrint('CampaignModule: Failed to track campaign conversion - $e');
    }
  }

  /// Track email campaign events
  Future<void> trackEmailCampaign({
    required String emailCampaignId,
    required String action, // 'sent', 'opened', 'clicked', 'unsubscribed'
    String? emailAddress,
    String? linkUrl,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('CampaignModule: Cannot track email campaign - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'email_campaign_$action',
        properties: {
          'email_campaign_id': emailCampaignId,
          'action': action,
          if (emailAddress != null) 'email_address': emailAddress,
          if (linkUrl != null) 'link_url': linkUrl,
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('CampaignModule: Email campaign tracked - $action');
    } catch (e) {
      debugPrint('CampaignModule: Failed to track email campaign - $e');
    }
  }

  /// Track push notification campaign
  Future<void> trackPushCampaign({
    required String pushCampaignId,
    required String action, // 'sent', 'delivered', 'opened', 'dismissed'
    String? notificationTitle,
    String? notificationBody,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('CampaignModule: Cannot track push campaign - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'push_campaign_$action',
        properties: {
          'push_campaign_id': pushCampaignId,
          'action': action,
          if (notificationTitle != null) 'notification_title': notificationTitle,
          if (notificationBody != null) 'notification_body': notificationBody,
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('CampaignModule: Push campaign tracked - $action');
    } catch (e) {
      debugPrint('CampaignModule: Failed to track push campaign - $e');
    }
  }

  /// Track social media campaign
  Future<void> trackSocialCampaign({
    required String socialCampaignId,
    required String platform, // 'facebook', 'instagram', 'twitter', etc.
    required String action, // 'impression', 'click', 'share', 'like'
    String? postId,
    String? adId,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('CampaignModule: Cannot track social campaign - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'social_campaign_$action',
        properties: {
          'social_campaign_id': socialCampaignId,
          'platform': platform,
          'action': action,
          if (postId != null) 'post_id': postId,
          if (adId != null) 'ad_id': adId,
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('CampaignModule: Social campaign tracked - $platform:$action');
    } catch (e) {
      debugPrint('CampaignModule: Failed to track social campaign - $e');
    }
  }

  /// Track referral campaign
  Future<void> trackReferralCampaign({
    required String referralCode,
    required String action, // 'invited', 'joined', 'rewarded'
    String? referrerId,
    String? refereeId,
    double? rewardValue,
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('CampaignModule: Cannot track referral campaign - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'referral_campaign_$action',
        properties: {
          'referral_code': referralCode,
          'action': action,
          if (referrerId != null) 'referrer_id': referrerId,
          if (refereeId != null) 'referee_id': refereeId,
          if (rewardValue != null) 'reward_value': rewardValue,
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('CampaignModule: Referral campaign tracked - $action');
    } catch (e) {
      debugPrint('CampaignModule: Failed to track referral campaign - $e');
    }
  }

  /// Track A/B test campaign
  Future<void> trackABTestCampaign({
    required String testId,
    required String variant,
    required String action, // 'assigned', 'converted', 'completed'
    Map<String, dynamic>? properties,
  }) async {
    if (!_isInitialized) {
      debugPrint('CampaignModule: Cannot track A/B test - module not initialized');
      return;
    }

    try {
      await Posthog().capture(
        eventName: 'ab_test_campaign_$action',
        properties: {
          'test_id': testId,
          'variant': variant,
          'action': action,
          'timestamp': DateTime.now().toIso8601String(),
          ...?properties,
        },
      );

      debugPrint('CampaignModule: A/B test campaign tracked - $testId:$variant:$action');
    } catch (e) {
      debugPrint('CampaignModule: Failed to track A/B test campaign - $e');
    }
  }

  /// Get current campaign information
  Map<String, dynamic>? get currentCampaign {
    if (_currentCampaign == null || _currentCampaignData == null) {
      return null;
    }

    return {
      'campaign_id': _currentCampaign,
      'campaign_data': _currentCampaignData,
      'start_time': _campaignStartTimes[_currentCampaign!]?.toIso8601String(),
    };
  }

  /// Check if there's an active campaign
  bool get hasActiveCampaign => _currentCampaign != null;

  /// Get current campaign ID
  String? get currentCampaignId => _currentCampaign;

  /// Clear current campaign tracking
  void clearCurrentCampaign() {
    _currentCampaign = null;
    _currentCampaignData = null;
    debugPrint('CampaignModule: Current campaign cleared');
  }
}
