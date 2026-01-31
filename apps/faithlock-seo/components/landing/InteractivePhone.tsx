'use client'

import { useState } from 'react'

export default function InteractivePhone() {
  const [unlocked, setUnlocked] = useState(false)

  return (
    <div className="relative w-full flex justify-center perspective-[2000px] mt-10 lg:mt-0">
      {/* Interaction Hint */}
      <div className="absolute top-1/2 -right-4 md:-right-12 z-40 hidden md:flex items-center gap-2 animate-pulse-slow">
        <div className="bg-slate-800/80 backdrop-blur text-xs px-3 py-1.5 rounded-lg border border-white/10 text-white">
          Try it live
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="inline ml-1 text-white" strokeLinecap="round" strokeLinejoin="round">
            <path d="M3 3l7.07 16.97 2.51-7.39 7.39-2.51L3 3z" />
            <path d="M13 13l6 6" />
          </svg>
        </div>
        <div className="w-8 h-[1px] bg-slate-700" />
      </div>

      {/* Phone Container */}
      <div className="relative w-[280px] h-[580px] md:w-[320px] md:h-[640px] bg-black rounded-[3rem] iphone-border z-20 animate-float shadow-2xl shadow-indigo-900/30 transition-transform duration-500">
        {/* Dynamic Island */}
        <div className="absolute top-5 left-1/2 -translate-x-1/2 w-24 h-7 bg-black rounded-full z-50 flex items-center justify-between px-3 shadow-sm border border-white/5 pointer-events-none">
          <div className="w-1.5 h-1.5 rounded-full bg-indigo-500 animate-pulse" />
        </div>

        {/* Screen */}
        <div className={`relative w-full h-full rounded-[2.5rem] overflow-hidden bg-slate-950 flex flex-col select-none ${unlocked ? 'is-unlocked' : ''}`}>
          {/* Top Bar */}
          <div className="h-14 w-full flex items-end justify-between px-6 pb-2 text-[10px] font-medium text-white/90 z-20">
            <span>9:41</span>
            <div className="flex gap-1.5 text-white/70">
              <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor"><rect x="1" y="18" width="4" height="4" rx="1" /><rect x="7" y="12" width="4" height="10" rx="1" /><rect x="13" y="6" width="4" height="16" rx="1" /><rect x="19" y="1" width="4" height="21" rx="1" /></svg>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M5 12.55a11 11 0 0 1 14.08 0" /><path d="M1.42 9a16 16 0 0 1 21.16 0" /><path d="M8.53 16.11a6 6 0 0 1 6.95 0" /><circle cx="12" cy="20" r="1" fill="currentColor" /></svg>
              <svg width="14" height="12" viewBox="0 0 28 14" fill="currentColor"><rect x="0" y="1" width="24" height="12" rx="3" stroke="currentColor" strokeWidth="1.5" fill="none" /><rect x="25" y="4.5" width="2" height="5" rx="1" /><rect x="2" y="3" width="16" height="8" rx="1.5" className="text-green-400" /></svg>
            </div>
          </div>

          {/* STATE 1: LOCKED */}
          <div className="locked-screen absolute inset-0 flex flex-col items-center pt-24 px-5 z-10 h-full w-full">
            <div className="absolute top-1/4 left-0 right-0 h-64 bg-indigo-600/20 blur-3xl rounded-full pointer-events-none" />

            <div className="w-20 h-20 bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl flex items-center justify-center text-white mb-6 shadow-xl shadow-indigo-500/10">
              <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" className="text-white" strokeLinecap="round" strokeLinejoin="round">
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                <path d="M7 11V7a5 5 0 0 1 10 0v4" />
                <circle cx="12" cy="16" r="1" />
              </svg>
            </div>

            <div className="text-center mb-8">
              <h3 className="text-white text-xl font-semibold tracking-tight">App Locked</h3>
              <p className="text-xs text-slate-400 mt-2">Read to unlock</p>
            </div>

            {/* Verse Card */}
            <div className="w-full bg-slate-900/80 backdrop-blur-md border border-indigo-500/30 rounded-3xl p-6 relative overflow-hidden mb-auto">
              <div className="flex justify-between items-start mb-3">
                <span className="text-[9px] font-bold text-indigo-300 uppercase tracking-wider bg-indigo-500/10 px-2 py-0.5 rounded">
                  Daily Bread
                </span>
              </div>
              <p className="text-white font-serif text-lg leading-relaxed italic">
                &ldquo;I can do all things through Christ who strengthens me.&rdquo;
              </p>
              <p className="text-right text-xs text-slate-400 mt-3 font-medium">
                Philippians 4:13
              </p>
            </div>

            {/* Slider */}
            <button
              onClick={() => setUnlocked(true)}
              className="mb-10 w-full h-14 bg-slate-900 rounded-full border border-slate-800 flex items-center px-1.5 relative overflow-hidden group cursor-pointer shadow-inner"
            >
              <div className="absolute inset-0 flex items-center justify-center text-[10px] font-medium text-slate-500 tracking-widest uppercase pl-4 group-hover:text-white transition-colors">
                Slide to unlock
              </div>
              <div className="slider-handle w-11 h-11 bg-white rounded-full flex items-center justify-center text-slate-900 shadow-lg relative z-10 animate-slide-hint group-hover:scale-110">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <line x1="5" y1="12" x2="19" y2="12" />
                  <polyline points="12 5 19 12 12 19" />
                </svg>
              </div>
            </button>
          </div>

          {/* STATE 2: UNLOCKED */}
          <div className="unlocked-screen absolute inset-0 flex flex-col items-center justify-center bg-white z-20 h-full w-full">
            <div className="w-20 h-20 bg-emerald-100 rounded-full flex items-center justify-center text-emerald-600 mb-4 animate-bounce">
              <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                <polyline points="22 4 12 14.01 9 11.01" />
              </svg>
            </div>
            <h3 className="text-slate-900 text-xl font-bold tracking-tight">Unlocked!</h3>
            <p className="text-slate-500 text-xs mt-2 mb-8">You have 5 minutes of access.</p>
            <button
              onClick={() => setUnlocked(false)}
              className="px-6 py-2 bg-slate-900 text-white rounded-full text-xs font-medium hover:bg-slate-800 transition-colors"
            >
              Lock again
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
