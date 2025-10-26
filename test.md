Plan de Test - Blocage/Déblocage FaithLock

1. Configuration Initiale (5 min)

  ✅ Settings → Autoriser Screen Time
  ✅ Sélectionner 2-3 apps à bloquer (Instagram, TikTok, Safari)
  ✅ Créer 1 schedule actif (ex: maintenant → +30 min)
  ✅ Vérifier que les apps sont immédiatement bloquées

2. Test Shield & Navigation (3 min)
3. Ouvrir une app bloquée → Shield apparaît
4. Cliquer "Start Prayer" → Notification envoyée
5. Taper sur notification → App ouvre
6. ✅ VÉRIFIER: Navigation automatique vers Prayer Learning
7. Test Prayer Learning & Unlock (5 min)
8. Compléter les 4 étapes de prière
9. À la fin → Message "Apps unlocked for X minutes"
10. ✅ VÉRIFIER: Apps sont débloquées (ouvrir Instagram)
11. ✅ VÉRIFIER: Logs Xcode "🔓 Temporary unlock for X minutes"
12. Test Re-lock Automatique (Variable)
13. Attendre la fin du unlock period
14. ✅ VÉRIFIER: Apps se re-bloquent automatiquement
15. ✅ VÉRIFIER: Shield réapparaît si on ouvre l'app
16. ✅ VÉRIFIER: Logs Xcode "🔒 Apps Re-locked"
17. Test Edge Cases (5 min)

  ✅ Shield → Cliquer "Later" → Retour sans débloquer
  ✅ Tuer l'app pendant unlock → Rouvrir → Toujours débloqué?
  ✅ Schedule se termine pendant unlock → Que se passe-t-il?
  ✅ Multiple prayers dans même schedule → Fonctionne?

  Logs Xcode à surveiller

  🛡️ Shield displayed
  ✅ Primary button pressed
  🙏 Prayer flag set
  🔓 Temporary unlock for X minutes
  ⏰ DeviceActivity monitoring started
  🔒 Apps Re-locked (quand temps expire)

  Bugs à noter

  Pour chaque problème, note:

1. Étape où ça plante
2. Comportement attendu vs réel
3. Logs Xcode (copie-colle)
4. Screenshots si possible
