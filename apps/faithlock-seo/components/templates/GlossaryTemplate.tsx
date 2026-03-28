import { GlossaryTerm } from '@/lib/types'
import { APP_STORE_URL } from '@/lib/constants'
import BibleVerse from '@/components/ui/BibleVerse'
import CTAButton from '@/components/ui/CTAButton'
import RichText, { stripMarkdown } from '@/components/ui/RichText'
import TemplateTracker from '@/components/templates/TemplateTracker'
import TableOfContents from '@/components/seo/TableOfContents'
import ReadingTime from '@/components/seo/ReadingTime'
import SubtleCallout from '@/components/seo/SubtleCallout'
import BreadcrumbSchema from '@/components/seo/BreadcrumbSchema'

interface GlossaryTemplateProps {
  term: GlossaryTerm
  updatedAt: string
}

// Categories that use "What is X?" format (glossary definitions)
const DEFINITION_CATEGORIES = ['General', 'Understanding Addiction', 'Digital Wellness', 'Spiritual Disciplines', 'Practical Solutions']

function isDefinitionPage(category: string): boolean {
  return DEFINITION_CATEGORIES.includes(category)
}

function estimateWordCount(term: GlossaryTerm): number {
  const text = [
    stripMarkdown(term.shortDefinition),
    stripMarkdown(term.detailedExplanation),
    term.christianPerspective ? stripMarkdown(term.christianPerspective) : '',
    ...(term.faqs && Array.isArray(term.faqs) ? term.faqs : []).map((f) => `${f.question} ${f.answer}`),
  ].join(' ')
  return text.split(/\s+/).filter(Boolean).length
}

function formatDate(dateString: string): string {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { month: 'short', year: 'numeric' })
}

export default function GlossaryTemplate({ term, updatedAt }: GlossaryTemplateProps) {
  const wordCount = estimateWordCount(term)
  const isDefinition = isDefinitionPage(term.category)
  const hasChristianPerspective = term.christianPerspective && stripMarkdown(term.christianPerspective).trim().length > 10
  const hasFaqs = term.faqs && Array.isArray(term.faqs) && term.faqs.length > 0
  const hasStats = term.statistics && Array.isArray(term.statistics) && term.statistics.length > 0
  const hasRelated = term.relatedTerms && Array.isArray(term.relatedTerms) && term.relatedTerms.length > 0
  const hasBibleVerses = term.bibleVerses && Array.isArray(term.bibleVerses) && term.bibleVerses.length > 0

  // Build TOC dynamically based on what content exists
  const tocItems = [
    ...(isDefinition
      ? [{ id: 'understanding', text: `Understanding ${term.term}` }]
      : [{ id: 'content', text: term.term }]
    ),
    ...(hasChristianPerspective
      ? [{ id: 'biblical-view', text: 'Biblical Perspective' }]
      : []),
    ...(hasStats
      ? [{ id: 'statistics', text: 'Statistics & Research' }]
      : []),
    ...(hasFaqs
      ? [{ id: 'faqs', text: 'Frequently Asked Questions' }]
      : []),
    ...(hasRelated
      ? [{ id: 'related', text: 'Related Topics' }]
      : []),
  ]

  return (
    <article>
      <TemplateTracker type="glossary" slug={term.slug} />
      <BreadcrumbSchema
        items={[
          { name: 'Home', url: '/' },
          { name: 'Learn', url: '/learn' },
          { name: term.term, url: `/learn/${term.slug}` },
        ]}
      />

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

          <div className="flex items-center gap-3 mb-4">
            <span className="badge bg-warm-500/20 text-warm-300">{term.category}</span>
            <ReadingTime wordCount={wordCount} />
            <span className="text-sm text-white/50">Updated {formatDate(updatedAt)}</span>
          </div>

          {/* H1: adaptive based on category */}
          <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold mb-6 tracking-tight leading-tight">
            {isDefinition ? `What is ${term.term}?` : term.term}
          </h1>

          {/* Quick summary — only for definitions, or when shortDefinition is meaningfully different from body */}
          {term.shortDefinition && stripMarkdown(term.shortDefinition).length > 20 && (
            <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-6 border border-white/10 max-w-2xl">
              <p className="text-sm font-semibold text-warm-300 mb-2 uppercase tracking-wide">
                {isDefinition ? 'Quick Definition' : 'Summary'}
              </p>
              <p className="text-white/80 leading-relaxed">
                {stripMarkdown(term.shortDefinition)}
              </p>
            </div>
          )}
        </div>
      </div>

      <div className="container-default py-12 md:py-16">
        {/* Table of Contents */}
        <TableOfContents items={tocItems} />

        {/* Main Content */}
        <section id={isDefinition ? 'understanding' : 'content'} className="mb-16 md:mb-20">
          {isDefinition && (
            <h2 className="text-2xl md:text-3xl font-bold mb-6 text-gray-900">
              Understanding {term.term}
            </h2>
          )}
          <RichText
            content={term.detailedExplanation}
            className="prose prose-lg max-w-none"
          />
        </section>

        {/* Christian Perspective — only if content exists */}
        {hasChristianPerspective && (
          <section id="biblical-view" className="mb-16 md:mb-20 bg-brand-950 text-white rounded-3xl p-8 md:p-12">
            <span className="badge bg-warm-500/20 text-warm-300 mb-4">Christian Perspective</span>
            <h2 className="text-2xl md:text-3xl font-bold mb-6">
              A Biblical View of {term.term}
            </h2>
            <RichText
              content={term.christianPerspective}
              className="prose prose-lg max-w-none prose-invert text-white/80 [&_p]:text-white/80 [&_li]:text-white/80 [&_strong]:text-white mb-8"
            />
            {hasBibleVerses && (
              <div className="space-y-4 mt-8">
                <h3 className="text-lg font-bold text-white/90">Biblical Foundation</h3>
                {term.bibleVerses.map((verse, i) => (
                  <BibleVerse key={i} reference={verse.reference} text={verse.text} />
                ))}
              </div>
            )}
          </section>
        )}

        {/* Statistics */}
        {hasStats && (
          <section id="statistics" className="mb-16 md:mb-20">
            <h2 className="text-2xl md:text-3xl font-bold mb-8 text-gray-900">
              Statistics &amp; Research
            </h2>
            <div className="grid sm:grid-cols-2 gap-4">
              {term.statistics!.map((stat, i) => (
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
        {hasFaqs && (
          <section id="faqs" className="mb-16 md:mb-20">
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

        {/* Subtle product mention */}
        <SubtleCallout />

        {/* CTA */}
        <section className="bg-cta-gradient text-white p-10 md:p-16 rounded-3xl text-center mb-16">
          <h2 className="text-2xl md:text-4xl font-bold mb-4 text-balance">
            Start building a daily Scripture habit
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
            trackingLocation="glossary_cta"
          />
        </section>

        {/* Related */}
        {hasRelated && (
          <section id="related">
            <h2 className="text-xl font-bold mb-6 text-gray-900">Related Topics</h2>
            <div className="grid sm:grid-cols-3 gap-4">
              {term.relatedTerms!.map((slug, i) => {
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
