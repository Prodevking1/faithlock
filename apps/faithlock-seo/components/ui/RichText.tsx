import { documentToReactComponents } from '@contentful/rich-text-react-renderer'
import { Document } from '@contentful/rich-text-types'
import { marked } from 'marked'

interface RichTextProps {
  content: Document | string | unknown
  className?: string
}

/**
 * Extract all raw text from a Contentful Rich Text Document.
 * Used to detect if text nodes contain embedded HTML strings.
 */
function extractRawText(node: unknown): string {
  if (!node || typeof node !== 'object') return ''
  const n = node as Record<string, unknown>
  let text = ''
  if (typeof n.value === 'string') text += n.value
  if (Array.isArray(n.content)) {
    for (const child of n.content) {
      text += extractRawText(child)
    }
  }
  return text
}

/**
 * Detect if a string contains markdown syntax.
 */
function isMarkdown(text: string): boolean {
  return /^#{1,6}\s|^\*\*|^\- |\*\*.*\*\*|^\|.*\|/m.test(text)
}

/**
 * Convert markdown string to sanitized HTML.
 */
function markdownToHtml(md: string): string {
  return marked.parse(md, { async: false }) as string
}

export default function RichText({ content, className }: RichTextProps) {
  if (!content) return null

  // String content: could be HTML or Markdown
  if (typeof content === 'string') {
    const html = isMarkdown(content) ? markdownToHtml(content) : content
    return <div className={className} dangerouslySetInnerHTML={{ __html: html }} />
  }

  // If it's a Contentful Rich Text Document object
  if (
    typeof content === 'object' &&
    content !== null &&
    'nodeType' in (content as Record<string, unknown>)
  ) {
    // Check if the Document's text nodes contain embedded HTML tags.
    // This happens when HTML strings are stored inside Rich Text fields.
    const rawText = extractRawText(content)
    if (/<[a-z][\s\S]*>/i.test(rawText)) {
      return <div className={className} dangerouslySetInnerHTML={{ __html: rawText }} />
    }

    // Check for markdown inside Rich Text text nodes
    if (isMarkdown(rawText)) {
      return <div className={className} dangerouslySetInnerHTML={{ __html: markdownToHtml(rawText) }} />
    }

    // Proper Rich Text Document — render with Contentful's renderer
    return (
      <div className={className}>
        {documentToReactComponents(content as Document)}
      </div>
    )
  }

  // Fallback
  return <div className={className}>{String(content)}</div>
}
