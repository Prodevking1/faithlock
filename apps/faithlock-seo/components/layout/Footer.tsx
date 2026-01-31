import { NAV_LINKS, APP_STORE_URL, COMPANY } from '@/lib/constants'

export default function Footer() {
  return (
    <footer className="bg-brand-950 text-gray-300 mt-0">
      <div className="container-wide py-16">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-10 md:gap-8">
          {/* Brand */}
          <div className="col-span-2 md:col-span-1">
            <div className="flex items-center gap-2.5 mb-4">
              <div className="w-8 h-8 bg-brand-500 rounded-lg flex items-center justify-center">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                </svg>
              </div>
              <span className="text-lg font-bold text-white">FaithLock</span>
            </div>
            <p className="text-sm text-gray-400 leading-relaxed mb-4">
              Stop scrolling. Start Scripture. Turn phone addiction into daily devotion.
            </p>
            <p className="text-xs text-gray-500 italic">
              Faith over phone. Every time.
            </p>
          </div>

          {/* Explore */}
          <div>
            <h4 className="font-semibold text-white text-sm uppercase tracking-wider mb-4">
              Explore
            </h4>
            <ul className="space-y-3 text-sm">
              {NAV_LINKS.map((link) => (
                <li key={link.href}>
                  <a
                    href={link.href}
                    className="text-gray-400 hover:text-white transition-colors"
                  >
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          {/* Popular Comparisons */}
          <div>
            <h4 className="font-semibold text-white text-sm uppercase tracking-wider mb-4">
              Top Comparisons
            </h4>
            <ul className="space-y-3 text-sm">
              <li>
                <a
                  href="/compare/faithlock-vs-bible-mode"
                  className="text-gray-400 hover:text-white transition-colors"
                >
                  vs Bible Mode
                </a>
              </li>
              <li>
                <a
                  href="/compare/faithlock-vs-holy-focus"
                  className="text-gray-400 hover:text-white transition-colors"
                >
                  vs Holy Focus
                </a>
              </li>
              <li>
                <a
                  href="/compare/faithlock-vs-one-sec"
                  className="text-gray-400 hover:text-white transition-colors"
                >
                  vs One Sec
                </a>
              </li>
            </ul>
          </div>

          {/* Get FaithLock */}
          <div>
            <h4 className="font-semibold text-white text-sm uppercase tracking-wider mb-4">
              Download
            </h4>
            <a
              href={APP_STORE_URL}
              className="inline-flex items-center gap-2 bg-white text-brand-950 px-5 py-3 rounded-xl font-semibold text-sm hover:bg-gray-100 transition-all"
              target="_blank"
              rel="noopener noreferrer"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
              </svg>
              App Store
            </a>
            <p className="mt-3 text-xs text-gray-500">
              Free &middot; iOS 16+
            </p>
          </div>
        </div>

        {/* Bottom bar */}
        <div className="border-t border-gray-800/60 mt-12 pt-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-gray-500">
          <p>&copy; {new Date().getFullYear()} FaithLock by AppBiz Studio. All rights reserved.</p>
          <div className="flex items-center gap-6">
            <a href={COMPANY.privacyUrl} className="hover:text-gray-300 transition-colors">
              Privacy
            </a>
            <a href={COMPANY.termsUrl} className="hover:text-gray-300 transition-colors">
              Terms
            </a>
            <a href={`mailto:${COMPANY.email}`} className="hover:text-gray-300 transition-colors">
              Contact
            </a>
          </div>
        </div>
      </div>
    </footer>
  )
}
