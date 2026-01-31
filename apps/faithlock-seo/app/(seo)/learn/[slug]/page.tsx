import { Metadata } from 'next'
import { notFound } from 'next/navigation'
import { getAllGlossaryTerms, getGlossaryTermBySlug } from '@/lib/contentful'
import { GlossaryTerm } from '@/lib/types'
import { SITE_URL } from '@/lib/constants'
import GlossaryTemplate from '@/components/templates/GlossaryTemplate'
import SchemaMarkup from '@/components/seo/SchemaMarkup'

export async function generateStaticParams() {
  const terms = await getAllGlossaryTerms()
  return terms.map((t) => ({ slug: t.fields.slug as string }))
}

export async function generateMetadata({
  params,
}: {
  params: { slug: string }
}): Promise<Metadata> {
  const entry = await getGlossaryTermBySlug(params.slug)

  if (!entry) {
    return { title: 'Term Not Found' }
  }

  const fields = entry.fields as unknown as GlossaryTerm

  return {
    title: fields.seoTitle,
    description: fields.seoDescription,
    openGraph: {
      title: fields.seoTitle,
      description: fields.seoDescription,
      type: 'article',
      url: `${SITE_URL}/learn/${fields.slug}`,
      images: [
        {
          url: `/og/learn-${fields.slug}.png`,
          width: 1200,
          height: 630,
          alt: `${fields.term} - Christian Perspective`,
        },
      ],
    },
    twitter: {
      card: 'summary_large_image',
      title: fields.seoTitle,
      description: fields.seoDescription,
    },
    alternates: {
      canonical: `/learn/${fields.slug}`,
    },
  }
}

export default async function LearnSlugPage({
  params,
}: {
  params: { slug: string }
}) {
  const entry = await getGlossaryTermBySlug(params.slug)

  if (!entry) {
    notFound()
  }

  const fields = entry.fields as unknown as GlossaryTerm

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
      '@id': `${SITE_URL}/learn/${fields.slug}`,
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

  const schemas = faqSchema ? [articleSchema, faqSchema] : [articleSchema]

  return (
    <>
      <SchemaMarkup data={schemas} />
      <GlossaryTemplate term={fields} />
    </>
  )
}
