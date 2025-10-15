import 'package:faithlock/services/analytics/posthog/config/event_templates.dart';
import 'package:faithlock/services/analytics/posthog/posthog_service.dart';

/// Helpers spécialisés pour le marketing et l'équipe marketing
///
/// Cette classe fournit des méthodes prêtes à l'emploi pour les équipes marketing
/// afin de tracker facilement les métriques importantes sans connaissance technique.
class PostHogMarketingHelpers {
  static final PostHogService _postHog = PostHogService.instance;

  // ==================== ACQUISITION ====================

  /// Track l'attribution d'acquisition d'un nouvel utilisateur
  static Future<void> trackUserAcquisition({
    required String source,
    required String medium,
    String? campaign,
    String? term,
    String? content,
    Map<String, dynamic>? additionalData,
  }) async {
    if (!_postHog.isInitialized || !_postHog.isEnabled) {
      print('PostHog not initialized or disabled. Skipping user acquisition tracking.');
      return;
    }
    
    try {
      await _postHog.events.track(PostHogEventType.userSignup, {
        'acquisition_source': source,
        'acquisition_medium': medium,
        'utm_source': source,
        'utm_medium': medium,
        if (campaign != null) 'utm_campaign': campaign,
        if (term != null) 'utm_term': term,
        if (content != null) 'utm_content': content,
        'acquisition_timestamp': DateTime.now().toIso8601String(),
        ...?additionalData,
      });
    } catch (e) {
      print('Error tracking user acquisition: $e');
    }
  }

  /// Track le coût d'acquisition par utilisateur
  static Future<void> trackAcquisitionCost({
    required String source,
    required double cost,
    required String currency,
    String? campaignId,
  }) async {
    if (!_postHog.isInitialized || !_postHog.isEnabled) {
      print('PostHog not initialized or disabled. Skipping acquisition cost tracking.');
      return;
    }
    
    try {
      await _postHog.events.trackCustom('acquisition_cost_tracked', {
        'source': source,
        'cost': cost,
        'currency': currency,
        if (campaignId != null) 'campaign_id': campaignId,
        'cost_per_user': cost,
        'tracking_date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking acquisition cost: $e');
    }
  }

  // ==================== ENGAGEMENT ====================

  /// Track l'engagement quotidien de l'utilisateur
  static Future<void> trackDailyEngagement({
    required int sessionCount,
    required Duration totalTimeSpent,
    required int screenViewsCount,
    required int actionsCount,
  }) async {
    if (!_postHog.isInitialized || !_postHog.isEnabled) {
      print('PostHog not initialized or disabled. Skipping daily engagement tracking.');
      return;
    }
    
    try {
      await _postHog.events.trackCustom('daily_engagement', {
        'session_count': sessionCount,
        'total_time_spent_seconds': totalTimeSpent.inSeconds,
        'screen_views_count': screenViewsCount,
        'actions_count': actionsCount,
        'engagement_score': _calculateEngagementScore(
          sessionCount,
          totalTimeSpent,
          screenViewsCount,
          actionsCount,
        ),
        'date': DateTime.now().toIso8601String().split('T')[0],
      });
    } catch (e) {
      print('Error tracking daily engagement: $e');
    }
  }

  /// Track la retention d'utilisateur
  static Future<void> trackUserRetention({
    required String cohort,
    required int daysSinceSignup,
    required bool isActive,
  }) async {
    await _postHog.events.trackCustom('user_retention', {
      'cohort': cohort,
      'days_since_signup': daysSinceSignup,
      'is_active': isActive,
      'retention_period': _getRetentionPeriod(daysSinceSignup),
      'tracking_date': DateTime.now().toIso8601String(),
    });
  }

  // ==================== CONVERSION ====================

  /// Track une conversion de funnel marketing
  static Future<void> trackMarketingConversion({
    required String funnelName,
    required String step,
    required bool converted,
    String? source,
    String? campaign,
    double? value,
    String? currency,
  }) async {
    await _postHog.conversions.trackConversion(
      conversionType: 'marketing_funnel',
      conversionValue: value ?? 0,
      currency: currency ?? 'EUR',
      conversionName: funnelName,
      properties: {
        'funnel_name': funnelName,
        'step': step,
        'converted': converted,
        if (source != null) 'source': source,
        if (campaign != null) 'campaign': campaign,
      },
    );
  }

  /// Track une conversion de vente
  static Future<void> trackSalesConversion({
    required String productId,
    required String productName,
    required double price,
    required String currency,
    String? promotionCode,
    String? salesChannel,
  }) async {
    await _postHog.events.track(PostHogEventType.purchaseCompleted, {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'currency': currency,
      'conversion_type': 'sale',
      if (promotionCode != null) 'promotion_code': promotionCode,
      if (salesChannel != null) 'sales_channel': salesChannel,
      'conversion_timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ==================== CAMPAGNES ====================

  /// Track les performances d'une campagne email
  static Future<void> trackEmailCampaignPerformance({
    required String campaignId,
    required String action, // 'sent', 'opened', 'clicked', 'converted'
    String? email,
    String? linkUrl,
    Map<String, dynamic>? segmentData,
  }) async {
    await _postHog.campaigns.trackEmailCampaign(
      emailCampaignId: campaignId,
      action: action,
      properties: {
        if (email != null) 'email': email,
        if (linkUrl != null) 'link_url': linkUrl,
        'campaign_channel': 'email',
        ...?segmentData,
      },
    );
  }

  /// Track les performances d'une campagne publicitaire
  static Future<void> trackAdCampaignPerformance({
    required String campaignId,
    required String adSetId,
    required String adId,
    required String action, // 'impression', 'click', 'conversion'
    required String platform, // 'facebook', 'google', 'instagram', etc.
    double? cost,
    double? revenue,
  }) async {
    await _postHog.events.track(PostHogEventType.adClicked, {
      'campaign_id': campaignId,
      'ad_set_id': adSetId,
      'ad_id': adId,
      'action': action,
      'platform': platform,
      if (cost != null) 'cost': cost,
      if (revenue != null) 'revenue': revenue,
      'ctr': cost != null && revenue != null ? revenue / cost : null,
      'tracking_timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ==================== ROI ET MÉTRIQUES ====================

  /// Track le ROI d'une campagne
  static Future<void> trackCampaignROI({
    required String campaignId,
    required double spent,
    required double revenue,
    required String currency,
    int? conversions,
    int? impressions,
    int? clicks,
  }) async {
    final roi = (revenue - spent) / spent * 100;
    final roas = revenue / spent;

    await _postHog.events.trackCustom('campaign_roi', {
      'campaign_id': campaignId,
      'spent': spent,
      'revenue': revenue,
      'currency': currency,
      'roi_percentage': roi,
      'roas': roas,
      if (conversions != null) 'conversions': conversions,
      if (impressions != null) 'impressions': impressions,
      if (clicks != null) 'clicks': clicks,
      if (conversions != null && spent > 0) 'cpa': spent / conversions,
      if (clicks != null && impressions != null) 'ctr': clicks / impressions * 100,
      'calculation_date': DateTime.now().toIso8601String(),
    });
  }

  /// Track la Customer Lifetime Value (CLV)
  static Future<void> trackCustomerLifetimeValue({
    required String userId,
    required double totalRevenue,
    required String currency,
    required int totalOrders,
    required Duration customerLifespan,
    String? segment,
  }) async {
    final avgOrderValue = totalRevenue / totalOrders;
    final monthlyValue = totalRevenue / (customerLifespan.inDays / 30);

    await _postHog.events.trackCustom('customer_lifetime_value', {
      'user_id': userId,
      'total_revenue': totalRevenue,
      'currency': currency,
      'total_orders': totalOrders,
      'avg_order_value': avgOrderValue,
      'customer_lifespan_days': customerLifespan.inDays,
      'monthly_value': monthlyValue,
      if (segment != null) 'segment': segment,
      'calculation_date': DateTime.now().toIso8601String(),
    });
  }

  // ==================== COHORT ANALYSIS ====================

  /// Track l'analyse de cohorte
  static Future<void> trackCohortAnalysis({
    required String cohortId,
    required DateTime cohortDate,
    required int periodNumber, // 1 = première semaine/mois, 2 = deuxième, etc.
    required String periodType, // 'week', 'month'
    required int activeUsers,
    required int totalUsers,
  }) async {
    final retentionRate = (activeUsers / totalUsers) * 100;

    await _postHog.events.trackCustom('cohort_analysis', {
      'cohort_id': cohortId,
      'cohort_date': cohortDate.toIso8601String().split('T')[0],
      'period_number': periodNumber,
      'period_type': periodType,
      'active_users': activeUsers,
      'total_users': totalUsers,
      'retention_rate': retentionRate,
      'analysis_date': DateTime.now().toIso8601String(),
    });
  }

  // ==================== SEGMENTATION ====================

  /// Track un segment d'utilisateur
  static Future<void> trackUserSegment({
    required String segmentName,
    required Map<String, dynamic> segmentCriteria,
  }) async {
    await _postHog.users.trackSegment(
      segmentName: segmentName,
      properties: segmentCriteria,
    );
  }

  // ==================== MÉTHODES HELPERS PRIVÉES ====================

  static double _calculateEngagementScore(
    int sessionCount,
    Duration totalTimeSpent,
    int screenViewsCount,
    int actionsCount,
  ) {
    // Formule simple pour calculer un score d'engagement (0-100)
    final sessionScore = (sessionCount * 10).clamp(0, 30);
    final timeScore = (totalTimeSpent.inMinutes * 2).clamp(0, 30);
    final screenScore = (screenViewsCount * 1).clamp(0, 20);
    final actionScore = (actionsCount * 2).clamp(0, 20);

    return (sessionScore + timeScore + screenScore + actionScore).toDouble();
  }

  static String _getRetentionPeriod(int daysSinceSignup) {
    if (daysSinceSignup <= 1) return 'D1';
    if (daysSinceSignup <= 7) return 'D7';
    if (daysSinceSignup <= 30) return 'D30';
    if (daysSinceSignup <= 90) return 'D90';
    return 'D90+';
  }

  // ==================== MÉTRIQUES PRÊTES POUR DASHBOARD ====================

  /// Obtient les métriques pour dashboard marketing
  static Map<String, dynamic> getMarketingDashboardMetrics() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'service_status': 'active',
      'tracking_enabled': _postHog.isEnabled,
      'session_id': _postHog.sessionId,
      'user_id': _postHog.currentUserId,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }
}
