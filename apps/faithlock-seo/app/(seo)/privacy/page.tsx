import { Metadata } from 'next'
import { COMPANY } from '@/lib/faithlock-data'

export const metadata: Metadata = {
  title: 'Privacy Policy — FaithLock',
  description:
    'How FaithLock collects, uses, and protects your personal information.',
  alternates: { canonical: '/privacy' },
}

const LAST_UPDATED = 'May 5, 2026'

export default function PrivacyPolicyPage() {
  return (
    <div>
      <div className="bg-hero-pattern text-white">
        <div className="container-narrow py-14 md:py-20">
          <nav className="breadcrumb mb-8 text-white/50">
            <a href="/" className="hover:text-white/80">Home</a>
            <span className="breadcrumb-separator text-white/30">/</span>
            <span className="text-white/70">Privacy Policy</span>
          </nav>
          <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold mb-4 tracking-tight">
            Privacy Policy
          </h1>
          <p className="text-white/70">Last updated: {LAST_UPDATED}</p>
        </div>
      </div>

      <div className="container-narrow py-12 md:py-16">
        <article className="prose">
          <p>
            FaithLock (&ldquo;we&rdquo;, &ldquo;us&rdquo;, &ldquo;our&rdquo;) is operated by {COMPANY.name}.
            This Privacy Policy explains what data we collect when you use the FaithLock
            mobile app and our websites, why we collect it, and the rights you have over it.
          </p>

          <h2>1. Information we collect</h2>
          <h3>a. Information you provide</h3>
          <ul>
            <li>Profile inputs from onboarding (first name, age range, prayer frequency, goals).</li>
            <li>Contact information when you email support.</li>
            <li>Subscription and purchase data processed by Apple and RevenueCat.</li>
          </ul>

          <h3>b. Information collected automatically</h3>
          <ul>
            <li>
              Device information: model, operating system version, language, time zone,
              app version, and a non-resettable anonymous device identifier (IDFV on iOS).
            </li>
            <li>
              Usage events: screens viewed, taps, errors, and interaction patterns. Used to
              understand how the app is used and improve it.
            </li>
            <li>
              Crash and performance data via Sentry to diagnose and fix bugs.
            </li>
            <li>
              Approximate location derived from IP address (city/country level only).
            </li>
          </ul>

          <h3>c. Advertising identifiers (iOS)</h3>
          <p>
            On iOS 14.5+, the operating system asks for your permission before any app may
            access the IDFA (Identifier for Advertisers). FaithLock will only collect the
            IDFA if you tap &ldquo;Allow&rdquo; on the App Tracking Transparency prompt. If you decline,
            we do not access the IDFA, and our advertising partners receive only aggregated,
            privacy-preserving signals (Apple SKAdNetwork and Meta Aggregated Event
            Measurement).
          </p>

          <h2>2. How we use your data</h2>
          <ul>
            <li>To provide and personalize the FaithLock experience.</li>
            <li>To process subscription purchases and prevent fraud.</li>
            <li>To send the daily verses, reminders, and notifications you opt into.</li>
            <li>To measure the performance of our marketing and improve our ads.</li>
            <li>To debug crashes and improve stability.</li>
            <li>To comply with legal obligations.</li>
          </ul>

          <h2>3. Third parties we share data with</h2>
          <p>We share the minimum data necessary with carefully selected providers:</p>
          <ul>
            <li>
              <strong>Apple</strong> — App Store payments, App Tracking Transparency, push
              notifications.
            </li>
            <li>
              <strong>RevenueCat</strong> — manages subscriptions and entitlements.
            </li>
            <li>
              <strong>PostHog</strong> — product analytics (self-hosted EU/US infrastructure).
            </li>
            <li>
              <strong>Sentry</strong> — crash and error reporting.
            </li>
            <li>
              <strong>Meta (Facebook)</strong> — measurement of ad campaigns through the
              Facebook App Events SDK and (server-side) the Meta Conversions API. Meta
              receives hashed identifiers for matching only.
            </li>
            <li>
              <strong>TikTok</strong> — measurement of TikTok ad campaigns through the TikTok
              Events SDK. Advertiser ID collection is disabled by default.
            </li>
            <li>
              <strong>OpenAI</strong> — used to power some in-app generative features. Inputs
              you provide for those features are sent to OpenAI for processing only.
            </li>
          </ul>
          <p>
            We do not sell your personal information.
          </p>

          <h2>4. Data retention</h2>
          <p>
            We keep account and usage data for as long as your account is active. When you
            delete your account or request data deletion, we erase or de-identify your
            personal data within 30 days, except where we are required to retain it for
            legal or accounting purposes (e.g. tax records for purchases).
          </p>

          <h2>5. Your rights</h2>
          <p>
            Depending on where you live (GDPR, UK GDPR, CCPA/CPRA, LGPD, etc.), you may have
            the right to:
          </p>
          <ul>
            <li>Access the personal data we hold about you.</li>
            <li>Correct inaccurate data.</li>
            <li>Delete your data.</li>
            <li>Object to or restrict certain processing.</li>
            <li>Port your data.</li>
            <li>Withdraw consent at any time.</li>
          </ul>
          <p>
            To exercise these rights, use our{' '}
            <a href="/request-data-delete">data deletion request form</a> or email{' '}
            <a href={`mailto:${COMPANY.email}`}>{COMPANY.email}</a>. We respond within 30
            days.
          </p>

          <h2>6. Children</h2>
          <p>
            FaithLock is not directed to children under 13 (or the equivalent minimum age in
            your jurisdiction). We do not knowingly collect personal information from
            children. If you believe a child has provided us data, contact us and we will
            delete it.
          </p>

          <h2>7. International transfers</h2>
          <p>
            Data may be processed in countries other than your own, including the United
            States. When we transfer personal data out of the EEA/UK, we rely on Standard
            Contractual Clauses or equivalent safeguards.
          </p>

          <h2>8. Security</h2>
          <p>
            We use industry-standard measures to protect your data: TLS in transit,
            encryption at rest, least-privilege access controls, and regular security
            reviews. No system is perfectly secure; please use a strong password and notify
            us of any suspicious activity.
          </p>

          <h2>9. Changes to this policy</h2>
          <p>
            We may update this Privacy Policy from time to time. The &ldquo;Last updated&rdquo; date
            at the top reflects the latest revision. Material changes will be communicated
            in-app or by email.
          </p>

          <h2>10. Contact</h2>
          <p>
            Questions or complaints? Email{' '}
            <a href={`mailto:${COMPANY.email}`}>{COMPANY.email}</a>. {COMPANY.name} is the
            data controller for the personal data described in this policy.
          </p>
        </article>
      </div>
    </div>
  )
}
