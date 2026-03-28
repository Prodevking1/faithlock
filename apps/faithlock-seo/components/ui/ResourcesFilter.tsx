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
          className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${
            !activeCategory
              ? 'bg-brand-600 text-white'
              : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
          }`}
        >
          All <span className="ml-1 opacity-70">{totalCount}</span>
        </button>
        {categories.map(cat => (
          <button
            key={cat}
            onClick={() => setActiveCategory(activeCategory === cat ? null : cat)}
            className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${
              activeCategory === cat
                ? 'bg-brand-600 text-white'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
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
            className="card-interactive p-5 md:p-6 group"
          >
            <div className="flex items-center gap-2 mb-3">
              <span className={`text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full ${
                resource.category === 'Bible Verses'
                  ? 'bg-brand-100 text-brand-700'
                  : resource.category === 'Prayers'
                    ? 'bg-warm-100 text-warm-700'
                    : resource.category === 'Guides'
                      ? 'bg-sage-100 text-sage-700'
                      : resource.category === 'Devotionals'
                        ? 'bg-purple-100 text-purple-700'
                        : resource.category === 'Reviews'
                          ? 'bg-amber-100 text-amber-700'
                          : resource.category === 'Articles'
                            ? 'bg-blue-100 text-blue-700'
                            : 'bg-gray-100 text-gray-700'
              }`}>
                {resource.category}
              </span>
              <span className="text-xs text-gray-400">
                {estimateReadTime(resource.shortDefinition)} min read
              </span>
              <span className="text-xs text-gray-400">
                &middot; {formatDate(resource.updatedAt)}
              </span>
            </div>
            <h3 className="text-base font-bold text-gray-900 mb-2 group-hover:text-brand-600 transition-colors">
              {resource.term}
            </h3>
            <p className="text-sm text-gray-500 line-clamp-2 mb-3">
              {resource.shortDefinition}
            </p>
            <span className="text-sm font-medium text-brand-600">
              Read more &rarr;
            </span>
          </a>
        ))}
      </div>

      {/* Empty state */}
      {filtered.length === 0 && (
        <div className="text-center py-12">
          <p className="text-gray-500">No resources found in this category.</p>
        </div>
      )}
    </>
  )
}
