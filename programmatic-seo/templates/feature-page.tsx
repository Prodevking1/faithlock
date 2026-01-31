// app/features/[slug]/page.tsx
import { Metadata } from 'next'
import { notFound } from 'next/navigation'
import { getAllFeatures, getFeatureBySlug } from '@/lib/contentful'
import { Feature } from '@/lib/types'
import FeatureTemplate from '@/components/templates/FeatureTemplate'
import SchemaMarkup from '@/components/seo/SchemaMarkup'

// Generate static params for all features
export async function generateStaticParams() {
  const features = await getAllFeatures()

  return features.map((feature) => ({
    slug: feature.fields.slug,
  }))
}

// Generate metadata for SEO
export async function generateMetadata({
  params
}: {
  params: { slug: string }
}): Promise<Metadata> {
  const feature = await getFeatureBySlug(params.slug)

  if (!feature) {
    return {
      title: 'Feature Not Found',
    }
  }

  const fields = feature.fields

  return {
    title: fields.seoTitle,
    description: fields.seoDescription,
    openGraph: {
      title: fields.seoTitle,
      description: fields.seoDescription,
      type: 'article',
      url: `https://faithlock.com/features/${fields.slug}`,
      images: [
        {
          url: `/og/feature-${fields.slug}.png`,
          width: 1200,
          height: 630,
          alt: `${fields.name} - FaithLock Feature`,
        },
      ],
    },
    twitter: {
      card: 'summary_large_image',
      title: fields.seoTitle,
      description: fields.seoDescription,
      images: [`/og/feature-${fields.slug}.png`],
    },
    alternates: {
      canonical: `https://faithlock.com/features/${fields.slug}`,
    },
  }
}

export default async function FeaturePage({
  params
}: {
  params: { slug: string }
}) {
  const feature = await getFeatureBySlug(params.slug)

  if (!feature) {
    notFound()
  }

  const fields = feature.fields as Feature

  // Article schema markup
  const articleSchema = {
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
    datePublished: feature.sys.createdAt,
    dateModified: feature.sys.updatedAt,
    mainEntityOfPage: {
      '@type': 'WebPage',
      '@id': `https://faithlock.com/features/${fields.slug}`,
    },
  }

  // FAQ schema markup
  const faqSchema = fields.faqs && fields.faqs.length > 0 ? {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: fields.faqs.map((faq) => ({
      '@type': 'Question',
      name: faq.question,
      acceptedAnswer: {
        '@type': 'Answer',
        text: faq.answer,
      },
    })),
  } : null

  // SoftwareApplication schema for the feature
  const softwareSchema = {
    '@context': 'https://schema.org',
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
    featureList: fields.name,
  }

  const schemas = faqSchema
    ? [articleSchema, faqSchema, softwareSchema]
    : [articleSchema, softwareSchema]

  return (
    <>
      <SchemaMarkup data={schemas} />
      <FeatureTemplate feature={fields} />
    </>
  )
}
