#!/usr/bin/env node

/**
 * Import SEO Content from Markdown Files to Contentful
 *
 * Usage:
 *   node scripts/import-seo-content.mjs              # Show status & next action
 *   node scripts/import-seo-content.mjs 08           # Import day08
 *   node scripts/import-seo-content.mjs 08 --dry-run # Preview without importing
 *   node scripts/import-seo-content.mjs --list       # List all days with status
 *   node scripts/import-seo-content.mjs --reset      # Reset all status to pending
 *
 * Requires: CONTENTFUL_MANAGEMENT_TOKEN env variable
 */

import contentful from 'contentful-management'
import { readFileSync, readdirSync, existsSync, writeFileSync } from 'fs'
import { resolve, dirname, basename } from 'path'
import { fileURLToPath } from 'url'
import { createInterface } from 'readline'

const __dirname = dirname(fileURLToPath(import.meta.url))

// Load .env.local manually
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
      if (!process.env[key]) {
        process.env[key] = value
      }
    }
  }
}

loadEnvFile(resolve(__dirname, '../.env.local'))
loadEnvFile(resolve(__dirname, '../.env'))
const SEO_CONTENT_DIR = resolve(__dirname, '../seo-content')
const STATUS_FILE = resolve(SEO_CONTENT_DIR, '.publish-status.json')

// ─── Config ───
const SPACE_ID = process.env.CONTENTFUL_SPACE_ID || 'dhjf84rpcqxo'
const CMA_TOKEN = process.env.CONTENTFUL_MANAGEMENT_TOKEN

// ─── CLI Args ───
const args = process.argv.slice(2)
const isDryRun = args.includes('--dry-run')
const showList = args.includes('--list')
const forceUpdate = args.includes('--force')
const doReset = args.includes('--reset')
const dayArg = args.find((a) => /^\d+$/.test(a))

// ─── Publication Calendar (from PUBLICATION_CALENDAR.md) ───
const PUBLICATION_CALENDAR = {
  '08': { name: 'Jour 8 (Lundi)', type: 'Comparaisons principales', priority: '⭐⭐⭐⭐⭐' },
  '10': { name: 'Jour 10 (Mercredi)', type: 'Glossaire prioritaire', priority: '⭐⭐⭐⭐⭐' },
  '12': { name: 'Jour 12 (Vendredi)', type: 'Mix glossaire + features', priority: '⭐⭐⭐⭐' },
  '14': { name: 'Jour 14 (Dimanche)', type: 'Glossaire + feature', priority: '⭐⭐⭐⭐' },
  '22': { name: 'Jour 22 (Lundi)', type: 'Comparaisons alternatives', priority: '⭐⭐⭐⭐' },
  '24': { name: 'Jour 24 (Mercredi)', type: 'Glossaire addiction terms', priority: '⭐⭐⭐⭐⭐' },
  '26': { name: 'Jour 26 (Vendredi)', type: 'Comparaisons catégorie', priority: '⭐⭐⭐⭐⭐' },
  '28': { name: 'Jour 28 (Dimanche)', type: 'Glossaire stats + features', priority: '⭐⭐⭐⭐' },
  '29': { name: 'Jour 29 (Lundi)', type: 'Glossaire Christian concepts', priority: '⭐⭐⭐⭐' },
  '31': { name: 'Jour 31 (Mercredi)', type: 'Glossaire solutions', priority: '⭐⭐⭐⭐⭐' },
  '33': { name: 'Jour 33 (Vendredi)', type: 'Glossaire solutions (continued)', priority: '⭐⭐⭐⭐' },
  '35': { name: 'Jour 35 (Dimanche)', type: 'Features', priority: '⭐⭐⭐⭐' },
  '36': { name: 'Jour 36 (Lundi)', type: 'Comparaisons long-tail', priority: '⭐⭐⭐' },
  '38': { name: 'Jour 38 (Mercredi)', type: 'Comparaisons alternatives', priority: '⭐⭐⭐' },
  '40': { name: 'Jour 40 (Vendredi)', type: 'Glossaire niche topics', priority: '⭐⭐⭐⭐' },
  '42': { name: 'Jour 42 (Dimanche)', type: 'Glossaire niche + features', priority: '⭐⭐⭐⭐' },
  '43': { name: 'Jour 43 (Lundi)', type: 'Comparaisons finales', priority: '⭐⭐⭐' },
  '45': { name: 'Jour 45 (Mercredi)', type: 'Glossaire final topics', priority: '⭐⭐⭐⭐' },
}

// ─── Status Management ───

function loadStatus() {
  if (existsSync(STATUS_FILE)) {
    try {
      return JSON.parse(readFileSync(STATUS_FILE, 'utf-8'))
    } catch {
      return {}
    }
  }
  return {}
}

function saveStatus(status) {
  writeFileSync(STATUS_FILE, JSON.stringify(status, null, 2))
}

function markAsPublished(dayNum, filesCount) {
  const status = loadStatus()
  status[dayNum] = {
    status: 'published',
    publishedAt: new Date().toISOString(),
    filesCount,
  }
  saveStatus(status)
}

function resetStatus() {
  saveStatus({})
  console.log('\n✅ Status reset. All days marked as pending.\n')
}

// ─── Interactive Prompt ───

function askQuestion(question) {
  const rl = createInterface({
    input: process.stdin,
    output: process.stdout,
  })

  return new Promise((resolve) => {
    rl.question(question, (answer) => {
      rl.close()
      resolve(answer.toLowerCase().trim())
    })
  })
}

// ─── List with Status ───

function listDaysWithStatus() {
  const status = loadStatus()

  console.log('\n📅 Publication Status\n')
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  console.log('Day │ Status      │ Files │ Type                          │ Priority')
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')

  const folders = readdirSync(SEO_CONTENT_DIR)
    .filter((f) => f.startsWith('day'))
    .sort((a, b) => {
      const numA = parseInt(a.match(/\d+/)?.[0] || '0')
      const numB = parseInt(b.match(/\d+/)?.[0] || '0')
      return numA - numB
    })

  let published = 0
  let pending = 0
  let totalFiles = 0

  for (const folder of folders) {
    const files = readdirSync(resolve(SEO_CONTENT_DIR, folder)).filter((f) =>
      f.endsWith('.md')
    )
    const dayNum = folder.match(/\d+/)?.[0]?.padStart(2, '0') || '??'
    const dayStatus = status[dayNum]
    const calendarInfo = PUBLICATION_CALENDAR[dayNum] || { type: 'Unknown', priority: '' }

    const statusIcon = dayStatus?.status === 'published' ? '✅ Published' : '⏳ Pending  '

    if (dayStatus?.status === 'published') {
      published++
    } else {
      pending++
    }
    totalFiles += files.length

    console.log(
      ` ${dayNum} │ ${statusIcon} │ ${String(files.length).padStart(5)} │ ${calendarInfo.type.padEnd(29)} │ ${calendarInfo.priority}`
    )
  }

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  console.log(`\n📊 Total: ${published} published, ${pending} pending (${totalFiles} files)\n`)
}

// ─── Show Next Action ───

function getNextDay() {
  const status = loadStatus()

  const folders = readdirSync(SEO_CONTENT_DIR)
    .filter((f) => f.startsWith('day'))
    .sort((a, b) => {
      const numA = parseInt(a.match(/\d+/)?.[0] || '0')
      const numB = parseInt(b.match(/\d+/)?.[0] || '0')
      return numA - numB
    })

  // Find next unpublished day
  for (const folder of folders) {
    const dayNum = folder.match(/\d+/)?.[0]?.padStart(2, '0')
    if (dayNum && status[dayNum]?.status !== 'published') {
      const files = readdirSync(resolve(SEO_CONTENT_DIR, folder)).filter((f) =>
        f.endsWith('.md')
      )
      return { dayNum, folder, files, folders }
    }
  }

  return null
}

function showNextAction(nextDay, showCommands = true) {
  const status = loadStatus()

  console.log('\n🚀 FaithLock pSEO Publisher\n')
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')

  if (!nextDay) {
    console.log('🎉 Tous les jours sont publiés!')
    console.log('\n✅ Phase 1 complète (75 pages)')
    console.log('\nProchaines étapes:')
    console.log('  1. Vérifier indexation dans Google Search Console')
    console.log('  2. Analyser les performances (impressions, clics)')
    console.log('  3. Optimiser les pages avec faible CTR')
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n')
    return
  }

  const calendarInfo = PUBLICATION_CALENDAR[nextDay.dayNum] || {}

  // Count published/pending
  let publishedCount = 0
  for (const folder of nextDay.folders) {
    const dayNum = folder.match(/\d+/)?.[0]?.padStart(2, '0')
    if (dayNum && status[dayNum]?.status === 'published') {
      publishedCount++
    }
  }

  console.log(`📊 Progress: ${publishedCount}/${nextDay.folders.length} jours publiés`)
  console.log('')
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  console.log('📌 PROCHAIN À PUBLIER')
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  console.log('')
  console.log(`   📅 ${calendarInfo.name || `Jour ${nextDay.dayNum}`}`)
  console.log(`   📦 ${calendarInfo.type || 'Content'}`)
  console.log(`   📄 ${nextDay.files.length} fichiers`)
  console.log(`   ${calendarInfo.priority || ''}`)
  console.log('')
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')

  if (showCommands) {
    console.log('')
    console.log('🔧 Commandes:')
    console.log('')
    console.log(`   # Preview (sans importer)`)
    console.log(`   node scripts/import-seo-content.mjs ${nextDay.dayNum} --dry-run`)
    console.log('')
    console.log(`   # Importer maintenant`)
    console.log(`   node scripts/import-seo-content.mjs ${nextDay.dayNum}`)
    console.log('')
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n')
  }
}

// ─── Parse Markdown Files ───

function parseComparisonMarkdown(content, filename) {
  // Format: metadata in ``` block at start
  const metaMatch = content.match(/^```[\s\S]*?```/m)
  let meta = {}

  if (metaMatch) {
    const metaBlock = metaMatch[0].replace(/```/g, '').trim()
    for (const line of metaBlock.split('\n')) {
      const [key, ...valueParts] = line.split(':')
      if (key && valueParts.length) {
        const cleanKey = key.trim().toLowerCase().replace(/\s+/g, '_')
        meta[cleanKey] = valueParts.join(':').trim()
      }
    }
  }

  // Extract content after metadata block
  const bodyContent = metaMatch
    ? content.slice(metaMatch.index + metaMatch[0].length).trim()
    : content

  // Extract slug from filename if not in meta
  const slug = meta.slug || filename.replace('.md', '')

  return {
    slug,
    name: meta.slug
      ? meta.slug
          .split('-')
          .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
          .join(' ')
      : filename.replace('.md', ''),
    seoTitle: meta.meta_title || meta.title || '',
    seoDescription: meta.meta_description || meta.description || '',
    description: bodyContent,
    // Defaults for required fields
    tagline: `Compare FaithLock vs ${slug.replace('faithlock-vs-', '').replace(/-/g, ' ')}`,
    price: 'See website',
    platforms: ['iOS'],
    features: {},
    pros: [],
    cons: [],
  }
}

function parseYamlFrontmatter(content, filename) {
  // Format: YAML frontmatter between ---
  const frontmatterMatch = content.match(/^---\n([\s\S]*?)\n---/)
  let meta = {}

  if (frontmatterMatch) {
    const yamlContent = frontmatterMatch[1]
    for (const line of yamlContent.split('\n')) {
      const colonIndex = line.indexOf(':')
      if (colonIndex > 0) {
        const key = line.slice(0, colonIndex).trim()
        const value = line.slice(colonIndex + 1).trim()
        meta[key] = value
      }
    }
  }

  // Extract content after frontmatter
  const bodyContent = frontmatterMatch
    ? content.slice(frontmatterMatch.index + frontmatterMatch[0].length).trim()
    : content

  const slug = meta.slug || filename.replace('.md', '')

  return { meta, bodyContent, slug }
}

function parseGlossaryMarkdown(content, filename) {
  const { meta, bodyContent, slug } = parseYamlFrontmatter(content, filename)

  // Try to extract definition from content
  const defMatch = bodyContent.match(
    /## Definition\n\n([\s\S]*?)(?=\n---|\n## |$)/
  )
  const shortDefinition = defMatch
    ? defMatch[1].trim().slice(0, 500)
    : bodyContent.slice(0, 500)

  return {
    slug,
    term:
      meta.title?.replace(' - FaithLock Glossary', '') ||
      slug.replace(/-/g, ' '),
    category: meta.category || 'General',
    shortDefinition,
    detailedExplanation: bodyContent,
    seoTitle: meta.meta_title || meta.title || '',
    seoDescription: meta.meta_description || '',
    bibleVerses: {},
    statistics: {},
    relatedTerms: [],
    faqs: {},
  }
}

function parseFeatureMarkdown(content, filename) {
  const { meta, bodyContent, slug } = parseYamlFrontmatter(content, filename)

  // Try to extract overview/description
  const overviewMatch = bodyContent.match(
    /## Overview\n\n([\s\S]*?)(?=\n## |$)/
  )
  const description = overviewMatch
    ? overviewMatch[1].trim()
    : bodyContent.slice(0, 1000)

  return {
    slug,
    name:
      meta.title?.replace(' - FaithLock Feature', '') ||
      slug.replace(/-/g, ' '),
    tagline: meta.meta_description?.slice(0, 100) || 'FaithLock Feature',
    description: bodyContent,
    howItWorks: '',
    benefits: [],
    useCases: {},
    screenshots: [],
    faqs: {},
    bibleVerses: {},
    seoTitle: meta.meta_title || meta.title || '',
    seoDescription: meta.meta_description || '',
  }
}

// ─── Determine content type from folder name ───
function getContentTypeFromFolder(folderName) {
  if (folderName.includes('comparison')) return 'competitor'
  if (folderName.includes('glossary')) return 'glossaryTerm'
  if (folderName.includes('feature')) return 'feature'
  // Mix folders - determine from filename or default
  return 'mixed'
}

function parseMarkdownFile(filePath, contentType) {
  const content = readFileSync(filePath, 'utf-8')
  const filename = basename(filePath)

  switch (contentType) {
    case 'competitor':
      return parseComparisonMarkdown(content, filename)
    case 'glossaryTerm':
      return parseGlossaryMarkdown(content, filename)
    case 'feature':
      return parseFeatureMarkdown(content, filename)
    case 'mixed':
      // Detect from content or filename
      if (filename.includes('faithlock-vs-')) {
        return { type: 'competitor', data: parseComparisonMarkdown(content, filename) }
      }
      // Check for YAML frontmatter category
      const catMatch = content.match(/category:\s*(\w+)/i)
      if (catMatch) {
        const cat = catMatch[1].toLowerCase()
        if (cat === 'features' || cat === 'feature') {
          return { type: 'feature', data: parseFeatureMarkdown(content, filename) }
        }
      }
      // Default to glossary for mixed
      return { type: 'glossaryTerm', data: parseGlossaryMarkdown(content, filename) }
    default:
      return null
  }
}

// ─── Contentful Helpers ───

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

// Convert plain text to Contentful Rich Text format
function toRichText(text) {
  // Split text into paragraphs
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

  // Handle RichText fields - convert string to RichText format
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
    // Check for existing entry with same slug
    const existing = await environment.getEntries({
      content_type: contentTypeId,
      'fields.slug[match]': slug,
      limit: 1,
    })

    if (existing.items.length > 0) {
      if (forceUpdate) {
        // Update existing entry
        const entry = existing.items[0]
        const newFields = makeEntryFields(data, fieldTypes)

        // Merge new fields into existing entry
        for (const [key, value] of Object.entries(newFields)) {
          entry.fields[key] = value
        }

        const updated = await entry.update()
        await updated.publish()
        console.log(`    🔄 Updated & published "${slug}"`)
        return { status: 'updated', slug }
      } else {
        console.log(`    ⏭️  "${slug}" already exists, skipping (use --force to update)`)
        return { status: 'skipped', slug }
      }
    }
  } catch {
    // Content type might not be queryable yet, continue
  }

  const entry = await environment.createEntry(contentTypeId, {
    fields: makeEntryFields(data, fieldTypes),
  })
  await entry.publish()
  console.log(`    ✅ Created & published "${slug}"`)
  return { status: 'created', slug }
}

// ─── Import Logic ───

async function runImport(dayNum, targetFolder, files) {
  const folderPath = resolve(SEO_CONTENT_DIR, targetFolder)
  const calendarInfo = PUBLICATION_CALENDAR[dayNum] || {}

  console.log(`\n🚀 Import SEO Content - ${targetFolder}`)
  console.log(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`)
  console.log(`📅 ${calendarInfo.name || `Jour ${dayNum}`}`)
  console.log(`📦 ${calendarInfo.type || 'Content'}`)
  console.log(`📄 Files: ${files.length}`)
  console.log(`${isDryRun ? '🔍 DRY RUN - No changes will be made' : ''}`)
  console.log('')

  // Check if already published
  const status = loadStatus()
  if (status[dayNum]?.status === 'published' && !isDryRun) {
    console.log(`⚠️  Ce jour a déjà été publié le ${new Date(status[dayNum].publishedAt).toLocaleDateString('fr-FR')}`)
    console.log('')
    const answer = await askQuestion('   Republier quand même? (o/n): ')
    if (answer !== 'o' && answer !== 'oui' && answer !== 'y' && answer !== 'yes') {
      console.log('\n👋 Annulé.\n')
      return
    }
    console.log('')
  }

  // Determine base content type
  const baseContentType = getContentTypeFromFolder(targetFolder)
  console.log(`📦 Content type: ${baseContentType === 'mixed' ? 'mixed (auto-detect)' : baseContentType}`)
  console.log('')

  // Parse all files
  const entries = []
  for (const file of files) {
    const filePath = resolve(folderPath, file)
    const result = parseMarkdownFile(filePath, baseContentType)

    if (result) {
      if (baseContentType === 'mixed') {
        entries.push({ contentType: result.type, data: result.data, file })
      } else {
        entries.push({ contentType: baseContentType, data: result, file })
      }
    }
  }

  // Show preview
  console.log('📋 Entries to import:\n')
  for (const entry of entries) {
    console.log(`  • [${entry.contentType}] ${entry.data.slug}`)
    if (isDryRun) {
      console.log(`    Title: ${entry.data.seoTitle || entry.data.name || entry.data.term}`)
    }
  }

  if (isDryRun) {
    console.log('\n✅ Dry run complete. Run without --dry-run to import.\n')
    return
  }

  // Check for token
  if (!CMA_TOKEN) {
    console.error('\n❌ CONTENTFUL_MANAGEMENT_TOKEN is required!')
    console.error('\nSet it in your environment:')
    console.error('  export CONTENTFUL_MANAGEMENT_TOKEN=your-token')
    console.error('\nOr run with --dry-run to preview without importing\n')
    process.exit(1)
  }

  // Import to Contentful
  console.log('\n📤 Importing to Contentful...\n')

  const client = contentful.createClient({
    accessToken: CMA_TOKEN,
    timeout: 60000, // 60 second timeout
    retryOnError: true,
    retryLimit: 5,
  })
  const space = await client.getSpace(SPACE_ID)
  const environment = await space.getEnvironment('master')

  const results = { created: 0, updated: 0, skipped: 0, failed: 0 }

  for (const entry of entries) {
    try {
      const result = await createEntry(environment, entry.contentType, entry.data)
      results[result.status]++
    } catch (err) {
      console.error(`    ❌ Failed "${entry.data.slug}": ${err.message}`)
      results.failed++
    }
  }

  // Mark as published if successful
  if (results.created > 0 || results.updated > 0 || results.skipped > 0) {
    markAsPublished(dayNum, files.length)
  }

  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  console.log(`✅ Import complete!`)
  console.log(`   Created: ${results.created}`)
  console.log(`   Updated: ${results.updated}`)
  console.log(`   Skipped: ${results.skipped}`)
  console.log(`   Failed:  ${results.failed}`)
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n')

  if (results.created > 0 || results.updated > 0) {
    console.log('📝 Next steps:')
    console.log('   1. Redeploy the site (Vercel)')
    console.log('   2. Submit new URLs to Google Search Console')
    console.log('   3. Request indexing for each new page\n')
  }

  // Show what's next
  const nextDay = getNextDay()
  if (nextDay) {
    showNextAction(nextDay, true)
  }
}

// ─── Main ───

async function main() {
  // Handle --reset
  if (doReset) {
    resetStatus()
    return
  }

  // Handle --list
  if (showList) {
    listDaysWithStatus()
    return
  }

  // No args - show next action and prompt
  if (!dayArg) {
    const nextDay = getNextDay()
    showNextAction(nextDay, false)

    if (!nextDay) {
      return
    }

    console.log('')
    const answer = await askQuestion(`📥 Importer le jour ${nextDay.dayNum} maintenant? (o/n): `)

    if (answer === 'o' || answer === 'oui' || answer === 'y' || answer === 'yes') {
      return await runImport(nextDay.dayNum, nextDay.folder, nextDay.files)
    } else {
      console.log('\n👋 OK, à plus tard!\n')
      return
    }
  }

  // Find folder matching day
  const folders = readdirSync(SEO_CONTENT_DIR).filter((f) => f.startsWith('day'))
  const targetFolder = folders.find((f) => {
    const num = f.match(/\d+/)?.[0]
    return num === dayArg || num === dayArg.padStart(2, '0')
  })

  if (!targetFolder) {
    console.error(`\n❌ No folder found for day ${dayArg}`)
    console.error('\nAvailable folders:')
    folders.forEach((f) => console.error(`  - ${f}`))
    process.exit(1)
  }

  const folderPath = resolve(SEO_CONTENT_DIR, targetFolder)
  const files = readdirSync(folderPath).filter((f) => f.endsWith('.md'))
  const dayNum = targetFolder.match(/\d+/)?.[0]?.padStart(2, '0') || dayArg

  await runImport(dayNum, targetFolder, files)
}

main().catch((err) => {
  console.error('\n❌ Error:', err.message || err)
  if (err.details?.errors) {
    console.error('Details:', JSON.stringify(err.details.errors, null, 2))
  }
  process.exit(1)
})
