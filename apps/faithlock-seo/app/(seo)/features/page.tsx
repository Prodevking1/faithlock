import { Metadata } from 'next'
import { getAllFeatures } from '@/lib/contentful'
import { FAITHLOCK_STATS, APP_STORE_URL } from '@/lib/constants'
import CTAButton from '@/components/ui/CTAButton'

export const metadata: Metadata = {
  title: 'FaithLock Features - Bible Quiz, Covenant Tracking & More',
  description:
    'Explore FaithLock features: Bible quiz unlock, 30-day spiritual covenant, app blocking, accountability partners, and progress analytics. The most comprehensive Christian screen time app.',
  alternates: {
    canonical: '/features',
  },
}

export default async function FeaturesPage() {
  const features = await getAllFeatures()

  return (
    <div>
      {/* Hero */}
      <div className="bg-hero-pattern text-white">
        <div className="container-default py-14 md:py-20">
          <nav className="breadcrumb mb-8 text-white/50">
            <a href="/" className="hover:text-white/80">Home</a>
            <span className="breadcrumb-separator text-white/30">/</span>
            <span className="text-white/70">Features</span>
          </nav>

          <span className="badge bg-warm-500/20 text-warm-300 mb-4">Features</span>
          <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold mb-4 tracking-tight leading-tight">
            Everything You Need to Break Free
          </h1>
          <p className="text-lg md:text-xl text-white/70 max-w-2xl">
            Bible quizzes, covenant tracking, smart scheduling, and more.
            FaithLock gives you the tools to turn phone addiction into
            spiritual growth.
          </p>
        </div>
      </div>

      <div className="container-default py-12 md:py-16">
        {/* Quick Stats */}
        <section className="mb-12 md:mb-16">
          <div className="grid sm:grid-cols-3 gap-4">
            {[
              { value: FAITHLOCK_STATS.versesInLibrary, label: 'Bible verses in library', color: 'brand' },
              { value: '~30s', label: 'To unlock with Scripture', color: 'brand' },
              { value: 'KJV', label: 'Bible translation', color: 'warm' },
            ].map((stat) => (
              <div key={stat.label} className="card p-5 text-center">
                <p className={`text-2xl md:text-3xl font-bold mb-1 ${stat.color === 'warm' ? 'text-warm-500' : 'text-brand-600'}`}>
                  {stat.value}
                </p>
                <p className="text-xs text-gray-500">{stat.label}</p>
              </div>
            ))}
          </div>
        </section>

        {/* Feature List */}
        <section className="mb-16 md:mb-20">
          <h2 className="text-2xl md:text-3xl font-bold mb-8 text-gray-900">
            Explore Features
          </h2>
          <div className="space-y-4">
            {features.map((entry) => {
              const f = entry.fields as Record<string, unknown>
              return (
                <a
                  key={entry.sys.id}
                  href={`/features/${f.slug}`}
                  className="card-interactive p-6 md:p-8 flex flex-col md:flex-row md:items-center gap-4 md:gap-6"
                >
                  <div className="flex-1 min-w-0">
                    <h2 className="text-lg md:text-xl font-bold text-gray-900 mb-1">
                      {f.name as string}
                    </h2>
                    <p className="text-sm text-gray-500 mb-3">
                      {f.tagline as string}
                    </p>
                    {Array.isArray(f.benefits) && f.benefits.length > 0 && (
                      <div className="flex flex-wrap gap-2">
                        {(f.benefits as string[]).slice(0, 3).map((benefit, i) => (
                          <span
                            key={i}
                            className="inline-flex items-center gap-1 text-xs bg-sage-50 text-sage-700 px-2.5 py-1 rounded-full border border-sage-100"
                          >
                            <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" className="text-sage-500" strokeLinecap="round" strokeLinejoin="round">
                              <polyline points="20 6 9 17 4 12" />
                            </svg>
                            {benefit}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>
                  <div className="flex-shrink-0">
                    <span className="inline-flex items-center gap-1 text-sm font-medium text-brand-600">
                      Learn more
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <polyline points="9 18 15 12 9 6" />
                      </svg>
                    </span>
                  </div>
                </a>
              )
            })}
          </div>
        </section>

        {/* How It All Works Together */}
        <section className="mb-16 md:mb-20">
          <div className="card p-8 md:p-10 bg-brand-50/50 border-brand-100">
            <h2 className="text-2xl md:text-3xl font-bold mb-6 text-brand-900">
              How It All Works Together
            </h2>
            <div className="grid sm:grid-cols-3 gap-6">
              {[
                {
                  step: '1',
                  title: 'Choose Your Distractions',
                  description: 'Lock social media, games, browsers\u2014anything stealing your attention.',
                },
                {
                  step: '2',
                  title: 'Unlock with Scripture',
                  description: 'Read a daily Bible verse to access your apps. Takes 30 seconds.',
                },
                {
                  step: '3',
                  title: 'Build the Habit',
                  description: 'Track your streak, earn insights, and watch your faith grow.',
                },
              ].map((item) => (
                <div key={item.step} className="flex gap-4">
                  <div className="w-9 h-9 bg-brand-100 rounded-xl flex items-center justify-center flex-shrink-0">
                    <span className="text-sm font-bold text-brand-700">
                      {item.step}
                    </span>
                  </div>
                  <div>
                    <h3 className="font-bold text-gray-900 mb-1 text-sm">
                      {item.title}
                    </h3>
                    <p className="text-sm text-gray-600 leading-relaxed">
                      {item.description}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* CTA */}
        <section className="bg-cta-gradient text-white p-10 md:p-16 rounded-3xl text-center">
          <h2 className="text-2xl md:text-4xl font-bold mb-4 text-balance">
            Experience every feature for free
          </h2>
          <p className="text-lg mb-8 text-white/80">
            Join Christians transforming phone addiction into spiritual growth.
          </p>
          <CTAButton
            text="Try FaithLock Free"
            href={APP_STORE_URL}
            variant="white"
            size="large"
            showAppleIcon
          />
          <p className="mt-4 text-sm text-white/50">
            No credit card required
          </p>
        </section>
      </div>
    </div>
  )
}
