import { Metadata } from 'next'
import { getAllGlossaryTerms } from '@/lib/contentful'
import { stripMarkdown } from '@/components/ui/RichText'
import ResourcesFilter from '@/components/ui/ResourcesFilter'

export const metadata: Metadata = {
  title: 'Resources - Bible Verses, Prayers, Guides & More',
  description:
    'Bible verses, prayers, guides, and tools for Christian digital wellness. Find Scripture for every struggle, practical guides to stop scrolling, and more.',
  alternates: {
    canonical: '/resources',
  },
}

// Map Contentful categories to display categories
function getDisplayCategory(category: string, slug: string): string {
  if (slug.startsWith('bible-verses-about-')) return 'Bible Verses'
  if (slug.startsWith('prayer-for-')) return 'Prayers'
  if (slug.startsWith('how-to-block-')) return 'Guides'
  if (slug.endsWith('-addiction-christian')) return 'Guides'
  if (slug.endsWith('-review')) return 'Reviews'
  if (slug.endsWith('-statistics')) return 'Articles'
  if (slug.startsWith('screen-time-')) return 'Guides'
  if (slug.startsWith('christian-guide-to-')) return 'Guides'
  if (slug.startsWith('best-')) return 'Guides'
  if (slug.includes('-vs-')) return 'Comparisons'
  if (slug.includes('-on-') || slug.startsWith('psalms-') || slug.startsWith('jesus-') || slug.startsWith('proverbs-')) return 'Devotionals'

  // Fallback based on Contentful category
  const cat = category.toLowerCase()
  if (cat === 'scripture') return 'Bible Verses'
  if (cat === 'prayers') return 'Prayers'
  if (cat === 'reviews') return 'Reviews'
  if (cat === 'devotionals') return 'Devotionals'
  if (cat === 'research' || cat === 'statistics') return 'Articles'
  if (cat === 'comparisons') return 'Comparisons'
  return 'Guides'
}

export default async function ResourcesPage() {
  const terms = await getAllGlossaryTerms()

  const resources = terms.map((entry) => {
    const t = entry.fields as Record<string, unknown>
    const slug = t.slug as string
    const category = t.category as string
    const displayCategory = getDisplayCategory(category, slug)

    return {
      slug,
      term: t.term as string,
      shortDefinition: stripMarkdown((t.shortDefinition as string) || ''),
      category: displayCategory,
      updatedAt: entry.sys.updatedAt,
    }
  })

  // Count per category
  const categoryCounts: Record<string, number> = {}
  resources.forEach(r => {
    categoryCounts[r.category] = (categoryCounts[r.category] || 0) + 1
  })

  // Sort categories by count
  const categoryOrder = ['Bible Verses', 'Prayers', 'Guides', 'Devotionals', 'Articles', 'Reviews', 'Comparisons']
  const categories = categoryOrder.filter(c => categoryCounts[c])

  return (
    <div className="cozy-page">
      {/* Hero */}
      <div className="cozy-hero">
        <div className="container-default py-14 md:py-20">
          <nav className="cozy-breadcrumb mb-8">
            <a href="/" className="hover:text-cozy-primary">Home</a>
            <span className="cozy-breadcrumb-separator">/</span>
            <span className="text-cozy-ink/70">Resources</span>
          </nav>

          <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold mb-4 tracking-tight leading-tight text-cozy-ink">
            Resources
          </h1>
          <p className="text-lg md:text-xl text-cozy-ink-muted max-w-2xl">
            Bible verses, prayers, guides, and tools for Christian digital wellness.
          </p>
        </div>
      </div>

      <div className="container-default py-8 md:py-12">
        <ResourcesFilter
          resources={resources}
          categories={categories}
          categoryCounts={categoryCounts}
          totalCount={resources.length}
        />
      </div>
    </div>
  )
}
