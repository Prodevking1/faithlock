# meta-capi-worker

Cloudflare Worker that bridges **RevenueCat webhooks → Meta Conversions API**
so paid events (Purchase, StartTrial, Subscribe) are sent server-side with the
same `event_id` the iOS SDK uses. Meta deduplicates the two deliveries
automatically and falls back to the server-side one when the client event is
lost (ATT denied, network failure, crash before flush, ad-blockers).

## Setup

```bash
cd apps/meta-capi-worker
pnpm install     # or npm install
pnpm wrangler login
```

Copy local env file:

```bash
cp .dev.vars.example .dev.vars
# fill the values
```

Run locally:

```bash
pnpm dev
# → exposes http://127.0.0.1:8787
```

## Deploy

```bash
# 1. Push secrets (one-time)
pnpm wrangler secret put META_PIXEL_ID
pnpm wrangler secret put META_ACCESS_TOKEN
pnpm wrangler secret put REVENUECAT_WEBHOOK_SECRET
# Optional during testing — remove for production
pnpm wrangler secret put META_TEST_EVENT_CODE

# 2. Deploy
pnpm deploy
# → returns the worker URL, e.g. https://meta-capi-worker.<account>.workers.dev
```

## RevenueCat configuration

In the RevenueCat dashboard:

1. **Project Settings → Integrations → Webhooks → Add webhook**
2. **URL**: the worker URL from the deploy step.
3. **Authorization header**: `Bearer <REVENUECAT_WEBHOOK_SECRET>` (must match
   the secret you set with `wrangler secret put`).
4. **Events**: enable `INITIAL_PURCHASE`, `RENEWAL`, `TRIAL_STARTED`,
   `TRIAL_CONVERTED`, `NON_RENEWING_PURCHASE`. The worker silently ignores
   the others.

## How dedup works

- The Flutter app sends `Purchase` (and `StartTrial`) via the Facebook App
  Events SDK with `eventId = transactionIdentifier`.
- This worker receives the same RevenueCat event and posts to Meta CAPI with
  `event_id = ev.transaction_id`.
- Both ids are the same string → Meta keeps one event and merges the
  `user_data` from both sources for better matching.

## Improving Event Match Quality (EMQ)

Meta scores each event 0–10. Aim for ≥ 7 by attaching:

- `email` → set in the app via `Purchases.setEmail(...)`. Forwarded via the
  `$email` subscriber attribute.
- `IP` → `Purchases.setAttributes({'\$ip': '<public ip>'})`.
- `User-Agent` → `Purchases.setAttributes({'\$userAgent': '<UA>'})`.
- `country` → comes from RevenueCat's `country_code`.
- `external_id` → `app_user_id`, hashed by the worker.

The worker already SHA-256 hashes everything before sending.

## Verify in Events Manager

- Events Manager → your dataset → **Test events** → set the same
  `META_TEST_EVENT_CODE` and trigger a sandbox purchase.
- You should see two rows for the same `event_id` (one from `Browser/App`,
  one from `Server`) with a "Deduplicated" indicator.
- After a few real purchases, **Events Manager → Diagnostics → Event Match
  Quality** should report ≥ 7/10.

## Removing the test code in production

```bash
pnpm wrangler secret delete META_TEST_EVENT_CODE
pnpm deploy
```

## Endpoint contract

- `POST /` with header `Authorization: Bearer <REVENUECAT_WEBHOOK_SECRET>`.
- Body: RevenueCat webhook payload (see RC docs).
- Returns `200` on success or ignored event types, `401` on bad auth,
  `400` on invalid JSON, `502` if Meta rejects the event with a 4xx.
- `5xx` from Meta is swallowed (returns `200`) so RevenueCat doesn't infinitely
  retry; check logs with `pnpm tail`.
