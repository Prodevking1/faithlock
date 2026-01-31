import { Metadata } from 'next'
import { getAllGlossaryTerms } from '@/lib/contentful'
import { FAITHLOCK_STATS, APP_STORE_URL } from '@/lib/constants'
import CTAButton from '@/components/ui/CTAButton'
import BibleVerse from '@/components/ui/BibleVerse'

export const metadata: Metadata = {
  title: 'Christian Digital Wellness Guide - Phone Addiction Resources',
  description:
    'Learn about phone addiction, digital detox, and spiritual disciplines from a Christian perspective. Biblical insights and practical solutions for screen time management.',
  alternates: {
    canonical: '/learn',
  },
}

const CATEGORY_CONFIG: Record<string, { label: string; icon: string; color: string }> = {
  addiction: {
    label: 'Understanding Addiction',
    icon: 'brain',
    color: 'warm',
  },
  spiritual: {
    label: 'Spiritual Disciplines',
    icon: 'book',
    color: 'brand',
  },
  tech: {
    label: 'Digital Wellness',
    icon: 'screen',
    color: 'sage',
  },
  solutions: {
    label: 'Practical Solutions',
    icon: 'lightbulb',
    color: 'brand',
  },
}

function CategoryIcon({ icon, className }: { icon: string; className?: string }) {
  const props = { width: 18, height: 18, viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', strokeWidth: 2, className, strokeLinecap: 'round' as const, strokeLinejoin: 'round' as const }

  switch (icon) {
    case 'brain':
      return (
        <svg {...props}>
          <path d="M9.5 2A5.5 5.5 0 0 0 5 9a5.5 5.5 0 0 0 .96 3.09A5.5 5.5 0 0 0 4 16.5 5.5 5.5 0 0 0 9.5 22h5a5.5 5.5 0 0 0 5.5-5.5 5.5 5.5 0 0 0-1.96-4.41A5.5 5.5 0 0 0 19 9a5.5 5.5 0 0 0-5.5-7h-4z" />
          <path d="M12 2v20" />
        </svg>
      )
    case 'book':
      return (
        <svg {...props}>
          <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z" />
          <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z" />
        </svg>
      )
    case 'screen':
      return (
        <svg {...props}>
          <rect x="2" y="3" width="20" height="14" rx="2" ry="2" />
          <line x1="8" y1="21" x2="16" y2="21" />
          <line x1="12" y1="17" x2="12" y2="21" />
        </svg>
      )
    case 'lightbulb':
      return (
        <svg {...props}>
          <path d="M9 18h6" />
          <path d="M10 22h4" />
          <path d="M15.09 14c.18-.98.65-1.74 1.41-2.5A4.65 4.65 0 0 0 18 8 6 6 0 0 0 6 8c0 1 .23 2.23 1.5 3.5A4.61 4.61 0 0 1 8.91 14" />
        </svg>
      )
    default:
      return null
  }
}

export default async function LearnPage() {
  const terms = await getAllGlossaryTerms()

  const grouped = terms.reduce(
    (acc, entry) => {
      const category = (entry.fields as Record<string, unknown>).category as string
      if (!acc[category]) acc[category] = []
      acc[category].push(entry)
      return acc
    },
    {} as Record<string, typeof terms>
  )

  return (
    <div>
      {/* Hero */}
      <div className="bg-gradient-to-br from-brand-950 via-brand-900 to-brand-800 text-white">
        <div className="container-default py-14 md:py-20">
          <nav className="breadcrumb mb-8 text-white/50">
            <a href="/" className="hover:text-white/80">Home</a>
            <span className="breadcrumb-separator text-white/30">/</span>
            <span className="text-white/70">Learn</span>
          </nav>

          <span className="badge bg-warm-500/20 text-warm-300 mb-4">Glossary</span>
          <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold mb-4 tracking-tight leading-tight">
            Christian Digital Wellness Guide
          </h1>
          <p className="text-lg md:text-xl text-white/70 max-w-2xl">
            Biblical perspectives on phone addiction, digital detox, and
            spiritual disciplines for the modern age. Learn how to reclaim
            your time for God.
          </p>
        </div>
      </div>

      <div className="container-default py-12 md:py-16">
        {/* Quick Stat */}
        <section className="mb-12 md:mb-16">
          <div className="card p-6 md:p-8 bg-brand-50/50 border-brand-100">
            <div className="flex flex-col sm:flex-row sm:items-center gap-4">
              <div className="flex items-center gap-3">
                <p className="text-3xl md:text-4xl font-bold text-brand-600">
                  {FAITHLOCK_STATS.phoneChecksPerDay}
                </p>
                <div>
                  <p className="text-sm font-semibold text-gray-900">
                    times per day
                  </p>
                  <p className="text-xs text-gray-500">
                    the average person checks their phone
                  </p>
                </div>
              </div>
              <div className="hidden sm:block w-px h-10 bg-gray-200" />
              <p className="text-sm text-gray-600 max-w-md">
                Understanding the problem is the first step. Explore our guides
                to learn about digital wellness from a biblical perspective.
              </p>
            </div>
          </div>
        </section>

        {/* Categories */}
        {Object.entries(grouped).map(([category, entries]) => {
          const config = CATEGORY_CONFIG[category] || {
            label: category,
            icon: 'book',
            color: 'brand',
          }

          const bgColor = config.color === 'warm'
            ? 'bg-warm-100'
            : config.color === 'sage'
              ? 'bg-sage-100'
              : 'bg-brand-100'

          const iconColor = config.color === 'warm'
            ? 'text-warm-600'
            : config.color === 'sage'
              ? 'text-sage-600'
              : 'text-brand-600'

          return (
            <section key={category} className="mb-12 md:mb-16">
              <div className="flex items-center gap-3 mb-6">
                <div className={`w-9 h-9 ${bgColor} rounded-lg flex items-center justify-center`}>
                  <CategoryIcon icon={config.icon} className={iconColor} />
                </div>
                <h2 className="text-xl md:text-2xl font-bold text-gray-900">
                  {config.label}
                </h2>
              </div>
              <div className="grid sm:grid-cols-2 gap-4">
                {entries.map((entry) => {
                  const t = entry.fields as Record<string, unknown>
                  return (
                    <a
                      key={entry.sys.id}
                      href={`/learn/${t.slug}`}
                      className="card-interactive p-5 md:p-6"
                    >
                      <div className="flex items-start gap-3">
                        <div className={`w-8 h-8 ${bgColor} rounded-lg flex items-center justify-center flex-shrink-0 mt-0.5`}>
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className={iconColor} strokeLinecap="round" strokeLinejoin="round">
                            <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z" />
                            <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z" />
                          </svg>
                        </div>
                        <div className="min-w-0">
                          <h3 className="text-base font-bold text-gray-900 mb-1">
                            {t.term as string}
                          </h3>
                          <p className="text-sm text-gray-500 line-clamp-2">
                            {t.shortDefinition as string}
                          </p>
                        </div>
                      </div>
                    </a>
                  )
                })}
              </div>
            </section>
          )
        })}

        {/* Biblical Foundation */}
        <section className="mb-16 md:mb-20 bg-brand-950 text-white rounded-3xl p-8 md:p-12">
          <span className="badge bg-warm-500/20 text-warm-300 mb-4">Scripture</span>
          <h2 className="text-2xl md:text-3xl font-bold mb-4">
            What Does the Bible Say?
          </h2>
          <p className="text-white/70 mb-8 max-w-2xl leading-relaxed">
            Scripture speaks directly to how we use our time and attention.
            These verses guide our approach to digital wellness.
          </p>
          <div className="space-y-4 max-w-2xl">
            <BibleVerse
              reference="Ephesians 5:15-16"
              text="Be very careful, then, how you live&mdash;not as unwise but as wise, making the most of every opportunity, because the days are evil."
            />
            <BibleVerse
              reference="Psalm 119:37"
              text="Turn my eyes away from worthless things; preserve my life according to your word."
            />
          </div>
        </section>

        {/* CTA */}
        <section className="bg-cta-gradient text-white p-10 md:p-16 rounded-3xl text-center">
          <h2 className="text-2xl md:text-4xl font-bold mb-4 text-balance">
            Ready to put knowledge into action?
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
          <p className="mt-4 text-sm text-white/50">
            No credit card required
          </p>
        </section>
      </div>
    </div>
  )
}
