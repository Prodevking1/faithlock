'use client'

import { useEffect } from 'react'
import { trackTemplateView } from '@/lib/analytics'

interface TemplateTrackerProps {
  type: 'comparison' | 'feature' | 'glossary'
  slug: string
}

export default function TemplateTracker({ type, slug }: TemplateTrackerProps) {
  useEffect(() => {
    trackTemplateView(type, slug)
  }, [type, slug])

  return null
}
