// Shared types for all content models

export interface BibleVerseData {
  reference: string
  text: string
}

export interface FAQ {
  question: string
  answer: string
}

export interface Statistic {
  stat: string
  source: string
}

// Competitor content model (for /compare pages)
export interface Competitor {
  name: string
  slug: string
  tagline: string
  description: string
  price: string
  platforms: string[]
  features: {
    bibleQuiz: boolean
    physicalBibleScan: boolean
    screenTimeTracking: boolean | string
    appBlocking: boolean | string
    androidSupport: boolean
    '30DayCovenant': boolean
    progressAnalytics: string
    customScheduling: boolean | string
    bibleVerseLibrary: string
    accountabilityPartner: boolean
  }
  pros: string[]
  cons: string[]
  appStoreUrl: string
  websiteUrl: string
  downloads: number
  rating: number
  seoTitle: string
  seoDescription: string
}

// GlossaryTerm content model (for /learn pages)
export interface GlossaryTerm {
  term: string
  slug: string
  category: string
  shortDefinition: string
  detailedExplanation: string
  christianPerspective: string
  bibleVerses: BibleVerseData[]
  statistics?: Statistic[]
  relatedTerms?: string[]
  faqs: FAQ[]
  seoTitle: string
  seoDescription: string
}

// Feature content model (for /features pages)
export interface Feature {
  name: string
  slug: string
  tagline: string
  description: string
  howItWorks: string
  benefits: string[]
  useCases: Array<{
    title: string
    description: string
  }>
  screenshots?: string[]
  videoDemo?: string
  faqs: FAQ[]
  bibleVerses: BibleVerseData[]
  seoTitle: string
  seoDescription: string
}

// Contentful entry wrapper
export interface ContentfulEntry<T> {
  sys: {
    id: string
    createdAt: string
    updatedAt: string
  }
  fields: T
}
