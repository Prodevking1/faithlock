import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import { SITE_NAME, SITE_DESCRIPTION, SITE_URL, SITE_TAGLINE, APP_STORE_URL } from '@/lib/constants'
import { PostHogProvider } from './providers'
import SchemaMarkup from '@/components/seo/SchemaMarkup'
import './globals.css'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
})

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: `${SITE_NAME} \u2014 ${SITE_TAGLINE}`,
    template: `%s | ${SITE_NAME}`,
  },
  description: SITE_DESCRIPTION,
  openGraph: {
    type: 'website',
    siteName: SITE_NAME,
    locale: 'en_US',
  },
  twitter: {
    card: 'summary_large_image',
  },
  robots: {
    index: true,
    follow: true,
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={inter.variable}>
      <body className="font-sans antialiased">
        <SchemaMarkup
          data={[
            {
              '@context': 'https://schema.org',
              '@type': 'WebSite',
              name: SITE_NAME,
              url: SITE_URL,
              publisher: {
                '@type': 'Organization',
                name: SITE_NAME,
                url: SITE_URL,
              },
            },
            {
              '@context': 'https://schema.org',
              '@type': 'SoftwareApplication',
              name: SITE_NAME,
              applicationCategory: 'LifestyleApplication',
              operatingSystem: 'iOS',
              offers: {
                '@type': 'Offer',
                price: '0',
                priceCurrency: 'USD',
              },
              url: APP_STORE_URL,
            },
          ]}
        />
        <PostHogProvider>{children}</PostHogProvider>
      </body>
    </html>
  )
}
