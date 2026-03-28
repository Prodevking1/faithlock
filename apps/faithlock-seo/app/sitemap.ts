import { MetadataRoute } from 'next'
import { getAllSlugs } from '@/lib/contentful'
import { SITE_URL } from '@/lib/constants'

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const { competitors, glossaryTerms, features } = await getAllSlugs()

  const staticPages: MetadataRoute.Sitemap = [
    {
      url: SITE_URL,
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 1,
    },
    {
      url: `${SITE_URL}/compare`,
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 0.9,
    },
    {
      url: `${SITE_URL}/resources`,
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 0.9,
    },
    {
      url: `${SITE_URL}/features`,
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 0.9,
    },
  ]

  const comparisonPages: MetadataRoute.Sitemap = competitors.map((entry) => ({
    url: `${SITE_URL}/compare/${entry.slug.startsWith('faithlock-vs-') ? entry.slug : `faithlock-vs-${entry.slug}`}`,
    lastModified: new Date(entry.updatedAt),
    changeFrequency: 'monthly' as const,
    priority: 0.8,
  }))

  const glossaryPages: MetadataRoute.Sitemap = glossaryTerms.map((entry) => ({
    url: `${SITE_URL}/resources/${entry.slug}`,
    lastModified: new Date(entry.updatedAt),
    changeFrequency: 'monthly' as const,
    priority: 0.8,
  }))

  const featurePages: MetadataRoute.Sitemap = features.map((entry) => ({
    url: `${SITE_URL}/features/${entry.slug}`,
    lastModified: new Date(entry.updatedAt),
    changeFrequency: 'monthly' as const,
    priority: 0.8,
  }))

  return [
    ...staticPages,
    ...comparisonPages,
    ...glossaryPages,
    ...featurePages,
  ]
}
