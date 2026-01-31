'use client'

import { useState, useEffect } from 'react'

const WORDS = ['Instagram', 'TikTok', 'News', 'Twitter']

export default function TypewriterHeadline() {
  const [index, setIndex] = useState(0)
  const [visible, setVisible] = useState(true)

  useEffect(() => {
    const interval = setInterval(() => {
      setVisible(false)
      setTimeout(() => {
        setIndex((prev) => (prev + 1) % WORDS.length)
        setVisible(true)
      }, 200)
    }, 2500)
    return () => clearInterval(interval)
  }, [])

  return (
    <h1 className="text-5xl sm:text-6xl md:text-7xl font-semibold text-white tracking-tight leading-[1.05] mb-6">
      Stop scrolling <br />
      <span
        className="text-transparent bg-clip-text bg-gradient-to-r from-indigo-300 via-white to-indigo-300 transition-opacity duration-200"
        style={{ opacity: visible ? 1 : 0 }}
      >
        {WORDS[index]}
      </span>
      <span className="animate-typewriter text-indigo-400">|</span>
    </h1>
  )
}
