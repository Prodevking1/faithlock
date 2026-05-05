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
    <div>
      <div className="bg-hero-pattern text-white">
        <div className="container-narrow py-14 md:py-20">
          <nav className="breadcrumb mb-8 text-white/50">
            <a href="/" className="hover:text-white/80">Home</a>
            <span className="breadcrumb-separator text-white/30">/</span>
            <span className="text-white/70">Request Data Deletion</span>
          </nav>
          <h1 className="text-3xl sm:text-4xl md:text-5xl font-bold mb-4 tracking-tight">
            Request Data Deletion
          </h1>
          <p className="text-white/70 max-w-2xl">
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
