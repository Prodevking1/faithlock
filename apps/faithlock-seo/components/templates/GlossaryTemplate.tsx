import { GlossaryTerm } from '@/lib/types'
import { FAITHLOCK_STATS, APP_STORE_URL } from '@/lib/constants'
import BibleVerse from '@/components/ui/BibleVerse'
import CTAButton from '@/components/ui/CTAButton'
import RichText from '@/components/ui/RichText'

interface GlossaryTemplateProps {
  term: GlossaryTerm
}

export default function GlossaryTemplate({ term }: GlossaryTemplateProps) {
  return (
    <article>
      {/* Hero */}
      <div className="bg-gradient-to-br from-brand-950 via-brand-900 to-brand-800 text-white">
        <div className="container-default py-14 md:py-20">
          <nav className="breadcrumb mb-8 text-white/50">
            <a href="/" className="hover:text-white/80">Home</a>
            <span className="breadcrumb-separator text-white/30">/</span>
            <a href="/learn" className="hover:text-white/80">Learn</a>
            <span className="breadcrumb-separator text-white/30">/</span>
            <span className="text-white/70">{term.term}</span>
          </nav>

          <span className="badge bg-warm-500/20 text-warm-300 mb-4">{term.category}</span>
          <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold mb-6 tracking-tight leading-tight">
            What is {term.term}?
          </h1>

          {/* Quick Definition */}
          <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-6 border border-white/10 max-w-2xl">
            <p className="text-sm font-semibold text-warm-300 mb-2 uppercase tracking-wide">
              Quick Definition
            </p>
            <p className="text-white/80 leading-relaxed">
              {term.shortDefinition}
            </p>
          </div>
        </div>
      </div>

      <div className="container-default py-12 md:py-16">
        {/* Detailed Explanation */}
        <section className="mb-16 md:mb-20">
          <h2 className="text-2xl md:text-3xl font-bold mb-6 text-gray-900">
            Understanding {term.term}
          </h2>
          <RichText
            content={term.detailedExplanation}
            className="prose prose-lg max-w-none"
          />
        </section>

        {/* Christian Perspective */}
        <section className="mb-16 md:mb-20 bg-brand-950 text-white rounded-3xl p-8 md:p-12">
          <span className="badge bg-warm-500/20 text-warm-300 mb-4">Christian Perspective</span>
          <h2 className="text-2xl md:text-3xl font-bold mb-6">
            A Biblical View of {term.term}
          </h2>
          <RichText
            content={term.christianPerspective}
            className="prose prose-lg max-w-none prose-invert text-white/80 [&_p]:text-white/80 [&_li]:text-white/80 [&_strong]:text-white mb-8"
          />
          {term.bibleVerses && term.bibleVerses.length > 0 && (
            <div className="space-y-4 mt-8">
              <h3 className="text-lg font-bold text-white/90">Biblical Foundation</h3>
              {term.bibleVerses.map((verse, i) => (
                <BibleVerse key={i} reference={verse.reference} text={verse.text} />
              ))}
            </div>
          )}
        </section>

        {/* Statistics */}
        {term.statistics && term.statistics.length > 0 && (
          <section className="mb-16 md:mb-20">
            <h2 className="text-2xl md:text-3xl font-bold mb-8 text-gray-900">
              Statistics &amp; Research
            </h2>
            <div className="grid sm:grid-cols-2 gap-4">
              {term.statistics.map((stat, i) => (
                <div key={i} className="card p-6">
                  <p className="text-lg font-bold text-gray-900 mb-2 leading-snug">
                    {stat.stat}
                  </p>
                  <p className="text-xs text-gray-400">Source: {stat.source}</p>
                </div>
              ))}
            </div>
          </section>
        )}

        {/* FAQs */}
        {term.faqs && term.faqs.length > 0 && (
          <section className="mb-16 md:mb-20">
            <h2 className="text-2xl md:text-3xl font-bold mb-8 text-gray-900">
              Frequently Asked Questions
            </h2>
            <div className="space-y-3">
              {term.faqs.map((faq, i) => (
                <details key={i} className="card p-5 md:p-6 group">
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

        {/* How FaithLock Helps */}
        <section className="mb-16 md:mb-20">
          <div className="card p-8 md:p-10 bg-gradient-to-br from-brand-50 to-white border-brand-100">
            <h2 className="text-2xl md:text-3xl font-bold mb-4 text-gray-900">
              How FaithLock Addresses {term.term}
            </h2>
            <p className="text-gray-600 mb-8 max-w-2xl">
              FaithLock was designed to help Christians overcome{' '}
              {term.term.toLowerCase()} by transforming phone usage into spiritual
              growth opportunities.
            </p>
            <div className="grid sm:grid-cols-2 gap-4 mb-8">
              <div className="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
                <div className="w-10 h-10 bg-brand-100 rounded-lg flex items-center justify-center mb-3">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-brand-600" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z" />
                    <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z" />
                  </svg>
                </div>
                <h3 className="font-bold text-gray-900 mb-2">Bible Verse Unlocking</h3>
                <p className="text-sm text-gray-600">
                  Read Scripture before accessing blocked apps. Turns every temptation into a moment with God.
                </p>
              </div>
              <div className="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
                <div className="w-10 h-10 bg-warm-100 rounded-lg flex items-center justify-center mb-3">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-warm-600" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z" />
                  </svg>
                </div>
                <h3 className="font-bold text-gray-900 mb-2">Streak Tracking</h3>
                <p className="text-sm text-gray-600">
                  Build consistency with visible progress. Track verses read, time saved, and daily streaks.
                </p>
              </div>
            </div>
            <div className="flex items-center gap-3 p-4 bg-sage-50 rounded-xl border border-sage-100">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-sage-600 flex-shrink-0" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="20 6 9 17 4 12" />
              </svg>
              <p className="text-sm font-medium text-sage-800">
                Replace mindless scrolling with daily Scripture in ~30 seconds
              </p>
            </div>
          </div>
        </section>

        {/* CTA */}
        <section className="bg-cta-gradient text-white p-10 md:p-16 rounded-3xl text-center mb-16">
          <h2 className="text-2xl md:text-4xl font-bold mb-4 text-balance">
            Ready to overcome {term.term.toLowerCase()}?
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

        {/* Related */}
        {term.relatedTerms && term.relatedTerms.length > 0 && (
          <section>
            <h2 className="text-xl font-bold mb-6 text-gray-900">Related Topics</h2>
            <div className="grid sm:grid-cols-3 gap-4">
              {term.relatedTerms.map((slug, i) => {
                const displayName = slug
                  .split('-')
                  .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
                  .join(' ')
                return (
                  <a key={i} href={`/learn/${slug}`} className="card-interactive p-5">
                    <h3 className="font-semibold text-gray-900 text-sm">{displayName}</h3>
                    <p className="text-xs text-gray-500 mt-1">
                      Learn about {displayName.toLowerCase()}
                    </p>
                  </a>
                )
              })}
            </div>
          </section>
        )}
      </div>
    </article>
  )
}
