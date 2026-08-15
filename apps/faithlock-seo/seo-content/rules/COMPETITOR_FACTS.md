# COMPETITOR_FACTS — couche de faits concurrents (source de vérité B)

*Équivalent du `content/competitors.ts` de Montaj. Toutes les pages comparisons/reviews/listicles piochent ICI. Un concurrent est décrit identiquement sur toutes les pages : cohérence par construction. Un fait absent de ce fichier ne va pas sur une page.*

> ⚠️ **À REMPLIR par un agent de recherche (web search, sources datées) puis relire une fois, AVANT le batch.** Ne pas remplir de mémoire. Chaque entrée doit porter la date de vérification.
> Règle prix : `pricingModel` **qualitatif** (« free tier + subscription for full blocking »), jamais un montant figé sans date + source.

## Template d'entrée

```yaml
- name:            # nom exact de l'app
  owner:           # société
  platforms:       # iOS / Android / desktop / extension
  pricingModel:    # qualitatif, daté
  blockingMethod:  # Screen Time API / VPN / DNS / accountability
  strictness:      # contournable facilement ? strict mode ?
  keyFeatures: []  # 3-6 features vérifiées
  weaknesses: []   # réelles, sourcées (App Store/Trustpilot), avec lien
  faithlockAngle:  # notre angle honnête face à cette app
  verifiedAt:      # YYYY-MM-DD
  sources: []      # URLs
```

## Apps à couvrir (déduites des pages existantes + cibles du batch)

Bloqueurs génériques : Opal · Brick · ScreenZen · one sec · Freedom · Cold Turkey · Forest · Flora · Jomo · Clearspace · Unpluq · AppBlock
Bloqueurs chrétiens : Prayer Lock · Bible Mode · Pray Screen Time · Holy Focus · Sanctum
Accountability / parental chrétien : Covenant Eyes · Bark · Canopy · Truple · Accountable2You

## Entrées

(vide : à remplir par l'agent de recherche avec sources datées)
