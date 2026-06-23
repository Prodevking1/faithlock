'use client'

import { useState } from 'react'

interface Resource {
  slug: string
  term: string
  shortDefinition: string
  category: string
  updatedAt: string
}

interface ResourcesFilterProps {
  resources: Resource[]
  categories: string[]
  categoryCounts: Record<string, number>
  totalCount: number
}

function formatDate(dateString: string): string {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

function estimateReadTime(text: string): number {
  const words = text.split(/\s+/).length
  return Math.max(1, Math.ceil(words / 200))
}

export default function ResourcesFilter({
  resources,
  categories,
  categoryCounts,
  totalCount,
}: ResourcesFilterProps) {
  const [activeCategory, setActiveCategory] = useState<string | null>(null)

  const filtered = activeCategory
    ? resources.filter(r => r.category === activeCategory)
    : resources

  return (
    <>
      {/* Filter tabs */}
      <div className="flex flex-wrap gap-2 mb-8">
        <button
          onClick={() => setActiveCategory(null)}
          className={`px-4 py-2 rounded-cozy-sm text-sm font-bold border-2 border-cozy-ink transition-colors ${
            !activeCategory
              ? 'bg-cozy-primary text-cozy-ink shadow-cozy-hard-sm'
              : 'bg-cozy-surface text-cozy-ink/85 hover:bg-cozy-surface-muted'
          }`}
        >
          All <span className="ml-1 opacity-70">{totalCount}</span>
        </button>
        {categories.map(cat => (
          <button
            key={cat}
            onClick={() => setActiveCategory(activeCategory === cat ? null : cat)}
            className={`px-4 py-2 rounded-cozy-sm text-sm font-bold border-2 border-cozy-ink transition-colors ${
              activeCategory === cat
                ? 'bg-cozy-primary text-cozy-ink shadow-cozy-hard-sm'
                : 'bg-cozy-surface text-cozy-ink/85 hover:bg-cozy-surface-muted'
            }`}
          >
            {cat} <span className="ml-1 opacity-70">{categoryCounts[cat]}</span>
          </button>
        ))}
      </div>

      {/* Results grid */}
      <div className="grid sm:grid-cols-2 gap-4">
        {filtered.map((resource) => (
          <a
            key={resource.slug}
            href={`/resources/${resource.slug}`}
            className="cozy-card-interactive p-5 md:p-6 group"
          >
            <div className="flex items-center gap-2 mb-3">
              <span className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-cozy-sm border-2 border-cozy-ink ${
                resource.category === 'Bible Verses'
                  ? 'bg-cozy-peach text-cozy-ink'
                  : resource.category === 'Prayers'
                    ? 'bg-cozy-primary-light text-cozy-ink'
                    : resource.category === 'Guides'
                      ? 'bg-cozy-sage text-cozy-ink'
                      : resource.category === 'Devotionals'
                        ? 'bg-cozy-gold text-cozy-ink'
                        : resource.category === 'Reviews'
                          ? 'bg-cozy-beige text-cozy-ink'
                          : resource.category === 'Articles'
                            ? 'bg-cozy-surface-muted text-cozy-ink'
                            : 'bg-cozy-surface-muted text-cozy-ink'
              }`}>
                {resource.category}
              </span>
              <span className="text-xs text-cozy-ink-muted">
                {estimateReadTime(resource.shortDefinition)} min read
              </span>
              <span className="text-xs text-cozy-ink-muted">
                &middot; {formatDate(resource.updatedAt)}
              </span>
            </div>
            <h3 className="text-base font-bold text-cozy-ink mb-2 group-hover:text-cozy-primary transition-colors">
              {resource.term}
            </h3>
            <p className="text-sm text-cozy-ink/85 line-clamp-2 mb-3">
              {resource.shortDefinition}
            </p>
            <span className="text-sm font-bold text-cozy-primary">
              Read more &rarr;
            </span>
          </a>
        ))}
      </div>

      {/* Empty state */}
      {filtered.length === 0 && (
        <div className="text-center py-12">
          <p className="text-cozy-ink-muted">No resources found in this category.</p>
        </div>
      )}
    </>
  )
}
