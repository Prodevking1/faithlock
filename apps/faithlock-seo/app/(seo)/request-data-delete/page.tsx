import { Metadata } from 'next'
import RequestDataDeleteForm from './RequestDataDeleteForm'

export const metadata: Metadata = {
  title: 'Request Data Deletion — FaithLock',
  description:
    'Submit a request to delete your FaithLock account and all associated personal data.',
  alternates: { canonical: '/request-data-delete' },
}

export default function RequestDataDeletePage() {
  return (
    <div className="cozy-page">
      <div className="cozy-hero">
        <div className="container-narrow py-14 md:py-20">
          <nav className="cozy-breadcrumb mb-8">
            <a href="/">Home</a>
            <span className="cozy-breadcrumb-separator">/</span>
            <span>Request Data Deletion</span>
          </nav>
          <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold mb-4 tracking-tight text-cozy-ink">
            Request Data Deletion
          </h1>
          <p className="text-cozy-ink-muted max-w-2xl">
            Use this form to ask us to delete your FaithLock account and all personal data
            associated with it. We respond within 30 days.
          </p>
        </div>
      </div>

      <div className="container-narrow py-12 md:py-16">
        <RequestDataDeleteForm />
      </div>
    </div>
  )
}
