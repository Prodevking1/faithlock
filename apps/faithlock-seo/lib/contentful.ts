import { createClient } from 'contentful'

if (!process.env.CONTENTFUL_SPACE_ID) {
  throw new Error('CONTENTFUL_SPACE_ID is not defined')
}

if (!process.env.CONTENTFUL_ACCESS_TOKEN) {
  throw new Error('CONTENTFUL_ACCESS_TOKEN is not defined')
}

// Delivery client (published content)
export const client = createClient({
  space: process.env.CONTENTFUL_SPACE_ID,
  accessToken: process.env.CONTENTFUL_ACCESS_TOKEN,
})

// Preview client (draft content) - optional
export const previewClient = process.env.CONTENTFUL_PREVIEW_ACCESS_TOKEN
  ? createClient({
      space: process.env.CONTENTFUL_SPACE_ID,
      accessToken: process.env.CONTENTFUL_PREVIEW_ACCESS_TOKEN,
      host: 'preview.contentful.com',
    })
  : null

// Safe query wrapper - returns empty array if content type doesn't exist yet
async function safeGetEntries(query: Record<string, unknown>) {
  try {
    const response = await client.getEntries(query)
    return response.items
  } catch {
    return []
  }
}

// ─── Competitors (Comparison Pages) ───

export async function getAllCompetitors() {
  return safeGetEntries({
    content_type: 'competitor',
    order: ['-fields.downloads'],
  })
}

export async function getCompetitorBySlug(slug: string) {
  const items = await safeGetEntries({
    content_type: 'competitor',
    'fields.slug': slug,
    limit: 1,
  })
  return items[0] || null
}

// ─── Glossary Terms (Learn Pages) ───

export async function getAllGlossaryTerms() {
  return safeGetEntries({
    content_type: 'glossaryTerm',
    order: ['fields.term'],
  })
}

export async function getGlossaryTermBySlug(slug: string) {
  const items = await safeGetEntries({
    content_type: 'glossaryTerm',
    'fields.slug': slug,
    limit: 1,
  })
  return items[0] || null
}

export async function getGlossaryTermsByCategory(category: string) {
  return safeGetEntries({
    content_type: 'glossaryTerm',
    'fields.category': category,
    order: ['fields.term'],
  })
}

// ─── Features (Feature Pages) ───

export async function getAllFeatures() {
  return safeGetEntries({
    content_type: 'feature',
    order: ['fields.name'],
  })
}

export async function getFeatureBySlug(slug: string) {
  const items = await safeGetEntries({
    content_type: 'feature',
    'fields.slug': slug,
    limit: 1,
  })
  return items[0] || null
}

// ─── Utility: Get all content for sitemap ───

export async function getAllSlugs() {
  const [competitors, glossaryTerms, features] = await Promise.all([
    getAllCompetitors(),
    getAllGlossaryTerms(),
    getAllFeatures(),
  ])

  return {
    competitors: competitors.map((c) => c.fields.slug as string),
    glossaryTerms: glossaryTerms.map((t) => t.fields.slug as string),
    features: features.map((f) => f.fields.slug as string),
  }
}
