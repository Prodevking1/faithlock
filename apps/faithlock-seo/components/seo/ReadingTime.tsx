interface ReadingTimeProps {
  wordCount: number
}

export default function ReadingTime({ wordCount }: ReadingTimeProps) {
  const minutes = Math.max(1, Math.ceil(wordCount / 200))

  return (
    <span className="text-sm text-white/50">
      {minutes} min read
    </span>
  )
}
