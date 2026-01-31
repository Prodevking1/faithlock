interface BibleVerseProps {
  reference: string
  text: string
}

export default function BibleVerse({ reference, text }: BibleVerseProps) {
  return (
    <blockquote className="relative bg-white rounded-2xl p-6 md:p-8 shadow-soft border border-brand-50 overflow-hidden">
      {/* Decorative quote mark */}
      <div className="absolute top-3 left-4 text-brand-100 text-6xl font-serif leading-none select-none" aria-hidden="true">
        &ldquo;
      </div>
      <div className="relative">
        <p className="text-gray-700 text-lg md:text-xl leading-relaxed font-serif italic pl-6">
          {text}
        </p>
        <cite className="block mt-4 pl-6 not-italic">
          <span className="inline-flex items-center gap-2 text-sm font-semibold text-brand-700 bg-brand-50 px-3 py-1 rounded-full">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z" />
              <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z" />
            </svg>
            {reference}
          </span>
        </cite>
      </div>
    </blockquote>
  )
}
