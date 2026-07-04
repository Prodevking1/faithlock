# Garden of Grace — Design Spec **v2** (expert-panel reviewed)

> v2 integrates a 5-expert review (gardener, game designer, narrative designer, pastor,
> art director) + a cross-debate resolving the theology↔retention tensions. See
> `docs/garden-panel-review-round1.md` for the full panel record.
>
> **The one principle behind every decision:** the retention engine runs *underneath*;
> the surface the user feels is **rhythm, story, and gift** — never possession, score, or
> dread. And theologically: **you tend; God grows.**

---

## 0. North Star
The garden is a **living mirror of the user's walk with God**, made of the **9 Fruits of
the Spirit**. The user **tends** (shows up, reads, prays, reflects); **God gives the
growth** (1 Cor 3:6–7). The garden simply *remembers* time spent with God and reflects it
back as a beautiful, living thing.

**Non-negotiables (anti-dark-pattern + anti-works-righteousness):**
- No purchasable growth or decorations. Ever.
- **Growth is never lost** — you don't lose what God grew in you. Only *health* dips (the
  plant rests/droops) and recovers. Grace, not punishment.
- A plant **never dies** (health floor 20). Revival is frictionless.
- No random loot / slot-machine pulls. The garden is a reflection, not a casino.
- **No score of holiness.** No user-facing growth numbers, no %-complete, **no comparison
  to anyone, ever.**
- The user never *earns* the fruit. The Spirit grows it; the app tracks *time abiding*.
- Notifications encourage, never guilt; capped + opt-out.

**The covenant (shown to every new user, in Pip's voice):**
> *"I can't make anything grow here — that's not my job, or yours. We just show up, water
> a little, and watch. Ready?"* — Pip

---

## 1. Structure — 9 plots = 9 Fruits of the Spirit (Galatians 5:22–23)
Love · Joy · Peace · Patience · Kindness · Goodness · Faithfulness · Gentleness · Self-control

One **fruit** (singular, Gal 5:22), nine facets — they grow **together** at their own
paces, never sequentially. Each plot holds one plant with:
- `growth` — **unbounded, monotonic** cumulative tending (engine-only; never shown as a number)
- `maturityTier` — derived life-stage (the *named*, qualitative identity the user sees)
- `health` — per-garden, 0–100 (fluctuates: rest ↔ revive)
- `harvestsShared`, `lastTendedAt`, `bloomedTiers`

---

## 2. Theology guardrails (load-bearing — every surface obeys these)
1. **You tend; God grows.** A fixed, gentle line lives in the garden: *"You tend; God
   gives the growth."* All copy uses *tend / water / abide*, never *earn / produce / grow
   (yourself)*.
2. **The bar is "time abiding," not "holiness."** Any progress surface is framed as a
   record of time with God — *"Fruit is the Spirit's quiet work."*
3. **A bare or resting plot is never God's disappointment.** Suffering-safe by design
   (Ps 34:18; Isa 42:3). Low health = *resting/waiting*, never *failing*.
4. **No measuring, no comparing.** Luke 18:9–14 (the one who *counted* went home
   unjustified). No scores, no leaderboards, no completion %.
5. **The harvest is given, not hoarded** (Prov 3:9; Gal 6:9–10).
6. **Scripture is reverent** — always shown with reference + context, themed to grace/gift
   (e.g. Peace → John 14:27, Phil 4:6–7), never confetti/loot, never paired with a tally.
7. **A quiet anchor screen** (always accessible): *"This garden is a picture, not a
   scoreboard. You don't grow the fruit by trying harder — the Spirit grows it as you stay
   close to Jesus (John 15). The garden simply remembers your time with God."*

---

## 3. The Companion — **Pip**
The mascot gardener **is the app's Companion** — one character everywhere. **Hard rule:
Pip is a humble helper, NEVER God / Jesus / the Holy Spirit** (no halo, robe, staff, or
glow). *Pip doesn't make things grow — the Spirit does; Pip notices, waters, and
celebrates what's already growing in you.*

**Personality:** gentle, curious, a little shy; delighted by small things; notices *you*,
not just the garden; humble — credits the user and God, never itself; quietly joyful.

**Voice rules (writers' guide):**
- ✅ Short (1–2 sentences), a friend texting. "We / your / you" — beside, not over.
- ✅ Deflect glory to God; wonder over praise: *"Look what God is growing in you"* >
  *"Great job!"*. Encourage *presence/abiding*, not productivity.
- ❌ Never: "you should," "don't forget," "you missed," "X days since," any guilt; never
  preachy; never quote Scripture *as* God speaking in first person; never claim authority
  or divinity.

(Full character bible + paste-ready copy: see §10, §13, §14, §15.)

---

## 4. Resources — what each practice tends
The app's existing daily practices generate tending (engine: **Tending Points, TP** — never
shown). Each is a garden *metaphor*; the verbs are all "water / let in light," never "earn."

| Practice (already in app) | Metaphor | Effect (engine) |
|---|---|---|
| 📖 Read a verse | Sunlight | **+10 TP** to the verse's mapped fruit, **+2 splash** to all |
| 🙏 Pray | **Rain God sends** | **+1 splash/min to ALL** (no single-fruit award), cap **+20/day** |
| 💬 A talk with Pip (reflection) | Tending the soil | **+15 TP** to the conversation's topic fruit |
| ☀️ Showing up (any active day) | Faithfulness of presence | **+3 TP** to Faithfulness ("the discipline of showing up") |
| 🌿 Rhythm | The garden hitting its stride | a gentle **multiplier** (see §7) |

**Why prayer = rain (panel consensus):** prayer is *communion*, not a "faithfulness score"
(rewarding prayer-minutes as Faithfulness teaches "pray more = more faithful," false). As
rain it waters the *whole* garden — and it also fixes the idle-prayer farming exploit.
Faithfulness instead grows from **returning** (showing up over time), which is what
faithfulness actually is.

**Splash** lifts the whole garden a little, so no fruit is ever starved — and it mirrors
that grace touches the *whole* person, not just the part you "worked on."

---

## 5. Attribution — practice → fruit (mapping + grace-framed copy)
Verses are tagged with `VerseCategory`. We map category → fruit. **Journal copy never says
"you produced this virtue"** — it says *"Time with God on [theme] — He often grows [fruit]
here."*

| Verse category | Grows fruit | Split |
|---|---|---|
| fearAnxiety | Peace | — |
| anger | Gentleness (+ Self-control) | 70 / 30 |
| temptation | Self-control | — |
| lust | Self-control (+ Goodness) | 70 / 30 |
| pride | **Gentleness** (Gal 6:1, "restore… gently") | — |
| gratitude / praise | Joy | — |
| love / relationships | Love | — |
| perseverance / trials | Patience (+ Faithfulness) | 70 / 30 |
| service / generosity | Goodness (+ Kindness) | 70 / 30 |

- **A talk with Pip** → topic fruit, else the user's current top struggle
  (`user_stats.versesByCategory`).
- **Prayer** → rain (splash all, §4). **Faithfulness** → returning/showing up (§4).
- *(pride → Gentleness, not Kindness: pride's antidote is humility, which isn't one of the
  nine; gentleness is the nearest scriptural fit. Panel — Pastor.)*

> Result: someone who keeps reading about anxiety watches their **Peace** plant flourish
> first — the garden *tells their story*.

---

## 6. Growth & endless maturity — **the plant IS the progress bar**
Growth is **monotonic and unbounded** (spec never caps it; "you don't lose what God grew").
**No number is ever shown.** Progress is read entirely through **the living plant** and a
**named life-stage** — qualitative, beautiful, and theologically honest (Mark 4:27–28, the
seed grows "he knows not how").

**Named life-stages (the user-facing identity — verbs, not levels):**

| Stage / tier | Name | Engine TP (approx) | What the user sees |
|---|---|---|---|
| 1 | Seed | 0–20 | tiny sprout |
| 2 | Sprouting | 20–40 | short stem, few leaves |
| 3 | Growing | 40–60 | bushy, many leaves |
| 4 | Blossoming | 60–80 | leaves + flowers |
| 5 | Bearing fruit | 80–100 | flowers + ripe fruit |
| 6 | Young tree | ~160 | a real little tree |
| 7 | Established | ~256 | taller, denser, creatures nest |
| 8 | Flourishing | ~410 | abundant, a companion sapling appears |
| 9 | Ancient | ~656 | *"an old friend"* — the largest form |
| 10+ | Grove | ~1050, then ×1.6/tier | spreads into a small grove (endless) |

- **First post-fruit tier softened** (Young tree ~160, not 260) to kill the "month-1 wall,"
  then ×1.6 per tier (panel — GameDesigner).
- **Patience/Oak** gets the steepest curve + largest Ancient (slow + enduring = real oak
  biology + the symbolism). (panel — Gardener)
- **Micro-feedback every ~50 TP** = a *visible change on the plant* (a new branch, a bud
  swelling, a bird nests, a fruit ripens) — never a meter ticking. "Hide the math; never
  hide the consequence." (panel — GameDesigner + Narrative)
- **The "almost"** is felt through anticipation (a bud visibly swelling, a tip-glow, Pip's
  "one-verse-from-blooming"), never "72/100."

**Allowed numbers (outward, time-based, never a soul-score):** mornings shown up this
season, seasons tended, **fruit shared** (§10). These describe faithfulness over time, not
quality of soul.

---

## 7. Rhythm (not streaks)
A consistency reward exists — but reframed so it **breathes** instead of shattering.

- **Engine:** a **7-day rolling presence ratio** → multiplier `1 + 0.04 × activeDaysInLast7`,
  **cap ×1.28** at 7/7. It is **mathematically incapable of "breaking":** a missed day
  lowers the ratio by ~1/7 and the next active day raises it. No zero-reset, no chain to
  protect, **never subtracts growth already given.** (panel — GameDesigner mechanic +
  Narrative/Pastor framing)
- **Surface:** shown as **warmth/momentum**, not a count — richer light, more creatures,
  quicker grow-animations ("the garden is hitting its stride"). **No number, no flame, no
  day count, no "streak lost" state.**
- **Pip on rhythm:**
  - building → *"We're finding a rhythm, you and I. The garden can feel it. 🌿"*
  - after a gap (steps down, never resets, never scolds) → *"We slowed down for a bit, and
    that's alright. Rest is part of it. Let's pick the rhythm back up — gently."*
- **Hard rule:** no guilt notification for a lapse, ever. The reward is for *returning*.
  (Lam 3:22–23 — mercies new every morning.)

---

## 8. Health, resting & revival (decay model)
Health is **per-garden** (gentler than per-plot), 0–100, starts 100.

| Event | Health change |
|---|---|
| Any tending today | **+10** (cap 100) |
| A fully missed day | **−6** (floor **20** — never dies) |
| First day back after absence | **+12** + a warm welcome + a gift verse |

- comeback **+12** (≤ a normal active state) so skip-then-return never out-gains showing up.
- **Surface both ends:** a small *"your garden is thriving ☀️"* state at health ≥ 80, not
  only wilt (otherwise retained users never see the system). (panel — GameDesigner)

**Visual mapping (driven in-engine by a shader on a dedicated foliage material — no baked
wilt models):**
- ≥ 80 → lush, upright, creatures present, "thriving"
- 60–80 → fine
- 35–60 → leaves desaturate ~30%, slight droop ("resting")
- < 35 → heavier droop + brown ~55%, creatures hidden ("deeply resting")

**Reframe wilt as resting, never failure** (suffering-safe): *"Your garden is resting and
ready whenever you return."* + an accessible note: *"A drooping plant is not God's
disappointment. He is near to the brokenhearted (Ps 34:18). Some of the godliest seasons
look bare."*

---

## 9. Tending gestures (the user acts — not just Pip)
The most "alive"-making interaction, and it *embodies* "you tend, God grows." (panel —
Gardener + Pastor + Narrative)
- **Harvest ripe fruit** — one tap; triggers the share moment (§10) + a fruit/petal pop.
- **Prune / clear fallen leaves** — in autumn; a small tidy gesture, gentle satisfaction.
- **Water** — the per-action grow animation (arc of droplets → soil splash → plant
  scale-bounce).
These are zero-pressure: optional, never gated, never scored.

---

## 10. Bloom moments & **the harvest you share**
- **Stage-up bloom:** crossing a named life-stage → a celebration + a verse *about that
  fruit* (grace/gift-framed) + gentle haptic. Recorded in `bloomedTiers` (fires once).
- **First fruit:** a plot reaches *Bearing fruit* → *"It bore fruit. Your Peace actually
  bore fruit."*
- **The harvest (recurring, bi-weekly in-app season):** mature plants bear fruit → the
  renewable reason to return. **But the celebrated act is GIVING it, not collecting it.**
  - Pip offers a one-tap **"share the harvest":** a beautiful verse-card themed to that
    fruit, sent to a friend / saved as encouragement for someone. Sharing triggers the
    celebration and is what the garden *remembers*.
  - **Fully optional, no guilt:** if unshared, *"We'll let this one fall to the soil — it'll
    feed what comes next. There's always more."* (it visibly enriches ambient life — more
    creatures, a sapling).
  - **The one tally that's safe to grow forever = "fruit shared"** (outward), shown
    qualitatively (*"your garden has blessed others many times"*), never "harvests: 47."
  - Occasional soft legacy note: *"That bit of Peace you shared last week? Someone opened
    it today. 🤍"*
  - *(This is also the only sharing/virality lever — inherently on-theme, no ranking.)*
- **Full bloom / golden hour:** all 9 *Bearing fruit* at once → the island enters
  **golden hour** (warm light, max creatures) → *"All nine. Stand here a second — look what
  a year of small mornings made."* A milestone in *this* garden's life.

---

## 11. Botanical realism — the 9 species & a living world
Species chosen for symbolism, distinct silhouette, AND ability to **age endlessly**.

| Fruit | Species | Notes |
|---|---|---|
| Love | Rose bush → climbing rose arch | red roses |
| Joy | **Sunflower** (self-seeding patch) | the one annual — kept for its iconic joy; ages via a **self-sowing patch that returns each season + harvest**, not height (panel — Gardener exemption) |
| Peace | Olive tree | silver-green, olives; evergreen |
| Patience | Oak | broad spreading dome; **steepest curve, largest Ancient** |
| Kindness | Cherry blossom | soft pink, drifting petals |
| Goodness | Apple | short low-branching orchard form + baked red fruit (distinct from oak) |
| Faithfulness | Pine / evergreen | triangular; **stays green in winter** |
| Gentleness | Willow | soft drooping strands |
| Self-control | Grapevine on trellis | pruned vines, purple grapes; vine-aging track (arbor, not height) |

**Make it feel alive (cheap, high payoff — panel Gardener):**
- **Staggered seasonal blooms** by real timing (cherry early spring, rose/olive summer,
  apple blossom→fruit, grape late summer) → the garden is never uniformly "done"; something
  always cresting.
- **Real dormancy:** deciduous (oak, cherry, apple, willow, rose) go bare in winter; the
  **evergreens (pine, olive) stay green** → *Faithfulness stays green when all else
  rests* — a strong theological payoff + earned spring regrowth.
- **Transient micro-events:** morning dew that evaporates by midday; petals drifting at
  bloom then settling; a bee/butterfly that *lands* then leaves; one falling leaf in autumn.
- **Companion sapling** beside Flourishing/Ancient plants = visible legacy/regrowth.

---

## 12. Meta-progression (earned, never bought)
- **Decorations** unlocked at milestones (bench, well, stone path, birdbath, plain wooden
  cross, trellis, lanterns, fence) → personalization + long-term goals.
- **Creatures** appear with health/blooms: butterflies (any bloom), bees (flowers present),
  birds (≥3 fruits mature). Ambient, behavior-caused — never random loot.
- **Memory stone:** when a user survives a hard stretch (long absence → comeback →
  sustained return), the garden grows a small stone marker by the relevant plant — *"I set
  a little stone here, to remember the season you came back."* Gives the garden *memory* and
  dignifies the struggle. (panel — Narrative)
- **Seasons** (spring blossom / summer lush / autumn / winter rest) on the **real calendar**;
  **the garden persists & ages — never reset.** "Trophies" = milestones in *this* garden's
  life, not past gardens that vanished.
- **Day/night** tied to real device time → morning dew, golden evening, starry night.
- **Surprise-and-delight:** occasional unscripted creature/bloom on an active day
  (*"a butterfly visited because your garden is thriving"*) — delight without loot.

---

## 13. The loop — daily / weekly / seasonal
- **Daily:** open → Pip's brief welcome + any "while you were away" recap → tend (read /
  pray / talk) → each action waters/grows the relevant plot (instant qualitative feedback) →
  rhythm warms.
- **Weekly (gentle, zero pressure):** a Sunday *"this week in your garden"* recap — what
  grew, which fruit led, a verse. (Daily = rhythm, seasonal = harvest; the *week* is where
  retention is quietly won.) (panel — GameDesigner)
- **Seasonal:** **a Letter from Pip** at each real-calendar season turn — reflects real
  data back as story (*the* device that makes "the garden tells your story" literally true):
  > *"Dear friend — winter's here on the island. You came many mornings this season (no need
  > to count — I just notice). Your Faithfulness has grown into a real little pine now; birds
  > are starting to nest in it. Rest easy this season. The roots keep working. — Pip 🌲"*
- **Winter framing:** lean into winter-dormant as a no-pressure season (fewer
  notifications, *"gardens rest too"*) — a guilt-free off-ramp + return cycle, uniquely apt
  for a faith/Sabbath context.

---

## 14. Notifications (gentle, proactive — Pip's voice)
- *"Your Peace is right on the edge of opening — one more bit of sunlight, whenever you're
  ready. ☀️"*
- *"There you are. Nothing was lost while you were away — the leaves just waited for you. 🤍"*
- *"It's golden hour out here — thought you'd want to see it. 🌇"*
Capped (≤1/day default), encouraging, **never** a guilt/streak nudge, fully opt-out.

---

## 15. Growth journal — per-plot, narrative & qualitative
Tap a plot → a Cozy sheet that reads like a **journal of your walk**, not a logbook.
Driven by the event log; **gains only** (growth is monotonic; the only "regression" is
garden-wide health, surfaced gently elsewhere — never a per-fruit failure list).

- **Header:** fruit, named life-stage, the living plant, + **one Pip sentence** that
  reflects the real data as story.
- **Entries (reverse-chronological), qualitative — no numbers:**

```
🕊️  Peace · Blossoming

   "This one started the day you arrived, anxious. Look at it now."   — Pip

   (the plant, visibly almost in fruit — a bud swelling)
──────────────────────────────
This week
 📖  "Do not be anxious…" · Phil 4:6   → your Peace deepened
 🙏  A few quiet minutes of prayer      → everything drank a little
Last week
 💬  You talked it through with me
 🌸  It reached Blossoming — I remember this one.
A while back
 📖  Psalm 23
```

- Microcopy at the foot: *"This tracks your time abiding — not your holiness. Fruit is the
  Spirit's quiet work."*
- Raw TP exists **only** in a dev/debug view, never the player's.

---

## 16. Data model (local-only, private)
```
GardenState {
  season: Season
  seasonStartedAt: DateTime
  lastActiveDate: DateTime
  presenceWindow: List<Date>   // trailing days for the rolling rhythm ratio
  health: int                  // 0–100, per-garden
  plots: List<FruitPlot>       // length 9
  unlockedDecor: Set<DecorId>
  memoryStones: List<MemoryStone>
  fruitShared: int             // outward tally (qualitative display only)
}
FruitPlot {
  fruit: Fruit
  growth: int                  // UNBOUNDED cumulative TP (monotonic) — never shown
  maturityTier: int            // derived life-stage (the named, shown identity)
  bloomedTiers: Set<int>
  harvestReadyAt: DateTime      // bi-weekly cadence
  lastTendedAt: DateTime
}
GrowthEvent {                   // the event log → journal + recap + animations
  id; at; practice; source; rhythmMultiplier; awards[]; healthDelta
}
```

---

## 17. Tuning (engine-only — none of this is ever shown to the user)
| Knob | Value |
|---|---|
| Verse read → fruit | +10 TP |
| Verse read → splash all | +2 TP |
| Prayer → rain (splash all) | +1 TP/min, **cap +20/day** |
| A talk with Pip → topic fruit | +15 TP |
| Showing up (active day) → Faithfulness | +3 TP |
| Two-fruit split | 70 / 30 |
| **Per-fruit daily cap** (pre-multiplier) | ~40 TP (smooths the curve, keeps it endless) |
| **Splash cap** | ~+10 TP/plot/day (stops year-1 homogenization) |
| **Rhythm multiplier** | `1 + 0.04 × activeDaysInLast7`, **max ×1.28** |
| Life-stage thresholds (youth) | 20 / 40 / 60 / 80 / 100 |
| Endless tiers | 160 → 256 → 410 → 656 → 1050 → ×1.6/tier |
| Visible micro-change cadence | ~every 50 TP |
| Health: active / missed / comeback | +10 / −6 (floor 20) / +12 |
| Thriving state | health ≥ 80 |
| Harvest cadence | bi-weekly in-app season |
| Wilt visual | < 60 light, < 35 heavy (shader-driven) |

---

## 18. Edge cases
- **New user:** all plots growth 5, health 100, season = spring; the covenant line (§0) first.
- **Clock tampering:** clamp day deltas to [0, 14].
- **Timezone change:** local calendar days.
- **Very long absence:** health floors at 20, growth intact; comeback recap is warm
  (memory stone may form), never scolding.
- **Suffering season:** low health never reads as disfavor (§2, §8).
- **Offline:** fully local; no network needed for the garden.

---

## 19. Rendering & validation path
Engine is independent of rendering. Direction: **navigable low-poly 3D diorama** (Alto's
Odyssey / Monument Valley), Cozy palette, orbit camera (drag-rotate, scroll-zoom).
1. **Web prototype** (`apps/garden-web/`, React Three Fiber) — validate the look + feel
   incrementally (done: world & art direction).
2. Port the validated look to Flutter — the engine doesn't change.

Assets: see `docs/garden-asset-prompts.md` (art-director-reviewed). Plants must **age past
the Fruit stage forever** (young tree → ancient → grove), not plateau.

---

## 20. Adoption & daily engagement (ethical retention)
We deliberately banned the strongest *manipulative* retention levers (dread-streaks, guilt
notifications, scores, comparison, loot). So daily adoption rests entirely on **ethical
retention** — the Finch / Neko Atsume / Animal Crossing model: a real-time world that
*rewards* showing up and never punishes absence.

**Guiding principle:** the garden must not become another chore. Its job is to make the
**2-minute practice the user is already trying to keep** (read a verse / pray) feel
*consequential and beautiful*. The garden is the **reflection** of the daily devotion, not
a competitor to it. Surface a garden glimpse in the path of the existing routine (home
surface / post-practice reward screen), not as a separate destination.

**The 5 levers:**
1. **Gentle trigger anchored to a real habit.** ≤1 notification/day, Pip's voice, timed to
   the user's chosen prayer time. Always value-first ("there's dew this morning 🌤️", "your
   Joy is about to bloom", "someone opened the Peace you shared 🤍") — never guilt (§14).
2. **Minimum-viable-day (tiny friction).** A "tended day" = one verse OR one minute of
   prayer OR a check-in with Pip. Lowering the bar is the #1 retention lever. "Tend one
   thing today."
3. **Nature-based variable reward (not slot-machine).** The garden looks different every
   open — real day/night, seasons, morning dew, a butterfly that landed, a bud opened
   overnight. Ethical variable reward = *nature*, not loot.
4. **Recap-first.** On open, the garden shows what happened *while you were away* (dew,
   bloom, a note from Pip) **before** asking anything → reward-before-effort lowers the
   cost of opening.
5. **Anticipation = tomorrow's hook.** Real-clock resolutions pull the next visit: a bud
   "about to open," morning dew, the harvest ripening (bi-weekly), golden hour in the
   evening. The garden's own clock invites a glance.

**Why there's always a reason to return (multi-timescale):**

| Cadence | Hook |
|---|---|
| Every open | day/night + weather + dew → the world has changed |
| Daily | rhythm warmth; a small visible change on a plant |
| Weekly | Sunday recap + "tend one fruit" micro-goal |
| Bi-weekly | a harvest to **share** (+ the "your fruit was opened" reply) |
| Seasonal | Pip's Letter + season change (bloom / dormancy) |
| Endless | a plant becoming an *Ancient tree* — a horizon that never closes |

**The first 7 days decide everything** (habit-formation window). The youth curve is
**fast by design**: Day 1 plant → Day 2–3 first sprout → Day 5–7 first bloom → the user
feels "it works, and it's *mine*" before novelty fades. The rhythm warms gently across
this week.

**What we will NOT do (and that is *also* retention):** no guilt, no breaking streak, no
dying garden. A user who feels shame churns — so the anti-guilt design *is* a retention
strategy: returning is always frictionless and warm.

**North-star metric:** **"days with a genuine practice"** (not vanity metrics) — aligns the
business with the spiritual good. Track D1 / D7 / D30.

---

## 21. Onboarding tour (first run)
A short, skippable, Pip-led tour whose two jobs are to set the **grace covenant** (so the
mechanic never reads as merit) and to deliver the **aha** ("I tend → it grows"). Show, don't
tell. ~40s, replayable. 5 beats:

1. **Welcome / covenant** — *"I can't make anything grow here — that's not my job, or yours.
   We just show up, water a little, and watch. Ready?"*
2. **"This is your garden"** — nine plots, the nine fruits, growing together at their own pace.
3. **"Tending is simple"** — read a verse, pray, or talk with Pip.
4. **The aha (interactive)** — the user reads one verse → a plant visibly grows →
   *"See that? Small, but real. That's how everything begins — and nothing you grow is ever
   lost. Some seasons you'll be away; the garden just rests and waits. Coming back is always
   enough."* (folds in the grace/anti-guilt reassurance).
5. **"It tells your story" + preview** — an optional time-lapse (reuses the auto-journey)
   shows the garden growing into a grove over ~12 weeks → **Begin**.

Implemented in the prototype (`apps/garden-web/src/ui/Onboarding.tsx`), forcing the full
live garden underneath and reusing the engine + auto-journey.

---

## Appendix — panel provenance
- Round 1 (independent reviews) + Round 2 (cross-debate) record: `docs/garden-panel-review-round1.md`.
- Theology↔retention resolved by one move: **keep the engine; reframe the surface to
  rhythm / story / gift.** Pastor conceded the mechanics; GameDesigner conceded the
  labels & scores; Narrative built the bridge (Pip's voice).
