import { Metadata } from 'next'
import { notFound } from 'next/navigation'
import { getAllCompetitors, getCompetitorBySlug } from '@/lib/contentful'
import { Competitor } from '@/lib/types'
import { SITE_URL } from '@/lib/constants'
import ComparisonTemplate from '@/components/templates/ComparisonTemplate'
import SchemaMarkup from '@/components/seo/SchemaMarkup'

export async function generateStaticParams() {
  const competitors = await getAllCompetitors()
  return competitors.map((c) => ({
    slug: `faithlock-vs-${c.fields.slug}`,
  }))
}

export async function generateMetadata({
  params,
}: {
  params: { slug: string }
}): Promise<Metadata> {
  const competitorSlug = params.slug.replace('faithlock-vs-', '')
  const entry = await getCompetitorBySlug(competitorSlug)

  if (!entry) {
    return { title: 'Comparison Not Found' }
  }

  const fields = entry.fields as unknown as Competitor

  return {
    title: fields.seoTitle,
    description: fields.seoDescription,
    openGraph: {
      title: fields.seoTitle,
      description: fields.seoDescription,
      type: 'article',
      url: `${SITE_URL}/compare/${params.slug}`,
      images: [
        {
          url: `/og/compare-${competitorSlug}.png`,
          width: 1200,
          height: 630,
          alt: `FaithLock vs ${fields.name} Comparison`,
        },
      ],
    },
    twitter: {
      card: 'summary_large_image',
      title: fields.seoTitle,
      description: fields.seoDescription,
    },
    alternates: {
      canonical: `/compare/${params.slug}`,
    },
  }
}

export default async function ComparisonPage({
  params,
}: {
  params: { slug: string }
}) {
  const competitorSlug = params.slug.replace('faithlock-vs-', '')
  const entry = await getCompetitorBySlug(competitorSlug)

  if (!entry) {
    notFound()
  }

  const fields = entry.fields as unknown as Competitor

  const articleSchema = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: fields.seoTitle,
    description: fields.seoDescription,
    author: { '@type': 'Organization', name: 'FaithLock' },
    publisher: {
      '@type': 'Organization',
      name: 'FaithLock',
      logo: { '@type': 'ImageObject', url: `${SITE_URL}/logo.png` },
    },
    datePublished: entry.sys.createdAt,
    dateModified: entry.sys.updatedAt,
    mainEntityOfPage: {
      '@type': 'WebPage',
      '@id': `${SITE_URL}/compare/${params.slug}`,
    },
  }

  const comparisonSchema = {
    '@context': 'https://schema.org',
    '@type': 'ItemList',
    itemListElement: [
      {
        '@type': 'SoftwareApplication',
        name: 'FaithLock',
        applicationCategory: 'HealthApplication',
        operatingSystem: 'iOS',
        offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
      },
      {
        '@type': 'SoftwareApplication',
        name: fields.name,
        applicationCategory: 'HealthApplication',
        operatingSystem: fields.platforms.join(', '),
        offers: {
          '@type': 'Offer',
          price: fields.price,
          priceCurrency: 'USD',
        },
        aggregateRating: {
          '@type': 'AggregateRating',
          ratingValue: fields.rating.toString(),
          reviewCount: Math.floor(fields.downloads / 10).toString(),
        },
      },
    ],
  }

  return (
    <>
      <SchemaMarkup data={[articleSchema, comparisonSchema]} />
      <ComparisonTemplate competitor={fields} />
    </>
  )
}
