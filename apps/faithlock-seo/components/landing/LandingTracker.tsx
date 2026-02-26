'use client'

import { useEffect, useRef, useCallback } from 'react'
import { trackCTAClick, trackFAQOpen, trackSectionView, trackNavClick, trackOutboundClick } from '@/lib/analytics'

export default function LandingTracker() {
  const tracked = useRef(new Set<string>())

  // Section scroll tracking (fire once per section)
  useEffect(() => {
    const sections = document.querySelectorAll('[data-track-section]')
    if (!sections.length) return

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const name = (entry.target as HTMLElement).dataset.trackSection!
            if (!tracked.current.has(name)) {
              tracked.current.add(name)
              trackSectionView(name)
            }
          }
        })
      },
      { threshold: 0.3 }
    )

    sections.forEach((s) => observer.observe(s))
    return () => observer.disconnect()
  }, [])

  // CTA click tracking via delegation
  useEffect(() => {
    function handleClick(e: MouseEvent) {
      const el = (e.target as HTMLElement).closest('[data-track-cta]') as HTMLElement | null
      if (el) {
        trackCTAClick(
          el.dataset.trackCta!,
          el.textContent?.trim()
        )
      }

      const faq = (e.target as HTMLElement).closest('[data-track-faq]') as HTMLElement | null
      if (faq) {
        trackFAQOpen(
          faq.dataset.trackFaq!,
          Number(faq.dataset.trackFaqIndex || 0)
        )
      }

      const nav = (e.target as HTMLElement).closest('[data-track-nav]') as HTMLElement | null
      if (nav) {
        trackNavClick(
          nav.dataset.trackNav!,
          (nav as HTMLAnchorElement).href || '',
          'header'
        )
      }

      const outbound = (e.target as HTMLElement).closest('[data-track-outbound]') as HTMLElement | null
      if (outbound) {
        trackOutboundClick(
          (outbound as HTMLAnchorElement).href || '',
          outbound.dataset.trackOutbound!
        )
      }
    }

    document.addEventListener('click', handleClick)
    return () => document.removeEventListener('click', handleClick)
  }, [])

  return null
}
