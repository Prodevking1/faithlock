// components/templates/GlossaryTemplate.tsx
import { GlossaryTerm } from '@/lib/types'
import BibleVerse from '@/components/ui/BibleVerse'
import CTAButton from '@/components/ui/CTAButton'

interface GlossaryTemplateProps {
  term: GlossaryTerm
}

export default function GlossaryTemplate({ term }: GlossaryTemplateProps) {
  return (
    <article className="max-w-4xl mx-auto px-4 py-12">
      {/* Breadcrumbs */}
      <nav className="mb-6 text-sm text-gray-600">
        <a href="/" className="hover:text-blue-600">Home</a>
        <span className="mx-2">/</span>
        <a href="/learn" className="hover:text-blue-600">Learn</a>
        <span className="mx-2">/</span>
        <span>{term.term}</span>
      </nav>

      {/* Hero Section */}
      <header className="mb-12">
        <h1 className="text-4xl md:text-5xl font-bold mb-6 text-gray-900">
          What is {term.term}?
        </h1>

        {/* Featured Snippet Optimized Definition */}
        <div className="p-6 bg-blue-50 rounded-lg border-l-4 border-blue-600 mb-8">
          <p className="text-lg font-semibold text-blue-900 mb-2">📖 Quick Definition</p>
          <p className="text-gray-800 text-lg leading-relaxed">
            {term.shortDefinition}
          </p>
        </div>
      </header>

      {/* Detailed Explanation */}
      <section className="mb-16">
        <h2 className="text-3xl font-bold mb-6 text-gray-900">
          Understanding {term.term}
        </h2>
        <div
          className="prose prose-lg max-w-none text-gray-700"
          dangerouslySetInnerHTML={{ __html: term.detailedExplanation }}
        />
      </section>

      {/* Christian Perspective */}
      <section className="mb-16 bg-purple-50 p-8 rounded-lg">
        <h2 className="text-3xl font-bold mb-6 text-purple-900">
          ✝️ Christian Perspective on {term.term}
        </h2>
        <div
          className="prose prose-lg max-w-none text-gray-800 mb-6"
          dangerouslySetInnerHTML={{ __html: term.christianPerspective }}
        />

        {/* Bible Verses */}
        {term.bibleVerses && term.bibleVerses.length > 0 && (
          <div className="space-y-6 mt-8">
            <h3 className="text-xl font-bold text-purple-900">📖 Biblical Foundation</h3>
            {term.bibleVerses.map((verse, index) => (
              <BibleVerse
                key={index}
                reference={verse.reference}
                text={verse.text}
              />
            ))}
          </div>
        )}
      </section>

      {/* Statistics Section */}
      {term.statistics && term.statistics.length > 0 && (
        <section className="mb-16">
          <h2 className="text-3xl font-bold mb-6 text-gray-900">
            📊 Statistics & Research
          </h2>
          <div className="bg-gray-50 p-8 rounded-lg">
            <div className="space-y-6">
              {term.statistics.map((stat, index) => (
                <div key={index} className="border-l-4 border-blue-500 pl-6">
                  <p className="text-xl font-semibold text-gray-900 mb-2">
                    {stat.stat}
                  </p>
                  <p className="text-sm text-gray-600">
                    Source: {stat.source}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </section>
      )}

      {/* FAQ Section */}
      {term.faqs && term.faqs.length > 0 && (
        <section className="mb-16">
          <h2 className="text-3xl font-bold mb-6 text-gray-900">
            ❓ Frequently Asked Questions
          </h2>
          <div className="space-y-4">
            {term.faqs.map((faq, index) => (
              <details key={index} className="bg-white p-6 rounded-lg shadow-sm border">
                <summary className="font-semibold text-lg cursor-pointer text-gray-900">
                  {faq.question}
                </summary>
                <p className="mt-3 text-gray-700 leading-relaxed">
                  {faq.answer}
                </p>
              </details>
            ))}
          </div>
        </section>
      )}

      {/* How FaithLock Helps Section */}
      <section className="mb-16 bg-gradient-to-br from-blue-50 to-purple-50 p-8 rounded-lg border border-blue-200">
        <h2 className="text-3xl font-bold mb-6 text-gray-900">
          🙏 How FaithLock Addresses {term.term}
        </h2>
        <div className="space-y-4 text-gray-800">
          <p className="text-lg">
            FaithLock was designed specifically to help Christians overcome {term.term.toLowerCase()}
            by transforming phone usage into spiritual growth opportunities.
          </p>

          <div className="grid md:grid-cols-2 gap-6 mt-6">
            <div className="bg-white p-6 rounded-lg shadow-sm">
              <h3 className="font-bold text-blue-600 mb-3">🎯 Bible Quiz System</h3>
              <p className="text-gray-700">
                Answer Scripture questions before accessing blocked apps, replacing
                mindless scrolling with meaningful engagement with God's Word.
              </p>
            </div>

            <div className="bg-white p-6 rounded-lg shadow-sm">
              <h3 className="font-bold text-blue-600 mb-3">📅 30-Day Covenant</h3>
              <p className="text-gray-700">
                Commit to a sacred 30-day journey with accountability, progress tracking,
                and spiritual encouragement to build lasting habits.
              </p>
            </div>

            <div className="bg-white p-6 rounded-lg shadow-sm">
              <h3 className="font-bold text-blue-600 mb-3">📊 Progress Analytics</h3>
              <p className="text-gray-700">
                Track screen time reduction, verses memorized, and spiritual growth
                metrics to see measurable transformation.
              </p>
            </div>

            <div className="bg-white p-6 rounded-lg shadow-sm">
              <h3 className="font-bold text-blue-600 mb-3">🤝 Accountability Partners</h3>
              <p className="text-gray-700">
                Connect with accountability partners who encourage you and pray for
                your journey toward digital freedom.
              </p>
            </div>
          </div>

          <div className="mt-6 p-4 bg-green-50 border border-green-200 rounded-lg">
            <p className="text-green-900 font-semibold">
              ✅ <strong>Proven Results:</strong> 73% average screen time reduction in 30 days,
              with 70% of users completing their covenant commitment.
            </p>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="bg-gradient-to-r from-blue-600 to-purple-600 text-white p-12 rounded-lg text-center mb-16">
        <h2 className="text-3xl md:text-4xl font-bold mb-4">
          Ready to Overcome {term.term}?
        </h2>
        <p className="text-xl mb-8 opacity-90">
          Join 25,000+ Christians using FaithLock to replace scrolling with Scripture.
          Start your free 30-day covenant today.
        </p>
        <CTAButton
          text="Try FaithLock Free"
          href={process.env.NEXT_PUBLIC_APP_STORE_URL || '#'}
          variant="white"
          size="large"
        />
        <p className="mt-4 text-sm opacity-75">
          No credit card required • 7-day Premium trial • Cancel anytime
        </p>
      </section>

      {/* Related Terms */}
      {term.relatedTerms && term.relatedTerms.length > 0 && (
        <section>
          <h2 className="text-2xl font-bold mb-6 text-gray-900">
            Related Topics
          </h2>
          <div className="grid md:grid-cols-3 gap-4">
            {term.relatedTerms.map((relatedSlug, index) => {
              // Convert slug to display name
              const displayName = relatedSlug
                .split('-')
                .map(word => word.charAt(0).toUpperCase() + word.slice(1))
                .join(' ')

              return (
                <a
                  key={index}
                  href={`/learn/${relatedSlug}`}
                  className="p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition border border-gray-200"
                >
                  <h3 className="font-semibold text-blue-600">{displayName}</h3>
                  <p className="text-sm text-gray-600 mt-1">
                    Learn about {displayName.toLowerCase()}
                  </p>
                </a>
              )
            })}
          </div>
        </section>
      )}
    </article>
  )
}
