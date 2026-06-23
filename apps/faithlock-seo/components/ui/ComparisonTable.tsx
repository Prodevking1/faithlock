import { Competitor } from '@/lib/types'

interface ComparisonTableProps {
  faithlock: {
    name: string
    features: Record<string, boolean | string>
    price: string
    platforms: string[]
    rating?: number
    downloads?: number
  }
  competitor: Competitor
}

const FEATURE_LABELS: Record<string, string> = {
  bibleQuiz: 'Bible Quiz System',
  physicalBibleScan: 'Physical Bible Scanning',
  screenTimeTracking: 'Screen Time Tracking',
  appBlocking: 'App Blocking',
  androidSupport: 'Android Support',
  '30DayCovenant': '30-Day Covenant',
  progressAnalytics: 'Progress Analytics',
  customScheduling: 'Custom Scheduling',
  bibleVerseLibrary: 'Bible Verse Library',
  accountabilityPartner: 'Accountability Partner',
}

function renderFeatureValue(value: boolean | string) {
  if (typeof value === 'boolean') {
    return value ? (
      <span className="inline-flex items-center justify-center w-7 h-7 bg-cozy-sage/20 text-cozy-sage rounded-full">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
          <polyline points="20 6 9 17 4 12" />
        </svg>
      </span>
    ) : (
      <span className="inline-flex items-center justify-center w-7 h-7 bg-cozy-surface-muted text-cozy-ink-muted rounded-full">
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
          <line x1="18" y1="6" x2="6" y2="18" />
          <line x1="6" y1="6" x2="18" y2="18" />
        </svg>
      </span>
    )
  }
  return <span className="text-sm text-cozy-ink/85 font-medium">{value}</span>
}

export default function ComparisonTable({
  faithlock,
  competitor,
}: ComparisonTableProps) {
  const featureKeys = Object.keys(FEATURE_LABELS)

  return (
    <div className="cozy-card overflow-hidden border-[2.5px] border-cozy-ink rounded-cozy">
      {/* Mobile: stacked cards */}
      <div className="md:hidden">
        {featureKeys.map((key) => (
          <div key={key} className="border-b border-cozy-border p-4">
            <p className="text-sm font-medium text-cozy-ink-muted mb-3">{FEATURE_LABELS[key]}</p>
            <div className="grid grid-cols-2 gap-4">
              <div className="flex items-center gap-2">
                <span className="text-xs font-semibold text-cozy-primary">FaithLock</span>
                {renderFeatureValue(faithlock.features[key] as boolean | string)}
              </div>
              <div className="flex items-center gap-2">
                <span className="text-xs font-semibold text-cozy-ink-muted">{competitor.name}</span>
                {renderFeatureValue(competitor.features[key as keyof typeof competitor.features])}
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Desktop: table */}
      <div className="hidden md:block overflow-x-auto">
        <table className="w-full">
          <thead>
            <tr className="bg-cozy-surface-muted border-b-[2.5px] border-cozy-ink">
              <th className="text-left p-5 font-medium text-cozy-ink-muted text-sm">
                Feature
              </th>
              <th className="text-center p-5 w-44 bg-cozy-peach">
                <span className="font-bold text-cozy-primary-dark text-sm">FaithLock</span>
              </th>
              <th className="text-center p-5 w-44">
                <span className="font-medium text-cozy-ink-muted text-sm">{competitor.name}</span>
              </th>
            </tr>
          </thead>
          <tbody>
            {featureKeys.map((key, i) => (
              <tr
                key={key}
                className={`border-b border-cozy-border ${i % 2 === 0 ? '' : 'bg-cozy-surface-muted/40'}`}
              >
                <td className="p-4 text-sm text-cozy-ink/85 font-medium">{FEATURE_LABELS[key]}</td>
                <td className="p-4 text-center bg-cozy-peach/30">
                  {renderFeatureValue(faithlock.features[key] as boolean | string)}
                </td>
                <td className="p-4 text-center">
                  {renderFeatureValue(competitor.features[key as keyof typeof competitor.features])}
                </td>
              </tr>
            ))}

            {/* Pricing */}
            <tr className="bg-cozy-surface-muted/50 font-medium">
              <td className="p-4 text-sm text-cozy-ink/85">Pricing</td>
              <td className="p-4 text-center text-sm text-cozy-primary-dark bg-cozy-peach/30 font-semibold">
                {faithlock.price}
              </td>
              <td className="p-4 text-center text-sm text-cozy-ink/70">
                {competitor.price}
              </td>
            </tr>

            {/* Platforms */}
            <tr className="border-b border-cozy-border">
              <td className="p-4 text-sm text-cozy-ink/85 font-medium">Platforms</td>
              <td className="p-4 text-center text-sm bg-cozy-peach/30">
                {faithlock.platforms.join(', ')}
              </td>
              <td className="p-4 text-center text-sm">
                {competitor.platforms.join(', ')}
              </td>
            </tr>

            {/* Rating - only show if FaithLock has data */}
            {faithlock.rating ? (
              <tr className="bg-cozy-surface-muted/50">
                <td className="p-4 text-sm text-cozy-ink/85 font-medium">App Store Rating</td>
                <td className="p-4 text-center bg-cozy-peach/30">
                  <span className="inline-flex items-center gap-1 text-sm font-bold text-cozy-primary-dark">
                    {faithlock.rating}
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" className="text-cozy-gold">
                      <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
                    </svg>
                  </span>
                </td>
                <td className="p-4 text-center">
                  <span className="inline-flex items-center gap-1 text-sm text-cozy-ink/70">
                    {competitor.rating}
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" className="text-cozy-ink-muted">
                      <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
                    </svg>
                  </span>
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>
    </div>
  )
}
