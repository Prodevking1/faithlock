import { COMPANY } from '@/lib/constants'
import InteractivePhone from '@/components/landing/InteractivePhone'
import TypewriterHeadline from '@/components/landing/TypewriterHeadline'
import ScrollReveal from '@/components/landing/ScrollReveal'

const APP_LINK = 'https://pim.ms/kTxgKF4'

export default function LandingPage() {
  return (
    <div className="bg-slate-950 text-slate-400 font-sans antialiased overflow-x-hidden pb-32 md:pb-0">
      <ScrollReveal />

      {/* ── Navigation ── */}
      <nav className="fixed top-0 w-full z-50 border-b border-white/5 bg-slate-950/80 backdrop-blur-xl transition-all duration-500">
        <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
          <a href="/" className="flex items-center gap-2 group">
            <div className="w-8 h-8 bg-gradient-to-tr from-indigo-50 to-indigo-100 text-indigo-950 rounded-lg flex items-center justify-center shadow-lg shadow-indigo-500/20 group-hover:scale-105 transition-transform duration-300">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                <polyline points="9 12 11 14 15 10" />
              </svg>
            </div>
            <span className="text-white font-medium tracking-tight text-sm">FaithLock</span>
          </a>

          <div className="hidden md:flex items-center gap-8 text-sm font-medium text-slate-400">
            <a href="#how-it-works" className="hover:text-white transition-colors">How it Works</a>
            <a href="#reviews" className="hover:text-white transition-colors">Stories</a>
            <a href="#faq" className="hover:text-white transition-colors">FAQ</a>
            <a href="/compare" className="hover:text-white transition-colors">Compare</a>
            <a href="/learn" className="hover:text-white transition-colors">Learn</a>
            <a href="/features" className="hover:text-white transition-colors">Features</a>
          </div>

          <div className="hidden md:flex items-center gap-4">
            <a
              href={APP_LINK}
              className="relative group overflow-hidden text-xs font-semibold bg-white text-slate-950 px-5 py-2.5 rounded-full hover:bg-indigo-50 transition-all shadow-lg shadow-white/10 flex items-center gap-2"
            >
              <span className="relative z-10 flex items-center gap-2">
                Get App
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="-mr-1 group-hover:translate-x-0.5 transition-transform" strokeLinecap="round" strokeLinejoin="round">
                  <polyline points="9 18 15 12 9 6" />
                </svg>
              </span>
            </a>
          </div>
        </div>
      </nav>

      {/* ── Mobile Sticky CTA ── */}
      <div className="md:hidden fixed bottom-0 left-0 w-full z-[60] px-5 py-4 sticky-blur flex items-center justify-between gap-4">
        <div className="flex flex-col">
          <span className="text-white text-sm font-semibold">Try it free</span>
          <span className="text-xs text-slate-400">Available on iOS</span>
        </div>
        <a
          href={APP_LINK}
          className="bg-white text-slate-950 h-11 px-6 rounded-full font-semibold text-sm flex items-center justify-center gap-2 shadow-lg active:scale-95 transition-transform"
        >
          Get Started
        </a>
      </div>

      {/* ── Hero ── */}
      <header className="relative pt-32 pb-16 md:pt-48 md:pb-32 overflow-hidden">
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[200%] h-[600px] md:w-[1000px] bg-indigo-600/10 rounded-[100%] blur-[100px] pointer-events-none opacity-40 animate-pulse-slow" />

        <div className="max-w-6xl mx-auto px-6 grid lg:grid-cols-2 gap-12 lg:gap-16 items-center relative z-10">
          <div className="text-center lg:text-left flex flex-col items-center lg:items-start">
            {/* Social Proof Pill */}
            <a
              href="#reviews"
              className="reveal-view inline-flex items-center gap-2 mb-8 p-1 pl-1 pr-3 rounded-full border border-indigo-500/20 bg-indigo-950/30 backdrop-blur-md hover:border-indigo-500/40 transition-colors cursor-pointer shadow-lg shadow-indigo-900/20 group"
            >
              <div className="flex -space-x-2">
                <div className="w-6 h-6 rounded-full border-2 border-slate-900 bg-indigo-800 flex items-center justify-center text-[8px] text-white font-bold">J</div>
                <div className="w-6 h-6 rounded-full border-2 border-slate-900 bg-violet-800 flex items-center justify-center text-[8px] text-white font-bold">M</div>
                <div className="w-6 h-6 rounded-full border-2 border-slate-900 bg-slate-700 flex items-center justify-center text-[8px] text-white font-bold">S</div>
              </div>
              <span className="text-xs font-medium text-indigo-200 group-hover:text-white transition-colors">
                Join the Movement
              </span>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-indigo-400" strokeLinecap="round" strokeLinejoin="round">
                <line x1="5" y1="12" x2="19" y2="12" /><polyline points="12 5 19 12 12 19" />
              </svg>
            </a>

            <div className="reveal-view reveal-delay-100">
              <TypewriterHeadline />
            </div>

            <p className="reveal-view reveal-delay-200 text-base md:text-lg text-slate-400 max-w-lg leading-relaxed mb-10 font-light">
              The only app blocker that unlocks your phone with Scripture. Break the dopamine loop and reconnect with God in seconds.
            </p>

            <div className="reveal-view reveal-delay-300 flex flex-col sm:flex-row items-center gap-4 w-full md:w-auto">
              <a
                href={APP_LINK}
                className="w-full sm:w-auto px-8 py-4 bg-white text-slate-950 rounded-full font-semibold text-sm hover:bg-slate-200 transition-all flex items-center justify-center gap-2 hover:scale-105 active:scale-95 duration-200 shadow-[0_0_30px_rgba(255,255,255,0.15)] animate-glow-pulse"
              >
                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
                Download for iOS
              </a>
              <div className="flex flex-col items-center sm:items-start gap-1 ml-2">
                <div className="flex text-amber-400 text-xs gap-0.5">
                  {[...Array(5)].map((_, i) => (
                    <svg key={i} width="12" height="12" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" /></svg>
                  ))}
                </div>
                <span className="text-[10px] text-slate-500">Available on the App Store</span>
              </div>
            </div>
          </div>

          {/* Interactive Phone */}
          <div className="reveal-view reveal-delay-200">
            <InteractivePhone />
          </div>
        </div>
      </header>

      {/* ── How it Works / Features ── */}
      <section id="how-it-works" className="py-20 bg-slate-950 relative">
        <div className="max-w-6xl mx-auto px-6">
          <div className="text-center mb-16 max-w-2xl mx-auto">
            <span className="text-indigo-400 font-medium text-xs tracking-widest uppercase mb-2 block">The Method</span>
            <h2 className="reveal-view text-3xl md:text-4xl font-semibold text-white tracking-tight mb-4">
              Replace dopamine with Truth.
            </h2>
            <p className="reveal-view reveal-delay-100 text-slate-400 text-sm leading-relaxed">
              Willpower fails. Systems work. We&apos;ve built a system that turns your greatest distraction into your spiritual gym.
            </p>
          </div>

          {/* Bento Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
            {/* Card 1: Core Feature */}
            <div className="md:col-span-2 bento-card rounded-[2rem] p-8 md:p-10 relative overflow-hidden group reveal-view reveal-delay-100 cursor-default">
              <div className="relative z-10 flex flex-col h-full items-start">
                <div className="w-10 h-10 bg-indigo-500/10 text-indigo-400 rounded-xl flex items-center justify-center mb-6 border border-indigo-500/20 group-hover:bg-indigo-500 group-hover:text-white transition-all duration-300">
                  <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z" />
                    <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z" />
                  </svg>
                </div>
                <h3 className="text-xl md:text-2xl font-semibold text-white mb-2">The Verse Barrier</h3>
                <p className="text-slate-400 text-sm max-w-sm leading-relaxed">
                  Most blockers just say &ldquo;No&rdquo;. FaithLock says &ldquo;Yes, but first...&rdquo;.
                  Pause for 15 seconds of scripture. It disrupts the habit loop instantly.
                </p>
              </div>
              <div className="absolute right-0 bottom-0 translate-y-8 translate-x-8 group-hover:translate-y-4 group-hover:translate-x-4 transition-transform duration-500">
                <div className="bg-slate-900 border border-white/10 rounded-tl-2xl p-4 shadow-2xl w-56">
                  <div className="flex items-center gap-3 mb-3">
                    <div className="w-2 h-2 rounded-full bg-red-500" />
                    <div className="h-1.5 w-20 bg-slate-800 rounded-full" />
                  </div>
                  <div className="h-1.5 w-32 bg-slate-800 rounded-full mb-2" />
                  <div className="h-1.5 w-24 bg-slate-800 rounded-full" />
                </div>
              </div>
            </div>

            {/* Card 2: Stats (Tall) */}
            <div className="md:col-span-1 md:row-span-2 bento-card rounded-[2rem] p-8 flex flex-col relative overflow-hidden group reveal-view reveal-delay-200">
              <div className="flex items-center justify-between mb-6">
                <div className="w-10 h-10 bg-emerald-500/10 text-emerald-400 rounded-xl flex items-center justify-center border border-emerald-500/20">
                  <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <polyline points="22 12 18 12 15 21 9 3 6 12 2 12" />
                  </svg>
                </div>
              </div>
              <h4 className="text-lg font-medium text-white">Screen Time ROI</h4>
              <p className="text-xs text-slate-400 mt-2 mb-8">Track scripture read vs. time saved. Measure your spiritual growth.</p>
              <div className="mt-auto relative h-32 flex items-end justify-between gap-2 px-2">
                <div className="w-full bg-slate-800 rounded-t-sm h-[30%]" />
                <div className="w-full bg-slate-800 rounded-t-sm h-[50%]" />
                <div className="w-full bg-gradient-to-t from-emerald-600 to-emerald-400 rounded-t-sm h-[80%] shadow-[0_0_20px_rgba(16,185,129,0.2)] group-hover:h-[95%] transition-all duration-500 relative">
                  <div className="absolute -top-6 left-1/2 -translate-x-1/2 text-[9px] font-bold text-emerald-400 opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">
                    You
                  </div>
                </div>
                <div className="w-full bg-slate-800 rounded-t-sm h-[40%]" />
              </div>
            </div>

            {/* Card 3: Sabbath Mode */}
            <div className="md:col-span-1 bento-card rounded-[2rem] p-8 relative overflow-hidden group reveal-view reveal-delay-200">
              <div className="relative z-10">
                <div className="flex items-center gap-3 mb-4">
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-amber-400" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                    <path d="M12 8v4" /><path d="M12 16h.01" />
                  </svg>
                  <span className="text-[10px] uppercase font-bold text-amber-500 tracking-wider bg-amber-500/10 px-2 py-0.5 rounded">Pro Feature</span>
                </div>
                <h4 className="text-lg font-medium text-white">Sabbath Mode</h4>
                <p className="text-xs text-slate-400 mt-2 leading-relaxed">Lock apps completely for set durations. Perfect for deep prayer or family time.</p>
              </div>
            </div>

            {/* Card 4: One-Tap */}
            <div className="md:col-span-1 bento-card rounded-[2rem] p-8 relative overflow-hidden group reveal-view reveal-delay-300">
              <div className="relative z-10">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-violet-400 mb-4" strokeLinecap="round" strokeLinejoin="round">
                  <rect x="3" y="3" width="7" height="7" /><rect x="14" y="3" width="7" height="7" /><rect x="14" y="14" width="7" height="7" /><rect x="3" y="14" width="7" height="7" />
                </svg>
                <h4 className="text-lg font-medium text-white">One-Tap Block</h4>
                <p className="text-xs text-slate-400 mt-2 leading-relaxed">Block &ldquo;Social Media&rdquo; or &ldquo;Games&rdquo; instantly. No complex setup required.</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── Reviews ── */}
      <section id="reviews" className="py-24 border-t border-white/5 bg-slate-900/20">
        <div className="max-w-6xl mx-auto px-6">
          <h2 className="reveal-view text-2xl md:text-3xl font-semibold text-white text-center mb-16">
            Stories from the Community
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {[
              {
                text: 'I used to scroll TikTok for an hour before bed. Now I read a Psalm to unlock it, and honestly, half the time I don\'t even open TikTok afterwards. The desire just fades.',
                name: 'James D.',
                role: 'Youth Pastor',
                initials: 'JD',
                highlight: false,
              },
              {
                text: 'This isn\'t just an app blocker, it\'s a liturgy. It has completely changed my morning routine from doomscrolling to prayer.',
                name: 'Marcus L.',
                role: 'Entrepreneur',
                initials: 'ML',
                highlight: true,
              },
              {
                text: 'Finally an app that helps me use my phone less without making me feel guilty. It just redirects my attention to what matters.',
                name: 'Sarah H.',
                role: 'Student',
                initials: 'S',
                highlight: false,
              },
            ].map((review, i) => (
              <div
                key={i}
                className={`reveal-view ${i === 1 ? 'reveal-delay-100' : i === 2 ? 'reveal-delay-200' : ''} bento-card p-6 rounded-2xl ${review.highlight ? 'bg-indigo-500/10 border-indigo-500/30' : 'hover:bg-white/5'} transition-colors`}
              >
                <div className="flex gap-1 text-amber-400 mb-4 text-[10px]">
                  {[...Array(5)].map((_, j) => (
                    <svg key={j} width="12" height="12" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" /></svg>
                  ))}
                </div>
                <p className={`${review.highlight ? 'text-indigo-100 font-medium' : 'text-slate-300 font-light'} text-sm leading-relaxed mb-6`}>
                  &ldquo;{review.text}&rdquo;
                </p>
                <div className={`flex items-center gap-3 pt-4 border-t ${review.highlight ? 'border-indigo-500/20' : 'border-white/5'}`}>
                  <div className={`w-9 h-9 rounded-full ${review.highlight ? 'bg-indigo-700' : i === 2 ? 'bg-violet-900' : 'bg-slate-700'} flex items-center justify-center text-xs text-white font-medium`}>
                    {review.initials}
                  </div>
                  <div>
                    <div className="text-white text-xs font-medium">{review.name}</div>
                    <div className={`${review.highlight ? 'text-indigo-300' : 'text-slate-500'} text-[10px]`}>{review.role}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── FAQ ── */}
      <section id="faq" className="py-16 bg-slate-950">
        <div className="max-w-3xl mx-auto px-6">
          <h2 className="text-2xl font-semibold text-white mb-8">Frequently Asked</h2>
          <div className="space-y-4">
            {[
              {
                q: 'Does it really work for TikTok and Instagram?',
                a: 'Yes. FaithLock integrates deeply with iOS Screen Time API to block any app you choose until the scripture requirement is met.',
              },
              {
                q: 'Is it easy to uninstall?',
                a: "We don't hold your phone hostage. You can uninstall anytime, but we bet you won't want to once you feel the peace it brings.",
              },
              {
                q: 'Is my data private?',
                a: 'All data stays on your device. We never sell data, never track browsing, and never share personal information.',
              },
            ].map((faq, i) => (
              <details key={i} className="group bg-slate-900/50 rounded-xl border border-white/5 overflow-hidden">
                <summary className="flex justify-between items-center p-4 cursor-pointer">
                  <span className="text-sm font-medium text-slate-300">{faq.q}</span>
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-slate-500 transition-transform group-open:rotate-180 flex-shrink-0 ml-2" strokeLinecap="round" strokeLinejoin="round">
                    <polyline points="6 9 12 15 18 9" />
                  </svg>
                </summary>
                <div className="px-4 pb-4 text-xs text-slate-400 leading-relaxed">{faq.a}</div>
              </details>
            ))}
          </div>
        </div>
      </section>

      {/* ── CTA ── */}
      <section className="py-16 md:py-24 px-4 md:px-6">
        <div id="download" className="reveal-view max-w-5xl mx-auto relative rounded-[2.5rem] overflow-hidden bg-indigo-600 shadow-2xl shadow-indigo-900/50 group">
          <div className="absolute inset-0 bg-gradient-to-br from-indigo-500 to-violet-700 transition-transform duration-[2s] group-hover:scale-105" />
          <div className="absolute top-0 right-0 w-64 h-64 bg-white/10 rounded-full blur-[80px]" />

          <div className="relative z-10 flex flex-col md:flex-row items-center justify-between p-10 md:p-16 gap-10">
            <div className="text-center md:text-left flex-1">
              <h2 className="text-3xl md:text-5xl font-semibold text-white tracking-tight mb-6">
                Build the habit<br />today.
              </h2>
              <p className="text-indigo-100 text-base mb-8 max-w-sm mx-auto md:mx-0">
                Join thousands of Christians using technology to fuel their faith.
              </p>

              <a
                href={APP_LINK}
                className="inline-flex bg-white text-indigo-950 px-8 py-4 rounded-full font-semibold text-sm hover:bg-indigo-50 transition-all hover:scale-105 active:scale-95 items-center justify-center gap-2 shadow-xl shadow-indigo-900/20 w-full md:w-auto"
              >
                <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
                </svg>
                Download on App Store
              </a>

              <div className="mt-6 flex flex-wrap justify-center md:justify-start gap-x-6 gap-y-2 text-xs font-medium text-indigo-200/80">
                <span className="flex items-center gap-1">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" /><polyline points="22 4 12 14.01 9 11.01" /></svg>
                  No credit card required
                </span>
                <span className="flex items-center gap-1">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" /></svg>
                  Private &amp; Secure
                </span>
              </div>
            </div>

            <div className="relative w-full md:w-80 flex justify-center">
              <div className="w-40 h-40 bg-white/10 backdrop-blur-md border border-white/20 rounded-3xl flex flex-col items-center justify-center text-white shadow-2xl rotate-6 group-hover:rotate-0 transition-all duration-500">
                <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                  <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                  <path d="M7 11V7a5 5 0 0 1 9.9-1" />
                  <circle cx="12" cy="16" r="1" />
                </svg>
              </div>
              <div className="absolute top-4 -right-4 bg-white text-indigo-600 px-3 py-1 rounded-full text-xs font-bold shadow-lg animate-bounce">
                Start Free
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── Explore More ── */}
      <section className="py-12 border-t border-white/5">
        <div className="max-w-6xl mx-auto px-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <a href="/compare" className="bento-card rounded-2xl p-6 hover:bg-white/5 transition-colors group">
              <span className="text-[10px] uppercase font-bold text-indigo-400 tracking-wider mb-2 block">Compare</span>
              <h3 className="text-white font-medium mb-1">FaithLock vs Others</h3>
              <p className="text-xs text-slate-500">See how we compare to other screen time apps</p>
            </a>
            <a href="/learn" className="bento-card rounded-2xl p-6 hover:bg-white/5 transition-colors group">
              <span className="text-[10px] uppercase font-bold text-emerald-400 tracking-wider mb-2 block">Learn</span>
              <h3 className="text-white font-medium mb-1">Digital Wellness Guide</h3>
              <p className="text-xs text-slate-500">Biblical perspectives on phone addiction</p>
            </a>
            <a href="/features" className="bento-card rounded-2xl p-6 hover:bg-white/5 transition-colors group">
              <span className="text-[10px] uppercase font-bold text-violet-400 tracking-wider mb-2 block">Features</span>
              <h3 className="text-white font-medium mb-1">Everything Inside</h3>
              <p className="text-xs text-slate-500">Bible quiz, covenant tracking, scheduling & more</p>
            </a>
          </div>
        </div>
      </section>

      {/* ── Footer ── */}
      <footer className="pb-24 md:pb-12 pt-0">
        <div className="max-w-6xl mx-auto px-6 flex flex-col md:flex-row justify-between items-center gap-6 border-t border-white/5 pt-8 text-center md:text-left">
          <p className="text-slate-600 text-xs">Created by Appbiz Studio LLC</p>
          <div className="flex flex-col md:flex-row gap-4 md:gap-8 text-xs text-slate-500 items-center">
            <a href={COMPANY.privacyUrl} target="_blank" rel="noopener noreferrer" className="hover:text-slate-300 transition-colors">Privacy Policy</a>
            <a href={COMPANY.termsUrl} target="_blank" rel="noopener noreferrer" className="hover:text-slate-300 transition-colors">Terms</a>
            <div className="flex gap-1">
              <span>Need help?</span>
              <a href={`mailto:${COMPANY.email}`} className="text-indigo-400 hover:text-indigo-300 transition-colors">{COMPANY.email}</a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}
