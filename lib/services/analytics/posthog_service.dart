// // =============================================================================
// // SERVICE POSTHOG COMPLET ET MODULAIRE POUR FLUTTER
// // =============================================================================
// // Optimisé pour les équipes marketing et techniques
// // Couvre : Analytics, Feature Flags, A/B Testing, Session Replay, Surveys
// // =============================================================================

// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:posthog_flutter/posthog_flutter.dart';

// // =============================================================================
// // ENUMS ET CONSTANTES
// // =============================================================================

// enum AnalyticsEventType {
//   userAction,
//   navigation,
//   conversion,
//   engagement,
//   error,
//   performance,
//   marketing,
//   business
// }

// enum UserJourneyStage {
//   acquisition,
//   activation,
//   retention,
//   revenue,
//   referral
// }

// enum SessionType {
//   authenticated,
//   anonymous,
//   guest
// }

// // =============================================================================
// // MODÈLES DE DONNÉES
// // =============================================================================

// class AnalyticsEvent {
//   final String name;
//   final Map<String, dynamic> properties;
//   final AnalyticsEventType type;
//   final DateTime timestamp;
//   final UserJourneyStage? journeyStage;
//   final String? category;
//   final String? label;
//   final double? value;

//   AnalyticsEvent({
//     required this.name,
//     required this.properties,
//     required this.type,
//     required this.timestamp,
//     this.journeyStage,
//     this.category,
//     this.label,
//     this.value,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'timestamp': timestamp.toIso8601String(),
//       'type': type.name,
//       'journey_stage': journeyStage?.name,
//       'category': category,
//       'label': label,
//       'value': value,
//       ...properties,
//     };
//   }
// }

// class UserProfile {
//   final String userId;
//   final Map<String, dynamic> properties;
//   final Map<String, dynamic> propertiesSetOnce;
//   final SessionType sessionType;
//   final DateTime createdAt;
//   final DateTime lastActiveAt;

//   UserProfile({
//     required this.userId,
//     required this.properties,
//     required this.propertiesSetOnce,
//     required this.sessionType,
//     required this.createdAt,
//     required this.lastActiveAt,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'user_id': userId,
//       'session_type': sessionType.name,
//       'created_at': createdAt.toIso8601String(),
//       'last_active_at': lastActiveAt.toIso8601String(),
//       ...properties,
//     };
//   }
// }

// class FeatureFlagResult {
//   final String key;
//   final dynamic value;
//   final Map<String, dynamic>? payload;
//   final bool isEnabled;
//   final String variant;
//   final DateTime evaluatedAt;

//   FeatureFlagResult({
//     required this.key,
//     required this.value,
//     this.payload,
//     required this.isEnabled,
//     required this.variant,
//     required this.evaluatedAt,
//   });
// }

// class ExperimentVariant {
//   final String key;
//   final String name;
//   final Map<String, dynamic> config;
//   final double weight;

//   ExperimentVariant({
//     required this.key,
//     required this.name,
//     required this.config,
//     required this.weight,
//   });
// }

// // =============================================================================
// // CONFIGURATION DU SERVICE
// // =============================================================================

// class PostHogServiceConfig {
//   final String apiKey;
//   final String host;
//   final bool debug;
//   final bool captureApplicationLifecycleEvents;
//   final bool sessionReplay;
//   final PostHogPersonProfiles personProfiles;
//   final int flushAt;
//   final int flushIntervalSeconds;
//   final bool enableAutoCapture;
//   final bool enablePerformanceTracking;
//   final bool enableErrorTracking;
//   final Map<String, dynamic> defaultProperties;

//   const PostHogServiceConfig({
//     required this.apiKey,
//     this.host = 'https://us.i.posthog.com',
//     this.debug = false,
//     this.captureApplicationLifecycleEvents = true,
//     this.sessionReplay = false,
//     this.personProfiles = PostHogPersonProfiles.identifiedOnly,
//     this.flushAt = 20,
//     this.flushIntervalSeconds = 30,
//     this.enableAutoCapture = true,
//     this.enablePerformanceTracking = true,
//     this.enableErrorTracking = true,
//     this.defaultProperties = const {},
//   });
// }

// // =============================================================================
// // MIXINS POUR FONCTIONNALITÉS SPÉCIALISÉES
// // =============================================================================

// mixin AnalyticsMixin {
//   /// Tracking d'événements avec enrichissement automatique
//   Future<void> trackEvent(
//     String eventName, {
//     Map<String, dynamic>? properties,
//     AnalyticsEventType type = AnalyticsEventType.userAction,
//     UserJourneyStage? journeyStage,
//     String? category,
//     String? label,
//     double? value,
//   }) async {
//     final event = AnalyticsEvent(
//       name: eventName,
//       properties: properties ?? {},
//       type: type,
//       timestamp: DateTime.now(),
//       journeyStage: journeyStage,
//       category: category,
//       label: label,
//       value: value,
//     );

//     await Posthog().capture(
//       eventName: eventName,
//       properties: event.toMap(),
//     );
//   }

//   /// Tracking automatique des parcours utilisateur
//   Future<void> trackUserJourney(
//     UserJourneyStage stage, {
//     Map<String, dynamic>? additionalData,
//   }) async {
//     final journeyEvents = {
//       UserJourneyStage.acquisition: 'user_acquired',
//       UserJourneyStage.activation: 'user_activated',
//       UserJourneyStage.retention: 'user_retained',
//       UserJourneyStage.revenue: 'revenue_generated',
//       UserJourneyStage.referral: 'user_referred',
//     };

//     await trackEvent(
//       journeyEvents[stage]!,
//       properties: {
//         'journey_stage': stage.name,
//         'timestamp': DateTime.now().toIso8601String(),
//         ...?additionalData,
//       },
//       type: AnalyticsEventType.conversion,
//       journeyStage: stage,
//     );
//   }

//   /// Tracking des conversions avec valeur
//   Future<void> trackConversion(
//     String conversionType, {
//     required double value,
//     String? currency,
//     Map<String, dynamic>? metadata,
//   }) async {
//     await trackEvent(
//       'conversion_$conversionType',
//       properties: {
//         'conversion_type': conversionType,
//         'value': value,
//         'currency': currency ?? 'EUR',
//         'conversion_timestamp': DateTime.now().toIso8601String(),
//         ...?metadata,
//       },
//       type: AnalyticsEventType.conversion,
//       value: value,
//     );
//   }
// }

// mixin NavigationMixin {
//   /// Tracking automatique des vues d'écran
//   Future<void> trackScreenView(
//     String screenName, {
//     Map<String, dynamic>? properties,
//     Duration? timeSpent,
//     String? previousScreen,
//   }) async {
//     await Posthog().capture(
//       eventName: '\$screen',
//       properties: {
//         'screen_name': screenName,
//         'previous_screen': previousScreen,
//         'time_spent_seconds': timeSpent?.inSeconds,
//         'timestamp': DateTime.now().toIso8601String(),
//         ...?properties,
//       },
//     );
//   }

//   /// Tracking des navigations avec chemin
//   Future<void> trackNavigation(
//     String from,
//     String to, {
//     String? method,
//     Map<String, dynamic>? context,
//   }) async {
//     await Posthog().capture(
//       eventName: 'navigation',
//       properties: {
//         'from_screen': from,
//         'to_screen': to,
//         'navigation_method': method ?? 'tap',
//         'navigation_timestamp': DateTime.now().toIso8601String(),
//         ...?context,
//       },
//     );
//   }

//   /// Tracking du temps passé sur les écrans
//   Future<void> trackTimeOnScreen(
//     String screenName,
//     Duration duration, {
//     Map<String, dynamic>? additionalData,
//   }) async {
//     await Posthog().capture(
//       eventName: 'screen_time',
//       properties: {
//         'screen_name': screenName,
//         'duration_seconds': duration.inSeconds,
//         'duration_minutes': duration.inMinutes,
//         'is_engaged': duration.inSeconds > 30,
//         'timestamp': DateTime.now().toIso8601String(),
//         ...?additionalData,
//       },
//     );
//   }
// }

// mixin FeatureFlagsMixin {
//   /// Cache local des feature flags
//   final Map<String, FeatureFlagResult> _flagsCache = {};

//   /// Évaluation d'un feature flag avec cache
//   Future<FeatureFlagResult> evaluateFeatureFlag(String flagKey) async {
//     // Vérifier le cache d'abord
//     if (_flagsCache.containsKey(flagKey)) {
//       final cached = _flagsCache[flagKey]!;
//       // Utiliser le cache pendant 5 minutes
//       if (DateTime.now().difference(cached.evaluatedAt).inMinutes < 5) {
//         return cached;
//       }
//     }

//     try {
//       final value = await Posthog().getFeatureFlag(flagKey);
//       final payload = await Posthog().getFeatureFlagPayload(flagKey);
//       final isEnabled = await Posthog().isFeatureEnabled(flagKey);

//       final result = FeatureFlagResult(
//         key: flagKey,
//         value: value,
//         payload: payload,
//         isEnabled: isEnabled,
//         variant: value?.toString() ?? 'control',
//         evaluatedAt: DateTime.now(),
//       );

//       _flagsCache[flagKey] = result;

//       // Tracking automatique de l'évaluation du flag
//       await Posthog().capture(
//         eventName: '\$feature_flag_called',
//         properties: {
//           '\$feature_flag': flagKey,
//           '\$feature_flag_response': value,
//           'flag_payload': payload,
//           'evaluation_timestamp': DateTime.now().toIso8601String(),
//         },
//       );

//       return result;
//     } catch (e) {
//       // Fallback en cas d'erreur
//       return FeatureFlagResult(
//         key: flagKey,
//         value: false,
//         isEnabled: false,
//         variant: 'control',
//         evaluatedAt: DateTime.now(),
//       );
//     }
//   }

//   /// Recharger tous les feature flags
//   Future<void> reloadAllFeatureFlags() async {
//     await Posthog().reloadFeatureFlags();
//     _flagsCache.clear();
//   }

//   /// Widget conditionnel basé sur un feature flag
//   Widget buildConditionalWidget({
//     required String flagKey,
//     required Widget Function(FeatureFlagResult result) builder,
//     Widget? fallback,
//   }) {
//     return FutureBuilder<FeatureFlagResult>(
//       future: evaluateFeatureFlag(flagKey),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return builder(snapshot.data!);
//         }
//         return fallback ?? const SizedBox.shrink();
//       },
//     );
//   }
// }

// mixin ExperimentsMixin {
//   /// Gestion des expériences A/B
//   Future<ExperimentVariant> getExperimentVariant(
//     String experimentKey, {
//     List<ExperimentVariant>? variants,
//   }) async {
//     try {
//       final flagValue = await Posthog().getFeatureFlag(experimentKey);
//       final payload = await Posthog().getFeatureFlagPayload(experimentKey);

//       // Tracking automatique de l'exposition à l'expérience
//       await Posthog().capture(
//         eventName: '\$feature_flag_called',
//         properties: {
//           '\$feature_flag': experimentKey,
//           '\$feature_flag_response': flagValue,
//           'experiment_exposure': true,
//           'exposure_timestamp': DateTime.now().toIso8601String(),
//         },
//       );

//       // Retourner la variante correspondante
//       if (variants != null) {
//         final variant = variants.firstWhere(
//           (v) => v.key == flagValue,
//           orElse: () => variants.first, // Fallback vers control
//         );
//         return variant;
//       }

//       // Variante par défaut basée sur la réponse du flag
//       return ExperimentVariant(
//         key: flagValue?.toString() ?? 'control',
//         name: flagValue?.toString() ?? 'Control',
//         config: payload ?? {},
//         weight: 1.0,
//       );
//     } catch (e) {
//       // Fallback vers la variante de contrôle
//       return ExperimentVariant(
//         key: 'control',
//         name: 'Control',
//         config: {},
//         weight: 1.0,
//       );
//     }
//   }

//   /// Tracking des événements de goal pour les expériences
//   Future<void> trackExperimentGoal(
//     String experimentKey,
//     String goalEvent, {
//     Map<String, dynamic>? properties,
//     double? value,
//   }) async {
//     await Posthog().capture(
//       eventName: goalEvent,
//       properties: {
//         'experiment_key': experimentKey,
//         'goal_value': value,
//         'goal_timestamp': DateTime.now().toIso8601String(),
//         ...?properties,
//       },
//     );
//   }
// }

// mixin UserProfilingMixin {
//   /// Profil utilisateur enrichi
//   Future<void> identifyUser(
//     String userId, {
//     Map<String, dynamic>? properties,
//     Map<String, dynamic>? propertiesSetOnce,
//     SessionType sessionType = SessionType.authenticated,
//   }) async {
//     final profile = UserProfile(
//       userId: userId,
//       properties: {
//         'session_type': sessionType.name,
//         'last_login': DateTime.now().toIso8601String(),
//         'platform': defaultTargetPlatform.name,
//         ...?properties,
//       },
//       propertiesSetOnce: {
//         'first_seen': DateTime.now().toIso8601String(),
//         'signup_date': DateTime.now().toIso8601String(),
//         ...?propertiesSetOnce,
//       },
//       sessionType: sessionType,
//       createdAt: DateTime.now(),
//       lastActiveAt: DateTime.now(),
//     );

//     await Posthog().identify(
//       userId: userId,
//       userProperties: profile.properties,
//       userPropertiesSetOnce: profile.propertiesSetOnce,
//     );
//   }

//   /// Mise à jour des propriétés utilisateur
//   Future<void> updateUserProperties(Map<String, dynamic> properties) async {
//     await Posthog().identify(
//       userId: await Posthog().getDistinctId(),
//       userProperties: {
//         'last_updated': DateTime.now().toIso8601String(),
//         ...properties,
//       },
//     );
//   }

//   /// Segmentation automatique des utilisateurs
//   Future<void> segmentUser({
//     String? customerTier,
//     String? subscriptionType,
//     double? lifetimeValue,
//     List<String>? interests,
//     Map<String, dynamic>? customSegments,
//   }) async {
//     await updateUserProperties({
//       'customer_tier': customerTier,
//       'subscription_type': subscriptionType,
//       'lifetime_value': lifetimeValue,
//       'interests': interests,
//       'segment_updated_at': DateTime.now().toIso8601String(),
//       ...?customSegments,
//     });
//   }
// }

// mixin PerformanceMixin {
//   /// Tracking des performances de l'app
//   Future<void> trackPerformanceMetric(
//     String metricName,
//     double value, {
//     String? unit,
//     Map<String, dynamic>? context,
//   }) async {
//     await Posthog().capture(
//       eventName: 'performance_metric',
//       properties: {
//         'metric_name': metricName,
//         'metric_value': value,
//         'metric_unit': unit,
//         'timestamp': DateTime.now().toIso8601String(),
//         ...?context,
//       },
//     );
//   }

//   /// Mesure automatique du temps d'exécution
//   Future<T> measureExecutionTime<T>(
//     String operationName,
//     Future<T> Function() operation, {
//     Map<String, dynamic>? additionalData,
//   }) async {
//     final stopwatch = Stopwatch()..start();

//     try {
//       final result = await operation();
//       stopwatch.stop();

//       await trackPerformanceMetric(
//         'execution_time_$operationName',
//         stopwatch.elapsedMilliseconds.toDouble(),
//         unit: 'milliseconds',
//         context: {
//           'operation_success': true,
//           ...?additionalData,
//         },
//       );

//       return result;
//     } catch (e) {
//       stopwatch.stop();

//       await trackPerformanceMetric(
//         'execution_time_$operationName',
//         stopwatch.elapsedMilliseconds.toDouble(),
//         unit: 'milliseconds',
//         context: {
//           'operation_success': false,
//           'error': e.toString(),
//           ...?additionalData,
//         },
//       );

//       rethrow;
//     }
//   }

//   /// Tracking de la mémoire utilisée
//   Future<void> trackMemoryUsage() async {
//     // Note: En production, utilisez des packages comme process_run ou system_info
//     await trackPerformanceMetric(
//       'memory_usage',
//       Random().nextDouble() * 100, // Simulation
//       unit: 'MB',
//       context: {
//         'timestamp': DateTime.now().toIso8601String(),
//         'platform': defaultTargetPlatform.name,
//       },
//     );
//   }
// }

// // =============================================================================
// // SERVICE PRINCIPAL POSTHOG
// // =============================================================================

// class PostHogService
//     with
//         AnalyticsMixin,
//         NavigationMixin,
//         FeatureFlagsMixin,
//         ExperimentsMixin,
//         UserProfilingMixin,
//         PerformanceMixin {

//   static PostHogService? _instance;
//   static PostHogService get instance => _instance ??= PostHogService._();

//   PostHogService._();

//   PostHogServiceConfig? _config;
//   bool _isInitialized = false;
//   final Map<String, dynamic> _superProperties = {};
//   Timer? _flushTimer;

//   // Getters publics
//   bool get isInitialized => _isInitialized;
//   PostHogServiceConfig? get config => _config;

//   /// Initialisation du service PostHog
//   Future<void> initialize(PostHogServiceConfig config) async {
//     if (_isInitialized) return;

//     _config = config;

//     try {
//       final postHogConfig = PostHogConfig(config.apiKey);
//       postHogConfig.host = config.host;
//       postHogConfig.debug = config.debug;
//       postHogConfig.captureApplicationLifecycleEvents = config.captureApplicationLifecycleEvents;
//       postHogConfig.sessionReplay = config.sessionReplay;
//       postHogConfig.personProfiles = config.personProfiles;
//       postHogConfig.flushAt = config.flushAt;

//       await Posthog().setup(postHogConfig);

//       // Configuration des propriétés par défaut
//       if (config.defaultProperties.isNotEmpty) {
//         await _registerDefaultProperties(config.defaultProperties);
//       }

//       // Configuration du timer de flush automatique
//       _setupFlushTimer(config.flushIntervalSeconds);

//       _isInitialized = true;

//       // Tracking de l'initialisation
//       await trackEvent(
//         'posthog_service_initialized',
//         properties: {
//           'sdk_version': '4.x',
//           'platform': defaultTargetPlatform.name,
//           'session_replay_enabled': config.sessionReplay,
//           'auto_capture_enabled': config.enableAutoCapture,
//         },
//         type: AnalyticsEventType.performance,
//       );

//       if (kDebugMode) {
//         print('🚀 PostHog Service initialized successfully');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('❌ PostHog Service initialization failed: $e');
//       }
//       rethrow;
//     }
//   }

//   /// Enregistrement des propriétés par défaut
//   Future<void> _registerDefaultProperties(Map<String, dynamic> properties) async {
//     for (final entry in properties.entries) {
//       await Posthog().register(entry.key, entry.value);
//       _superProperties[entry.key] = entry.value;
//     }
//   }

//   /// Configuration du timer de flush
//   void _setupFlushTimer(int intervalSeconds) {
//     _flushTimer?.cancel();
//     _flushTimer = Timer.periodic(
//       Duration(seconds: intervalSeconds),
//       (_) => flush(),
//     );
//   }

//   /// Flush manuel des événements
//   Future<void> flush() async {
//     try {
//       await Posthog().flush();
//       if (kDebugMode) {
//         print('📤 PostHog events flushed');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('❌ PostHog flush failed: $e');
//       }
//     }
//   }

//   /// Reset complet de l'utilisateur
//   Future<void> resetUser() async {
//     await Posthog().reset();
//     _flagsCache.clear();

//     await trackEvent(
//       'user_reset',
//       properties: {
//         'reset_timestamp': DateTime.now().toIso8601String(),
//       },
//       type: AnalyticsEventType.userAction,
//     );
//   }

//   /// Opt-out de l'utilisateur
//   Future<void> optOut() async {
//     // Note: La méthode optOut n'est pas directement disponible dans le SDK Flutter
//     // Implémentation custom nécessaire
//     await trackEvent(
//       'user_opted_out',
//       properties: {
//         'opt_out_timestamp': DateTime.now().toIso8601String(),
//       },
//       type: AnalyticsEventType.userAction,
//     );
//   }

//   /// Nettoyage et fermeture du service
//   void dispose() {
//     _flushTimer?.cancel();
//     _flushTimer = null;
//     _flagsCache.clear();
//     _superProperties.clear();
//     _isInitialized = false;
//     _instance = null;
//   }

//   // =============================================================================
//   // MÉTHODES POUR ÉQUIPES MARKETING
//   // =============================================================================

//   /// Tracking complet d'un funnel marketing
//   Future<void> trackMarketingFunnel(
//     String funnelStep, {
//     required String campaignSource,
//     String? campaignMedium,
//     String? campaignName,
//     String? campaignContent,
//     String? campaignTerm,
//     Map<String, dynamic>? additionalData,
//   }) async {
//     await trackEvent(
//       'marketing_funnel_$funnelStep',
//       properties: {
//         'funnel_step': funnelStep,
//         'utm_source': campaignSource,
//         'utm_medium': campaignMedium,
//         'utm_campaign': campaignName,
//         'utm_content': campaignContent,
//         'utm_term': campaignTerm,
//         'funnel_timestamp': DateTime.now().toIso8601String(),
//         ...?additionalData,
//       },
//       type: AnalyticsEventType.marketing,
//     );
//   }

//   /// Tracking des interactions produit pour le marketing
//   Future<void> trackProductInteraction(
//     String productId,
//     String interactionType, {
//     String? productName,
//     String? productCategory,
//     double? productPrice,
//     String? productVariant,
//     Map<String, dynamic>? metadata,
//   }) async {
//     await trackEvent(
//       'product_interaction',
//       properties: {
//         'product_id': productId,
//         'product_name': productName,
//         'product_category': productCategory,
//         'product_price': productPrice,
//         'product_variant': productVariant,
//         'interaction_type': interactionType,
//         'interaction_timestamp': DateTime.now().toIso8601String(),
//         ...?metadata,
//       },
//       type: AnalyticsEventType.engagement,
//     );
//   }

//   /// Tracking des campagnes d'email marketing
//   Future<void> trackEmailCampaign(
//     String campaignId, {
//     required String action, // 'sent', 'opened', 'clicked', 'unsubscribed'
//     String? emailType,
//     String? subject,
//     Map<String, dynamic>? segmentData,
//   }) async {
//     await trackEvent(
//       'email_campaign_$action',
//       properties: {
//         'campaign_id': campaignId,
//         'email_type': emailType,
//         'subject': subject,
//         'action_timestamp': DateTime.now().toIso8601String(),
//         ...?segmentData,
//       },
//       type: AnalyticsEventType.marketing,
//     );
//   }

//   /// Création de rapports automatiques pour le marketing
//   Future<Map<String, dynamic>> generateMarketingReport({
//     DateTime? startDate,
//     DateTime? endDate,
//   }) async {
//     // Cette méthode génèrerait un rapport basé sur les événements trackés
//     // En production, cela nécessiterait des appels à l'API PostHog

//     return {
//       'period': {
//         'start': startDate?.toIso8601String(),
//         'end': endDate?.toIso8601String(),
//       },
//       'summary': {
//         'total_users': 'Nécessite API call',
//         'conversions': 'Nécessite API call',
//         'funnel_performance': 'Nécessite API call',
//       },
//       'generated_at': DateTime.now().toIso8601String(),
//     };
//   }
// }

// // =============================================================================
// // WIDGETS UTILITAIRES
// // =============================================================================

// /// Widget pour l'analytics automatique des vues d'écran
// class PostHogScreenWrapper extends StatefulWidget {
//   final String screenName;
//   final Widget child;
//   final Map<String, dynamic>? screenProperties;

//   const PostHogScreenWrapper({
//     super.key,
//     required this.screenName,
//     required this.child,
//     this.screenProperties,
//   });

//   @override
//   State<PostHogScreenWrapper> createState() => _PostHogScreenWrapperState();
// }

// class _PostHogScreenWrapperState extends State<PostHogScreenWrapper> {
//   DateTime? _screenEnterTime;

//   @override
//   void initState() {
//     super.initState();
//     _screenEnterTime = DateTime.now();
//     _trackScreenView();
//   }

//   @override
//   void dispose() {
//     _trackTimeOnScreen();
//     super.dispose();
//   }

//   void _trackScreenView() {
//     PostHogService.instance.trackScreenView(
//       widget.screenName,
//       properties: widget.screenProperties,
//     );
//   }

//   void _trackTimeOnScreen() {
//     if (_screenEnterTime != null) {
//       final duration = DateTime.now().difference(_screenEnterTime!);
//       PostHogService.instance.trackTimeOnScreen(
//         widget.screenName,
//         duration,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }

// /// Widget pour feature flags avec fallback
// class PostHogFeatureFlag extends StatelessWidget {
//   final String flagKey;
//   final Widget Function(bool isEnabled, dynamic value, Map<String, dynamic>? payload) builder;
//   final Widget? fallback;

//   const PostHogFeatureFlag({
//     super.key,
//     required this.flagKey,
//     required this.builder,
//     this.fallback,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<FeatureFlagResult>(
//       future: PostHogService.instance.evaluateFeatureFlag(flagKey),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           final result = snapshot.data!;
//           return builder(result.isEnabled, result.value, result.payload);
//         }
//         return fallback ?? const SizedBox.shrink();
//       },
//     );
//   }
// }

// // =============================================================================
// // EXTENSION POUR FACILITER L'USAGE
// // =============================================================================

// extension PostHogWidgetExtension on Widget {
//   /// Wrapper automatique pour le tracking d'écran
//   Widget withPostHogScreen(
//     String screenName, {
//     Map<String, dynamic>? properties,
//   }) {
//     return PostHogScreenWrapper(
//       screenName: screenName,
//       screenProperties: properties,
//       child: this,
//     );
//   }
// }

// // =============================================================================
// // EXEMPLE D'UTILISATION DANS MAIN.DART
// // =============================================================================

// /*
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Configuration du service PostHog
//   const config = PostHogServiceConfig(
//     apiKey: 'YOUR_API_KEY',
//     host: 'https://eu.i.posthog.com',
//     debug: true,
//     sessionReplay: true,
//     enableAutoCapture: true,
//     defaultProperties: {
//       'app_version': '1.0.0',
//       'app_environment': 'production',
//     },
//   );

//   // Initialisation
//   await PostHogService.instance.initialize(config);

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'PostHog Demo',
//       home: HomeScreen().withPostHogScreen('home_screen'),
//       navigatorObservers: [PosthogObserver()],
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('PostHog Demo')),
//       body: Column(
//         children: [
//           // Exemple d'utilisation des feature flags
//           PostHogFeatureFlag(
//             flagKey: 'show_premium_button',
//             builder: (isEnabled, value, payload) {
//               if (isEnabled) {
//                 return ElevatedButton(
//                   onPressed: () async {
//                     await PostHogService.instance.trackEvent(
//                       'premium_button_clicked',
//                       properties: {'flag_value': value, 'payload': payload},
//                       type: AnalyticsEventType.conversion,
//                     );
//                   },
//                   child: Text('Premium Feature'),
//                 );
//               }
//               return SizedBox.shrink();
//             },
//           ),

//           // Exemple de tracking d'événement marketing
//           ElevatedButton(
//             onPressed: () async {
//               await PostHogService.instance.trackMarketingFunnel(
//                 'product_viewed',
//                 campaignSource: 'google',
//                 campaignMedium: 'cpc',
//                 campaignName: 'summer_sale',
//                 additionalData: {'product_category': 'electronics'},
//               );
//             },
//             child: Text('Track Marketing Event'),
//           ),

//           // Exemple de tracking d'interaction produit
//           ElevatedButton(
//             onPressed: () async {
//               await PostHogService.instance.trackProductInteraction(
//                 'product_123',
//                 'view_details',
//                 productName: 'Smartphone XYZ',
//                 productCategory: 'Electronics',
//                 productPrice: 699.99,
//               );
//             },
//             child: Text('View Product'),
//           ),
//         ],
//       ),
//     );
//   }
// }
// */

// // =============================================================================
// // UTILITAIRES AVANCÉS POUR ÉQUIPES MARKETING
// // =============================================================================

// class MarketingAnalytics {
//   static final PostHogService _service = PostHogService.instance;

//   /// Tracking complet d'un parcours d'achat e-commerce
//   static Future<void> trackEcommerceFunnel({
//     required String step, // 'product_view', 'add_to_cart', 'checkout', 'purchase'
//     required String productId,
//     String? productName,
//     String? productCategory,
//     double? productPrice,
//     int? quantity,
//     String? currency,
//     Map<String, dynamic>? additionalData,
//   }) async {
//     await _service.trackEvent(
//       'ecommerce_$step',
//       properties: {
//         'product_id': productId,
//         'product_name': productName,
//         'product_category': productCategory,
//         'product_price': productPrice,
//         'quantity': quantity,
//         'currency': currency ?? 'EUR',
//         'ecommerce_step': step,
//         'step_timestamp': DateTime.now().toIso8601String(),
//         ...?additionalData,
//       },
//       type: AnalyticsEventType.conversion,
//       journeyStage: _getJourneyStageFromEcommerceStep(step),
//     );
//   }

//   /// Déterminer l'étape du parcours utilisateur basée sur l'étape e-commerce
//   static UserJourneyStage _getJourneyStageFromEcommerceStep(String step) {
//     switch (step) {
//       case 'product_view':
//         return UserJourneyStage.activation;
//       case 'add_to_cart':
//         return UserJourneyStage.retention;
//       case 'checkout':
//       case 'purchase':
//         return UserJourneyStage.revenue;
//       default:
//         return UserJourneyStage.activation;
//     }
//   }

//   /// Tracking des campagnes push notifications
//   static Future<void> trackPushNotification({
//     required String campaignId,
//     required String action, // 'sent', 'delivered', 'opened', 'clicked'
//     String? notificationType,
//     String? title,
//     String? message,
//     Map<String, dynamic>? segmentData,
//   }) async {
//     await _service.trackEvent(
//       'push_notification_$action',
//       properties: {
//         'campaign_id': campaignId,
//         'notification_type': notificationType,
//         'title': title,
//         'message': message,
//         'push_timestamp': DateTime.now().toIso8601String(),
//         ...?segmentData,
//       },
//       type: AnalyticsEventType.marketing,
//     );
//   }

//   /// Tracking des partages sociaux
//   static Future<void> trackSocialShare({
//     required String platform, // 'facebook', 'twitter', 'instagram', 'linkedin'
//     required String contentType, // 'product', 'article', 'promotion'
//     String? contentId,
//     String? contentTitle,
//     Map<String, dynamic>? additionalData,
//   }) async {
//     await _service.trackEvent(
//       'social_share',
//       properties: {
//         'platform': platform,
//         'content_type': contentType,
//         'content_id': contentId,
//         'content_title': contentTitle,
//         'share_timestamp': DateTime.now().toIso8601String(),
//         ...?additionalData,
//       },
//       type: AnalyticsEventType.marketing,
//       journeyStage: UserJourneyStage.referral,
//     );
//   }

//   /// Tracking des référrals et programmes de parrainage
//   static Future<void> trackReferral({
//     required String referralCode,
//     required String action, // 'sent', 'clicked', 'completed'
//     String? referrerUserId,
//     String? referredUserId,
//     double? rewardValue,
//     Map<String, dynamic>? additionalData,
//   }) async {
//     await _service.trackEvent(
//       'referral_$action',
//       properties: {
//         'referral_code': referralCode,
//         'referrer_user_id': referrerUserId,
//         'referred_user_id': referredUserId,
//         'reward_value': rewardValue,
//         'referral_timestamp': DateTime.now().toIso8601String(),
//         ...?additionalData,
//       },
//       type: AnalyticsEventType.marketing,
//       journeyStage: UserJourneyStage.referral,
//     );
//   }

//   /// Tracking des programmes de fidélité
//   static Future<void> trackLoyaltyProgram({
//     required String action, // 'joined', 'points_earned', 'points_redeemed', 'tier_upgraded'
//     String? programId,
//     int? pointsValue,
//     String? tier,
//     String? rewardType,
//     Map<String, dynamic>? additionalData,
//   }) async {
//     await _service.trackEvent(
//       'loyalty_$action',
//       properties: {
//         'program_id': programId,
//         'points_value': pointsValue,
//         'tier': tier,
//         'reward_type': rewardType,
//         'loyalty_timestamp': DateTime.now().toIso8601String(),
//         ...?additionalData,
//       },
//       type: AnalyticsEventType.engagement,
//       journeyStage: UserJourneyStage.retention,
//     );
//   }
// }

// // =============================================================================
// // ANALYTICS AVANCÉS POUR MESURES BUSINESS
// // =============================================================================

// class BusinessAnalytics {
//   static final PostHogService _service = PostHogService.instance;

//   /// Tracking des KPIs business en temps réel
//   static Future<void> trackBusinessKPI({
//     required String kpiName,
//     required double value,
//     String? unit,
//     String? department,
//     Map<String, String>? dimensions,
//   }) async {
//     await _service.trackEvent(
//       'business_kpi',
//       properties: {
//         'kpi_name': kpiName,
//         'kpi_value': value,
//         'kpi_unit': unit,
//         'department': department,
//         'dimensions': dimensions,
//         'kpi_timestamp': DateTime.now().toIso8601String(),
//       },
//       type: AnalyticsEventType.business,
//     );
//   }

//   /// Tracking des revenus avec détails
//   static Future<void> trackRevenue({
//     required double amount,
//     required String currency,
//     String? revenueType, // 'subscription', 'one_time', 'upgrade', 'addon'
//     String? productId,
//     String? subscriptionPlan,
//     String? paymentMethod,
//     Map<String, dynamic>? taxDetails,
//   }) async {
//     await _service.trackConversion(
//       'revenue_generated',
//       value: amount,
//       currency: currency,
//       metadata: {
//         'revenue_type': revenueType,
//         'product_id': productId,
//         'subscription_plan': subscriptionPlan,
//         'payment_method': paymentMethod,
//         'tax_details': taxDetails,
//         'revenue_timestamp': DateTime.now().toIso8601String(),
//       },
//     );
//   }

//   /// Tracking des coûts d'acquisition client (CAC)
//   static Future<void> trackCustomerAcquisition({
//     required String acquisitionChannel,
//     required double acquisitionCost,
//     String? campaignId,
//     String? customerSegment,
//     Map<String, dynamic>? additionalMetrics,
//   }) async {
//     await _service.trackEvent(
//       'customer_acquisition',
//       properties: {
//         'acquisition_channel': acquisitionChannel,
//         'acquisition_cost': acquisitionCost,
//         'campaign_id': campaignId,
//         'customer_segment': customerSegment,
//         'acquisition_timestamp': DateTime.now().toIso8601String(),
//         ...?additionalMetrics,
//       },
//       type: AnalyticsEventType.business,
//       journeyStage: UserJourneyStage.acquisition,
//     );
//   }

//   /// Tracking de la satisfaction client (NPS, CSAT)
//   static Future<void> trackCustomerSatisfaction({
//     required String surveyType, // 'nps', 'csat', 'ces'
//     required int score,
//     String? feedback,
//     String? touchpoint,
//     Map<String, dynamic>? context,
//   }) async {
//     await _service.trackEvent(
//       'customer_satisfaction',
//       properties: {
//         'survey_type': surveyType,
//         'satisfaction_score': score,
//         'feedback': feedback,
//         'touchpoint': touchpoint,
//         'survey_timestamp': DateTime.now().toIso8601String(),
//         ...?context,
//       },
//       type: AnalyticsEventType.engagement,
//     );
//   }
// }

// // =============================================================================
// // SYSTEM DE COHORTS ET SEGMENTATION
// // =============================================================================

// class CohortAnalytics {
//   static final PostHogService _service = PostHogService.instance;

//   /// Assignation automatique à des cohortes
//   static Future<void> assignToCohort({
//     required String cohortName,
//     required String cohortType, // 'acquisition', 'behavior', 'demographic'
//     Map<String, dynamic>? cohortProperties,
//   }) async {
//     await _service.updateUserProperties({
//       'cohort_$cohortType': cohortName,
//       'cohort_assigned_at': DateTime.now().toIso8601String(),
//       ...?cohortProperties,
//     });

//     await _service.trackEvent(
//       'cohort_assignment',
//       properties: {
//         'cohort_name': cohortName,
//         'cohort_type': cohortType,
//         'assignment_timestamp': DateTime.now().toIso8601String(),
//         ...?cohortProperties,
//       },
//       type: AnalyticsEventType.business,
//     );
//   }

//   /// Tracking de la rétention par cohorte
//   static Future<void> trackCohortRetention({
//     required String cohortName,
//     required int daysSinceFirstUse,
//     String? retentionMilestone,
//   }) async {
//     await _service.trackEvent(
//       'cohort_retention',
//       properties: {
//         'cohort_name': cohortName,
//         'days_since_first_use': daysSinceFirstUse,
//         'retention_milestone': retentionMilestone,
//         'retention_timestamp': DateTime.now().toIso8601String(),
//       },
//       type: AnalyticsEventType.business,
//       journeyStage: UserJourneyStage.retention,
//     );
//   }
// }

// // =============================================================================
// // GESTIONNAIRE D'ERREURS ET MONITORING
// // =============================================================================

// class ErrorTrackingService {
//   static final PostHogService _service = PostHogService.instance;

//   /// Tracking automatique des erreurs
//   static Future<void> trackError({
//     required String errorType,
//     required String errorMessage,
//     String? stackTrace,
//     String? userId,
//     Map<String, dynamic>? context,
//     String? severity, // 'low', 'medium', 'high', 'critical'
//   }) async {
//     await _service.trackEvent(
//       'app_error',
//       properties: {
//         'error_type': errorType,
//         'error_message': errorMessage,
//         'stack_trace': stackTrace,
//         'user_id': userId,
//         'severity': severity ?? 'medium',
//         'error_timestamp': DateTime.now().toIso8601String(),
//         'app_version': 'Get from package_info',
//         'platform': defaultTargetPlatform.name,
//         ...?context,
//       },
//       type: AnalyticsEventType.error,
//     );
//   }

//   /// Handler global pour les erreurs Flutter
//   static void setupGlobalErrorHandler() {
//     FlutterError.onError = (FlutterErrorDetails details) {
//       trackError(
//         errorType: 'flutter_error',
//         errorMessage: details.exceptionAsString(),
//         stackTrace: details.stack.toString(),
//         context: {
//           'library': details.library,
//           'context': details.context?.toString(),
//         },
//         severity: 'high',
//       );

//       // Appeler le handler par défaut aussi
//       FlutterError.presentError(details);
//     };
//   }
// }

// // =============================================================================
// // WIDGET POUR TESTS A/B VISUELS
// // =============================================================================

// class ABTestWidget extends StatefulWidget {
//   final String experimentKey;
//   final Map<String, Widget Function(BuildContext)> variants;
//   final Widget Function(BuildContext)? fallback;
//   final VoidCallback? onExposure;

//   const ABTestWidget({
//     super.key,
//     required this.experimentKey,
//     required this.variants,
//     this.fallback,
//     this.onExposure,
//   });

//   @override
//   State<ABTestWidget> createState() => _ABTestWidgetState();
// }

// class _ABTestWidgetState extends State<ABTestWidget> {
//   ExperimentVariant? _currentVariant;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadExperiment();
//   }

//   Future<void> _loadExperiment() async {
//     try {
//       final variants = widget.variants.keys
//           .map((key) => ExperimentVariant(
//                 key: key,
//                 name: key.replaceAll('_', ' ').toUpperCase(),
//                 config: {},
//                 weight: 1.0,
//               ))
//           .toList();

//       final variant = await PostHogService.instance.getExperimentVariant(
//         widget.experimentKey,
//         variants: variants,
//       );

//       setState(() {
//         _currentVariant = variant;
//         _isLoading = false;
//       });

//       widget.onExposure?.call();
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_currentVariant != null &&
//         widget.variants.containsKey(_currentVariant!.key)) {
//       return widget.variants[_currentVariant!.key]!(context);
//     }

//     if (widget.fallback != null) {
//       return widget.fallback!(context);
//     }

//     // Fallback vers la première variante si disponible
//     if (widget.variants.isNotEmpty) {
//       return widget.variants.values.first(context);
//     }

//     return const SizedBox.shrink();
//   }
// }

// // =============================================================================
// // EXEMPLE D'USAGE COMPLET POUR ÉQUIPE MARKETING
// // =============================================================================

// /*
// class MarketingExampleScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Marketing Analytics Demo')),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Test A/B pour bouton d'achat
//             ABTestWidget(
//               experimentKey: 'purchase_button_test',
//               variants: {
//                 'control': (context) => ElevatedButton(
//                   onPressed: () => _handlePurchase(context, 'control'),
//                   child: Text('Buy Now'),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//                 ),
//                 'variant_a': (context) => ElevatedButton(
//                   onPressed: () => _handlePurchase(context, 'variant_a'),
//                   child: Text('Get Yours Today!'),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                 ),
//                 'variant_b': (context) => ElevatedButton(
//                   onPressed: () => _handlePurchase(context, 'variant_b'),
//                   child: Text('Limited Time Offer'),
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 ),
//               },
//               onExposure: () {
//                 PostHogService.instance.trackEvent(
//                   'ab_test_exposure',
//                   properties: {'test_name': 'purchase_button_test'},
//                 );
//               },
//             ),

//             SizedBox(height: 20),

//             // Tracking d'interaction produit
//             ElevatedButton(
//               onPressed: () async {
//                 await MarketingAnalytics.trackEcommerceFunnel(
//                   step: 'product_view',
//                   productId: 'smartphone_x1',
//                   productName: 'Smartphone X1',
//                   productCategory: 'Electronics',
//                   productPrice: 899.99,
//                   additionalData: {
//                     'view_source': 'featured_products',
//                     'discount_applied': false,
//                   },
//                 );
//               },
//               child: Text('View Product Details'),
//             ),

//             SizedBox(height: 20),

//             // Simulation de partage social
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 IconButton(
//                   onPressed: () => _shareSocial('facebook'),
//                   icon: Icon(Icons.facebook),
//                 ),
//                 IconButton(
//                   onPressed: () => _shareSocial('twitter'),
//                   icon: Icon(Icons.share),
//                 ),
//                 IconButton(
//                   onPressed: () => _shareSocial('instagram'),
//                   icon: Icon(Icons.camera_alt),
//                 ),
//               ],
//             ),

//             SizedBox(height: 20),

//             // Feature flag pour contenu premium
//             PostHogFeatureFlag(
//               flagKey: 'show_premium_content',
//               builder: (isEnabled, value, payload) {
//                 if (isEnabled) {
//                   return Card(
//                     color: Colors.gold,
//                     child: Padding(
//                       padding: EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           Text('Premium Content',
//                                style: TextStyle(fontWeight: FontWeight.bold)),
//                           Text('Exclusive offer just for you!'),
//                           ElevatedButton(
//                             onPressed: () => _trackPremiumInteraction(payload),
//                             child: Text('Claim Offer'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }
//                 return SizedBox.shrink();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _handlePurchase(BuildContext context, String variant) async {
//     // Track goal de l'expérience A/B
//     await PostHogService.instance.trackExperimentGoal(
//       'purchase_button_test',
//       'purchase_clicked',
//       properties: {'variant': variant},
//     );

//     // Track l'étape e-commerce
//     await MarketingAnalytics.trackEcommerceFunnel(
//       step: 'checkout',
//       productId: 'smartphone_x1',
//       productPrice: 899.99,
//       additionalData: {'ab_test_variant': variant},
//     );
//   }

//   void _shareSocial(String platform) async {
//     await MarketingAnalytics.trackSocialShare(
//       platform: platform,
//       contentType: 'product',
//       contentId: 'smartphone_x1',
//       contentTitle: 'Amazing Smartphone X1',
//     );
//   }

//   void _trackPremiumInteraction(Map<String, dynamic>? payload) async {
//     await PostHogService.instance.trackEvent(
//       'premium_offer_claimed',
//       properties: {
//         'offer_type': payload?['offer_type'],
//         'discount_percentage': payload?['discount'],
//       },
//       type: AnalyticsEventType.conversion,
//     );
//   }
// }
// */
