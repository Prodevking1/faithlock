import { Metadata } from 'next'
import { getAllCompetitors } from '@/lib/contentful'
import { FAITHLOCK_STATS, APP_STORE_URL } from '@/lib/constants'
import CTAButton from '@/components/ui/CTAButton'

export const metadata: Metadata = {
  title: 'FaithLock Comparisons - Christian Screen Time App Reviews',
  description:
    'Compare FaithLock with other Christian screen time apps. Detailed feature, pricing, and effectiveness comparisons to find the best faith-based app blocker.',
  alternates: {
    canonical: '/compare',
  },
}

export default async function ComparePage() {
  const competitors = await getAllCompetitors()

  return (
    <div>
      {/* Hero */}
      <div className="bg-hero-pattern text-white">
        <div className="container-default py-14 md:py-20">
          <nav className="breadcrumb mb-8 text-white/50">
            <a href="/" className="hover:text-white/80">Home</a>
            <span className="breadcrumb-separator text-white/30">/</span>
            <span className="text-white/70">Compare</span>
          </nav>

          <span className="badge bg-warm-500/20 text-warm-300 mb-4">Comparisons</span>
          <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold mb-4 tracking-tight leading-tight">
            FaithLock vs Other Apps
          </h1>
          <p className="text-lg md:text-xl text-white/70 max-w-2xl">
            Honest, detailed comparisons of FaithLock with other Christian and
            secular screen time apps. Find the right fit for your spiritual
            growth journey.
          </p>
        </div>
      </div>

      <div className="container-default py-12 md:py-16">
        {/* Why Compare */}
        <section className="mb-12 md:mb-16">
          <div className="card p-6 md:p-8 bg-brand-50/50 border-brand-100">
            <h2 className="text-lg font-bold text-brand-900 mb-3">
              Why These Comparisons Matter
            </h2>
            <p className="text-gray-600 text-sm leading-relaxed max-w-3xl">
              Most screen time apps treat phone addiction as a willpower problem.
              FaithLock treats it as a spiritual opportunity. We compare honestly so
              you can choose what works best for your faith journey&mdash;even if
              that means another app.
            </p>
          </div>
        </section>

        {/* Comparison Cards */}
        <section className="mb-16 md:mb-20">
          <h2 className="text-2xl md:text-3xl font-bold mb-8 text-gray-900">
            All Comparisons
          </h2>
          <div className="grid sm:grid-cols-2 gap-4">
            {competitors.map((entry) => {
              const c = entry.fields as Record<string, unknown>
              return (
                <a
                  key={entry.sys.id}
                  href={`/compare/faithlock-vs-${c.slug}`}
                  className="card-interactive p-6"
                >
                  <div className="flex items-center gap-3 mb-4">
                    <div className="w-10 h-10 bg-brand-100 rounded-xl flex items-center justify-center flex-shrink-0">
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-brand-600" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                      </svg>
                    </div>
                    <span className="text-sm font-medium text-gray-400">vs</span>
                    <div className="w-10 h-10 bg-gray-100 rounded-xl flex items-center justify-center flex-shrink-0">
                      <span className="text-gray-500 text-sm font-bold">
                        {(c.name as string)[0]}
                      </span>
                    </div>
                  </div>

                  <h2 className="text-lg font-bold text-gray-900 mb-1">
                    FaithLock vs {c.name as string}
                  </h2>
                  <p className="text-sm text-gray-500 mb-4 line-clamp-2">
                    {c.tagline as string}
                  </p>

                  <div className="flex items-center gap-3 text-xs text-gray-400">
                    <span className="inline-flex items-center gap-1">
                      <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor" className="text-warm-400">
                        <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
                      </svg>
                      {c.rating as number}
                    </span>
                    <span>{((c.downloads as number) || 0).toLocaleString()}+ downloads</span>
                    <span>{c.price as string}</span>
                  </div>
                </a>
              )
            })}
          </div>
        </section>

        {/* Quick Stats */}
        <section className="mb-16 md:mb-20">
          <h2 className="text-2xl md:text-3xl font-bold mb-8 text-gray-900">
            Why FaithLock Stands Out
          </h2>
          <div className="grid sm:grid-cols-3 gap-4">
            {[
              { value: FAITHLOCK_STATS.versesInLibrary, label: 'Bible verses in library', color: 'brand' },
              { value: '~30s', label: 'To unlock with Scripture', color: 'brand' },
              { value: 'iOS', label: 'Available on App Store', color: 'warm' },
            ].map((stat) => (
              <div key={stat.label} className="card p-6 text-center">
                <p className={`text-3xl md:text-4xl font-bold mb-1 ${stat.color === 'warm' ? 'text-warm-500' : 'text-brand-600'}`}>
                  {stat.value}
                </p>
                <p className="text-sm text-gray-500">{stat.label}</p>
              </div>
            ))}
          </div>
        </section>

        {/* CTA */}
        <section className="bg-cta-gradient text-white p-10 md:p-16 rounded-3xl text-center">
          <h2 className="text-2xl md:text-4xl font-bold mb-4 text-balance">
            Ready to choose faith over phone?
          </h2>
          <p className="text-lg mb-8 text-white/80">
            Join Christians replacing scrolling with Scripture.
          </p>
          <CTAButton
            text="Try FaithLock Free"
            href={APP_STORE_URL}
            variant="white"
            size="large"
            showAppleIcon
          />
        </section>
      </div>
    </div>
  )
}
