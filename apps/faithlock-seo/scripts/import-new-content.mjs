#!/usr/bin/env node

/**
 * Import New pSEO Content to Contentful
 *
 * Imports content from seo-content/new-pages/ subdirectories.
 * All content maps to the 'glossaryTerm' content type (rendered at /learn/*).
 *
 * Usage:
 *   node scripts/import-new-content.mjs --list              # Show all content with status
 *   node scripts/import-new-content.mjs --category reviews  # Import one category
 *   node scripts/import-new-content.mjs --all               # Import everything
 *   node scripts/import-new-content.mjs --all --dry-run     # Preview without importing
 *   node scripts/import-new-content.mjs --force             # Update existing entries
 *
 * Categories: reviews, how-to-block, bible-verses, addiction-guides, prayers, guides
 *
 * Requires: CONTENTFUL_MANAGEMENT_TOKEN env variable
 */

import contentful from 'contentful-management'
import { readFileSync, readdirSync, existsSync, writeFileSync } from 'fs'
import { resolve, dirname, basename } from 'path'
import { fileURLToPath } from 'url'

const __dirname = dirname(fileURLToPath(import.meta.url))

// ─── Load .env ───
function loadEnvFile(filePath) {
  if (!existsSync(filePath)) return
  const content = readFileSync(filePath, 'utf-8')
  for (const line of content.split('\n')) {
    const trimmed = line.trim()
    if (!trimmed || trimmed.startsWith('#')) continue
    const eqIndex = trimmed.indexOf('=')
    if (eqIndex > 0) {
      const key = trimmed.slice(0, eqIndex).trim()
      const value = trimmed.slice(eqIndex + 1).trim()
      if (!process.env[key]) process.env[key] = value
    }
  }
}

loadEnvFile(resolve(__dirname, '../.env.local'))
loadEnvFile(resolve(__dirname, '../.env'))

const NEW_CONTENT_DIR = resolve(__dirname, '../seo-content/new-pages')
const STATUS_FILE = resolve(NEW_CONTENT_DIR, '.import-status.json')
const SPACE_ID = process.env.CONTENTFUL_SPACE_ID || 'dhjf84rpcqxo'
const CMA_TOKEN = process.env.CONTENTFUL_MANAGEMENT_TOKEN

// ─── CLI Args ───
const args = process.argv.slice(2)
const isDryRun = args.includes('--dry-run')
const showList = args.includes('--list')
const importAll = args.includes('--all')
const forceUpdate = args.includes('--force')
const categoryArg = args.find((a, i) => args[i - 1] === '--category')

// ─── Categories ───
const CATEGORIES = {
  guides: { dir: '', pattern: '*.md', label: 'Guides (top-level)' },
  reviews: { dir: 'reviews', label: 'App Reviews' },
  'how-to-block': { dir: 'how-to-block', label: 'How to Block [App]' },
  'bible-verses': { dir: 'bible-verses', label: 'Bible Verses About [Topic]' },
  'addiction-guides': { dir: 'addiction-guides', label: 'Addiction Guides' },
  prayers: { dir: 'prayers', label: 'Prayers' },
}

// ─── Status Management ───
function loadStatus() {
  if (existsSync(STATUS_FILE)) {
    try { return JSON.parse(readFileSync(STATUS_FILE, 'utf-8')) }
    catch { return {} }
  }
  return {}
}

function saveStatus(status) {
  writeFileSync(STATUS_FILE, JSON.stringify(status, null, 2))
}

function markImported(slug) {
  const status = loadStatus()
  status[slug] = { importedAt: new Date().toISOString() }
  saveStatus(status)
}

// ─── Parse YAML Frontmatter ───
function parseFrontmatter(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---/)
  const meta = {}
  if (match) {
    for (const line of match[1].split('\n')) {
      const colonIndex = line.indexOf(':')
      if (colonIndex > 0) {
        const key = line.slice(0, colonIndex).trim()
        let value = line.slice(colonIndex + 1).trim()
        // Remove surrounding quotes
        if ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))) {
          value = value.slice(1, -1)
        }
        meta[key] = value
      }
    }
  }
  const body = match
    ? content.slice(match.index + match[0].length).trim()
    : content
  return { meta, body }
}

// ─── Extract short definition from body ───
function extractShortDef(body) {
  // Try to get first paragraph after Key Takeaways or first heading
  const afterTakeaways = body.match(/## Key Takeaways[\s\S]*?\n---\n\n([\s\S]*?)(?=\n##|\n---)/m)
  if (afterTakeaways) return afterTakeaways[1].trim().slice(0, 500)

  // Try first section after first heading
  const firstSection = body.match(/## [\s\S]*?\n\n([\s\S]*?)(?=\n##|$)/m)
  if (firstSection) return firstSection[1].trim().slice(0, 500)

  return body.slice(0, 500)
}

// ─── Extract FAQs from body ───
function extractFaqs(body) {
  const faqs = []
  // Match **Question?**\nAnswer pattern
  const faqMatches = body.matchAll(/\*\*([^*]+\?)\*\*\n([^*\n][\s\S]*?)(?=\n\*\*[^*]+\?|---|\n## |$)/gm)
  for (const match of faqMatches) {
    const question = match[1].trim()
    const answer = match[2].trim().slice(0, 1000)
    if (question && answer) {
      faqs.push({ question, answer })
    }
  }
  return faqs
}

// ─── Parse markdown to glossaryTerm fields ───
function parseToGlossaryTerm(filePath) {
  const content = readFileSync(filePath, 'utf-8')
  const { meta, body } = parseFrontmatter(content)
  const slug = meta.slug || basename(filePath, '.md')

  // Clean up title (remove quotes that might remain)
  const title = (meta.title || slug.replace(/-/g, ' '))
    .replace(/^["']|["']$/g, '')

  const faqs = extractFaqs(body)

  return {
    slug,
    term: title,
    category: meta.category || 'Guides',
    shortDefinition: extractShortDef(body),
    detailedExplanation: body,
    christianPerspective: '', // Will be empty for most new content — that's fine
    seoTitle: (meta.meta_title || title).replace(/^["']|["']$/g, ''),
    seoDescription: (meta.meta_description || '').replace(/^["']|["']$/g, ''),
    bibleVerses: {},
    statistics: {},
    relatedTerms: [],
    faqs: faqs.length > 0 ? faqs : {},
  }
}

// ─── Get files for a category ───
function getFilesForCategory(categoryKey) {
  const cat = CATEGORIES[categoryKey]
  if (!cat) return []

  if (categoryKey === 'guides') {
    // Top-level .md files
    const dir = NEW_CONTENT_DIR
    if (!existsSync(dir)) return []
    return readdirSync(dir)
      .filter(f => f.endsWith('.md'))
      .map(f => ({ path: resolve(dir, f), file: f, category: categoryKey }))
  }

  const dir = resolve(NEW_CONTENT_DIR, cat.dir)
  if (!existsSync(dir)) return []
  return readdirSync(dir)
    .filter(f => f.endsWith('.md'))
    .map(f => ({ path: resolve(dir, f), file: f, category: categoryKey }))
}

// ─── List all content ───
function listContent() {
  const status = loadStatus()
  let total = 0
  let imported = 0

  console.log('\n📄 New Content Status\n')
  console.log('━'.repeat(70))

  for (const [key, cat] of Object.entries(CATEGORIES)) {
    const files = getFilesForCategory(key)
    if (files.length === 0) continue

    const importedFiles = files.filter(f => {
      const slug = basename(f.file, '.md')
      return status[slug]
    })

    console.log(`\n📦 ${cat.label} (${importedFiles.length}/${files.length} imported)`)
    for (const f of files) {
      const slug = basename(f.file, '.md')
      const icon = status[slug] ? '✅' : '⏳'
      console.log(`   ${icon} ${slug}`)
    }
    total += files.length
    imported += importedFiles.length
  }

  console.log('\n' + '━'.repeat(70))
  console.log(`\n📊 Total: ${imported}/${total} imported\n`)
}

// ─── Contentful helpers (reused from import-seo-content.mjs) ───

const fieldTypeCache = {}

async function getFieldTypes(environment, contentTypeId) {
  if (fieldTypeCache[contentTypeId]) return fieldTypeCache[contentTypeId]
  try {
    const ct = await environment.getContentType(contentTypeId)
    const typeMap = {}
    for (const f of ct.fields) typeMap[f.id] = f.type
    fieldTypeCache[contentTypeId] = typeMap
    return typeMap
  } catch { return {} }
}

function toRichText(text) {
  const paragraphs = String(text).split('\n\n').filter(p => p.trim())
  return {
    nodeType: 'document',
    data: {},
    content: paragraphs.map(para => ({
      nodeType: 'paragraph',
      data: {},
      content: [{ nodeType: 'text', data: {}, marks: [], value: para.trim() }],
    })),
  }
}

function coerceValue(value, expectedType) {
  if (!expectedType) return value
  if (expectedType === 'RichText' && typeof value === 'string') return toRichText(value)
  if (expectedType === 'Text' && Array.isArray(value)) return value.join('\n')
  if (expectedType === 'Text' && typeof value === 'object' && value !== null) return JSON.stringify(value)
  if (expectedType === 'Symbol' && typeof value !== 'string') return String(value)
  if (expectedType === 'Object' && Array.isArray(value)) return { items: value }
  return value
}

function makeEntryFields(data, fieldTypes = {}) {
  const fields = {}
  for (const [key, value] of Object.entries(data)) {
    if (value !== undefined && value !== null && value !== '') {
      fields[key] = { 'en-US': coerceValue(value, fieldTypes[key]) }
    }
  }
  return fields
}

async function createEntry(environment, contentTypeId, data) {
  const slug = data.slug
  const fieldTypes = await getFieldTypes(environment, contentTypeId)

  try {
    const existing = await environment.getEntries({
      content_type: contentTypeId,
      'fields.slug[match]': slug,
      limit: 1,
    })

    if (existing.items.length > 0) {
      if (forceUpdate) {
        const entry = existing.items[0]
        const newFields = makeEntryFields(data, fieldTypes)
        for (const [key, value] of Object.entries(newFields)) {
          entry.fields[key] = value
        }
        const updated = await entry.update()
        await updated.publish()
        console.log(`    🔄 Updated "${slug}"`)
        return { status: 'updated', slug }
      } else {
        console.log(`    ⏭️  "${slug}" exists, skipping`)
        return { status: 'skipped', slug }
      }
    }
  } catch { /* continue */ }

  const entry = await environment.createEntry(contentTypeId, {
    fields: makeEntryFields(data, fieldTypes),
  })
  await entry.publish()
  console.log(`    ✅ Created "${slug}"`)
  return { status: 'created', slug }
}

// ─── Import logic ───
async function importCategory(categoryKey, environment) {
  const cat = CATEGORIES[categoryKey]
  const files = getFilesForCategory(categoryKey)
  const status = loadStatus()

  if (files.length === 0) {
    console.log(`\n⏭️  ${cat.label}: no files found`)
    return { created: 0, updated: 0, skipped: 0, failed: 0 }
  }

  // Filter already imported (unless --force)
  const toImport = forceUpdate
    ? files
    : files.filter(f => !status[basename(f.file, '.md')])

  if (toImport.length === 0) {
    console.log(`\n✅ ${cat.label}: all ${files.length} already imported`)
    return { created: 0, updated: 0, skipped: 0, failed: 0 }
  }

  console.log(`\n📤 ${cat.label}: importing ${toImport.length} of ${files.length} files`)

  const results = { created: 0, updated: 0, skipped: 0, failed: 0 }

  for (const f of toImport) {
    try {
      const data = parseToGlossaryTerm(f.path)

      if (isDryRun) {
        console.log(`    🔍 [dry-run] ${data.slug} → "${data.seoTitle}"`)
        results.skipped++
        continue
      }

      const result = await createEntry(environment, 'glossaryTerm', data)
      results[result.status]++

      if (result.status === 'created' || result.status === 'updated') {
        markImported(data.slug)
      }

      // Rate limit: 200ms between Contentful API calls
      await new Promise(r => setTimeout(r, 200))
    } catch (err) {
      console.error(`    ❌ Failed "${basename(f.file)}": ${err.message}`)
      results.failed++
    }
  }

  return results
}

// ─── Main ───
async function main() {
  if (showList) {
    listContent()
    return
  }

  const categoriesToImport = importAll
    ? Object.keys(CATEGORIES)
    : categoryArg
      ? [categoryArg]
      : null

  if (!categoriesToImport) {
    console.log(`
🚀 FaithLock New Content Importer

Usage:
  node scripts/import-new-content.mjs --list                # Show status
  node scripts/import-new-content.mjs --category reviews    # Import one category
  node scripts/import-new-content.mjs --all                 # Import everything
  node scripts/import-new-content.mjs --all --dry-run       # Preview
  node scripts/import-new-content.mjs --force --all         # Re-import all

Categories: ${Object.keys(CATEGORIES).join(', ')}
`)
    return
  }

  // Validate categories
  for (const cat of categoriesToImport) {
    if (!CATEGORIES[cat]) {
      console.error(`❌ Unknown category: "${cat}"`)
      console.error(`Valid: ${Object.keys(CATEGORIES).join(', ')}`)
      process.exit(1)
    }
  }

  if (isDryRun) {
    console.log('\n🔍 DRY RUN — no changes will be made\n')
  }

  // Connect to Contentful
  let environment
  if (!isDryRun) {
    if (!CMA_TOKEN) {
      console.error('\n❌ CONTENTFUL_MANAGEMENT_TOKEN required!')
      console.error('Set it: export CONTENTFUL_MANAGEMENT_TOKEN=your-token')
      console.error('Or use --dry-run to preview\n')
      process.exit(1)
    }

    console.log('\n🔗 Connecting to Contentful...')
    const client = contentful.createClient({
      accessToken: CMA_TOKEN,
      timeout: 60000,
      retryOnError: true,
      retryLimit: 5,
    })
    const space = await client.getSpace(SPACE_ID)
    environment = await space.getEnvironment('master')
    console.log('✅ Connected\n')
  }

  // Import
  const totals = { created: 0, updated: 0, skipped: 0, failed: 0 }

  for (const cat of categoriesToImport) {
    const result = await importCategory(cat, environment)
    totals.created += result.created
    totals.updated += result.updated
    totals.skipped += result.skipped
    totals.failed += result.failed
  }

  console.log('\n' + '━'.repeat(50))
  console.log('📊 Import Summary')
  console.log('━'.repeat(50))
  console.log(`   ✅ Created: ${totals.created}`)
  console.log(`   🔄 Updated: ${totals.updated}`)
  console.log(`   ⏭️  Skipped: ${totals.skipped}`)
  console.log(`   ❌ Failed:  ${totals.failed}`)
  console.log('━'.repeat(50))

  if (totals.created > 0 || totals.updated > 0) {
    console.log('\n📝 Next steps:')
    console.log('   1. Redeploy the site (Vercel)')
    console.log('   2. Submit new URLs to Google Search Console')
    console.log('   3. Request indexing for new pages\n')
  }
}

main().catch(err => {
  console.error('\n❌ Error:', err.message || err)
  if (err.details?.errors) {
    console.error('Details:', JSON.stringify(err.details.errors, null, 2))
  }
  process.exit(1)
})
