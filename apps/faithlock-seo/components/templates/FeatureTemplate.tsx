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
    <article>
      <TemplateTracker type="feature" slug={feature.slug} />
      <BreadcrumbSchema
        items={[
          { name: 'Home', url: '/' },
          { name: 'Features', url: '/features' },
          { name: feature.name, url: `/features/${feature.slug}` },
        ]}
      />

      {/* Hero */}
      <div className="bg-hero-pattern text-white">
        <div className="container-default py-14 md:py-20">
          <nav className="breadcrumb mb-8 text-white/50">
            <a href="/" className="hover:text-white/80">Home</a>
            <span className="breadcrumb-separator text-white/30">/</span>
            <a href="/features" className="hover:text-white/80">Features</a>
            <span className="breadcrumb-separator text-white/30">/</span>
            <span className="text-white/70">{feature.name}</span>
          </nav>

          <div className="flex items-center gap-3 mb-4">
            <span className="badge bg-warm-500/20 text-warm-300">Feature</span>
            <ReadingTime wordCount={wordCount} />
            <span className="text-sm text-white/50">Updated {formatDate(updatedAt)}</span>
          </div>

          <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold mb-4 tracking-tight leading-tight">
            {feature.name}
          </h1>
          <p className="text-lg md:text-xl text-warm-200 font-medium mb-6">
            {feature.tagline}
          </p>
          <RichText
            content={feature.description}
            className="prose prose-lg max-w-2xl prose-invert text-white/70 [&_p]:text-white/70 [&_li]:text-white/70 [&_strong]:text-white"
          />
        </div>
      </div>

      <div className="container-default py-12 md:py-16">
        {/* Table of Contents */}
        <TableOfContents items={tocItems} />

        {/* How It Works */}
        <section id="how-it-works" className="mb-16 md:mb-20">
          <div className="card p-8 md:p-10 bg-brand-50/50 border-brand-100">
            <h2 className="text-2xl md:text-3xl font-bold mb-6 text-brand-900">How It Works</h2>
            <RichText
              content={feature.howItWorks}
              className="prose prose-lg max-w-none [&_h3]:text-brand-800 [&_ol]:list-none [&_ol]:pl-0 [&_li]:pl-0 [&_li]:mb-4"
            />
          </div>
        </section>

        {/* Benefits */}
        <section id="benefits" className="mb-16 md:mb-20">
          <h2 className="text-2xl md:text-3xl font-bold mb-8 text-gray-900">Key Benefits</h2>
          <div className="grid sm:grid-cols-2 gap-3">
            {(Array.isArray(feature.benefits) ? feature.benefits : []).map((benefit, i) => (
              <div key={i} className="flex items-start gap-3 p-4 card">
                <div className="w-8 h-8 bg-sage-100 rounded-lg flex items-center justify-center flex-shrink-0">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-sage-600" strokeLinecap="round" strokeLinejoin="round">
                    <polyline points="20 6 9 17 4 12" />
                  </svg>
                </div>
                <p className="text-gray-700 font-medium text-sm pt-1">{benefit}</p>
              </div>
            ))}
          </div>
        </section>

        {/* User Stories */}
        {feature.useCases && feature.useCases.length > 0 && (
          <section id="stories" className="mb-16 md:mb-20">
            <h2 className="text-2xl md:text-3xl font-bold mb-8 text-gray-900">
              Real User Stories
            </h2>
            <div className="space-y-4">
              {feature.useCases.map((useCase, i) => (
                <div key={i} className="card p-6 md:p-8">
                  <div className="flex items-start gap-4">
                    <div className="w-10 h-10 bg-brand-100 rounded-full flex items-center justify-center flex-shrink-0">
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-brand-600" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                        <circle cx="12" cy="7" r="4" />
                      </svg>
                    </div>
                    <div>
                      <h3 className="text-lg font-bold text-gray-900 mb-2">
                        {useCase.title}
                      </h3>
                      <p className="text-gray-600 leading-relaxed italic text-sm">
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
          <section id="scripture" className="mb-16 md:mb-20 bg-brand-950 text-white rounded-3xl p-8 md:p-12">
            <span className="badge bg-warm-500/20 text-warm-300 mb-4">Scripture</span>
            <h2 className="text-2xl md:text-3xl font-bold mb-4">
              Biblical Foundation
            </h2>
            <p className="text-white/70 mb-8 max-w-2xl">
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
            <h2 className="text-2xl md:text-3xl font-bold mb-8 text-gray-900">
              Frequently Asked Questions
            </h2>
            <div className="space-y-3">
              {feature.faqs.map((faq, i) => (
                <details key={i} className="card p-5 md:p-6">
                  <summary className="font-semibold text-gray-900 cursor-pointer">
                    {faq.question}
                  </summary>
                  <p className="mt-4 text-gray-600 leading-relaxed text-sm">
                    {faq.answer}
                  </p>
                </details>
              ))}
            </div>
          </section>
        )}

        {/* At a Glance */}
        <section className="mb-16 md:mb-20">
          <h2 className="text-2xl md:text-3xl font-bold mb-8 text-gray-900">At a Glance</h2>
          <div className="grid sm:grid-cols-3 gap-4">
            {[
              { value: 'Complete Bible', label: 'Scripture library', color: 'brand' },
              { value: '~30s', label: 'To unlock with Scripture', color: 'brand' },
              { value: 'BSB', label: 'Bible translation', color: 'warm' },
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
        <section className="bg-cta-gradient text-white p-10 md:p-16 rounded-3xl text-center mb-16">
          <h2 className="text-2xl md:text-4xl font-bold mb-4 text-balance">
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
            <h2 className="text-xl font-bold mb-6 text-gray-900">Other Features</h2>
            <div className="grid sm:grid-cols-3 gap-4">
              {otherFeatures.slice(0, 2).map((feat) => (
                <a key={feat.slug} href={`/features/${feat.slug}`} className="card-interactive p-5">
                  <h3 className="font-semibold text-gray-900 text-sm">{feat.name}</h3>
                  <p className="text-xs text-gray-500 mt-1">Learn more about this feature</p>
                </a>
              ))}
              <a href="/features" className="card-interactive p-5">
                <h3 className="font-semibold text-brand-600 text-sm">All Features</h3>
                <p className="text-xs text-gray-500 mt-1">Explore everything FaithLock offers</p>
              </a>
            </div>
          </section>
        )}
      </div>
    </article>
  )
}
