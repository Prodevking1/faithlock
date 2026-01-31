// components/templates/FeatureTemplate.tsx
import { Feature } from '@/lib/types'
import BibleVerse from '@/components/ui/BibleVerse'
import CTAButton from '@/components/ui/CTAButton'

interface FeatureTemplateProps {
  feature: Feature
}

export default function FeatureTemplate({ feature }: FeatureTemplateProps) {
  return (
    <article className="max-w-4xl mx-auto px-4 py-12">
      {/* Breadcrumbs */}
      <nav className="mb-6 text-sm text-gray-600">
        <a href="/" className="hover:text-blue-600">Home</a>
        <span className="mx-2">/</span>
        <a href="/features" className="hover:text-blue-600">Features</a>
        <span className="mx-2">/</span>
        <span>{feature.name}</span>
      </nav>

      {/* Hero Section */}
      <header className="mb-12">
        <h1 className="text-4xl md:text-5xl font-bold mb-4 text-gray-900">
          {feature.name}
        </h1>
        <p className="text-2xl text-blue-600 font-semibold mb-6">
          {feature.tagline}
        </p>

        {/* Overview */}
        <div
          className="prose prose-lg max-w-none text-gray-700"
          dangerouslySetInnerHTML={{ __html: feature.description }}
        />
      </header>

      {/* How It Works Section */}
      <section className="mb-16 bg-blue-50 p-8 rounded-lg">
        <h2 className="text-3xl font-bold mb-6 text-blue-900">
          ⚙️ How It Works
        </h2>
        <div
          className="prose prose-lg max-w-none text-gray-800"
          dangerouslySetInnerHTML={{ __html: feature.howItWorks }}
        />
      </section>

      {/* Benefits Section */}
      <section className="mb-16">
        <h2 className="text-3xl font-bold mb-6 text-gray-900">
          ✨ Key Benefits
        </h2>
        <div className="grid md:grid-cols-2 gap-4">
          {feature.benefits.map((benefit, index) => (
            <div
              key={index}
              className="flex items-start space-x-3 p-4 bg-green-50 rounded-lg border border-green-200"
            >
              <span className="text-green-600 text-xl flex-shrink-0">✓</span>
              <p className="text-gray-800 font-medium">{benefit}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Real User Stories / Use Cases */}
      {feature.useCases && feature.useCases.length > 0 && (
        <section className="mb-16">
          <h2 className="text-3xl font-bold mb-6 text-gray-900">
            📖 Real User Stories
          </h2>
          <div className="space-y-6">
            {feature.useCases.map((useCase, index) => (
              <div
                key={index}
                className="bg-white p-6 rounded-lg shadow-md border-l-4 border-purple-500"
              >
                <h3 className="text-xl font-bold text-purple-900 mb-3">
                  {useCase.title}
                </h3>
                <p className="text-gray-700 leading-relaxed italic">
                  "{useCase.description}"
                </p>
              </div>
            ))}
          </div>
        </section>
      )}

      {/* Video Demo Section */}
      {feature.videoDemo && (
        <section className="mb-16">
          <h2 className="text-3xl font-bold mb-6 text-gray-900">
            🎥 See It In Action
          </h2>
          <div className="aspect-video rounded-lg overflow-hidden shadow-lg">
            <iframe
              src={feature.videoDemo}
              className="w-full h-full"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowFullScreen
            />
          </div>
        </section>
      )}

      {/* Screenshots Section */}
      {feature.screenshots && feature.screenshots.length > 0 && (
        <section className="mb-16">
          <h2 className="text-3xl font-bold mb-6 text-gray-900">
            📱 Screenshots
          </h2>
          <div className="grid md:grid-cols-3 gap-6">
            {feature.screenshots.map((screenshot, index) => (
              <div key={index} className="rounded-lg overflow-hidden shadow-md">
                <img
                  src={screenshot}
                  alt={`${feature.name} screenshot ${index + 1}`}
                  className="w-full h-auto"
                />
              </div>
            ))}
          </div>
        </section>
      )}

      {/* Biblical Foundation */}
      {feature.bibleVerses && feature.bibleVerses.length > 0 && (
        <section className="mb-16 bg-purple-50 p-8 rounded-lg">
          <h2 className="text-3xl font-bold mb-6 text-purple-900">
            ✝️ Biblical Foundation
          </h2>
          <p className="text-lg text-gray-800 mb-6">
            This feature is rooted in Scripture and designed to help you live out
            biblical principles in your digital life.
          </p>
          <div className="space-y-6">
            {feature.bibleVerses.map((verse, index) => (
              <BibleVerse
                key={index}
                reference={verse.reference}
                text={verse.text}
              />
            ))}
          </div>
        </section>
      )}

      {/* FAQ Section */}
      {feature.faqs && feature.faqs.length > 0 && (
        <section className="mb-16">
          <h2 className="text-3xl font-bold mb-6 text-gray-900">
            ❓ Frequently Asked Questions
          </h2>
          <div className="space-y-4">
            {feature.faqs.map((faq, index) => (
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

      {/* Social Proof Section */}
      <section className="mb-16 bg-gradient-to-br from-green-50 to-blue-50 p-8 rounded-lg border border-green-200">
        <h2 className="text-3xl font-bold mb-6 text-gray-900">
          📊 Proven Results
        </h2>
        <div className="grid md:grid-cols-3 gap-6">
          <div className="text-center">
            <p className="text-5xl font-bold text-blue-600 mb-2">73%</p>
            <p className="text-gray-700 font-medium">Average screen time reduction</p>
          </div>
          <div className="text-center">
            <p className="text-5xl font-bold text-purple-600 mb-2">25K+</p>
            <p className="text-gray-700 font-medium">Christians using FaithLock</p>
          </div>
          <div className="text-center">
            <p className="text-5xl font-bold text-green-600 mb-2">4.8★</p>
            <p className="text-gray-700 font-medium">App Store rating</p>
          </div>
        </div>

        <div className="mt-8 p-6 bg-white rounded-lg shadow-sm">
          <p className="text-center text-gray-800 text-lg">
            <strong>70% of users</strong> complete their 30-day covenant, far exceeding
            the <strong>12% average</strong> for generic screen time challenges.
          </p>
        </div>
      </section>

      {/* CTA Section */}
      <section className="bg-gradient-to-r from-blue-600 to-purple-600 text-white p-12 rounded-lg text-center mb-16">
        <h2 className="text-3xl md:text-4xl font-bold mb-4">
          Experience {feature.name} Today
        </h2>
        <p className="text-xl mb-8 opacity-90">
          Join thousands of Christians transforming phone addiction into spiritual growth.
          Start your free 30-day covenant now.
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

      {/* Related Features */}
      <section>
        <h2 className="text-2xl font-bold mb-6 text-gray-900">
          Other Powerful Features
        </h2>
        <div className="grid md:grid-cols-3 gap-4">
          <a
            href="/features/bible-quiz-unlock-phone"
            className="p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition border border-gray-200"
          >
            <h3 className="font-semibold text-blue-600">Bible Quiz to Unlock</h3>
            <p className="text-sm text-gray-600 mt-1">
              Answer Scripture correctly before accessing apps
            </p>
          </a>
          <a
            href="/features/30-day-covenant-tracking"
            className="p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition border border-gray-200"
          >
            <h3 className="font-semibold text-blue-600">30-Day Covenant</h3>
            <p className="text-sm text-gray-600 mt-1">
              Sacred commitment with measurable accountability
            </p>
          </a>
          <a
            href="/features"
            className="p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition border border-gray-200"
          >
            <h3 className="font-semibold text-blue-600">All Features</h3>
            <p className="text-sm text-gray-600 mt-1">
              Explore everything FaithLock offers
            </p>
          </a>
        </div>
      </section>
    </article>
  )
}
