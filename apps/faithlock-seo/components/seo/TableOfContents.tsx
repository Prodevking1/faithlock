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
      className="mb-12 bg-gray-50 rounded-2xl p-6 border border-gray-100"
    >
      <p className="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-3">
        In this article
      </p>
      <ol className="space-y-2">
        {items.map((item, i) => (
          <li key={item.id}>
            <a
              href={`#${item.id}`}
              className="text-sm text-gray-700 hover:text-brand-600 transition-colors flex items-start gap-2"
            >
              <span className="text-gray-400 font-mono text-xs mt-0.5 w-4 text-right flex-shrink-0">
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
