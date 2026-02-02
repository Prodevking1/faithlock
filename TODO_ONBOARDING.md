# Onboarding V2 Rework - TODO

## Phase 1 : Setup V2 (sans toucher V1)
- [ ] Dupliquer `scripture_onboarding_screen.dart` → `scripture_onboarding_v2_screen.dart`
- [ ] Creer `scripture_onboarding_v2_controller.dart` (nouveau controlleur independant)
- [ ] Ajouter flag/route pour switcher entre V1 et V2
- [ ] Verifier que V1 fonctionne toujours apres setup

## Phase 2 : Supprimer / Alleger dans V2
- [ ] Retirer Step Eternal Warfare du flow V2
- [ ] Retirer Step Mascot Transition du flow V2 (fusionne dans Summary)
- [ ] Retirer Step Testimonials du flow V2 (deplace dans Summary)
- [ ] Alleger Self-Confrontation : garder sliders + comparaison ratio + conversion annuelle + jauge de vie. Couper daily/weekly/psalm/justify

## Phase 3 : Nouveaux ecrans V2
- [ ] Creer ecran "Daily Verses" setup (remplace permission notif)
      - Mascot Judah + icone horloge animee
      - Choix frequence : 1x / 2x / 3x par jour (chips)
      - Time picker(s) selon choix (matin/midi/soir)
      - Bouton "Activate daily verses" → permission notif iOS
      - Lien "Maybe later"
- [ ] Creer ecran "How committed are you?" (5 niveaux, pre-commitment)
- [ ] Creer ecran "FaithLock is free for you" (soft transition avant paywall)

## Phase 4 : Ameliorer Summary screen
- [ ] Avant/Apres personnalise (donnees du Step 3 : Xh tel → Yh, 0 priere → quotidienne)
- [ ] Milestones progressifs (Semaine 1 → Semaine 2 → Mois 1)
- [ ] Freedom Projection (recup d'Eternal Warfare : X jours recuperes)
- [ ] Social proof / Testimonials integres
- [ ] Mascot Judah integre (proud state)

## Phase 5 : Feature Daily Verses Notifications
- [ ] Creer service `daily_verse_notification_service.dart`
- [ ] Logique de selection de verset quotidien
- [ ] Scheduling des notifications locales selon horaires choisis
- [ ] Persistence des preferences (frequence + heures)
- [ ] Integration avec `local_notification_service.dart` existant

## Phase 6 : Assets mascotte
- [ ] Generer image mascotte Judah + horloge (pour ecran Daily Verses)
- [ ] Animer en Lottie ou GIF
- [ ] Integrer nouvel asset dans `assets/mascot/`
- [ ] Ajouter nouveau state `JudahState.clockSetup` ou reutiliser `pointing`

## Flow final V2 (10 steps)
```
1.  Name/Age (ACTIF)
2.  Divine Revelation (PASSIF - court, pose le ton)
3.  Self-Confrontation allege (ACTIF - sliders + ratio + annuel + jauge de vie)
4.  Goals selection (ACTIF - 1 a 3 goals)
5.  Fingerprint Seal (ACTIF - engagement biometrique)
6.  Screen Time Permission (ACTIF)
7.  Daily Verses setup (ACTIF - remplace notif, frequence + heure + permission)
8.  Summary (PASSIF - projection perso + mascot + testimonials + freedom projection)
9.  How committed are you? (ACTIF - pre-commitment 5 niveaux)
10. FaithLock is free for you (PASSIF - soft transition)
→ PAYWALL
```

Ratio : 7 actifs / 3 passifs = 70% actif
Aucun passif consecutif avant le Summary
