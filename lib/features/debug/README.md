# Debug Tools

Module de débogage pour FaithLock avec outils de test et de diagnostic.

## Analytics Test Screen

Page de test complète pour valider l'implémentation PostHog Analytics.

### Accès

**En mode Debug uniquement:**

1. **FloatingActionButton** - Visible sur l'écran principal (MainScreen)
   - Appuyez sur le bouton violet avec l'icône bug
   - Sélectionnez "Analytics Test" dans le menu

2. **Navigation directe:**
   ```dart
   Get.toNamed(AppRoutes.analyticsTest);
   ```

### Fonctionnalités

#### Test All Analytics (Bouton Principal)
Teste tous les événements analytics en séquence:
- ✅ Onboarding flow complet (9 étapes)
- ✅ User properties (nom, âge, heures/jour, etc.)
- ✅ Feature adoption (catégories, apps, schedules)
- ✅ Paywall view
- ✅ Plan selection
- ✅ Purchase flow (start → complete)
- ✅ Purchase failure
- ✅ Promo code (success & failure)
- ✅ Paywall dismiss

#### Tests Individuels

**Onboarding Analytics:**
- `Test Onboarding Flow` - Simule les 9 étapes avec entrée/sortie
- `Test User Properties` - Envoie toutes les propriétés utilisateur
- `Test Feature Adoption` - Teste l'adoption de 3 features

**Paywall Analytics:**
- `Test Paywall View` - Événement de vue du paywall
- `Test Plan Selection` - Sélection d'un plan
- `Test Purchase Flow` - Achat complet avec succès
- `Test Purchase Failure` - Simulation d'échec d'achat
- `Test Promo Code` - Application de code promo (succès + échec)
- `Test Paywall Dismiss` - Fermeture du paywall

### Vérification dans PostHog

Après avoir exécuté les tests, vérifiez dans votre dashboard PostHog:

1. **Events** - Recherchez les événements:
   - `onboarding_*` - Onboarding events
   - `paywall_*` - Paywall events

2. **User Properties** - Vérifiez les propriétés:
   - `user_name`, `user_age`
   - `subscription_status`, `subscription_plan`
   - `hours_per_day`, `prayer_frequency`

3. **Funnels** - Créez des funnels:
   - Onboarding: start → step_entered → step_completed → completed
   - Paywall: viewed → plan_selected → purchase_started → purchase_completed

### Metadata de Test

Tous les événements de test incluent:
```dart
metadata: {
  'test_mode': true,
  'test_timestamp': DateTime.now().toIso8601String(),
}
```

Cela permet de filtrer les événements de test dans PostHog.

### Debug Output

Les tests affichent des logs détaillés dans la console:
```
📝 Onboarding started
➡️  Step 1 entered: Divine Revelation
✅ Step 1 completed
...
🎉 Onboarding completed
👁️  Paywall viewed
💳 Plan selected
...
```

### Status Card

La carte de statut en haut de la page affiche:
- ✅ **Initialized** - PostHog est initialisé
- ✅ **Enabled** - Tracking est activé
- 📊 **Modules Loaded** - Nombre de modules (10)
- 🆔 **Session ID** - ID de session actuel

### Notes

- Le FloatingActionButton n'apparaît qu'en mode debug (`kDebugMode = true`)
- Les tests utilisent des valeurs fictives pour la simulation
- Chaque test peut être exécuté individuellement ou tous ensemble
- Les événements sont envoyés en temps réel à PostHog
- Les succès/échecs sont affichés via des snackbars
