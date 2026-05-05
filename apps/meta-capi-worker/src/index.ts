/**
 * Cloudflare Worker — RevenueCat → Meta Conversions API bridge.
 *
 * Receives RevenueCat webhooks, maps them to Meta App Events (Purchase /
 * StartTrial / Subscribe), and forwards them to Meta's Conversions API with
 * the same `event_id` the iOS SDK uses, so Meta deduplicates the two
 * deliveries automatically.
 *
 * Deploy: `wrangler deploy` from this directory.
 */

export interface Env {
  // ─── Meta ───
  META_PIXEL_ID: string
  META_ACCESS_TOKEN: string
  META_TEST_EVENT_CODE?: string // remove in production

  // ─── RevenueCat ───
  REVENUECAT_WEBHOOK_SECRET: string

  // ─── App context (used in extinfo) ───
  APP_BUNDLE_ID: string // e.g. "com.faithlock.app"
  APP_BUILD_VERSION: string // e.g. "1.0.5"
}

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

type RcEventType =
  | 'INITIAL_PURCHASE'
  | 'RENEWAL'
  | 'TRIAL_STARTED'
  | 'TRIAL_CONVERTED'
  | 'TRIAL_CANCELLED'
  | 'CANCELLATION'
  | 'NON_RENEWING_PURCHASE'
  | 'PRODUCT_CHANGE'
  | 'EXPIRATION'
  | 'BILLING_ISSUE'
  | 'SUBSCRIBER_ALIAS'
  | 'SUBSCRIPTION_PAUSED'
  | 'TEST'

interface RcSubscriberAttribute {
  value: string
  updated_at_ms: number
}

interface RcEvent {
  id: string
  type: RcEventType
  event_timestamp_ms: number
  app_user_id: string
  original_app_user_id?: string
  product_id?: string
  period_type?: 'NORMAL' | 'TRIAL' | 'INTRO'
  purchased_at_ms?: number
  expiration_at_ms?: number
  store?: string
  environment?: 'PRODUCTION' | 'SANDBOX'
  is_family_share?: boolean
  country_code?: string
  app_id?: string
  transaction_id?: string
  original_transaction_id?: string
  is_trial_conversion?: boolean
  cancel_reason?: string
  currency?: string
  price?: number
  price_in_purchased_currency?: number
  subscriber_attributes?: Record<string, RcSubscriberAttribute>
}

interface RcWebhookBody {
  api_version: string
  event: RcEvent
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

async function sha256Hex(input: string): Promise<string> {
  const data = new TextEncoder().encode(input.trim().toLowerCase())
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  return [...new Uint8Array(hashBuffer)]
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
}

function eventNameFromRc(type: RcEventType): string | null {
  switch (type) {
    case 'INITIAL_PURCHASE':
    case 'RENEWAL':
    case 'NON_RENEWING_PURCHASE':
      return 'Purchase'
    case 'TRIAL_STARTED':
      return 'StartTrial'
    case 'TRIAL_CONVERTED':
      return 'Subscribe'
    default:
      return null
  }
}

function attr(ev: RcEvent, key: string): string | undefined {
  return ev.subscriber_attributes?.[key]?.value || undefined
}

/**
 * extinfo array — Meta's required mobile context block.
 * Format documented at:
 *   https://developers.facebook.com/docs/marketing-api/conversions-api/parameters/app-events
 *
 * Most fields are unknown server-side — we ship the minimum required and let
 * Meta infer the rest from the App Events SDK side.
 */
function extinfoForIos(env: Env): Array<string | number> {
  return [
    'i2', // 0: ext_version (i2 = iOS app)
    env.APP_BUNDLE_ID, // 1: app_package_name
    '0', // 2: app_version (numeric build, optional)
    env.APP_BUILD_VERSION, // 3: short_version
    '', // 4: os version — unknown server-side
    '', // 5: device_model_name
    '', // 6: locale
    '', // 7: timezone_abbreviation
    '', // 8: carrier
    '', // 9: screen_width
    '', // 10: screen_height
    '', // 11: screen_density
    '', // 12: cpu_cores
    '', // 13: external_storage_gb
    '', // 14: free_storage_gb
    '', // 15: device_time_zone
  ]
}

// ─────────────────────────────────────────────────────────────────────────────
// Worker entrypoint
// ─────────────────────────────────────────────────────────────────────────────

export default {
  async fetch(req: Request, env: Env, _ctx: ExecutionContext): Promise<Response> {
    if (req.method !== 'POST') {
      return new Response('method not allowed', { status: 405 })
    }

    // 1. Auth — RevenueCat sends `Authorization: Bearer <secret>`.
    const auth = req.headers.get('authorization') || ''
    if (auth !== `Bearer ${env.REVENUECAT_WEBHOOK_SECRET}`) {
      return new Response('unauthorized', { status: 401 })
    }

    // 2. Parse webhook payload.
    let body: RcWebhookBody
    try {
      body = (await req.json()) as RcWebhookBody
    } catch {
      return new Response('invalid json', { status: 400 })
    }

    const ev = body.event
    if (!ev) return new Response('no event', { status: 400 })

    const eventName = eventNameFromRc(ev.type)
    if (!eventName) {
      // Event types we don't forward to Meta (cancellation, expiration, test, …).
      return new Response('ignored', { status: 200 })
    }

    // 3. Build user_data for matching. All PII is SHA-256 lower-cased.
    const email = attr(ev, '$email')
    const ip = attr(ev, '$ip')
    const ua = attr(ev, '$userAgent')
    const phone = attr(ev, '$phoneNumber')
    const country = ev.country_code

    const user_data: Record<string, unknown> = {
      external_id: [await sha256Hex(ev.app_user_id)],
    }
    if (email) user_data.em = [await sha256Hex(email)]
    if (phone) user_data.ph = [await sha256Hex(phone)]
    if (country) user_data.country = [await sha256Hex(country)]
    if (ip) user_data.client_ip_address = ip
    if (ua) user_data.client_user_agent = ua

    // 4. Build Meta CAPI event payload.
    const value =
      typeof ev.price_in_purchased_currency === 'number'
        ? ev.price_in_purchased_currency
        : (ev.price ?? 0)

    const eventPayload = {
      event_name: eventName,
      event_time: Math.floor(ev.event_timestamp_ms / 1000),
      // ⚡ Same id used by the SDK on the device → Meta dedupes automatically.
      event_id: ev.transaction_id ?? ev.original_transaction_id ?? ev.id,
      action_source: 'app',
      user_data,
      custom_data: {
        currency: ev.currency ?? 'USD',
        value,
        product_id: ev.product_id,
        order_id: ev.transaction_id,
      },
      app_data: {
        // 0 = ATT denied / unknown server-side. The SDK side reports the
        // real value; Meta keeps the most permissive of the two.
        advertiser_tracking_enabled: 0,
        application_tracking_enabled: 1,
        extinfo: extinfoForIos(env),
      },
    }

    const capiBody: Record<string, unknown> = {
      data: [eventPayload],
    }
    if (env.META_TEST_EVENT_CODE) {
      capiBody.test_event_code = env.META_TEST_EVENT_CODE
    }

    // 5. POST to Meta.
    const url = `https://graph.facebook.com/v21.0/${env.META_PIXEL_ID}/events?access_token=${env.META_ACCESS_TOKEN}`
    const metaRes = await fetch(url, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(capiBody),
    })

    if (!metaRes.ok) {
      const text = await metaRes.text()
      console.error('Meta CAPI error', metaRes.status, text)
      // 200 to RevenueCat anyway: a 5xx makes RC retry, but if Meta is down
      // we don't want infinite retries. Return 502 only on 4xx (auth, payload).
      if (metaRes.status >= 400 && metaRes.status < 500) {
        return new Response(`capi rejected: ${text}`, { status: 502 })
      }
      return new Response('ok (meta 5xx, will not retry)', { status: 200 })
    }

    return new Response('ok', { status: 200 })
  },
}
