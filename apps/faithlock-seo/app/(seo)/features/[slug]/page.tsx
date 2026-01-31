import { Metadata } from 'next'
import { notFound } from 'next/navigation'
import { getAllFeatures, getFeatureBySlug } from '@/lib/contentful'
import { Feature } from '@/lib/types'
import { SITE_URL } from '@/lib/constants'
import FeatureTemplate from '@/components/templates/FeatureTemplate'
import SchemaMarkup from '@/components/seo/SchemaMarkup'

export async function generateStaticParams() {
  const features = await getAllFeatures()
  return features.map((f) => ({ slug: f.fields.slug as string }))
}

export async function generateMetadata({
  params,
}: {
  params: { slug: string }
}): Promise<Metadata> {
  const entry = await getFeatureBySlug(params.slug)

  if (!entry) {
    return { title: 'Feature Not Found' }
  }

  const fields = entry.fields as unknown as Feature

  return {
    title: fields.seoTitle,
    description: fields.seoDescription,
    openGraph: {
      title: fields.seoTitle,
      description: fields.seoDescription,
      type: 'article',
      url: `${SITE_URL}/features/${fields.slug}`,
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
    },
    alternates: {
      canonical: `/features/${fields.slug}`,
    },
  }
}

export default async function FeatureSlugPage({
  params,
}: {
  params: { slug: string }
}) {
  const entry = await getFeatureBySlug(params.slug)

  if (!entry) {
    notFound()
  }

  const fields = entry.fields as unknown as Feature

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
      '@id': `${SITE_URL}/features/${fields.slug}`,
    },
  }

  const faqSchema =
    fields.faqs && fields.faqs.length > 0
      ? {
          '@context': 'https://schema.org',
          '@type': 'FAQPage',
          mainEntity: fields.faqs.map((faq) => ({
            '@type': 'Question',
            name: faq.question,
            acceptedAnswer: { '@type': 'Answer', text: faq.answer },
          })),
        }
      : null

  const softwareSchema = {
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    name: 'FaithLock',
    applicationCategory: 'HealthApplication',
    operatingSystem: 'iOS',
    offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
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
