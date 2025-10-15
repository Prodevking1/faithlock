# 🚀 PostHog Analytics Setup Guide

## 📋 Overview

Ce guide vous explique comment configurer et utiliser le service PostHog Analytics intégré dans votre application Fast App. Le service est entièrement modulaire et optimisé pour les équipes marketing.

## 🛠️ Installation et Configuration

### 1. Prérequis

- ✅ PostHog Flutter SDK déjà installé (`posthog_flutter: ^4.11.0`)
- ✅ Service PostHog complètement intégré
- ✅ Modules spécialisés prêts à l'emploi

### 2. Configuration de Base

#### Étape 1: Obtenir votre clé API PostHog

1. Créez un compte sur [PostHog.com](https://posthog.com)
2. Créez un nouveau projet
3. Récupérez votre **Project API Key** (commence par `phc_`)

#### Étape 2: Configurer la clé API

Dans `lib/main.dart`, remplacez la clé par défaut :

```dart
// Initialize PostHog Analytics
final PostHogService postHog = PostHogService.instance;
await postHog.init(
  customApiKey: 'phc_votre_vraie_cle_api_ici', // ⚠️ Remplacez par votre vraie clé
  environment: kDebugMode ? 'development' : 'production',
  enableDebug: kDebugMode,
);
```

#### Étape 3: Configuration avancée (optionnel)

Pour une configuration personnalisée :

```dart
await postHog.init(
  customApiKey: 'phc_votre_cle',
  host: 'https://eu.posthog.com', // Si vous utilisez l'instance EU
  environment: 'staging',
  enableDebug: true,
);
```

## 🎯 Utilisation pour l'Équipe Marketing

### Import Principal

```dart
import 'package:faithlock/services/analytics/posthog/utils/marketing_helpers.dart';
```

### 📈 Tracking d'Acquisition

```dart
// Nouvel utilisateur acquis
await PostHogMarketingHelpers.trackUserAcquisition(
  source: 'google',
  medium: 'cpc',
  campaign: 'summer_promo_2024',
  term: 'productivity_app',
  content: 'ad_variant_a',
  additionalData: {
    'landing_page': '/home',
    'referrer': 'google.com',
  }
);

// Coût d'acquisition
await PostHogMarketingHelpers.trackAcquisitionCost(
  source: 'facebook_ads',
  cost: 2.50,
  currency: 'EUR',
  campaignId: 'camp_summer_001',
);
```

### 💰 ROI et Conversion

```dart
// ROI d'une campagne
await PostHogMarketingHelpers.trackCampaignROI(
  campaignId: 'summer_promo',
  spent: 1000.0,
  revenue: 3500.0,
  currency: 'EUR',
  conversions: 25,
  impressions: 10000,
  clicks: 500,
);

// Customer Lifetime Value
await PostHogMarketingHelpers.trackCustomerLifetimeValue(
  userId: 'user_123',
  totalRevenue: 150.0,
  currency: 'EUR',
  totalOrders: 5,
  customerLifespan: Duration(days: 180),
  segment: 'premium_users',
);
```

### 📧 Campagnes Email

```dart
// Performance email
await PostHogMarketingHelpers.trackEmailCampaignPerformance(
  campaignId: 'newsletter_march_2024',
  action: 'opened', // 'sent', 'opened', 'clicked', 'converted'
  email: 'user@example.com',
  linkUrl: 'https://app.com/promo',
  segmentData: {
    'user_tier': 'premium',
    'signup_date': '2024-01-15',
  }
);
```

### 📱 Campagnes Publicitaires

```dart
// Performance des ads
await PostHogMarketingHelpers.trackAdCampaignPerformance(
  campaignId: 'fb_retargeting_001',
  adSetId: 'adset_123',
  adId: 'ad_456',
  action: 'click', // 'impression', 'click', 'conversion'
  platform: 'facebook',
  cost: 1.20,
  revenue: 35.0,
);
```

### 📊 Engagement et Rétention

```dart
// Engagement quotidien
await PostHogMarketingHelpers.trackDailyEngagement(
  sessionCount: 3,
  totalTimeSpent: Duration(minutes: 45),
  screenViewsCount: 12,
  actionsCount: 8,
);

// Rétention par cohorte
await PostHogMarketingHelpers.trackUserRetention(
  cohort: '2024_01',
  daysSinceSignup: 7,
  isActive: true,
);

// Analyse de cohorte
await PostHogMarketingHelpers.trackCohortAnalysis(
  cohortId: 'jan_2024_mobile',
  cohortDate: DateTime(2024, 1, 1),
  periodNumber: 2, // 2ème semaine
  periodType: 'week',
  activeUsers: 85,
  totalUsers: 100,
);
```

## 🔧 Utilisation pour les Développeurs

### Import Principal

```dart
import 'package:faithlock/services/analytics/posthog/export.dart';
```

### 📝 Events de Base

```dart
final postHog = PostHogService.instance;

// Event prédéfini
await postHog.events.track(
  PostHogEventType.featureUsed,
  {
    'feature_name': 'dark_mode',
    'enabled': true,
    'user_preference': 'automatic'
  }
);

// Event personnalisé
await postHog.events.trackCustom(
  'user_completed_tutorial',
  {
    'tutorial_name': 'onboarding_basics',
    'completion_time_seconds': 180,
    'steps_completed': 5,
    'steps_total': 5,
  }
);
```

### 👤 Gestion des Utilisateurs

```dart
// Identifier un utilisateur
await postHog.users.identify(
  'user_123',
  {
    'email': 'user@example.com',
    'plan': 'premium',
    'signup_date': '2024-01-15',
    'country': 'France',
  }
);

// Mettre à jour les propriétés
await postHog.users.setUserProperties({
  'last_seen': DateTime.now().toIso8601String(),
  'subscription_status': 'active',
  'feature_usage_count': 42,
});

// Logout/Reset
await postHog.users.reset();
```

### 📱 Tracking d'Écrans

```dart
// Track manuel d'un écran
await postHog.screens.trackScreen(
  'ProductDetailScreen',
  properties: {
    'product_id': '123',
    'category': 'electronics',
    'price': 29.99,
    'in_stock': true,
  }
);

// Transition entre écrans
await postHog.screens.trackScreenTransition(
  from: 'HomeScreen',
  to: 'ProductListScreen',
  transitionType: 'navigation',
  properties: {
    'search_query': 'smartphone',
    'filter_applied': true,
  }
);
```

### 🚩 Feature Flags & A/B Testing

```dart
// Vérifier un feature flag
final showNewCheckout = await postHog.featureFlags.isEnabled('new_checkout_flow');

if (showNewCheckout) {
  // Afficher la nouvelle interface de checkout
  showNewCheckoutUI();
} else {
  // Afficher l'ancienne interface
  showOldCheckoutUI();
}

// Flag multivarié
final buttonColor = await postHog.featureFlags.getFlagValue('button_color');
// buttonColor peut être 'red', 'blue', 'green', etc.

// Rafraîchir les flags
await postHog.featureFlags.refreshFlags();
```

### 🛒 Conversion et Funnels

```dart
// Démarrer un funnel
await postHog.conversions.startFunnel(
  'purchase_funnel',
  {
    'source': 'product_page',
    'product_id': '123',
    'user_segment': 'returning_customer'
  }
);

// Étapes du funnel
await postHog.conversions.trackFunnelStep(
  'purchase_funnel',
  'add_to_cart',
  {
    'product_id': '123',
    'quantity': 2,
    'variant': 'blue_large'
  }
);

await postHog.conversions.trackFunnelStep(
  'purchase_funnel',
  'checkout_started',
  {
    'payment_method': 'credit_card',
    'shipping_method': 'express'
  }
);

// Conversion finale
await postHog.conversions.trackConversion(
  conversionName: 'purchase_completed',
  conversionType: 'purchase',
  conversionValue: 59.99,
  currency: 'EUR',
  properties: {
    'order_id': 'ORD_123456',
    'items_count': 2,
    'discount_applied': 10.0,
  }
);
```

### 🎬 Session Recording

```dart
// Démarrer l'enregistrement
await postHog.sessions.startRecording();

// Événements custom dans la session
await postHog.sessions.recordEvent(
  'critical_error_occurred',
  {
    'error_type': 'payment_failed',
    'error_code': 'CC_DECLINED',
    'attempt_number': 2,
  }
);

// Arrêter l'enregistrement
await postHog.sessions.stopRecording();
```

### 📋 Surveys et Feedback

```dart
// Démarrer un sondage
await postHog.surveys.startSurvey(
  'satisfaction_survey_q1_2024',
  {
    'trigger': 'app_opened_5_times',
    'user_segment': 'active_users'
  }
);

// Réponse NPS
await postHog.surveys.trackNPSResponse(
  score: 9,
  comment: 'Great app, love the new features!',
  surveyId: 'nps_q1_2024',
);

// Feedback général
await postHog.surveys.trackFeedback(
  type: 'feature_request',
  message: 'Please add dark mode to the settings page',
  category: 'ui_improvement',
  rating: 4,
);
```

## 🔒 Gestion de la Vie Privée et GDPR

```dart
import 'package:faithlock/services/analytics/posthog/utils/privacy_manager.dart';

// Vérifier le consentement
final consentStatus = PostHogPrivacyManager.instance.consentStatus;

// Définir le consentement
await PostHogPrivacyManager.instance.setConsent(ConsentStatus.granted);

// Opt-out global
await PostHogPrivacyManager.instance.setOptOut(true);

// Exporter les données utilisateur (GDPR)
final userData = PostHogPrivacyManager.instance.exportUserData();

// Supprimer toutes les données
await PostHogPrivacyManager.instance.deleteAllUserData();
```

## 📊 Métriques Disponibles dans PostHog

### 🎯 Acquisition
- **Sources d'acquisition** : Organic, Paid, Social, Email, Direct
- **Coût par acquisition (CPA)** par canal
- **Attribution marketing** multi-touch
- **Conversion rate** par source

### 📈 Engagement
- **Sessions par utilisateur** et durée moyenne
- **Pages vues** et parcours utilisateur
- **Feature adoption** et utilisation
- **Time to value** pour nouveaux utilisateurs

### 💰 Business
- **Revenue tracking** et transactions
- **Customer Lifetime Value (CLV)**
- **Churn rate** et rétention
- **Funnels de conversion** personnalisables

### 🧪 Expérimentation
- **A/B tests** avec feature flags
- **Multivariate testing**
- **Statistical significance** automatique
- **Variant performance** tracking

## 🚨 Debugging et Troubleshooting

### Vérifier l'État du Service

```dart
// Statistiques générales
final stats = PostHogService.instance.getStats();
print('PostHog Stats: $stats');

// État des modules
final eventStats = postHog.events.getStats();
final userStats = postHog.users.getStats();
final flagStats = postHog.featureFlags.getStats();
```

### Mode Debug

En mode debug, tous les événements sont loggés :

```
I/flutter (12345): PostHog: Event tracked: user_signup
I/flutter (12345): PostHog: User identified: user_123
I/flutter (12345): PostHog: Feature flag checked: new_feature = true
I/flutter (12345): PostHog: Conversion tracked: purchase_completed
```

### Problèmes Courants

| Problème | Solution |
|----------|----------|
| Événements non envoyés | Vérifiez la clé API et la connexion internet |
| Service non initialisé | Appelez `postHog.init()` dans `main.dart` |
| Opt-out activé | Vérifiez `PostHogPrivacyManager.instance.isOptedOut` |
| Feature flags vides | Appelez `postHog.featureFlags.refreshFlags()` |

## 📝 Événements Prédéfinis

Le service inclut des templates pour les événements courants :

### Utilisateur
- `userSignup`, `userLogin`, `userLogout`
- `userProfileUpdate`, `userSubscription`

### Navigation
- `screenView`, `screenExit`, `navigationAction`
- `deepLinkOpened`

### Business
- `purchaseCompleted`, `subscriptionStarted`, `subscriptionCancelled`
- `trialStarted`, `trialEnded`

### Engagement
- `featureUsed`, `tutorialStarted`, `tutorialCompleted`
- `onboardingCompleted`, `feedbackSubmitted`

### Marketing
- `campaignViewed`, `adClicked`, `emailOpened`
- `pushNotificationOpened`, `shareCompleted`

### Technique
- `errorOccurred`, `performanceMetric`, `crashReported`
- `apiCallMade`

## 🎯 Bonnes Pratiques

### ✅ À Faire
- Initialisez PostHog tôt dans `main.dart`
- Utilisez les événements prédéfinis quand possible
- Ajoutez des propriétés contextuelles aux événements
- Respectez le consentement utilisateur (GDPR)
- Testez en mode debug avant la production

### ❌ À Éviter
- Ne trackez jamais de données sensibles (mots de passe, tokens)
- N'appelez pas `init()` plusieurs fois
- Ne bloquez pas l'UI avec des appels analytics
- N'oubliez pas de gérer les cas d'erreur

## 🔗 Ressources Utiles

- [PostHog Documentation](https://posthog.com/docs)
- [PostHog Flutter SDK](https://posthog.com/docs/libraries/flutter)
- [Dashboard PostHog](https://app.posthog.com)
- [Feature Flags Guide](https://posthog.com/docs/feature-flags)
- [Session Replay](https://posthog.com/docs/session-replay)

---

🎉 **Votre service PostHog est maintenant prêt !** Commencez à tracker vos événements et obtenez des insights précieux sur votre application.
