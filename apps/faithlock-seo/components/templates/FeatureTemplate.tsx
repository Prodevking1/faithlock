import { Feature } from '@/lib/types'
import { APP_STORE_URL } from '@/lib/constants'
import BibleVerse from '@/components/ui/BibleVerse'
import CTAButton from '@/components/ui/CTAButton'
import RichText from '@/components/ui/RichText'
import TemplateTracker from '@/components/templates/TemplateTracker'
import TableOfContents from '@/components/seo/TableOfContents'
import ReadingTime from '@/components/seo/ReadingTime'
import BreadcrumbSchema from '@/components/seo/BreadcrumbSchema'

interface FeatureTemplateProps {
  feature: Feature
  updatedAt: string
  otherFeatures: { slug: string; name: string }[]
}

function formatDate(dateString: string): string {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { month: 'short', year: 'numeric' })
}

export default function FeatureTemplate({ feature, updatedAt, otherFeatures }: FeatureTemplateProps) {
  const wordCount = 800 + (feature.benefits?.length || 0) * 10 + (feature.useCases?.length || 0) * 30

  const tocItems = [
    { id: 'how-it-works', text: 'How It Works' },
    { id: 'benefits', text: 'Key Benefits' },
    ...(feature.useCases && feature.useCases.length > 0
      ? [{ id: 'stories', text: 'Real User Stories' }]
      : []),
    ...(feature.bibleVerses && feature.bibleVerses.length > 0
      ? [{ id: 'scripture', text: 'Biblical Foundation' }]
      : []),
    ...(feature.faqs && feature.faqs.length > 0
      ? [{ id: 'faqs', text: 'Frequently Asked Questions' }]
      : []),
    ...(otherFeatures.length > 0
      ? [{ id: 'related', text: 'Other Features' }]
      : []),
  ]

  return (
    <article className="cozy-page">
      <TemplateTracker type="feature" slug={feature.slug} />
      <BreadcrumbSchema
        items={[
          { name: 'Home', url: '/' },
          { name: 'Features', url: '/features' },
          { name: feature.name, url: `/features/${feature.slug}` },
        ]}
      />

      {/* Hero */}
      <div className="cozy-hero">
        <div className="container-default py-14 md:py-20">
          <nav className="cozy-breadcrumb mb-8">
            <a href="/">Home</a>
            <span className="cozy-breadcrumb-separator">/</span>
            <a href="/features">Features</a>
            <span className="cozy-breadcrumb-separator">/</span>
            <span>{feature.name}</span>
          </nav>

          <div className="flex items-center gap-3 mb-4">
            <span className="cozy-badge-peach">Feature</span>
            <ReadingTime wordCount={wordCount} />
            <span className="text-sm text-cozy-ink-muted">Updated {formatDate(updatedAt)}</span>
          </div>

          <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold mb-4 tracking-tight leading-tight text-cozy-ink">
            {feature.name}
          </h1>
          <p className="text-lg md:text-xl text-cozy-ink/70 font-medium mb-6">
            {feature.tagline}
          </p>
          <RichText
            content={feature.description}
            className="prose-cozy max-w-2xl [&_p]:text-cozy-ink/70 [&_li]:text-cozy-ink/70 [&_strong]:text-cozy-ink"
          />
        </div>
      </div>

      <div className="container-default py-12 md:py-16">
        {/* Table of Contents */}
        <TableOfContents items={tocItems} />

        {/* How It Works */}
        <section id="how-it-works" className="mb-16 md:mb-20">
          <div className="cozy-card p-8 md:p-10 bg-cozy-surface-muted border-cozy-border">
            <h2 className="text-2xl md:text-3xl font-bold mb-6 text-cozy-ink">How It Works</h2>
            <RichText
              content={feature.howItWorks}
              className="prose-cozy max-w-none [&_h3]:text-cozy-ink [&_ol]:list-none [&_ol]:pl-0 [&_li]:pl-0 [&_li]:mb-4"
            />
          </div>
        </section>

        {/* Benefits */}
        <section id="benefits" className="mb-16 md:mb-20">
          <h2 className="text-2xl md:text-3xl font-bold mb-8 text-cozy-ink">Key Benefits</h2>
          <div className="grid sm:grid-cols-2 gap-3">
            {(Array.isArray(feature.benefits) ? feature.benefits : []).map((benefit, i) => (
              <div key={i} className="flex items-start gap-3 p-4 cozy-card">
                <div className="w-8 h-8 bg-cozy-peach rounded-lg border-[2px] border-cozy-ink flex items-center justify-center flex-shrink-0">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-cozy-ink" strokeLinecap="round" strokeLinejoin="round">
                    <polyline points="20 6 9 17 4 12" />
                  </svg>
                </div>
                <p className="text-cozy-ink/85 font-medium text-sm pt-1">{benefit}</p>
              </div>
            ))}
          </div>
        </section>

        {/* User Stories */}
        {feature.useCases && feature.useCases.length > 0 && (
          <section id="stories" className="mb-16 md:mb-20">
            <h2 className="text-2xl md:text-3xl font-bold mb-8 text-cozy-ink">
              Real User Stories
            </h2>
            <div className="space-y-4">
              {feature.useCases.map((useCase, i) => (
                <div key={i} className="cozy-card p-6 md:p-8">
                  <div className="flex items-start gap-4">
                    <div className="w-10 h-10 bg-cozy-peach rounded-full border-[2px] border-cozy-ink flex items-center justify-center flex-shrink-0">
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-cozy-ink" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                        <circle cx="12" cy="7" r="4" />
                      </svg>
                    </div>
                    <div>
                      <h3 className="text-lg font-bold text-cozy-ink mb-2">
                        {useCase.title}
                      </h3>
                      <p className="text-cozy-ink/85 leading-relaxed italic text-sm">
                        &ldquo;{useCase.description}&rdquo;
                      </p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </section>
        )}

        {/* Biblical Foundation */}
        {feature.bibleVerses && feature.bibleVerses.length > 0 && (
          <section id="scripture" className="mb-16 md:mb-20 bg-cozy-primary text-white border-[2.5px] border-cozy-ink rounded-cozy-lg shadow-cozy-hard-lg p-8 md:p-12">
            <span className="cozy-badge mb-4">Scripture</span>
            <h2 className="text-2xl md:text-3xl font-bold mb-4 text-white">
              Biblical Foundation
            </h2>
            <p className="text-white/80 mb-8 max-w-2xl">
              This feature is rooted in Scripture and designed to help you live out
              biblical principles in your digital life.
            </p>
            <div className="space-y-4">
              {feature.bibleVerses.map((verse, i) => (
                <BibleVerse key={i} reference={verse.reference} text={verse.text} />
              ))}
            </div>
          </section>
        )}

        {/* FAQs */}
        {feature.faqs && feature.faqs.length > 0 && (
          <section id="faqs" className="mb-16 md:mb-20">
            <h2 className="text-2xl md:text-3xl font-bold mb-8 text-cozy-ink">
              Frequently Asked Questions
            </h2>
            <div className="space-y-3">
              {feature.faqs.map((faq, i) => (
                <details key={i} className="cozy-faq cozy-card p-5 md:p-6">
                  <summary className="font-semibold text-cozy-ink cursor-pointer">
                    {faq.question}
                  </summary>
                  <p className="mt-4 text-cozy-ink/85 leading-relaxed text-sm">
                    {faq.answer}
                  </p>
                </details>
              ))}
            </div>
          </section>
        )}

        {/* At a Glance */}
        <section className="mb-16 md:mb-20">
          <h2 className="text-2xl md:text-3xl font-bold mb-8 text-cozy-ink">At a Glance</h2>
          <div className="grid sm:grid-cols-3 gap-4">
            {[
              { value: 'Complete Bible', label: 'Scripture library', color: 'primary' },
              { value: '~30s', label: 'To unlock with Scripture', color: 'primary' },
              { value: 'BSB', label: 'Bible translation', color: 'gold' },
            ].map((stat) => (
              <div key={stat.label} className="cozy-card p-6 text-center">
                <p className={`text-3xl md:text-4xl font-bold mb-1 ${stat.color === 'gold' ? 'text-cozy-gold' : 'text-cozy-primary'}`}>
                  {stat.value}
                </p>
                <p className="text-sm text-cozy-ink-muted">{stat.label}</p>
              </div>
            ))}
          </div>
        </section>

        {/* CTA */}
        <section className="bg-cozy-primary text-white p-10 md:p-16 border-[2.5px] border-cozy-ink rounded-cozy-lg shadow-cozy-hard-lg text-center mb-16">
          <h2 className="text-2xl md:text-4xl font-bold mb-4 text-balance text-white">
            Experience {feature.name} today
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
            trackingLocation="feature_cta"
          />
        </section>

        {/* Related Features — dynamic */}
        {otherFeatures.length > 0 && (
          <section id="related">
            <h2 className="text-xl font-bold mb-6 text-cozy-ink">Other Features</h2>
            <div className="grid sm:grid-cols-3 gap-4">
              {otherFeatures.slice(0, 2).map((feat) => (
                <a key={feat.slug} href={`/features/${feat.slug}`} className="cozy-card-interactive p-5">
                  <h3 className="font-semibold text-cozy-ink text-sm">{feat.name}</h3>
                  <p className="text-xs text-cozy-ink-muted mt-1">Learn more about this feature</p>
                </a>
              ))}
              <a href="/features" className="cozy-card-interactive p-5">
                <h3 className="font-semibold text-cozy-primary text-sm">All Features</h3>
                <p className="text-xs text-cozy-ink-muted mt-1">Explore everything FaithLock offers</p>
              </a>
            </div>
          </section>
        )}
      </div>
    </article>
  )
}
