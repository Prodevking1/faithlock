# FAITHLOCK_FACTS — couche de faits produit (source de vérité A)

*Équivalent du `MONTAJ.md §12`. Les agents rédacteurs ne peuvent affirmer au présent QUE ce qui est `✅ LIVRÉ` ici. Tout le reste : au futur ou pas du tout.*

> ⚠️ **À VALIDER PAR LE FONDATEUR avant le batch de 650 pages.** Les statuts ci-dessous sont déduits du code de l'app (`/Users/abdoul/development/appbiz-studio/faithlock`) et des pages déjà publiées sur getfaithlock.com, croisés le 2026-08-15. Tant que ce fichier n'est pas validé, les agents ne peuvent réutiliser que des claims déjà présents sur le site publié.

## Statuts
`✅ LIVRÉ` = affirmable au présent · `◐ PARTIEL` = affirmable avec la nuance exacte · `🔮 CONÇU` = futur uniquement · `❓ À CONFIRMER` = déduit du code mais pas croisé avec une décision produit · `⛔ INTERDIT` = ne jamais mentionner

## Faits produit

| Fait | Statut | Formulation autorisée | Preuve |
|---|---|---|---|
| App iOS uniquement | ✅ LIVRÉ | "FaithLock is an iOS app" / "iOS only" | `pubspec.yaml` (commentaires "iOS-only project — no android/ directory exists", `flutter_launcher_icons: android: false`), aucun dossier `/android` dans le repo |
| Blocage d'apps via Apple Screen Time / Family Controls | ✅ LIVRÉ | "FaithLock blocks distracting apps using Apple's Family Controls (Screen Time) API" | `ios/Runner/Runner.entitlements` (`com.apple.developer.family-controls = true`), `lib/features/faithlock/services/screen_time_service.dart` (MethodChannel natif : `isAuthorized`, `requestAuthorization`, `presentAppPicker`, `applyShields`/`removeShields`, schedules via DeviceActivityMonitor) |
| Déverrouillage par quiz biblique (texte à trous) | ✅ LIVRÉ | "unlock blocked apps by reading a Bible verse and answering a quiz question about it" | `lib/features/lock_challenge/` (écran + contrôleur du quiz), `lib/features/faithlock/services/question_generator.dart` (génère la phrase à trous et 4 choix depuis le verset) |
| Widget verset du jour sur l'écran d'accueil iPhone | ◐ PARTIEL — écran d'accueil seulement, PAS lock screen | "home screen widget showing the verse of the day" — ne jamais dire "lock screen widget" pour FaithLock | `ios/FaithLockWidget/FaithLockWidget.swift:321` → `.supportedFamilies([.systemSmall, .systemMedium])` (familles Home Screen uniquement, aucune famille `accessory*` de lock screen), `lib/services/home_widget_service.dart` (App Group, verset + streak poussés au widget) |
| Verset affiché à l'écran de blocage (dans le shield, pas sur le lock screen iOS) | ✅ LIVRÉ | "when you try to open a blocked app, you see a Bible verse" | `lib/features/faithlock/services/question_generator.dart` + `lock_challenge_screen.dart` (le verset/quiz s'affiche au moment du déverrouillage, via le shield Screen Time, pas un widget natif iOS lock screen) |
| Version Android | ⛔ INTERDIT — n'existe pas | ne jamais promettre de version Android | aucun dossier `/android`, `pubspec.yaml` explicitement iOS-only |
| Prix / abonnement (RevenueCat) | ◐ PARTIEL — modèle confirmé : abonnement payant avec essai gratuit de 3 jours | « FaithLock offers a 3-day free trial » est tolérable ; « FaithLock is free » reste INTERDIT ; montants uniquement tels que déjà publiés sur le site | `lib/services/subscription/revenuecat_service.dart`, `lib/features/paywall/controllers/paywall_controller.dart`, `lib/core/localization/en_US.dart` (`paywall_ctaFreeTrial` = « Start FREE for 3 Days », `paywall_riskReversal` = « 3 days free · Cancel anytime ») |
| ⚠️ Gate d'accès premium (paywall) | ❓ À CONFIRMER — bypass actif dans le code | ne rien affirmer sur ce qui est "gratuit" vs "premium" tant que non confirmé | `lib/services/subscription/paywall_guard_service.dart` → `checkSubscriptionAccess()` retourne **toujours `true`**, commentaire en dur : `"BYPASS ACTIVE - Always granting access"` "for development/testing". Impossible de dire avec certitude aujourd'hui quelles fonctionnalités sont réellement verrouillées derrière le paywall en prod tant que le fondateur ne confirme pas si ce bypass est un résidu de dev ou un état voulu |
| Contrôle parental / comptes famille | ❓ À CONFIRMER — probablement absent | ne pas affirmer de fonctionnalité de contrôle parental multi-utilisateur | Aucune mention de "parent", "family account", "child profile" trouvée dans `lib/features` ou `lib/services`. La Family Controls API Apple sert uniquement à l'auto-blocage de l'utilisateur lui-même, pas à un contrôle parental d'un tiers |
| Statistiques d'usage / streaks / badges | ✅ LIVRÉ | "tracks prayer and Scripture-reading streaks, with badges and a streak-freeze system" | `lib/features/faithlock/services/stats_service.dart`, `stats_controller.dart`, `streak_freeze_service.dart` (1 freeze/semaine gratuit, 3/semaine premium, pas 2 freezes consécutifs), `badge_service.dart` + `badge_definitions.dart` (badges streak, versets, première prière, score parfait, lève-tôt/couche-tard) |
| Bibliothèque biblique complète (BSB, 31 000+ versets) | ✅ LIVRÉ | "the complete BSB (Berean Standard Bible) library of 31,000+ verses" (déjà publié) | `lib/features/bible/` (`bible_repository.dart`, `bible_controller.dart`), `lib/features/faithlock/services/bible_database_loader.dart`, base SQLite embarquée référencée dans le code (`bible_bsb.db`) |
| Langues de l'app | ◐ PARTIEL — 5 langues configurées, complétude des traductions non vérifiée fichier par fichier | "available in English, French, Portuguese, German and Japanese" | `lib/config/app_config.dart` (`supportedLocales`: en_US, fr_FR, pt_BR, de_DE, ja_JP), fichiers `lib/core/localization/{en_US,fr_FR,pt_BR,de_DE,ja_JP}.dart` présents |
| Compagnon spirituel conversationnel ("The Companion") | ◐ PARTIEL — réel côté code, jamais publié comme claim marketing à ce jour | "an AI-powered spiritual companion chat" — ne jamais nommer le modèle/fournisseur sous-jacent | `lib/features/companion/` (chat, historique, voix). Backend réel via API LLM, prompt système dédié anti-fabrication de versets (`assets/prompts/companion_system_prompt.txt`). Le nom du modèle est un détail d'implémentation interne, à ne jamais exposer publiquement |
| Prière : audio guidée, prière écrite, mémorisation de versets | ✅ LIVRÉ | "guided audio prayers, written prayer journaling, and verse memorization" | `lib/features/prayer_audio/` (lecteur audio avec script synchronisé), `lib/features/prayer_text/` (journal de prière écrite), `lib/features/prayer_learning/` (suivi de mémorisation de versets) |
| Jardin de grâce / gamification visuelle ("Grace Garden") | ✅ LIVRÉ dans le code — jamais publié comme claim marketing à ce jour | à ne pas utiliser tant que le fondateur n'a pas validé le nom de la fonctionnalité et de la mascotte | `lib/features/garden/` (arbre/pot qui grandit visuellement selon les prières et streaks, mascotte compagnon) |
| Engagement / "covenant" de 30 jours | ◐ PARTIEL — rituel d'engagement à l'onboarding, pas un tracker permanent confirmé | "a 30-day commitment ritual during onboarding" (le site dit déjà "30-day spiritual covenant feature" — formulation à garder mais sans sur-vendre un tracking continu) | `lib/features/onboarding/screens/step4_call_to_covenant.dart` (`save30DayGoals`, "Phase 4.4 - 30-Day Goals Selection", clés `covenant_*`). Aucune preuve trouvée ailleurs dans le code d'un compteur "jour X/30" persistant post-onboarding |
| Microphone / prière parlée | ✅ LIVRÉ | "you can pray aloud using the microphone" (usage optionnel) | `ios/Runner/Info.plist` → `NSMicrophoneUsageDescription`: "FaithLock uses the microphone only if you choose to speak or record a prayer aloud." |

## Claims déjà publiés sur le site (réutilisables tels quels)

Ces formulations exactes ont été trouvées dans `best-christian-app-blocker.md`, `comparisons/faithlock-vs-opal.md`, `best-bible-verse-lock-screen-apps.md` et `best-bible-verse-widgets-iphone.md`. Ce sont les seuls claims chiffrés/marketing réutilisables tant que ce fichier n'est pas validé par le fondateur.

- "the complete BSB (Berean Standard Bible) library of 31,000+ verses"
- "unlock blocked apps by reading a Bible verse and answering a quiz question about it" / "Bible verse quiz" / "Active interaction with verses instead of passive exposure"
- "A 30-day spiritual covenant feature turns the blocking into a commitment device rooted in biblical covenant theology"
- "Scheduled lock times (morning devotion, work hours, bedtime)" + "Prayer reminders throughout the day"
- "iOS-only" / "iOS only" (répété sur toutes les pages)
- Prix : "Free (Premium: $4.99/week or $24.99/year)" — repris identiquement sur 3 pages différentes
- "Strong (Family Controls API)" pour la solidité du blocage
- "For apps that don't offer a native lock screen widget (like FaithLock), the verse appears when you try to open a blocked app instead of sitting on the lock screen itself" — le site confirme déjà correctement l'absence de widget lock screen, cohérent avec le code
- Lien App Store utilisé sur le site : `https://apps.apple.com/app/faithlock` (URL non vérifiée par cette recherche — à confirmer que c'est le bon identifiant App Store avant réutilisation massive)

## Claims interdits

- Toute feature non listée `✅ LIVRÉ` ci-dessus.
- Tout chiffre d'utilisateurs/téléchargements non fourni par le fondateur.
- Toute mention de "lock screen widget" pour FaithLock (le widget est Home Screen uniquement — voir preuve ci-dessus).
- Toute mention de "contrôle parental" ou "comptes famille" (non trouvé dans le code).
- Toute mention du fournisseur/modèle IA derrière le Companion.
- Tout claim ferme sur ce qui est gratuit vs premium tant que le bypass du paywall (`paywall_guard_service.dart`) n'est pas expliqué par le fondateur.
- Version Android sous quelque forme que ce soit.
