import { Competitor } from '@/lib/types'
import { FAITHLOCK_STATS, APP_STORE_URL } from '@/lib/constants'
import ComparisonTable from '@/components/ui/ComparisonTable'
import CTAButton from '@/components/ui/CTAButton'
import BibleVerse from '@/components/ui/BibleVerse'

interface ComparisonTemplateProps {
  competitor: Competitor
}

export default function ComparisonTemplate({
  competitor,
}: ComparisonTemplateProps) {
  return (
    <article>
      {/* Hero */}
      <div className="bg-hero-pattern text-white">
        <div className="container-default py-16 md:py-20">
          <nav className="breadcrumb mb-8 text-white/50">
            <a href="/" className="hover:text-white/80">Home</a>
            <span className="breadcrumb-separator text-white/30">/</span>
            <a href="/compare" className="hover:text-white/80">Compare</a>
            <span className="breadcrumb-separator text-white/30">/</span>
            <span className="text-white/70">vs {competitor.name}</span>
          </nav>

          <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold mb-4 tracking-tight text-balance leading-tight">
            FaithLock vs {competitor.name}
          </h1>
          <p className="text-lg text-white/70 max-w-2xl mb-8">
            Comprehensive comparison of features, pricing, effectiveness, and
            spiritual impact. Find the best faith-based app blocker.
          </p>

          {/* Quick Answer */}
          <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-6 border border-white/10 max-w-2xl">
            <p className="text-sm font-semibold text-warm-300 mb-2 uppercase tracking-wide">
              Quick Answer
            </p>
            <p className="text-white/80 leading-relaxed">
              While {competitor.name} {competitor.tagline.toLowerCase()},
              FaithLock offers Bible verse unlocking with{' '}
              Bible verse unlocking to build a consistent Scripture habit.
              Best for Christians seeking spiritual growth, not just app blocking.
            </p>
          </div>
        </div>
      </div>

      <div className="container-default py-12 md:py-16">
        {/* Comparison Table */}
        <section className="mb-16 md:mb-20">
          <h2 className="text-2xl md:text-3xl font-bold mb-8 text-gray-900">
            Feature-by-Feature Comparison
          </h2>
          <ComparisonTable
            faithlock={{
              name: 'FaithLock',
              features: {
                bibleQuiz: true,
                physicalBibleScan: false,
                screenTimeTracking: true,
                appBlocking: true,
                androidSupport: false,
                '30DayCovenant': true,
                progressAnalytics: 'Advanced',
                customScheduling: true,
                bibleVerseLibrary: `${FAITHLOCK_STATS.versesInLibrary} verses`,
                accountabilityPartner: true,
              },
              price: `Freemium (${FAITHLOCK_STATS.price.weekly} Premium)`,
              platforms: [...FAITHLOCK_STATS.platforms],
              rating: undefined as unknown as number,
              downloads: undefined as unknown as number,
            }}
            competitor={competitor}
          />
        </section>

        {/* Pros & Cons */}
        <section className="mb-16 md:mb-20">
          <h2 className="text-2xl md:text-3xl font-bold mb-8 text-gray-900">
            Detailed Analysis
          </h2>
          <div className="grid md:grid-cols-2 gap-6">
            {/* FaithLock */}
            <div className="card p-6 md:p-8 border-brand-100">
              <div className="flex items-center gap-3 mb-6">
                <div className="w-10 h-10 bg-brand-100 rounded-xl flex items-center justify-center">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-brand-600">
                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                  </svg>
                </div>
                <h3 className="text-xl font-bold text-brand-700">FaithLock</h3>
              </div>
              <div className="mb-6">
                <h4 className="text-sm font-semibold text-sage-700 uppercase tracking-wide mb-3">Pros</h4>
                <ul className="space-y-2">
                  {[
                    'Bible verse unlocking ensures genuine Scripture engagement',
                    '30-day spiritual covenant for building consistent habits',
                    'Streak tracking and insights dashboard',
                    'Scheduled lock times for daily routines',
                    'Prayer reminders throughout the day',
                    'Active development and community support',
                  ].map((pro, i) => (
                    <li key={i} className="flex items-start gap-2.5 text-sm text-gray-700">
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-sage-500 flex-shrink-0 mt-0.5" strokeLinecap="round" strokeLinejoin="round">
                        <polyline points="20 6 9 17 4 12" />
                      </svg>
                      {pro}
                    </li>
                  ))}
                </ul>
              </div>
              <div>
                <h4 className="text-sm font-semibold text-red-500 uppercase tracking-wide mb-3">Cons</h4>
                <ul className="space-y-2">
                  {[
                    'iOS only (Android coming soon)',
                    'Newer app (less brand awareness)',
                    'Requires iOS 16+ for Family Controls',
                  ].map((con, i) => (
                    <li key={i} className="flex items-start gap-2.5 text-sm text-gray-500">
                      <span className="w-1.5 h-1.5 bg-gray-300 rounded-full flex-shrink-0 mt-2" />
                      {con}
                    </li>
                  ))}
                </ul>
              </div>
            </div>

            {/* Competitor */}
            <div className="card p-6 md:p-8">
              <div className="flex items-center gap-3 mb-6">
                <div className="w-10 h-10 bg-gray-100 rounded-xl flex items-center justify-center">
                  <span className="text-gray-400 text-lg font-bold">{competitor.name[0]}</span>
                </div>
                <h3 className="text-xl font-bold text-gray-600">{competitor.name}</h3>
              </div>
              <div className="mb-6">
                <h4 className="text-sm font-semibold text-sage-700 uppercase tracking-wide mb-3">Pros</h4>
                <ul className="space-y-2">
                  {competitor.pros.map((pro, i) => (
                    <li key={i} className="flex items-start gap-2.5 text-sm text-gray-700">
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-sage-500 flex-shrink-0 mt-0.5" strokeLinecap="round" strokeLinejoin="round">
                        <polyline points="20 6 9 17 4 12" />
                      </svg>
                      {pro}
                    </li>
                  ))}
                </ul>
              </div>
              <div>
                <h4 className="text-sm font-semibold text-red-500 uppercase tracking-wide mb-3">Cons</h4>
                <ul className="space-y-2">
                  {competitor.cons.map((con, i) => (
                    <li key={i} className="flex items-start gap-2.5 text-sm text-gray-500">
                      <span className="w-1.5 h-1.5 bg-gray-300 rounded-full flex-shrink-0 mt-2" />
                      {con}
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          </div>
        </section>

        {/* Pricing */}
        <section className="mb-16 md:mb-20">
          <h2 className="text-2xl md:text-3xl font-bold mb-8 text-gray-900">
            Pricing
          </h2>
          <div className="grid md:grid-cols-2 gap-6">
            <div className="card p-6 border-brand-100 bg-brand-50/30">
              <h3 className="font-bold text-brand-700 mb-3">FaithLock</h3>
              <p className="text-3xl font-bold text-gray-900 mb-1">Free</p>
              <p className="text-sm text-gray-500">
                {FAITHLOCK_STATS.price.weekly} or {FAITHLOCK_STATS.price.annual}.
              </p>
            </div>
            <div className="card p-6">
              <h3 className="font-bold text-gray-600 mb-3">{competitor.name}</h3>
              <p className="text-3xl font-bold text-gray-900 mb-1">{competitor.price}</p>
            </div>
          </div>
        </section>

        {/* Results */}
        <section className="mb-16 md:mb-20">
          <h2 className="text-2xl md:text-3xl font-bold mb-8 text-gray-900">
            Effectiveness &amp; Results
          </h2>
          <div className="grid sm:grid-cols-2 md:grid-cols-4 gap-4">
            {[
              { value: FAITHLOCK_STATS.versesInLibrary, label: 'Bible verses in library', color: 'brand' },
              { value: '~30s', label: 'Unlock time per app', color: 'brand' },
              { value: `${competitor.rating}\u2605`, label: `${competitor.name} rating`, color: 'gray' },
              { value: `${competitor.downloads.toLocaleString()}+`, label: `${competitor.name} downloads`, color: 'gray' },
            ].map((stat) => (
              <div key={stat.label} className={`card p-5 text-center ${stat.color === 'brand' ? 'bg-brand-50/50 border-brand-100' : ''}`}>
                <p className={`text-2xl font-bold mb-1 ${stat.color === 'brand' ? 'text-brand-700' : 'text-gray-600'}`}>
                  {stat.value}
                </p>
                <p className="text-xs text-gray-500">{stat.label}</p>
              </div>
            ))}
          </div>
        </section>

        {/* Biblical Perspective */}
        <section className="mb-16 md:mb-20 bg-brand-950 text-white rounded-3xl p-8 md:p-12">
          <h2 className="text-2xl md:text-3xl font-bold mb-4">
            Biblical Perspective on Screen Time
          </h2>
          <p className="text-white/70 mb-8 max-w-2xl leading-relaxed">
            Phone addiction isn&apos;t just a productivity issue&mdash;it&apos;s a spiritual
            battle for our attention, time, and worship. God calls us to redeem
            the time, knowing the days are evil.
          </p>
          <div className="max-w-2xl">
            <BibleVerse
              reference="Ephesians 5:15-16"
              text="Be very careful, then, how you live\u2014not as unwise but as wise, making the most of every opportunity, because the days are evil."
            />
          </div>
          <p className="text-white/60 mt-6">
            Both FaithLock and {competitor.name} help Christians reclaim time for
            God. The question is: which approach transforms addiction into
            spiritual growth most effectively?
          </p>
        </section>

        {/* CTA */}
        <section className="bg-cta-gradient text-white p-10 md:p-16 rounded-3xl text-center mb-16">
          <h2 className="text-2xl md:text-4xl font-bold mb-4 text-balance">
            Ready to transform phone addiction
            <br className="hidden md:block" />
            into spiritual growth?
          </h2>
          <p className="text-lg mb-8 text-white/80">
            Join Christians using FaithLock. Start free today.
          </p>
          <CTAButton
            text="Try FaithLock Free"
            href={APP_STORE_URL}
            variant="white"
            size="large"
            showAppleIcon
          />
        </section>

        {/* Related */}
        <section>
          <h2 className="text-xl font-bold mb-6 text-gray-900">
            Related Comparisons
          </h2>
          <div className="grid sm:grid-cols-3 gap-4">
            <a href="/compare/faithlock-vs-bible-mode" className="card-interactive p-5">
              <h3 className="font-semibold text-gray-900 text-sm">FaithLock vs Bible Mode</h3>
              <p className="text-xs text-gray-500 mt-1">Verse unlock vs physical Bible scanning</p>
            </a>
            <a href="/compare/faithlock-vs-holy-focus" className="card-interactive p-5">
              <h3 className="font-semibold text-gray-900 text-sm">FaithLock vs Holy Focus</h3>
              <p className="text-xs text-gray-500 mt-1">Professional vs prayer-focused</p>
            </a>
            <a href="/compare" className="card-interactive p-5">
              <h3 className="font-semibold text-brand-600 text-sm">All Comparisons</h3>
              <p className="text-xs text-gray-500 mt-1">View the complete guide</p>
            </a>
          </div>
        </section>
      </div>
    </article>
  )
}
