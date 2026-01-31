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
      url: `${SITE_URL}/learn`,
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

  const comparisonPages: MetadataRoute.Sitemap = competitors.map((slug) => ({
    url: `${SITE_URL}/compare/faithlock-vs-${slug}`,
    lastModified: new Date(),
    changeFrequency: 'monthly' as const,
    priority: 0.8,
  }))

  const glossaryPages: MetadataRoute.Sitemap = glossaryTerms.map((slug) => ({
    url: `${SITE_URL}/learn/${slug}`,
    lastModified: new Date(),
    changeFrequency: 'monthly' as const,
    priority: 0.8,
  }))

  const featurePages: MetadataRoute.Sitemap = features.map((slug) => ({
    url: `${SITE_URL}/features/${slug}`,
    lastModified: new Date(),
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
