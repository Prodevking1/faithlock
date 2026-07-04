# Garden of Grace — Asset Generation Prompts **v2** (art-director reviewed)

Prompts to generate every visual element of the garden, consistent with the Cozy design
system, the **navigable low-poly 3D diorama** direction, and the **endless-aging** spec
(`garden-gamification-spec.md` v2). Reviewed & corrected by the art-director pass.

---

## 0. How to use

**Target output:** low-poly **`.glb`** models for React Three Fiber (web prototype) →
**Flutter** (same glTF files port directly; only the renderer wrapper is re-authored).
Drop files in `apps/garden-web/public/assets/`.

**Recommended tools**
- Text-to-3D: **Meshy**, **Tripo**, **Rodin (Hyper3D)**, **Luma Genie** → export `.glb`.
- Concept art / turnarounds: **Midjourney / DALL·E / Firefly** → image-to-3D for tight
  style control (mandatory for the mascot).

**Output requirements**
- Low-poly, **flat / faceted shading**, **single clean watertight mesh**, game-ready,
  **~800–3000 tris**, quad-friendly topology.
- **Matte only** (no metalness/roughness/gloss). Baked flat vertex colors or simple solid
  materials. **Separate material group for foliage vs trunk/structure** (required for the
  wilt shader, see below).
- **Y-up**, **pivot at the base / soil contact**, transparent background, **no ground
  plane, no baked shadows**, single centered object.

**Endless-aging strategy (spec §6/§11):** plants must age past the Fruit stage forever.
Generate per plant as ADDITIVE meshes the engine stacks, not one baked tree:
`base trunk/structure + swappable canopy tiers + fruit/bloom add-on + nesting add-ons`.
Minimum per fruit: **`-seedling`, `-mature`, `-ancient`, `-grove`**. Aging tiers 6–10+ are
achieved in-engine by scaling `-mature`→`-ancient` and adding the companion sapling +
nesting-creature add-ons. Keep every variant on a shared origin so they cross-fade cleanly.

**Shared scale anchor (Y-up units, pivot at soil contact):**
```
seedling ≈ 0.30   mature ≈ 1.00   ancient ≈ 2.20   grove ≈ 3.00 (wider than tall)
mascot   ≈ 0.70   decor bench/well ≈ 0.8–1.2   creatures ≈ 0.08–0.15
```
State the scale in each prompt so variants stay proportional.

**Health / wilt (spec §8) is driven IN-ENGINE, not by separate wilt models:**
```
health <60 → shader desaturates foliage vertex colors ~30% + slight downward bend
health <35 → desaturate ~55% toward brown + heavier droop, hide creatures
```
Therefore model each plant **upright and healthy**, with **foliage as a distinct material /
vertex-color group** so the shader can target it. (Optionally add a `droop` blendshape /
morph target if the tool supports it.) No baked wilt.

---

## 1. Global Style Prefix  ⚠️ prepend to EVERY 3D prompt

```
low-poly stylized 3D game asset, flat-shaded faceted geometry, cozy storybook diorama
style (Alto's Odyssey, Monument Valley), single clean watertight mesh, game-ready,
low triangle count (~800–3000 tris), quad-friendly even topology, matte materials only
no metalness no roughness no gloss, baked flat vertex colors or simple solid color
materials, separate material group for foliage vs trunk/structure.
Warm cohesive palette: terracotta #D68A4E, sage green #8FA67A, cream #FBF3E2,
soft warm-brown #3D2B1F. Soft rounded chunky friendly forms, gentle wholesome peaceful
mood. Single centered object, symmetric where natural, Y-up, pivot at the base / soil
contact point, transparent background, NO ground plane, NO baked shadows, NO scene props.
```

**Global negative prompt**
```
photorealistic, realistic PBR textures, high-poly, hyperdetailed, baked lighting,
baked shadows, ground plane, base platform, pedestal, multiple objects, scene clutter,
text, logo, watermark, UI, sharp, gritty, dark, horror, neon, glossy, metallic,
sci-fi, gore, human anatomy detail, fixed camera angle
```

> Note: no baked camera angle (the user orbits these). For image-to-3D concept art, reuse
> the prefix but drop the mesh/tri-count lines.

---

## 2. The 9 fruit plants

Distinct species per fruit (distinct silhouette + palette). Each = full paste-ready
variants on the shared scale anchor, foliage on its own material.

| Fruit | Species | Signature color |
|---|---|---|
| Love | Rose bush → climbing arch | deep red roses |
| Joy | Sunflower (self-seeding patch) | bright gold |
| Peace | Olive tree (evergreen) | silver-green, olives |
| Patience | Oak (broad dome) | deep green, acorns |
| Kindness | Cherry blossom | soft pink |
| Goodness | Apple (short orchard form) | red apples |
| Faithfulness | Pine / evergreen (stays green in winter) | deep green |
| Gentleness | Willow | pale drooping green |
| Self-control | Grapevine on trellis | purple grapes |

> Validate each fruit's **`-mature`** first (it locks the identity), then derive the others
> + the harvest pickup from the approved hero.
> **Silhouette separation note:** Oak = broad horizontal spreading dome; Apple = small
> rounded canopy on a short low-branching orchard trunk with red fruit baked in even at
> `-mature`; Pine = triangular tiers. Keep these three readable apart *before* fruit appears.

**2.1 Love — Rose bush**
```
-seedling: a tiny low-poly rose seedling in a small soil mound, single slender stem,
two rounded sage-green leaves, one closed red bud, ~0.30 units tall, foliage as a
separate material. [+ Global Style Prefix]
-mature: a cozy low-poly rose bush in a small soil mound, rounded sage-green faceted
foliage with several chunky deep-red #B0303A rose blooms and a few buds, lush romantic
warm, ~1.0 units tall, foliage separate material from stems. [+ Global Style Prefix]
-ancient: an aged low-poly climbing rose arch, thick woody twisted base, dense deep-red
roses cascading over a rounded form, ~2.2 units tall, stately and abundant, foliage
separate material. [+ Global Style Prefix]
-grove: a low-poly cluster of three rose bushes of varying height around one tall climbing
arch, dense deep-red blooms, wide spreading footprint ~3.0 units wide. [+ Global Style Prefix]
```

**2.2 Joy — Sunflower (self-seeding patch)**
```
-seedling: a tiny low-poly sunflower sprout, short green stem, two broad leaves, one small
closed bud, ~0.30 units. [+ Global Style Prefix]
-mature: a cozy low-poly sunflower plant, one or two big cheerful golden-yellow #F2B705
sunflower heads with dark center, sturdy green stems, broad leaves, bright uplifting,
~1.0 units, foliage separate material. [+ Global Style Prefix]
-ancient: a tall low-poly cluster of several sunflowers on thick stalks all turned to the
sun, layered broad leaves, ~2.2 units, abundant and radiant. [+ Global Style Prefix]
-grove: a low-poly self-seeded patch of many sunflowers at varied heights, a small field,
golden mass, ~3.0 units wide. [+ Global Style Prefix]
```
> Joy is the only annual — it ages as a recurring self-sowing patch (returns each season +
> harvest), not as height/trunk. Keep its variants as denser patches, not a tree.

**2.3 Peace — Olive tree (evergreen)**
```
-seedling: a small low-poly olive sapling, thin soft trunk, sparse silver-green leaves,
~0.30 units. [+ Global Style Prefix]
-mature: a cozy low-poly olive tree, gnarled soft warm-brown trunk, rounded silver-green
#A9B89A faceted canopy dotted with small dark olives, tranquil gentle, ~1.0 units, canopy
separate material. [+ Global Style Prefix]
-ancient: a broad twisted ancient low-poly olive tree, wide gnarled hollow-look trunk,
sprawling silver-green canopy heavy with olives, serene and timeless, ~2.2 units. [+ Global Style Prefix]
-grove: a low-poly olive grove cluster, three trunks of varied age, sprawling canopy,
~3.0 units wide. [+ Global Style Prefix]
```

**2.4 Patience — Oak (broad dome; steepest curve, largest ancient)**
```
-seedling: a single low-poly oak sprout rising from a visible acorn, one stem two leaves,
~0.30 units. [+ Global Style Prefix]
-mature: a cozy low-poly young oak tree, thick steady warm-brown trunk, broad rounded
spreading deep-green #4F6B3A faceted dome canopy, a few acorns, solid enduring, ~1.0 units,
canopy separate material. [+ Global Style Prefix]
-ancient: a mighty wide low-poly ancient oak, massive buttressed trunk, broad spreading
multi-lobed deep-green canopy, strong and protective, ~2.6 units (largest in the set).
[+ Global Style Prefix]
-grove: a low-poly oak grove, one mighty oak flanked by two younger ones, ~3.2 units wide.
[+ Global Style Prefix]
```

**2.5 Kindness — Cherry blossom**
```
-seedling: a thin low-poly cherry sapling, slender trunk, a few pink buds, ~0.30 units. [+ Global Style Prefix]
-mature: a cozy low-poly cherry blossom tree, slender soft trunk, rounded canopy of soft
pink #F4C2D7 blossoms, a few falling petals, tender gentle, ~1.0 units, canopy separate
material. [+ Global Style Prefix]
-ancient: a full low-poly sakura in bloom, broad arching pink canopy, petals drifting,
graceful and generous, ~2.2 units. [+ Global Style Prefix]
-grove: a low-poly cluster of cherry trees, a drift of pink, scattered petals, ~3.0 units wide. [+ Global Style Prefix]
```

**2.6 Goodness — Apple (short orchard form)**
```
-seedling: a small low-poly apple sapling, thin trunk, no fruit, ~0.30 units. [+ Global Style Prefix]
-mature: a cozy low-poly apple tree on a short low-branching orchard trunk, rounded green
faceted canopy with several ripe red #C0392B apples baked in, friendly sturdy, wholesome
bountiful, ~1.0 units, canopy separate material. [+ Global Style Prefix]
-ancient: a heavy-laden old low-poly apple tree, broad low canopy dense with red apples,
~2.2 units. [+ Global Style Prefix]
-grove: a low-poly small orchard cluster of apple trees, abundant fruit, ~3.0 units wide. [+ Global Style Prefix]
```

**2.7 Faithfulness — Pine / evergreen (stays green in winter)**
```
-seedling: a tiny low-poly pine seedling, single small conical tier, ~0.30 units. [+ Global Style Prefix]
-mature: a cozy low-poly evergreen pine, layered faceted deep-green #2E5339 needle tiers,
steady triangular silhouette, a few small cones, constant dependable, ~1.0 units, needle
tiers separate material. [+ Global Style Prefix]
-ancient: a tall majestic low-poly pine, many stacked needle tiers, strong straight trunk,
snow-dusting-ready form, ~2.2 units. [+ Global Style Prefix]
-grove: a low-poly stand of pines at varied height, a little evergreen copse, ~3.0 units wide. [+ Global Style Prefix]
```

**2.8 Gentleness — Willow**
```
-seedling: a small low-poly willow whip, thin trunk, a few short drooping strands, ~0.30 units. [+ Global Style Prefix]
-mature: a cozy low-poly weeping willow, soft warm-brown trunk, long gentle drooping
strands of pale-green #B7C99A faceted foliage, soft soothing, ~1.0 units, foliage strands
separate material. [+ Global Style Prefix]
-ancient: a broad sweeping low-poly willow, wide canopy of long drooping strands forming a
soft dome, calm and sheltering, ~2.2 units. [+ Global Style Prefix]
-grove: a low-poly cluster of willows beside an implied stream curve, ~3.0 units wide. [+ Global Style Prefix]
```

**2.9 Self-control — Grapevine on trellis (vine-aging track)**
```
-seedling: a young low-poly grapevine starting up a tiny wooden stake, a few broad leaves
no grapes, ~0.30 units. [+ Global Style Prefix]
-mature: a cozy low-poly grapevine on a small wooden trellis, neat pruned vines, broad
leaves, clusters of purple #6C3A8C grapes, disciplined orderly, ~1.0 units, foliage
separate material from wood trellis. [+ Global Style Prefix]
-ancient: a full low-poly grape arbor, sturdy wooden pergola heavy with vines and dense
purple grape clusters, abundant restraint, ~2.2 units (spreads wide, not tall). [+ Global Style Prefix]
-grove: a low-poly row of trellised vines, a small vineyard arbor walk, ~3.0 units wide. [+ Global Style Prefix]
```

**Harvest pickups (one per fruit — for the share-the-harvest moment, spec §10):**
```
A tiny cozy low-poly <FRUIT-ITEM>, single ripe item, chunky rounded faceted, bright
signature color, ~0.12 units, pivot at center, for a collectible pop-up. [+ Global Style Prefix]
Items: red rose / sunflower seed-head / olive / acorn / cherry blossom cluster /
red apple / pine cone / willow catkin / purple grape cluster.
```

---

## 3. Mascot — **Pip** (humble helper-gardener, NEVER a deity)

### 3.0 Concept lock (DO FIRST — drives all 3D for consistency)
Generate ONE turnaround sheet, then image-to-3D every pose from it:
```
character turnaround reference sheet, four views (front / three-quarter / side / back),
cozy low-poly storybook gardener mascot, consistent proportions, neutral grey background,
flat shaded.
```

### 3.1 Character (hero model, T-pose for rigging)
```
A cozy low-poly mascot named Pip: a small round friendly gardener companion. Soft wide-brim
straw hat (#E8C77A), terracotta apron (#D68A4E), little sage gloves (#8FA67A), simple
rounded warm-brown body, big warm friendly eyes, gentle closed-mouth smile, huggable.
Neutral symmetric T-pose, arms out for rigging, feet together, pivot between feet,
~0.70 units tall. Clearly a humble little helper, NOT a deity, NOT robed, NOT glowing,
no halo. [+ Global Style Prefix]
```

### 3.2 Pose / animation variants (same character)
```
[Exact same gardener Pip — straw hat #E8C77A, terracotta apron #D68A4E, sage gloves
#8FA67A, warm-brown body, big friendly eyes, gentle smile — IDENTICAL proportions and
colors to the hero turnaround] in a <POSE>. Same character, ~0.70 units, pivot between
feet. Humble friendly helper, never a deity, no halo, no glow. [+ Global Style Prefix]

Poses: gardener-idle (relaxed standing, soft) · gardener-watering (tilting a small
watering can) · gardener-wave (one arm raised, welcoming) · gardener-sitting (cross-legged,
content) · gardener-celebrate (both arms up, joyful) · gardener-kneel-plant (kneeling,
pressing a seedling into soil) · gardener-point (gently gesturing toward a plot, for nudges).
```
> Prefer a rigged/animated `.glb` (idle + wave + water) if the tool supports it; else
> static poses tweened in-engine.

---

## 4. Decorations (unlocked at milestones, spec §12)

Base template — swap `<ITEM>`:
```
A cozy low-poly garden <ITEM>, warm wood and stone, soft rounded chunky form, weathered
and charming. [+ Global Style Prefix]
```
Items: **wooden bench**, **stone well**, **stone path tile (modular)**, **birdbath**,
**simple wooden cross** (plain, reverent, understated — NOT ornate/figurative), **wooden
trellis arch**, **hanging lantern**, **low wooden picket fence (modular)**, hanging
string-lights swag, wooden signpost, small pond, mushroom cluster, flower pot, static
watering-can prop, bird feeder.

**States:**
```
unlock-reveal: re-run any decor with "wrapped in soft glowing golden sparkles, gift-reveal
moment" as an FX overlay (see §9).
locked/placeholder: a cozy low-poly faint dashed-outline ghost marker of a garden
decoration spot, pale translucent sage, simple flat. [+ Global Style Prefix]
```

---

## 5. Creatures (ambient, behavior-caused — spec §12)

```
A cozy low-poly <CREATURE>, tiny, cute, soft rounded faceted form, cheerful colors, simple,
charming. Tiny ambient garden creature. [+ Global Style Prefix]
```
Creatures: **butterfly** (soft pastel wings), **bumblebee** (round, gold/black), **songbird**
(small, warm robin-like). Request a small wing-flap / hop animation if supported.

---

## 6. Environment

```
### 6.1 Floating island
A cozy low-poly floating island, round grassy sage-green top, tapered warm-brown soil
underside with faceted rock, a few small grass tufts and pebbles on top. Storybook diorama
base. [+ Global Style Prefix]

### 6.2 Raised planter bed (3×3)
A cozy low-poly raised square wooden garden planter bed, chunky terracotta-brown wooden
plank rim, dark soil fill, empty (no plants). Warm, handcrafted. [+ Global Style Prefix]

### 6.3 Single plot tile (empty / planted)
empty:   a cozy low-poly square soil plot tile, dark tilled soil, chunky terracotta wooden
rim, faint center dimple ready for a seed, ~1.0 unit square, pivot at base. [+ Global Style Prefix]
planted: same plot tile with a small soil mound and a fresh sprout, freshly tended. [+ Global Style Prefix]

### 6.4 Trophy shelf + season trophy (spec §12)
shelf:  a cozy low-poly wooden shelf / mantel for small trophies, warm wood, 3–4 slots,
~1.2 units wide. [+ Global Style Prefix]
trophy: a cozy low-poly season trophy, small wooden plaque with a stylized faceted
fruit-of-the-spirit emblem, warm wood and sage, ~0.3 units. [+ Global Style Prefix]

### 6.5 Companion sapling (spec §11 — sprouts beside a flourishing/ancient plant)
A tiny cozy low-poly generic sapling, two leaves on a thin stem in a soil tuft, neutral
sage-green, ~0.25 units. [+ Global Style Prefix]

### 6.6 Memory stone (spec §12 — honors a hard-season comeback)
A small cozy low-poly weathered standing stone marker, soft rounded, warm grey with a faint
sage moss patch, humble and gentle, ~0.3 units. [+ Global Style Prefix]
```

---

## 7. Seasonal & day/night variants (spec §11/§12) — generate later

Re-run key assets (island, hero trees) with a modifier appended:
- **Spring:** `with fresh blossoms and bright new green growth`
- **Summer:** `lush, deep green, full and vibrant`
- **Autumn:** `warm orange and amber foliage, a few falling leaves`
- **Winter rest:** `bare or frosted, dusting of snow, dormant` (evergreens pine/olive stay green)
- **Night:** `under a starry night sky, soft moonlight, warm glowing lanterns`

---

## 8. VFX, FX meshes & lighting (mostly NOT .glb)

Power §10 (bloom/harvest), §9 (watering/grow), §8 (revival), §12 (golden hour, day/night).
Build as RTF particle systems + small textures/meshes; only `*` items are `.glb`.

**Particle sprite textures (transparent PNG, soft painterly, palette-matched):**
- `water-droplet` — soft blue-teal droplet (watering)
- `sparkle-star` — soft 4-point golden sparkle (grow / bloom / unlock)
- `petal` — soft pink/white petal (bloom drift)
- `leaf-mote` — tiny sage leaf fleck (ambient / autumn)
- `dew-drop` — clear droplet with highlight (morning dew)
- `pollen-mote` — faint golden dot (pollinator trails)
- `heart-mote` — tiny soft warm heart (comeback / "garden missed you 🤍")

**FX behaviors (engine-driven):**
- watering: arc of water-droplets → splash ring on soil + 0.3s scale-bounce on the plant.
- grow / stage-up: upward sparkle burst + springy scale-pop, plant morphs to next tier.
- bloom-celebration: radial petal + sparkle burst, brief golden glow, warm screen-edge
  vignette pulse, haptic.
- harvest: ripe pickup pops off, arcs into the share moment, sparkle trail.
- revival / comeback: heart-motes rise, plant un-droops + re-saturates over ~1s.
- season-complete / full bloom: whole-island sparkle wash + golden-hour ramp.

```
* harvest-basket.glb — a cozy low-poly woven basket, warm tan, ~0.4 units. [+ Global Style Prefix]
* bloom-burst-ring.glb (optional) — a flat low-poly soft petal-ring decal to spin + fade. [+ Global Style Prefix]
```

**Lighting recipe (RTF scene, not an asset):**
- Base: warm hemispheric light (sky cream #FBF3E2, ground warm-brown #3D2B1F), one soft key
  directional (~35° elevation) casting long soft shadows, low ambient. Cozy, golden, never harsh.
- Day/night by device clock (spec §12): morning (cool-warm dawn, low angle, +dew) · midday
  (neutral-warm, short shadows) · golden-hour (low warm-amber key, long shadows, lanterns
  emissive, max sparkles) · night (deep blue-violet ambient, soft moon key, emissive
  lanterns + star skybox).
- Health tint hook: a global desaturation/brown-shift param the wilt shader reads (spec §8).

---

## 9. UI icons (flat 2D, SVG/PNG — NOT 3D)

Cozy flat design, Cozy palette, rounded chunky strokes, matched to HugeIcons weight,
transparent background, single icon, simple.
- **Fruit emblems ×9** — rose, sunflower, olive sprig, acorn, cherry blossom, apple, pine,
  willow leaf, grape cluster (journal headers + notifications).
- **Practice icons** — verse/book (sunlight), prayer hands (rain), talk-with-Pip (tending soil).
- **Milestone badges** — the named life-stages (seed/sprouting/growing/blossoming/bearing)
  + "harvest to share" + "season" ribbon.
- **Garden-health glyph** — small heart/leaf gauge (gentle; thriving ☀️ ↔ resting).
- **Micro-goal marker** — small "tend one fruit today" flag pin.
- **Rhythm glyph** — warm sun/leaf "stride" indicator (NOT a flame, NOT a counter).

---

## 10. Naming & delivery

```
apps/garden-web/public/assets/
  plants/    love-seedling.glb love-mature.glb love-ancient.glb love-grove.glb …(×9)
  pickups/   love-fruit.glb joy-fruit.glb …(×9)
  mascot/    pip-turnaround.png pip-tpose.glb pip-idle.glb pip-watering.glb pip-wave.glb
             pip-sitting.glb pip-celebrate.glb pip-kneel-plant.glb pip-point.glb
  decor/     bench.glb well.glb path-tile.glb birdbath.glb cross.glb trellis.glb
             lantern.glb fence.glb shelf.glb trophy-<season>.glb decor-locked.glb …
  creatures/ butterfly.glb bee.glb bird.glb
  env/       island.glb planter.glb plot-empty.glb plot-planted.glb sapling.glb
             memory-stone.glb harvest-basket.glb
  fx/        water-droplet.png sparkle-star.png petal.png leaf-mote.png dew-drop.png
             pollen-mote.png heart-mote.png bloom-burst-ring.glb
  icons/     fruit-love.svg …(×9) practice-verse.svg practice-prayer.svg practice-talk.svg
             badge-bearing.svg health-strip.svg rhythm.svg
```
Conventions: lowercase kebab-case, `<name>-<variant>.<ext>`. `.glb` ≤ 1–2 MB, ~800–3000
tris, **foliage on its own material** (wilt shader). Validate each fruit's `-mature` first;
for Pip, lock the turnaround PNG → image-to-3D the T-pose → derive poses.
```
