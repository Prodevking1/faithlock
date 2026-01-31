# 🏗️ TECHNICAL ARCHITECTURE - FAITHLOCK PROGRAMMATIC SEO

## Stack Technique Recommandé

### Core Stack
```yaml
Frontend/Static Site Generator: Next.js 14+ (App Router)
CMS/Data Source: Contentful (Free tier: 25K entries)
Hosting: Vercel (Free tier with custom domain)
Database: Not required (CMS handles it)
Analytics: Google Analytics 4 + Search Console
```

### Why This Stack?

**Next.js 14 App Router**:
- ✅ SSG (Static Site Generation) = ultra-fast SEO
- ✅ Built-in Image Optimization
- ✅ Automatic sitemap generation
- ✅ ISR (Incremental Static Regeneration) = update without rebuild
- ✅ Edge functions for performance

**Contentful CMS**:
- ✅ Headless CMS = full control
- ✅ GraphQL API = efficient queries
- ✅ Content modeling = structured data
- ✅ Preview mode = see before publish
- ✅ Webhooks = auto-rebuild on content change
- ✅ Free tier sufficient for Phase 1 (75 pages)

**Vercel Hosting**:
- ✅ Zero-config deployment
- ✅ Auto HTTPS + CDN global
- ✅ Preview deployments per commit
- ✅ Analytics built-in
- ✅ Free for hobby projects

---

## Project Structure

```
faithlock-seo/
├── app/
│   ├── compare/
│   │   └── [slug]/
│   │       └── page.tsx          # Dynamic comparison pages
│   ├── learn/
│   │   └── [slug]/
│   │       └── page.tsx          # Dynamic glossary pages
│   ├── features/
│   │   └── [slug]/
│   │       └── page.tsx          # Dynamic feature pages
│   ├── resources/
│   │   └── [slug]/
│   │       └── page.tsx          # Dynamic resource pages
│   ├── layout.tsx                # Global layout
│   ├── page.tsx                  # Homepage
│   └── sitemap.ts                # Auto-generated sitemap
│
├── components/
│   ├── seo/
│   │   ├── SchemaMarkup.tsx      # JSON-LD schemas
│   │   └── MetaTags.tsx          # SEO meta tags
│   ├── templates/
│   │   ├── ComparisonTemplate.tsx
│   │   ├── GlossaryTemplate.tsx
│   │   ├── FeatureTemplate.tsx
│   │   └── ResourceTemplate.tsx
│   └── ui/
│       ├── ComparisonTable.tsx
│       ├── FeatureGrid.tsx
│       └── CTAButton.tsx
│
├── lib/
│   ├── contentful.ts             # Contentful client
│   ├── seo-utils.ts              # SEO helpers
│   └── types.ts                  # TypeScript types
│
├── public/
│   ├── images/
│   │   ├── competitors/          # Competitor screenshots
│   │   ├── features/             # Feature demos
│   │   └── og/                   # Open Graph images
│   └── robots.txt
│
├── data/                         # Local data for development
│   ├── competitors.json
│   ├── glossary.json
│   └── features.json
│
├── .env.local                    # Environment variables
├── next.config.js                # Next.js configuration
├── tailwind.config.ts            # Tailwind CSS config
└── package.json
```

---

## Dependencies

### package.json

```json
{
  "name": "faithlock-seo",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "next": "^14.1.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "contentful": "^10.6.21",
    "@contentful/rich-text-react-renderer": "^15.19.0",
    "gray-matter": "^4.0.3",
    "marked": "^11.1.1",
    "date-fns": "^3.2.0"
  },
  "devDependencies": {
    "@types/node": "^20",
    "@types/react": "^18",
    "@types/react-dom": "^18",
    "typescript": "^5",
    "tailwindcss": "^3.4.0",
    "autoprefixer": "^10.4.17",
    "postcss": "^8.4.33",
    "eslint": "^8",
    "eslint-config-next": "14.1.0"
  }
}
```

---

## Environment Configuration

### .env.local (Git-ignored)

```bash
# Contentful
CONTENTFUL_SPACE_ID=your_space_id_here
CONTENTFUL_ACCESS_TOKEN=your_delivery_api_token
CONTENTFUL_PREVIEW_ACCESS_TOKEN=your_preview_api_token
CONTENTFUL_ENVIRONMENT=master

# Site
NEXT_PUBLIC_SITE_URL=https://faithlock.com
NEXT_PUBLIC_APP_STORE_URL=https://apps.apple.com/us/app/faithlock/...

# Analytics (Optional Phase 1)
NEXT_PUBLIC_GA_ID=G-XXXXXXXXXX
```

---

## Next.js Configuration

### next.config.js

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  images: {
    domains: ['images.ctfassets.net'], // Contentful images
    formats: ['image/avif', 'image/webp'],
  },

  // Generate sitemap automatically
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-DNS-Prefetch-Control',
            value: 'on'
          },
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=63072000; includeSubDomains; preload'
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff'
          },
        ],
      },
    ]
  },

  // Enable experimental features for better SEO
  experimental: {
    optimizeCss: true,
  },
}

module.exports = nextConfig
```

---

## Contentful Setup

### Content Models (à créer dans Contentful UI)

#### 1. Competitor (for Comparison pages)

```json
{
  "name": "Competitor",
  "displayField": "name",
  "fields": [
    {
      "id": "name",
      "name": "Name",
      "type": "Symbol",
      "required": true
    },
    {
      "id": "slug",
      "name": "Slug",
      "type": "Symbol",
      "required": true,
      "unique": true
    },
    {
      "id": "tagline",
      "name": "Tagline",
      "type": "Symbol"
    },
    {
      "id": "description",
      "name": "Description",
      "type": "Text",
      "required": true
    },
    {
      "id": "price",
      "name": "Price",
      "type": "Symbol"
    },
    {
      "id": "platforms",
      "name": "Platforms",
      "type": "Array",
      "items": {
        "type": "Symbol",
        "validations": [{
          "in": ["iOS", "Android"]
        }]
      }
    },
    {
      "id": "features",
      "name": "Features",
      "type": "Object"
    },
    {
      "id": "pros",
      "name": "Pros",
      "type": "Array",
      "items": {
        "type": "Symbol"
      }
    },
    {
      "id": "cons",
      "name": "Cons",
      "type": "Array",
      "items": {
        "type": "Symbol"
      }
    },
    {
      "id": "screenshots",
      "name": "Screenshots",
      "type": "Array",
      "items": {
        "type": "Link",
        "linkType": "Asset"
      }
    },
    {
      "id": "appStoreUrl",
      "name": "App Store URL",
      "type": "Symbol"
    },
    {
      "id": "websiteUrl",
      "name": "Website URL",
      "type": "Symbol"
    },
    {
      "id": "downloads",
      "name": "Estimated Downloads",
      "type": "Integer"
    },
    {
      "id": "rating",
      "name": "App Store Rating",
      "type": "Number"
    },
    {
      "id": "seoTitle",
      "name": "SEO Title",
      "type": "Symbol"
    },
    {
      "id": "seoDescription",
      "name": "SEO Description",
      "type": "Text"
    }
  ]
}
```

#### 2. GlossaryTerm (for Learn/Glossary pages)

```json
{
  "name": "GlossaryTerm",
  "displayField": "term",
  "fields": [
    {
      "id": "term",
      "name": "Term",
      "type": "Symbol",
      "required": true
    },
    {
      "id": "slug",
      "name": "Slug",
      "type": "Symbol",
      "required": true,
      "unique": true
    },
    {
      "id": "category",
      "name": "Category",
      "type": "Symbol",
      "validations": [{
        "in": ["addiction", "spiritual", "technical", "biblical"]
      }]
    },
    {
      "id": "shortDefinition",
      "name": "Short Definition (Featured Snippet)",
      "type": "Text",
      "required": true,
      "validations": [{
        "size": { "max": 160 }
      }]
    },
    {
      "id": "detailedExplanation",
      "name": "Detailed Explanation",
      "type": "RichText",
      "required": true
    },
    {
      "id": "christianPerspective",
      "name": "Christian Perspective",
      "type": "RichText"
    },
    {
      "id": "bibleVerses",
      "name": "Bible Verses",
      "type": "Array",
      "items": {
        "type": "Object"
      }
    },
    {
      "id": "statistics",
      "name": "Statistics",
      "type": "Array",
      "items": {
        "type": "Object"
      }
    },
    {
      "id": "relatedTerms",
      "name": "Related Terms",
      "type": "Array",
      "items": {
        "type": "Link",
        "linkType": "Entry"
      }
    },
    {
      "id": "faqs",
      "name": "FAQs",
      "type": "Array",
      "items": {
        "type": "Object"
      }
    },
    {
      "id": "seoTitle",
      "name": "SEO Title",
      "type": "Symbol"
    },
    {
      "id": "seoDescription",
      "name": "SEO Description",
      "type": "Text"
    }
  ]
}
```

#### 3. Feature (for Features pages)

```json
{
  "name": "Feature",
  "displayField": "name",
  "fields": [
    {
      "id": "name",
      "name": "Feature Name",
      "type": "Symbol",
      "required": true
    },
    {
      "id": "slug",
      "name": "Slug",
      "type": "Symbol",
      "required": true,
      "unique": true
    },
    {
      "id": "tagline",
      "name": "Tagline",
      "type": "Symbol"
    },
    {
      "id": "description",
      "name": "Description",
      "type": "RichText",
      "required": true
    },
    {
      "id": "howItWorks",
      "name": "How It Works",
      "type": "RichText"
    },
    {
      "id": "benefits",
      "name": "Benefits",
      "type": "Array",
      "items": {
        "type": "Symbol"
      }
    },
    {
      "id": "useCases",
      "name": "Use Cases",
      "type": "Array",
      "items": {
        "type": "Object"
      }
    },
    {
      "id": "screenshots",
      "name": "Screenshots",
      "type": "Array",
      "items": {
        "type": "Link",
        "linkType": "Asset"
      }
    },
    {
      "id": "videoDemo",
      "name": "Video Demo URL",
      "type": "Symbol"
    },
    {
      "id": "faqs",
      "name": "FAQs",
      "type": "Array",
      "items": {
        "type": "Object"
      }
    },
    {
      "id": "bibleVerses",
      "name": "Related Bible Verses",
      "type": "Array",
      "items": {
        "type": "Object"
      }
    },
    {
      "id": "seoTitle",
      "name": "SEO Title",
      "type": "Symbol"
    },
    {
      "id": "seoDescription",
      "name": "SEO Description",
      "type": "Text"
    }
  ]
}
```

---

## Contentful Client Setup

### lib/contentful.ts

```typescript
import { createClient } from 'contentful'

const client = createClient({
  space: process.env.CONTENTFUL_SPACE_ID!,
  accessToken: process.env.CONTENTFUL_ACCESS_TOKEN!,
})

const previewClient = createClient({
  space: process.env.CONTENTFUL_SPACE_ID!,
  accessToken: process.env.CONTENTFUL_PREVIEW_ACCESS_TOKEN!,
  host: 'preview.contentful.com',
})

export const getClient = (preview = false) => {
  return preview ? previewClient : client
}

// Helper functions
export async function getAllCompetitors() {
  const response = await client.getEntries({
    content_type: 'competitor',
    order: '-sys.createdAt',
  })
  return response.items
}

export async function getCompetitorBySlug(slug: string) {
  const response = await client.getEntries({
    content_type: 'competitor',
    'fields.slug': slug,
    limit: 1,
  })
  return response.items[0]
}

export async function getAllGlossaryTerms() {
  const response = await client.getEntries({
    content_type: 'glossaryTerm',
    order: 'fields.term',
  })
  return response.items
}

export async function getGlossaryTermBySlug(slug: string) {
  const response = await client.getEntries({
    content_type: 'glossaryTerm',
    'fields.slug': slug,
    limit: 1,
  })
  return response.items[0]
}

export async function getAllFeatures() {
  const response = await client.getEntries({
    content_type: 'feature',
    order: '-sys.createdAt',
  })
  return response.items
}

export async function getFeatureBySlug(slug: string) {
  const response = await client.getEntries({
    content_type: 'feature',
    'fields.slug': slug,
    limit: 1,
  })
  return response.items[0]
}
```

---

## TypeScript Types

### lib/types.ts

```typescript
export interface Competitor {
  name: string
  slug: string
  tagline: string
  description: string
  price: string
  platforms: ('iOS' | 'Android')[]
  features: {
    [key: string]: boolean | string
  }
  pros: string[]
  cons: string[]
  screenshots: any[]
  appStoreUrl: string
  websiteUrl: string
  downloads: number
  rating: number
  seoTitle: string
  seoDescription: string
}

export interface GlossaryTerm {
  term: string
  slug: string
  category: 'addiction' | 'spiritual' | 'technical' | 'biblical'
  shortDefinition: string
  detailedExplanation: any // RichText
  christianPerspective: any // RichText
  bibleVerses: {
    reference: string
    text: string
  }[]
  statistics: {
    stat: string
    source: string
  }[]
  relatedTerms: GlossaryTerm[]
  faqs: {
    question: string
    answer: string
  }[]
  seoTitle: string
  seoDescription: string
}

export interface Feature {
  name: string
  slug: string
  tagline: string
  description: any // RichText
  howItWorks: any // RichText
  benefits: string[]
  useCases: {
    title: string
    description: string
  }[]
  screenshots: any[]
  videoDemo: string
  faqs: {
    question: string
    answer: string
  }[]
  bibleVerses: {
    reference: string
    text: string
  }[]
  seoTitle: string
  seoDescription: string
}
```

---

## Deployment Workflow

### Vercel Setup

```bash
# 1. Install Vercel CLI
npm install -g vercel

# 2. Login
vercel login

# 3. Link project
vercel link

# 4. Set environment variables
vercel env add CONTENTFUL_SPACE_ID
vercel env add CONTENTFUL_ACCESS_TOKEN
vercel env add CONTENTFUL_PREVIEW_ACCESS_TOKEN

# 5. Deploy
vercel --prod
```

### Automatic Deployment

1. Push to GitHub
2. Connect GitHub repo to Vercel
3. Auto-deploy on every push to `main`
4. Contentful webhook triggers rebuild on content change

---

## Performance Targets

```yaml
Core Web Vitals:
  - LCP (Largest Contentful Paint): < 2.5s
  - FID (First Input Delay): < 100ms
  - CLS (Cumulative Layout Shift): < 0.1

Lighthouse Scores:
  - Performance: > 95
  - Accessibility: > 95
  - Best Practices: > 95
  - SEO: 100

Page Speed:
  - Initial Load: < 1.5s
  - Time to Interactive: < 2.5s
```

---

## Security Considerations

```yaml
Content Security:
  - API keys in environment variables only
  - No sensitive data in client code
  - Contentful delivery API (read-only)

HTTPS:
  - Forced HTTPS (Vercel automatic)
  - HSTS headers enabled
  - Secure cookies

Rate Limiting:
  - Contentful free tier: 55 requests/second
  - Implement caching to minimize API calls
```

---

## Alternative Stack (If Contentful not preferred)

### Option B: Airtable + Next.js

**Pros:**
- Visual spreadsheet interface (easier for non-technical)
- Free tier generous
- Simple API

**Cons:**
- Less robust than Contentful
- No content preview
- Manual image hosting

### Option C: Local JSON/Markdown + Next.js

**Pros:**
- Zero CMS cost
- Full control
- Git-based workflow

**Cons:**
- Manual content updates
- No UI for non-technical team
- Rebuild required for changes

---

## Next Steps

1. ✅ Create Next.js project
2. ✅ Setup Contentful space
3. ✅ Create content models
4. ✅ Build page templates
5. ✅ Connect to CMS
6. ✅ Deploy to Vercel

**Estimated Setup Time**: 2-3 days for technical setup, then ready for content entry.

---

**Created**: 2026-01-30
**Version**: 1.0
**Ready for Implementation** 🚀
