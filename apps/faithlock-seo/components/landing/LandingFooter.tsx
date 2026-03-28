import { getAllContentForFooter } from '@/lib/contentful'
import { COMPANY } from '@/lib/constants'

const APP_LINK = 'https://pim.ms/kTxgKF4'

const TOP_BIBLE_VERSES = [
  'bible-verses-about-love',
  'bible-verses-about-strength',
  'bible-verses-about-encouragement',
  'bible-verses-about-anxiety',
  'bible-verses-about-healing',
  'bible-verses-about-peace',
  'bible-verses-about-forgiveness',
  'bible-verses-about-faith',
]

const TOP_PRAYERS = [
  'prayer-for-anxiety',
  'prayer-for-strength',
  'prayer-for-healing',
  'prayer-for-peace',
  'prayer-for-guidance',
  'prayer-for-protection',
  'prayer-for-forgiveness',
  'prayer-for-courage',
]

export default async function LandingFooter() {
  const content = await getAllContentForFooter()

  const bibleVerses = TOP_BIBLE_VERSES
    .map(slug => content.glossaryTerms.find(t => t.slug === slug))
    .filter(Boolean) as { slug: string; term: string; category: string }[]

  const prayers = TOP_PRAYERS
    .map(slug => content.glossaryTerms.find(t => t.slug === slug))
    .filter(Boolean) as { slug: string; term: string; category: string }[]

  const topComparisons = content.competitors.slice(0, 8)

  return (
    <footer className="border-t border-white/5">
      {/* ─── Top: Brand + Meta ─── */}
      <div className="max-w-6xl mx-auto px-6 py-14">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-10 md:gap-8">
          {/* Brand */}
          <div>
            <div className="flex items-center gap-2 mb-4">
              <div className="w-7 h-7 bg-gradient-to-tr from-indigo-50 to-indigo-100 text-indigo-950 rounded-lg flex items-center justify-center">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                  <polyline points="9 12 11 14 15 10" />
                </svg>
              </div>
              <span className="text-white font-medium text-sm">FaithLock</span>
            </div>
            <p className="text-xs text-slate-500 leading-relaxed mb-5">
              Stop scrolling. Start Scripture. Turn phone addiction into daily devotion.
            </p>
            <a
              href={APP_LINK}
              className="inline-flex items-center gap-2 bg-white text-slate-950 px-4 py-2 rounded-full font-semibold text-xs hover:bg-indigo-50 transition-all"
              target="_blank"
              rel="noopener noreferrer"
            >
              <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
              </svg>
              Download on App Store
            </a>
            <p className="mt-2 text-[10px] text-slate-600">Free &middot; iOS 16+</p>
            <p className="mt-5 text-[10px] text-slate-700">
              &copy; {new Date().getFullYear()} {COMPANY.name}
            </p>
          </div>

          {/* Product */}
          <div>
            <h4 className="text-white text-xs font-semibold mb-4">Product</h4>
            <ul className="space-y-2.5 text-xs">
              <li><a href="/resources" className="text-slate-500 hover:text-white transition-colors">Resources</a></li>
              <li><a href="/compare" className="text-slate-500 hover:text-white transition-colors">Comparisons</a></li>
              <li><a href="/features" className="text-slate-500 hover:text-white transition-colors">Features</a></li>
              <li><a href={`mailto:${COMPANY.email}`} className="text-slate-500 hover:text-white transition-colors">Contact</a></li>
            </ul>
          </div>

          {/* Company */}
          <div>
            <h4 className="text-white text-xs font-semibold mb-4">Company</h4>
            <ul className="space-y-2.5 text-xs">
              <li><a href={COMPANY.privacyUrl} className="text-slate-500 hover:text-white transition-colors">Privacy Policy</a></li>
              <li><a href={COMPANY.termsUrl} className="text-slate-500 hover:text-white transition-colors">Terms of Use</a></li>
              <li><a href={`mailto:${COMPANY.email}`} className="text-slate-500 hover:text-white transition-colors">Support</a></li>
            </ul>
          </div>

          {/* Connect */}
          <div>
            <h4 className="text-white text-xs font-semibold mb-4">Connect</h4>
            <ul className="space-y-2.5 text-xs">
              <li>
                <a href={`mailto:${COMPANY.email}`} className="text-indigo-400 hover:text-indigo-300 transition-colors">
                  {COMPANY.email}
                </a>
              </li>
            </ul>
          </div>
        </div>
      </div>

      {/* ─── Bottom: Top content by category ─── */}
      <div className="border-t border-white/5">
        <div className="max-w-6xl mx-auto px-6 py-12">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-10 md:gap-8">
            {/* Bible Verses */}
            <div>
              <h4 className="text-white text-xs font-semibold mb-4">Bible Verses</h4>
              <ul className="space-y-2 text-xs">
                {bibleVerses.map((item) => (
                  <li key={item.slug}>
                    <a href={`/resources/${item.slug}`} className="text-slate-500 hover:text-white transition-colors leading-snug block">
                      {item.term}
                    </a>
                  </li>
                ))}
                <li>
                  <a href="/resources" className="text-indigo-400 hover:text-indigo-300 transition-colors font-medium">
                    View more &rarr;
                  </a>
                </li>
              </ul>
            </div>

            {/* Prayers */}
            <div>
              <h4 className="text-white text-xs font-semibold mb-4">Prayers</h4>
              <ul className="space-y-2 text-xs">
                {prayers.map((item) => (
                  <li key={item.slug}>
                    <a href={`/resources/${item.slug}`} className="text-slate-500 hover:text-white transition-colors leading-snug block">
                      {item.term}
                    </a>
                  </li>
                ))}
                <li>
                  <a href="/resources" className="text-indigo-400 hover:text-indigo-300 transition-colors font-medium">
                    View more &rarr;
                  </a>
                </li>
              </ul>
            </div>

            {/* Comparisons */}
            <div>
              <h4 className="text-white text-xs font-semibold mb-4">Comparisons</h4>
              <ul className="space-y-2 text-xs">
                {topComparisons.map((comp) => (
                  <li key={comp.slug}>
                    <a href={`/compare/${comp.slug}`} className="text-slate-500 hover:text-white transition-colors leading-snug block">
                      FaithLock vs {comp.name}
                    </a>
                  </li>
                ))}
                <li>
                  <a href="/compare" className="text-indigo-400 hover:text-indigo-300 transition-colors font-medium">
                    View more &rarr;
                  </a>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </footer>
  )
}
