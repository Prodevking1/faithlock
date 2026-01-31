# CMS Configuration Guide - Contentful Setup for FaithLock pSEO

This guide provides step-by-step instructions to set up Contentful CMS for the FaithLock programmatic SEO system.

---

## Table of Contents

1. [Contentful Account Setup](#1-contentful-account-setup)
2. [Create Content Models](#2-create-content-models)
3. [Import Sample Data](#3-import-sample-data)
4. [API Keys Configuration](#4-api-keys-configuration)
5. [Next.js Integration](#5-nextjs-integration)
6. [Content Entry Workflow](#6-content-entry-workflow)
7. [Preview & Publishing](#7-preview--publishing)

---

## 1. Contentful Account Setup

### Step 1.1: Create Account
1. Go to [contentful.com](https://www.contentful.com)
2. Click **"Start building for free"**
3. Sign up with email or GitHub account
4. Choose **"Build without a framework"** option

### Step 1.2: Create Space
1. After signup, you'll be prompted to create a space
2. Space Name: **"FaithLock pSEO"**
3. Choose region: **US East** (for better performance)
4. Click **"Create space"**

### Step 1.3: Skip Quick Start
- Skip the guided tour for now
- We'll create custom content models

---

## 2. Create Content Models

You need to create **3 content models**: Competitor, GlossaryTerm, and Feature.

### 2.1: Competitor Content Model

**Navigation:** Content model → Add content type

**Content Type Settings:**
- **Name:** Competitor
- **API Identifier:** competitor
- **Description:** Competitor comparison data for /compare pages

**Fields to Add:**

| Field Name | Field ID | Type | Validations | Help Text |
|------------|----------|------|-------------|-----------|
| Name | name | Short text | Required, Unique | Competitor name (e.g., "Bible Mode") |
| Slug | slug | Short text | Required, Unique, Regex: `^[a-z0-9-]+$` | URL slug (e.g., "bible-mode") |
| Tagline | tagline | Short text | Required | Brief tagline (max 100 chars) |
| Description | description | Long text | Required | Detailed competitor description |
| Price | price | Short text | Required | Pricing info (e.g., "$4.99/month") |
| Platforms | platforms | Short text, list | Required | Platforms supported (iOS, Android) |
| Features | features | JSON object | Required | Object with feature flags |
| Pros | pros | Short text, list | Required | List of pros (3-7 items) |
| Cons | cons | Short text, list | Required | List of cons (3-7 items) |
| App Store URL | appStoreUrl | Short text | URL validation | Link to App Store |
| Website URL | websiteUrl | Short text | URL validation | Competitor website |
| Downloads | downloads | Integer | Required | Number of downloads |
| Rating | rating | Number, decimal | Required, Range: 0-5 | App Store rating |
| SEO Title | seoTitle | Short text | Required, Max 60 chars | Meta title for SEO |
| SEO Description | seoDescription | Long text | Required, Max 160 chars | Meta description |

**Features JSON Structure Example:**
```json
{
  "bibleQuiz": false,
  "physicalBibleScan": true,
  "screenTimeTracking": true,
  "appBlocking": true,
  "androidSupport": false,
  "30DayCovenant": false,
  "progressAnalytics": "Basic",
  "customScheduling": true,
  "bibleVerseLibrary": "Limited",
  "accountabilityPartner": false
}
```

### 2.2: GlossaryTerm Content Model

**Content Type Settings:**
- **Name:** GlossaryTerm
- **API Identifier:** glossaryTerm
- **Description:** Educational glossary content for /learn pages

**Fields to Add:**

| Field Name | Field ID | Type | Validations | Help Text |
|------------|----------|------|-------------|-----------|
| Term | term | Short text | Required, Unique | Term name (e.g., "Phone Addiction") |
| Slug | slug | Short text | Required, Unique, Regex: `^[a-z0-9-]+$` | URL slug (e.g., "phone-addiction") |
| Category | category | Short text | Required | Category (addiction, spiritual, tech) |
| Short Definition | shortDefinition | Long text | Required, Max 160 chars | Featured snippet optimized definition |
| Detailed Explanation | detailedExplanation | Rich text | Required | Full explanation with HTML |
| Christian Perspective | christianPerspective | Rich text | Required | Faith-based perspective |
| Bible Verses | bibleVerses | JSON object | Required | Array of {reference, text} |
| Statistics | statistics | JSON object | | Array of {stat, source} |
| Related Terms | relatedTerms | Short text, list | | Slugs of related terms |
| FAQs | faqs | JSON object | Required | Array of {question, answer} |
| SEO Title | seoTitle | Short text | Required, Max 60 chars | Meta title |
| SEO Description | seoDescription | Long text | Required, Max 160 chars | Meta description |

**Bible Verses JSON Example:**
```json
[
  {
    "reference": "Ephesians 5:15-16",
    "text": "Be very careful, then, how you live—not as unwise but as wise, making the most of every opportunity, because the days are evil."
  }
]
```

**FAQs JSON Example:**
```json
[
  {
    "question": "What are the signs of phone addiction?",
    "answer": "Key signs include: checking phone first thing in morning and last thing at night, anxiety when phone is unavailable, using phone despite knowing it interferes with priorities..."
  }
]
```

### 2.3: Feature Content Model

**Content Type Settings:**
- **Name:** Feature
- **API Identifier:** feature
- **Description:** Feature pages for /features pages targeting functional keywords

**Fields to Add:**

| Field Name | Field ID | Type | Validations | Help Text |
|------------|----------|------|-------------|-----------|
| Name | name | Short text | Required, Unique | Feature name |
| Slug | slug | Short text | Required, Unique, Regex: `^[a-z0-9-]+$` | URL slug |
| Tagline | tagline | Short text | Required | Brief tagline (max 100 chars) |
| Description | description | Rich text | Required | Feature overview with HTML |
| How It Works | howItWorks | Rich text | Required | Step-by-step explanation |
| Benefits | benefits | Short text, list | Required | List of benefits (5-10 items) |
| Use Cases | useCases | JSON object | Required | Array of {title, description} |
| Screenshots | screenshots | Short text, list | | Array of image URLs |
| Video Demo | videoDemo | Short text | URL validation | YouTube/Vimeo embed URL |
| FAQs | faqs | JSON object | Required | Array of {question, answer} |
| Bible Verses | bibleVerses | JSON object | Required | Array of {reference, text} |
| SEO Title | seoTitle | Short text | Required, Max 60 chars | Meta title |
| SEO Description | seoDescription | Long text | Required, Max 160 chars | Meta description |

**Use Cases JSON Example:**
```json
[
  {
    "title": "College Student Overcoming Social Media Addiction",
    "description": "Sarah, 21, was checking Instagram 80+ times daily. With Bible Quiz unlock, she now reads 30+ verses per day just from unlock attempts..."
  }
]
```

---

## 3. Import Sample Data

### Option A: Manual Entry (Recommended for First Entry)

1. Navigate to **Content** tab
2. Click **Add entry** → Select content type
3. Fill in all required fields
4. Use the sample data files as reference:
   - `SAMPLE_DATA_competitors.json` (5 competitors)
   - `SAMPLE_DATA_glossary.json` (3 terms)
   - `SAMPLE_DATA_features.json` (3 features)

### Option B: Bulk Import via Contentful CLI

**Prerequisites:**
```bash
npm install -g contentful-cli
contentful login
```

**Create Import Script** (`import-data.js`):
```javascript
const contentful = require('contentful-management')

const client = contentful.createClient({
  accessToken: 'YOUR_MANAGEMENT_TOKEN'
})

async function importCompetitors() {
  const space = await client.getSpace('YOUR_SPACE_ID')
  const environment = await space.getEnvironment('master')

  const competitors = require('./SAMPLE_DATA_competitors.json')

  for (const competitor of competitors) {
    const entry = await environment.createEntry('competitor', {
      fields: {
        name: { 'en-US': competitor.name },
        slug: { 'en-US': competitor.slug },
        tagline: { 'en-US': competitor.tagline },
        description: { 'en-US': competitor.description },
        price: { 'en-US': competitor.price },
        platforms: { 'en-US': competitor.platforms },
        features: { 'en-US': competitor.features },
        pros: { 'en-US': competitor.pros },
        cons: { 'en-US': competitor.cons },
        appStoreUrl: { 'en-US': competitor.appStoreUrl },
        websiteUrl: { 'en-US': competitor.websiteUrl },
        downloads: { 'en-US': competitor.downloads },
        rating: { 'en-US': competitor.rating },
        seoTitle: { 'en-US': competitor.seoTitle },
        seoDescription: { 'en-US': competitor.seoDescription }
      }
    })

    await entry.publish()
    console.log(`Imported: ${competitor.name}`)
  }
}

importCompetitors().catch(console.error)
```

**Run Import:**
```bash
node import-data.js
```

---

## 4. API Keys Configuration

### Step 4.1: Get API Keys

1. Navigate to **Settings** → **API keys**
2. Click **Add API key** → **Content Delivery API**
3. Name: **"FaithLock pSEO Production"**
4. Copy the following:
   - **Space ID**
   - **Content Delivery API - access token**
   - **Content Preview API - access token** (for preview mode)

### Step 4.2: Environment Variables

Create `.env.local` in your Next.js project:

```bash
# Contentful Configuration
CONTENTFUL_SPACE_ID=your_space_id_here
CONTENTFUL_ACCESS_TOKEN=your_delivery_token_here
CONTENTFUL_PREVIEW_ACCESS_TOKEN=your_preview_token_here

# App Configuration
NEXT_PUBLIC_APP_STORE_URL=https://apps.apple.com/us/app/faithlock/id123456789
NEXT_PUBLIC_SITE_URL=https://faithlock.com
```

**Security Notes:**
- Never commit `.env.local` to git (add to `.gitignore`)
- Use different tokens for development/staging/production
- Rotate tokens periodically

---

## 5. Next.js Integration

### Step 5.1: Install Dependencies

```bash
npm install contentful @contentful/rich-text-react-renderer
```

### Step 5.2: Create Contentful Client

Create `lib/contentful.ts`:

```typescript
import { createClient } from 'contentful'

export const client = createClient({
  space: process.env.CONTENTFUL_SPACE_ID!,
  accessToken: process.env.CONTENTFUL_ACCESS_TOKEN!,
})

// Preview client for draft content
export const previewClient = createClient({
  space: process.env.CONTENTFUL_SPACE_ID!,
  accessToken: process.env.CONTENTFUL_PREVIEW_ACCESS_TOKEN!,
  host: 'preview.contentful.com',
})

// Helper functions
export async function getAllCompetitors() {
  const response = await client.getEntries({
    content_type: 'competitor',
    order: '-fields.downloads', // Most popular first
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
    order: 'fields.name',
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

### Step 5.3: TypeScript Types

Create `lib/types.ts`:

```typescript
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
    customScheduling: boolean
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

export interface GlossaryTerm {
  term: string
  slug: string
  category: string
  shortDefinition: string
  detailedExplanation: string
  christianPerspective: string
  bibleVerses: Array<{
    reference: string
    text: string
  }>
  statistics?: Array<{
    stat: string
    source: string
  }>
  relatedTerms?: string[]
  faqs: Array<{
    question: string
    answer: string
  }>
  seoTitle: string
  seoDescription: string
}

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
  faqs: Array<{
    question: string
    answer: string
  }>
  bibleVerses: Array<{
    reference: string
    text: string
  }>
  seoTitle: string
  seoDescription: string
}
```

### Step 5.4: Test Connection

Create `scripts/test-contentful.js`:

```javascript
const { client } = require('../lib/contentful')

async function testConnection() {
  try {
    const competitors = await client.getEntries({
      content_type: 'competitor',
      limit: 1,
    })

    console.log('✅ Contentful connection successful!')
    console.log('Sample entry:', competitors.items[0]?.fields.name)
  } catch (error) {
    console.error('❌ Connection failed:', error.message)
  }
}

testConnection()
```

**Run test:**
```bash
node scripts/test-contentful.js
```

---

## 6. Content Entry Workflow

### Best Practices for Content Creation

**For Competitors:**
1. Research competitor thoroughly
2. Test their app personally if possible
3. Take accurate screenshots
4. Verify pricing and features
5. Keep SEO title under 60 characters
6. Optimize SEO description for click-through (include numbers, benefits)

**For Glossary Terms:**
1. Start with authoritative definition (APA, WHO, etc.)
2. Add Christian perspective unique to FaithLock
3. Include 2-3 relevant Bible verses
4. Find current statistics (2024-2026 only)
5. Write FAQs based on real user questions

**For Features:**
1. Focus on user benefits, not just functionality
2. Include real user testimonials (with permission)
3. Add specific metrics (73% reduction, etc.)
4. Create compelling CTAs
5. Record demo videos showing actual feature usage

### Content Quality Checklist

Before publishing any entry:
- [ ] All required fields completed
- [ ] SEO title is unique and under 60 chars
- [ ] SEO description is compelling and under 160 chars
- [ ] Slug follows URL-safe format (lowercase, hyphens)
- [ ] No grammar/spelling errors
- [ ] Links are valid and functional
- [ ] JSON fields are properly formatted
- [ ] Bible verses are accurate (verify translation)
- [ ] Statistics have credible sources cited

---

## 7. Preview & Publishing

### Step 7.1: Preview Content

1. In Contentful, edit an entry
2. Click **"Open preview"** in top right
3. Configure preview URL in **Settings → Content preview**:
   - Name: "Next.js Preview"
   - URL: `http://localhost:3000/api/preview?secret=YOUR_PREVIEW_SECRET&slug={entry.fields.slug}`

### Step 7.2: Publishing Workflow

**Draft → Review → Publish**

1. **Draft:** Content editors create/edit entries
2. **Review:** Team lead reviews for quality
3. **Publish:** Click **"Publish"** button

**Bulk Publishing:**
1. Navigate to **Content** tab
2. Select multiple entries (checkbox)
3. Click **"Publish"** in bulk actions menu

### Step 7.3: Deployment Trigger

**Option A: Automatic Revalidation (ISR)**
- Next.js will regenerate pages based on `revalidate` setting
- No manual rebuild needed

**Option B: Webhook Trigger**
1. In Contentful: **Settings → Webhooks**
2. Add webhook:
   - **Name:** "Vercel Deploy Hook"
   - **URL:** Your Vercel deploy hook URL
   - **Triggers:** Entry publish, Entry unpublish
3. Now publishing triggers automatic rebuild

---

## Troubleshooting

### Common Issues

**Issue:** "Space not found" error
- **Solution:** Verify `CONTENTFUL_SPACE_ID` is correct in `.env.local`

**Issue:** "Access token invalid" error
- **Solution:** Regenerate API keys and update environment variables

**Issue:** Empty `response.items` array
- **Solution:** Ensure content is published (not draft), check content_type name matches exactly

**Issue:** Rich text not rendering
- **Solution:** Install `@contentful/rich-text-react-renderer` and use `documentToReactComponents()`

**Issue:** Build fails with "Cannot read property 'fields' of undefined"
- **Solution:** Add null checks in templates, ensure all referenced entries exist

---

## Next Steps

1. ✅ Complete this CMS setup
2. Import all sample data (5 competitors, 3 terms, 3 features)
3. Follow the **IMPLEMENTATION_ROADMAP.md** for deployment timeline
4. Test all pages locally: `npm run dev`
5. Deploy to Vercel staging environment
6. Verify SEO with Google Search Console

---

## Support Resources

- **Contentful Documentation:** https://www.contentful.com/developers/docs/
- **Contentful Community:** https://www.contentfulcommunity.com/
- **Next.js + Contentful Guide:** https://nextjs.org/learn/basics/data-fetching/contentful

---

**Need Help?** Review the TECHNICAL_ARCHITECTURE.md for system overview or IMPLEMENTATION_ROADMAP.md for step-by-step guidance.
