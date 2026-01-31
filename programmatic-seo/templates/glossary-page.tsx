// app/learn/[slug]/page.tsx
import { Metadata } from 'next'
import { notFound } from 'next/navigation'
import { getAllGlossaryTerms, getGlossaryTermBySlug } from '@/lib/contentful'
import { GlossaryTerm } from '@/lib/types'
import GlossaryTemplate from '@/components/templates/GlossaryTemplate'
import SchemaMarkup from '@/components/seo/SchemaMarkup'

// Generate static params for all glossary terms
export async function generateStaticParams() {
  const terms = await getAllGlossaryTerms()

  return terms.map((term) => ({
    slug: term.fields.slug,
  }))
}

// Generate metadata for SEO
export async function generateMetadata({
  params
}: {
  params: { slug: string }
}): Promise<Metadata> {
  const term = await getGlossaryTermBySlug(params.slug)

  if (!term) {
    return {
      title: 'Term Not Found',
    }
  }

  const fields = term.fields

  return {
    title: fields.seoTitle,
    description: fields.seoDescription,
    openGraph: {
      title: fields.seoTitle,
      description: fields.seoDescription,
      type: 'article',
      url: `https://faithlock.com/learn/${fields.slug}`,
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
      images: [`/og/learn-${fields.slug}.png`],
    },
    alternates: {
      canonical: `https://faithlock.com/learn/${fields.slug}`,
    },
  }
}

export default async function GlossaryPage({
  params
}: {
  params: { slug: string }
}) {
  const term = await getGlossaryTermBySlug(params.slug)

  if (!term) {
    notFound()
  }

  const fields = term.fields as GlossaryTerm

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
    datePublished: term.sys.createdAt,
    dateModified: term.sys.updatedAt,
    mainEntityOfPage: {
      '@type': 'WebPage',
      '@id': `https://faithlock.com/learn/${fields.slug}`,
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

  const schemas = faqSchema ? [articleSchema, faqSchema] : [articleSchema]

  return (
    <>
      <SchemaMarkup data={schemas} />
      <GlossaryTemplate term={fields} />
    </>
  )
}
