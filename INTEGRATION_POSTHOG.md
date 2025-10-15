# 🚀 PostHog Integration Guide - Fast App

## Vue d'ensemble

Cette intégration PostHog complète fournit un système d'analytics modulaire et puissant pour votre application Flutter. Le service est conçu spécialement pour les équipes marketing avec des méthodes prêtes à l'emploi pour tracker toutes les métriques importantes.

## 📦 Structure du Service

```
lib/services/analytics/posthog/
├── posthog_service.dart              # Service principal
├── config/
│   ├── posthog_config.dart           # Configuration
│   └── event_templates.dart          # Templates d'événements
├── modules/
│   ├── event_tracking_module.dart    # Tracking événements
│   ├── user_analytics_module.dart    # Analytics utilisateur
│   ├── screen_tracking_module.dart   # Tracking écrans
│   ├── feature_flags_module.dart     # Feature flags
│   ├── session_recording_module.dart # Session replay
│   ├── conversion_module.dart        # Conversions
│   ├── campaign_module.dart          # Campagnes
│   └── surveys_module.dart           # Sondages
├── models/
│   └── posthog_event.dart           # Modèles d'événements
├── utils/
│   ├── privacy_manager.dart         # Gestion vie privée
│   └── marketing_helpers.dart       # Helpers marketing
└── export.dart                     # Exports publics
```

## ⚙️ Configuration

### 1. Variables d'environnement

Ajoutez dans votre fichier `.env` :

```env
POSTHOG_API_KEY=phc_votre_cle_api_posthog_ici
POSTHOG_HOST=https://us.i.posthog.com
```

### 2. Initialisation

Le service est déjà initialisé dans `main.dart` :

```dart
// Initialize PostHog Analytics
final PostHogService postHog = PostHogService.instance;
await postHog.init(
  environment: kDebugMode ? 'development' : 'production',
  enableDebug: kDebugMode,
);
```

## 🎯 Utilisation pour l'Équipe Marketing

### Tracking d'Acquisition

```dart
import 'package:faithlock/services/analytics/posthog/utils/marketing_helpers.dart';

// Track l'acquisition d'un nouvel utilisateur
await PostHogMarketingHelpers.trackUserAcquisition(
  source: 'google',
  medium: 'cpc',
  campaign: 'summer_2024',
  term: 'productivity_app',
  content: 'ad_variant_a',
);

// Track le coût d'acquisition
await PostHogMarketingHelpers.trackAcquisitionCost(
  source: 'facebook_ads',
  cost: 2.50,
  currency: 'EUR',
  campaignId: 'camp_123',
);
```

### Analytics d'Engagement

```dart
// Track l'engagement quotidien
await PostHogMarketingHelpers.trackDailyEngagement(
  sessionCount: 3,
  totalTimeSpent: Duration(minutes: 45),
  screenViewsCount: 12,
  actionsCount: 8,
);

// Track la rétention
await PostHogMarketingHelpers.trackUserRetention(
  cohort: '2024_01',
  daysSinceSignup: 7,
  isActive: true,
);
```

### Tracking de Campagnes

```dart
// Campagne email
await PostHogMarketingHelpers.trackEmailCampaignPerformance(
  campaignId: 'newsletter_001',
  action: 'opened',
  email: 'user@example.com',
  linkUrl: 'https://app.com/promo',
);

// Campagne publicitaire
await PostHogMarketingHelpers.trackAdCampaignPerformance(
  campaignId: 'fb_camp_001',
  adSetId: 'adset_123',
  adId: 'ad_456',
  action: 'click',
  platform: 'facebook',
  cost: 1.20,
);
```

### ROI et Métriques

```dart
// Track ROI de campagne
await PostHogMarketingHelpers.trackCampaignROI(
  campaignId: 'summer_promo',
  spent: 1000.0,
  revenue: 3500.0,
  currency: 'EUR',
  conversions: 25,
  impressions: 10000,
  clicks: 500,
);

// Track Customer Lifetime Value
await PostHogMarketingHelpers.trackCustomerLifetimeValue(
  userId: 'user_123',
  totalRevenue: 150.0,
  currency: 'EUR',
  totalOrders: 5,
  customerLifespan: Duration(days: 180),
  segment: 'premium_users',
);
```

## 🔧 Utilisation Développeur

### Service Principal

```dart
import 'package:faithlock/services/analytics/posthog/export.dart';

final postHog = PostHogService.instance;

// Vérification de l'état
if (postHog.isReady) {
  // Le service est prêt
}
```

### Modules Spécialisés

#### Event Tracking

```dart
// Event prédéfini
await postHog.events.track(
  PostHogEventType.featureUsed,
  {'feature_name': 'dark_mode', 'enabled': true}
);

// Event personnalisé
await postHog.events.trackCustom(
  'custom_event',
  {'key': 'value'}
);

// Track une erreur
await postHog.events.trackError(
  'validation_error',
  'Email format invalid',
  stackTrace: stackTrace,
);
```

#### User Analytics

```dart
// Identifier un utilisateur
await postHog.users.identify(
  'user_123',
  {'email': 'user@example.com', 'plan': 'premium'}
);

// Mettre à jour les propriétés
await postHog.users.setUserProperties({
  'last_seen': DateTime.now().toIso8601String(),
  'subscription_status': 'active',
});

// Reset (logout)
await postHog.users.reset();
```

#### Screen Tracking

```dart
// Track manuellement un écran
await postHog.screens.trackScreen(
  'ProductDetailScreen',
  properties: {'product_id': '123', 'category': 'electronics'}
);

// Track une transition
await postHog.screens.trackScreenTransition(
  from: 'HomeScreen',
  to: 'ProductListScreen',
  transitionType: 'navigation',
);
```

#### Feature Flags

```dart
// Vérifier un feature flag
final showNewFeature = await postHog.featureFlags.isEnabled('new_checkout');

// Obtenir la valeur d'un flag multivarié
final variant = await postHog.featureFlags.getFlagValue('button_color');

// Rafraîchir les flags
await postHog.featureFlags.refreshFlags();
```

#### Conversions

```dart
// Démarrer un funnel
await postHog.conversions.startFunnel(
  'purchase_funnel',
  {'source': 'product_page'}
);

// Track une étape
await postHog.conversions.trackFunnelStep(
  'purchase_funnel',
  'add_to_cart',
  {'product_id': '123'}
);

// Track une conversion
await postHog.conversions.trackConversion(
  conversionType: 'purchase',
  conversionValue: 29.99,
  currency: 'EUR',
);
```

#### Session Recording

```dart
// Démarrer l'enregistrement
await postHog.sessions.startRecording();

// Enregistrer un événement custom
await postHog.sessions.recordEvent(
  'button_clicked',
  {'button_id': 'checkout_btn'}
);

// Arrêter l'enregistrement
await postHog.sessions.stopRecording();
```

#### Surveys

```dart
// Démarrer un sondage
await postHog.surveys.startSurvey(
  'nps_survey',
  {'trigger': 'app_opened'}
);

// Enregistrer une réponse
await postHog.surveys.recordResponse(
  'nps_survey',
  'nps_score',
  9
);

// Track NPS
await postHog.surveys.trackNPSResponse(
  score: 9,
  comment: 'Great app!'
);
```

## 🔒 Gestion de la Vie Privée

### Configuration GDPR

```dart
// Vérifier le statut de consentement
final consentStatus = PostHogPrivacyManager.instance.consentStatus;

// Définir le consentement
await PostHogPrivacyManager.instance.setConsent(ConsentStatus.granted);

// Opt-out global
await PostHogPrivacyManager.instance.setOptOut(true);

// Exporter les données utilisateur
final userData = PostHogPrivacyManager.instance.exportUserData();

// Supprimer toutes les données
await PostHogPrivacyManager.instance.deleteAllUserData();
```

## 📊 Métriques Disponibles pour le Marketing

### Acquisition
- **Source d'acquisition** : D'où viennent les nouveaux utilisateurs
- **Coût par acquisition (CPA)** : Coût pour acquérir un nouvel utilisateur
- **Attribution marketing** : Performance par canal marketing
- **Entonnoir d'acquisition** : Conversion du visiteur au client

### Engagement
- **Sessions par utilisateur** : Fréquence d'utilisation
- **Temps dans l'app** : Durée d'engagement par session
- **Écrans visités** : Parcours utilisateur dans l'app
- **Actions par session** : Niveau d'interaction

### Rétention
- **Rétention D1, D7, D30** : Utilisateurs qui reviennent
- **Analyse de cohorte** : Performance par groupe d'utilisateurs
- **Churn rate** : Taux d'abandon
- **Réactivation** : Utilisateurs qui reviennent après absence

### Conversion
- **Funnels de conversion** : Étapes vers l'achat/abonnement
- **Revenue par utilisateur** : Valeur économique
- **Lifetime Value (LTV)** : Valeur à long terme
- **ROI des campagnes** : Retour sur investissement

### Campagnes
- **Performance email** : Ouvertures, clics, conversions
- **Performance ads** : CTR, CPC, ROAS
- **A/B testing** : Performance des variants
- **Attribution multi-touch** : Contribution de chaque touchpoint

## 🚨 Troubleshooting

### Vérification du Service

```dart
// Obtenir les statistiques
final stats = postHog.getStats();
print('PostHog Stats: $stats');

// Vérifier l'état des modules
final eventStats = postHog.events.getStats();
final userStats = postHog.users.getStats();
```

### Debug Mode

En mode debug, tous les événements sont loggés dans la console :

```
PostHog: Event tracked: user_signup
PostHog: User identified: user_123
PostHog: Feature flag checked: new_feature = true
```

### Erreurs Communes

1. **API Key manquante** : Vérifiez que `POSTHOG_API_KEY` est dans `.env`
2. **Service non initialisé** : Appelez `postHog.init()` avant utilisation
3. **Opt-out activé** : Vérifiez le statut de confidentialité
4. **Propriétés manquantes** : Certains événements ont des propriétés requises

## 📝 Événements Prédéfinis

Le service inclut des templates pour les événements courants :

- `userSignup`, `userLogin`, `userLogout`
- `screenView`, `navigationAction`
- `purchaseCompleted`, `subscriptionStarted`
- `featureUsed`, `tutorialCompleted`
- `campaignViewed`, `adClicked`
- `errorOccurred`, `performanceMetric`

Chaque événement a des propriétés par défaut et des validations automatiques.

## 🎯 Bonnes Pratiques

1. **Initialisez tôt** : Le service doit être initialisé avant utilisation
2. **Respectez la vie privée** : Vérifiez toujours le consentement
3. **Utilisez les templates** : Les événements prédéfinis ont des validations
4. **Ajoutez du contexte** : Plus de propriétés = meilleures insights
5. **Testez en debug** : Utilisez le mode debug pour vérifier les événements
6. **Flush régulièrement** : En cas de fermeture rapide de l'app

Ce service PostHog est maintenant complètement intégré dans votre boilerplate Fast App et prêt à fournir des analytics détaillées pour votre équipe marketing ! 🚀
