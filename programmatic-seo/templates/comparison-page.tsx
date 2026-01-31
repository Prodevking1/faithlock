// app/compare/[slug]/page.tsx
import { Metadata } from 'next'
import { notFound } from 'next/navigation'
import { getAllCompetitors, getCompetitorBySlug } from '@/lib/contentful'
import { Competitor } from '@/lib/types'
import ComparisonTemplate from '@/components/templates/ComparisonTemplate'
import SchemaMarkup from '@/components/seo/SchemaMarkup'

// Generate static params for all competitors
export async function generateStaticParams() {
  const competitors = await getAllCompetitors()

  return competitors.map((competitor) => ({
    slug: competitor.fields.slug,
  }))
}

// Generate metadata for SEO
export async function generateMetadata({
  params
}: {
  params: { slug: string }
}): Promise<Metadata> {
  const competitor = await getCompetitorBySlug(params.slug)

  if (!competitor) {
    return {
      title: 'Comparison Not Found',
    }
  }

  const fields = competitor.fields

  return {
    title: fields.seoTitle,
    description: fields.seoDescription,
    openGraph: {
      title: fields.seoTitle,
      description: fields.seoDescription,
      type: 'article',
      url: `https://faithlock.com/compare/${fields.slug}`,
      images: [
        {
          url: `/og/compare-${fields.slug}.png`,
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
      images: [`/og/compare-${fields.slug}.png`],
    },
    alternates: {
      canonical: `https://faithlock.com/compare/${fields.slug}`,
    },
  }
}

export default async function ComparisonPage({
  params
}: {
  params: { slug: string }
}) {
  const competitor = await getCompetitorBySlug(params.slug)

  if (!competitor) {
    notFound()
  }

  const fields = competitor.fields as Competitor

  // Schema markup for rich snippets
  const schemaData = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: fields.seoTitle,
    description: fields.seoDescription,
    author: {
      '@type': 'Organization',
      name: 'FaithLock',
    },
    publisher: {
      '@type': 'Organization',
      name: 'FaithLock',
      logo: {
        '@type': 'ImageObject',
        url: 'https://faithlock.com/logo.png',
      },
    },
    datePublished: competitor.sys.createdAt,
    dateModified: competitor.sys.updatedAt,
    mainEntityOfPage: {
      '@type': 'WebPage',
      '@id': `https://faithlock.com/compare/${fields.slug}`,
    },
  }

  // Comparison table schema
  const comparisonSchema = {
    '@context': 'https://schema.org',
    '@type': 'ItemList',
    itemListElement: [
      {
        '@type': 'SoftwareApplication',
        name: 'FaithLock',
        applicationCategory: 'HealthApplication',
        operatingSystem: 'iOS',
        offers: {
          '@type': 'Offer',
          price: '0',
          priceCurrency: 'USD',
        },
        aggregateRating: {
          '@type': 'AggregateRating',
          ratingValue: '4.8',
          reviewCount: '1200',
        },
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
      <SchemaMarkup data={[schemaData, comparisonSchema]} />
      <ComparisonTemplate competitor={fields} />
    </>
  )
}
