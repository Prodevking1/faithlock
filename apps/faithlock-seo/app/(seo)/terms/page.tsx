import { Metadata } from 'next'
import { COMPANY } from '@/lib/faithlock-data'

export const metadata: Metadata = {
  title: 'Terms of Use — FaithLock',
  description:
    'The terms that govern your use of the FaithLock app and our websites.',
  alternates: { canonical: '/terms' },
}

const LAST_UPDATED = 'May 5, 2026'

export default function TermsPage() {
  return (
    <div>
      <div className="bg-hero-pattern text-white">
        <div className="container-narrow py-14 md:py-20">
          <nav className="breadcrumb mb-8 text-white/50">
            <a href="/" className="hover:text-white/80">Home</a>
            <span className="breadcrumb-separator text-white/30">/</span>
            <span className="text-white/70">Terms of Use</span>
          </nav>
          <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold mb-4 tracking-tight">
            Terms of Use
          </h1>
          <p className="text-white/70">Last updated: {LAST_UPDATED}</p>
        </div>
      </div>

      <div className="container-narrow py-12 md:py-16">
        <article className="prose">
          <p>
            These Terms of Use (&ldquo;Terms&rdquo;) form a binding agreement between you and{' '}
            {COMPANY.name} (&ldquo;we&rdquo;, &ldquo;us&rdquo;, &ldquo;our&rdquo;) and govern your use of the FaithLock
            mobile application and our websites (the &ldquo;Service&rdquo;). By using the Service you
            accept these Terms. If you do not agree, do not use the Service.
          </p>

          <h2>1. Eligibility</h2>
          <p>
            You must be at least 13 years old (or the minimum digital-consent age in your
            country) to use the Service. By using FaithLock you confirm that you meet this
            requirement and have authority to enter into these Terms.
          </p>

          <h2>2. Your account and content</h2>
          <p>
            You are responsible for the activity on your device-bound account, the accuracy
            of information you provide, and any content you submit. Do not upload anything
            unlawful, infringing, abusive, or that violates third-party rights.
          </p>

          <h2>3. Subscriptions, free trials and billing</h2>
          <ul>
            <li>
              FaithLock offers auto-renewing subscriptions sold through the Apple App Store.
              Pricing, billing period, and trial length are shown on the paywall before
              purchase.
            </li>
            <li>
              Payment is charged to your Apple ID at confirmation of purchase. Subscriptions
              auto-renew unless cancelled at least 24 hours before the end of the current
              period.
            </li>
            <li>
              You can manage or cancel subscriptions in your Apple ID settings. Deleting the
              app does not cancel your subscription.
            </li>
            <li>
              Free trials convert to paid subscriptions automatically. To avoid being
              charged, cancel before the trial ends.
            </li>
          </ul>

          <h2>4. Refunds</h2>
          <p>
            All purchases are processed by Apple. Refund requests must be submitted to Apple
            via{' '}
            <a href="https://reportaproblem.apple.com" target="_blank" rel="noopener noreferrer">
              reportaproblem.apple.com
            </a>
            . We do not have access to your payment method and cannot process refunds on
            Apple&rsquo;s behalf.
          </p>

          <h2>5. License</h2>
          <p>
            We grant you a personal, non-transferable, non-exclusive, revocable license to
            install and use the Service on devices you own or control, for personal,
            non-commercial use, subject to these Terms and the Apple Media Services Terms.
          </p>

          <h2>6. Acceptable use</h2>
          <p>You agree not to:</p>
          <ul>
            <li>Reverse-engineer, decompile, or attempt to extract source code.</li>
            <li>Bypass technical limitations, security features, or licensing checks.</li>
            <li>Use the Service to harass, harm, or impersonate others.</li>
            <li>Resell, sublicense, or redistribute the Service.</li>
            <li>Use the Service in ways that violate applicable laws.</li>
          </ul>

          <h2>7. Intellectual property</h2>
          <p>
            The Service, including its source code, design, content, trademarks, and logos,
            is owned by {COMPANY.name} or its licensors and protected by intellectual
            property laws. You receive no rights other than the limited license in Section
            5.
          </p>

          <h2>8. Spiritual content disclaimer</h2>
          <p>
            FaithLock includes Bible verses, prayers, and devotional material. We provide
            this content for personal reflection. It is not a substitute for professional
            counseling, medical, mental-health, or pastoral advice. If you are in crisis,
            contact a qualified professional or local emergency services.
          </p>

          <h2>9. Third-party services</h2>
          <p>
            The Service relies on third-party providers (Apple, RevenueCat, Meta, TikTok,
            OpenAI, PostHog, Sentry). Your use of those services is subject to their own
            terms and privacy policies. We are not responsible for third-party services.
          </p>

          <h2>10. Disclaimers</h2>
          <p>
            THE SERVICE IS PROVIDED &ldquo;AS IS&rdquo; AND &ldquo;AS AVAILABLE&rdquo; WITHOUT WARRANTIES OF ANY
            KIND, EXPRESS OR IMPLIED, INCLUDING WARRANTIES OF MERCHANTABILITY, FITNESS FOR
            A PARTICULAR PURPOSE, AND NON-INFRINGEMENT. WE DO NOT WARRANT THAT THE SERVICE
            WILL BE UNINTERRUPTED, ERROR-FREE, OR FREE OF MALWARE.
          </p>

          <h2>11. Limitation of liability</h2>
          <p>
            TO THE MAXIMUM EXTENT PERMITTED BY LAW, {COMPANY.name.toUpperCase()} SHALL NOT
            BE LIABLE FOR INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES,
            OR FOR ANY LOSS OF PROFITS, REVENUE, OR DATA, ARISING OUT OF OR RELATED TO YOUR
            USE OF THE SERVICE. OUR TOTAL LIABILITY FOR ANY CLAIM RELATED TO THE SERVICE
            SHALL NOT EXCEED THE GREATER OF (A) THE AMOUNT YOU PAID US IN THE TWELVE MONTHS
            BEFORE THE CLAIM OR (B) USD 50.
          </p>

          <h2>12. Termination</h2>
          <p>
            You may stop using the Service at any time. We may suspend or terminate your
            access if you violate these Terms or to protect the Service. Sections that by
            their nature should survive (IP, disclaimers, liability, governing law) survive
            termination.
          </p>

          <h2>13. Governing law and disputes</h2>
          <p>
            These Terms are governed by the laws of the State of Delaware, USA, without
            regard to conflict-of-laws principles. Any dispute shall be brought exclusively
            in the state or federal courts located in Delaware, except where applicable
            consumer-protection law gives you the right to bring proceedings in your home
            jurisdiction.
          </p>

          <h2>14. Changes</h2>
          <p>
            We may update these Terms. The &ldquo;Last updated&rdquo; date reflects the latest
            revision. Material changes will be communicated in-app or by email; continued
            use after the effective date constitutes acceptance.
          </p>

          <h2>15. Contact</h2>
          <p>
            Questions? Email{' '}
            <a href={`mailto:${COMPANY.email}`}>{COMPANY.email}</a>.
          </p>
        </article>
      </div>
    </div>
  )
}
