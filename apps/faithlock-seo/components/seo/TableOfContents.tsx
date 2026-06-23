interface TOCItem {
  id: string
  text: string
}

interface TableOfContentsProps {
  items: TOCItem[]
}

export default function TableOfContents({ items }: TableOfContentsProps) {
  if (items.length < 2) return null

  return (
    <nav
      aria-label="Table of contents"
      className="mb-12 cozy-card-soft p-6"
    >
      <p className="text-sm font-bold text-cozy-ink-muted uppercase tracking-wide mb-3">
        In this article
      </p>
      <ol className="space-y-2">
        {items.map((item, i) => (
          <li key={item.id}>
            <a
              href={`#${item.id}`}
              className="text-sm text-cozy-ink/85 hover:text-cozy-primary transition-colors flex items-start gap-2"
            >
              <span className="text-cozy-primary font-mono text-xs mt-0.5 w-4 text-right flex-shrink-0 font-bold">
                {i + 1}.
              </span>
              {item.text}
            </a>
          </li>
        ))}
      </ol>
    </nav>
  )
}
