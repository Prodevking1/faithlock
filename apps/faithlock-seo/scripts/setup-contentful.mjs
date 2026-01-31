#!/usr/bin/env node

/**
 * Contentful Setup Script
 * Creates 3 content models + inserts 11 sample entries
 *
 * Usage: CONTENTFUL_MANAGEMENT_TOKEN=xxx node scripts/setup-contentful.mjs
 */

import contentful from 'contentful-management'
import { readFileSync } from 'fs'
import { resolve, dirname } from 'path'
import { fileURLToPath } from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))

// ─── Config ───
const SPACE_ID = process.env.CONTENTFUL_SPACE_ID || 'dhjf84rpcqxo'
const CMA_TOKEN = process.env.CONTENTFUL_MANAGEMENT_TOKEN

if (!CMA_TOKEN) {
  console.error('\n❌ CONTENTFUL_MANAGEMENT_TOKEN is required!')
  console.error('\nTo get it:')
  console.error('  1. Go to https://app.contentful.com')
  console.error('  2. Settings → CMA tokens')
  console.error('  3. Generate personal token')
  console.error('\nThen run:')
  console.error('  CONTENTFUL_MANAGEMENT_TOKEN=xxx node scripts/setup-contentful.mjs\n')
  process.exit(1)
}

const client = contentful.createClient({ accessToken: CMA_TOKEN })

// ─── Content Type Definitions ───

const COMPETITOR_FIELDS = [
  { id: 'name', name: 'Name', type: 'Symbol', required: true },
  { id: 'slug', name: 'Slug', type: 'Symbol', required: true, unique: true },
  { id: 'tagline', name: 'Tagline', type: 'Symbol', required: true },
  { id: 'description', name: 'Description', type: 'Text', required: true },
  { id: 'price', name: 'Price', type: 'Symbol', required: true },
  { id: 'platforms', name: 'Platforms', type: 'Array', itemType: 'Symbol' },
  { id: 'features', name: 'Features', type: 'Object' },
  { id: 'pros', name: 'Pros', type: 'Array', itemType: 'Symbol' },
  { id: 'cons', name: 'Cons', type: 'Array', itemType: 'Symbol' },
  { id: 'appStoreUrl', name: 'App Store URL', type: 'Symbol' },
  { id: 'websiteUrl', name: 'Website URL', type: 'Symbol' },
  { id: 'downloads', name: 'Downloads', type: 'Integer' },
  { id: 'rating', name: 'Rating', type: 'Number' },
  { id: 'seoTitle', name: 'SEO Title', type: 'Symbol', required: true },
  { id: 'seoDescription', name: 'SEO Description', type: 'Text', required: true },
]

const GLOSSARY_FIELDS = [
  { id: 'term', name: 'Term', type: 'Symbol', required: true },
  { id: 'slug', name: 'Slug', type: 'Symbol', required: true, unique: true },
  { id: 'category', name: 'Category', type: 'Symbol', required: true },
  { id: 'shortDefinition', name: 'Short Definition', type: 'Text', required: true },
  { id: 'detailedExplanation', name: 'Detailed Explanation', type: 'Text' },
  { id: 'christianPerspective', name: 'Christian Perspective', type: 'Text' },
  { id: 'bibleVerses', name: 'Bible Verses', type: 'Object' },
  { id: 'statistics', name: 'Statistics', type: 'Object' },
  { id: 'relatedTerms', name: 'Related Terms', type: 'Array', itemType: 'Symbol' },
  { id: 'faqs', name: 'FAQs', type: 'Object' },
  { id: 'seoTitle', name: 'SEO Title', type: 'Symbol', required: true },
  { id: 'seoDescription', name: 'SEO Description', type: 'Text', required: true },
]

const FEATURE_FIELDS = [
  { id: 'name', name: 'Name', type: 'Symbol', required: true },
  { id: 'slug', name: 'Slug', type: 'Symbol', required: true, unique: true },
  { id: 'tagline', name: 'Tagline', type: 'Symbol', required: true },
  { id: 'description', name: 'Description', type: 'Text', required: true },
  { id: 'howItWorks', name: 'How It Works', type: 'Text' },
  { id: 'benefits', name: 'Benefits', type: 'Array', itemType: 'Symbol' },
  { id: 'useCases', name: 'Use Cases', type: 'Object' },
  { id: 'screenshots', name: 'Screenshots', type: 'Array', itemType: 'Symbol' },
  { id: 'videoDemo', name: 'Video Demo URL', type: 'Symbol' },
  { id: 'faqs', name: 'FAQs', type: 'Object' },
  { id: 'bibleVerses', name: 'Bible Verses', type: 'Object' },
  { id: 'seoTitle', name: 'SEO Title', type: 'Symbol', required: true },
  { id: 'seoDescription', name: 'SEO Description', type: 'Text', required: true },
]

// ─── Helpers ───

function buildContentfulFields(fieldDefs) {
  return fieldDefs.map((f) => {
    const field = {
      id: f.id,
      name: f.name,
      type: f.type,
      required: f.required || false,
      localized: false,
    }

    if (f.type === 'Array') {
      field.items = { type: f.itemType || 'Symbol' }
    }

    if (f.unique) {
      field.validations = [{ unique: true }]
    }

    return field
  })
}

async function createOrUpdateContentType(environment, id, name, description, fieldDefs) {
  const fields = buildContentfulFields(fieldDefs)

  try {
    // Check if already exists
    const existing = await environment.getContentType(id)
    console.log(`  ✅ Content type "${id}" already exists, skipping`)
    return existing
  } catch (err) {
    if (err.sys?.id === 'NotFound') {
      console.log(`  📝 Creating content type "${id}"...`)
      const contentType = await environment.createContentTypeWithId(id, {
        name,
        description,
        displayField: fields[0].id,
        fields,
      })
      await contentType.publish()
      console.log(`  ✅ Created & published "${id}"`)
      return contentType
    }
    throw err
  }
}

function toRichText(text) {
  return {
    nodeType: 'document',
    data: {},
    content: [
      {
        nodeType: 'paragraph',
        data: {},
        content: [
          { nodeType: 'text', data: {}, marks: [], value: String(text) },
        ],
      },
    ],
  }
}

// Cache content type field info
const fieldTypeCache = {}

async function getFieldTypes(environment, contentTypeId) {
  if (fieldTypeCache[contentTypeId]) return fieldTypeCache[contentTypeId]
  try {
    const ct = await environment.getContentType(contentTypeId)
    const typeMap = {}
    for (const f of ct.fields) {
      typeMap[f.id] = f.type
    }
    fieldTypeCache[contentTypeId] = typeMap
    return typeMap
  } catch {
    return {}
  }
}

function coerceValue(value, expectedType) {
  if (!expectedType) return value

  if (expectedType === 'RichText' && typeof value === 'string') {
    return toRichText(value)
  }

  if (expectedType === 'Text' && Array.isArray(value)) {
    return value.join('\n')
  }

  if (expectedType === 'Text' && typeof value === 'object' && value !== null) {
    return JSON.stringify(value)
  }

  if (expectedType === 'Symbol' && typeof value !== 'string') {
    return String(value)
  }

  if (expectedType === 'Object' && Array.isArray(value)) {
    return { items: value }
  }

  return value
}

function makeEntryFields(data, fieldTypes = {}) {
  const fields = {}
  for (const [key, value] of Object.entries(data)) {
    fields[key] = { 'en-US': coerceValue(value, fieldTypes[key]) }
  }
  return fields
}

async function createEntry(environment, contentTypeId, data) {
  const slug = data.slug || data.name?.toLowerCase().replace(/\s+/g, '-')
  try {
    // Check for existing entry with same slug
    const existing = await environment.getEntries({
      content_type: contentTypeId,
      'fields.slug[match]': slug,
      limit: 1,
    })

    if (existing.items.length > 0) {
      console.log(`    ⏭️  "${data.name || data.term}" already exists, skipping`)
      return existing.items[0]
    }
  } catch {
    // Content type might not be queryable yet, continue
  }

  const fieldTypes = await getFieldTypes(environment, contentTypeId)
  const entry = await environment.createEntry(contentTypeId, {
    fields: makeEntryFields(data, fieldTypes),
  })
  await entry.publish()
  console.log(`    ✅ Created & published "${data.name || data.term}"`)
  return entry
}

// ─── Load Sample Data ───

function loadSampleData(filename) {
  const path = resolve(__dirname, '../../../programmatic-seo', filename)
  try {
    return JSON.parse(readFileSync(path, 'utf-8'))
  } catch {
    console.warn(`  ⚠️  Could not load ${filename}, skipping data import`)
    return []
  }
}

// ─── Main ───

async function main() {
  console.log('\n🚀 FaithLock Contentful Setup\n')
  console.log(`Space: ${SPACE_ID}`)

  const space = await client.getSpace(SPACE_ID)
  const environment = await space.getEnvironment('master')

  console.log(`Environment: master\n`)

  // ── Step 1: Create Content Models ──
  console.log('━━━ Step 1: Content Models ━━━\n')

  await createOrUpdateContentType(
    environment,
    'competitor',
    'Competitor',
    'Competitor apps for comparison pages (/compare)',
    COMPETITOR_FIELDS
  )

  await createOrUpdateContentType(
    environment,
    'glossaryTerm',
    'Glossary Term',
    'Glossary terms for learn pages (/learn)',
    GLOSSARY_FIELDS
  )

  await createOrUpdateContentType(
    environment,
    'feature',
    'Feature',
    'App features for feature pages (/features)',
    FEATURE_FIELDS
  )

  // Small delay to let Contentful propagate
  console.log('\n  ⏳ Waiting for models to propagate...')
  await new Promise((r) => setTimeout(r, 3000))

  // ── Step 2: Insert Sample Data ──
  console.log('\n━━━ Step 2: Sample Data ━━━\n')

  // Competitors
  console.log('  📂 Competitors:')
  const competitors = loadSampleData('SAMPLE_DATA_competitors.json')
  for (const comp of competitors) {
    await createEntry(environment, 'competitor', comp)
  }

  // Glossary Terms
  console.log('\n  📂 Glossary Terms:')
  const glossaryTerms = loadSampleData('SAMPLE_DATA_glossary.json')
  for (const term of glossaryTerms) {
    await createEntry(environment, 'glossaryTerm', term)
  }

  // Features
  console.log('\n  📂 Features:')
  const features = loadSampleData('SAMPLE_DATA_features.json')
  for (const feature of features) {
    await createEntry(environment, 'feature', feature)
  }

  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  console.log('✅ Setup complete!')
  console.log(`   ${competitors.length} competitors`)
  console.log(`   ${glossaryTerms.length} glossary terms`)
  console.log(`   ${features.length} features`)
  console.log(`   = ${competitors.length + glossaryTerms.length + features.length} total entries`)
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n')
}

main().catch((err) => {
  console.error('\n❌ Error:', err.message || err)
  if (err.details?.errors) {
    console.error('Details:', JSON.stringify(err.details.errors, null, 2))
  }
  process.exit(1)
})
