'use client'

import { useState } from 'react'
import { COMPANY } from '@/lib/faithlock-data'

type Status = 'idle' | 'submitting' | 'success' | 'error'

export default function RequestDataDeleteForm() {
  const [status, setStatus] = useState<Status>('idle')
  const [errorMsg, setErrorMsg] = useState<string | null>(null)

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setStatus('submitting')
    setErrorMsg(null)

    const form = e.currentTarget
    const data = new FormData(form)

    const email = String(data.get('email') ?? '').trim()
    const userId = String(data.get('userId') ?? '').trim()
    const reason = String(data.get('reason') ?? '').trim()
    const confirm = data.get('confirm') === 'on'

    if (!email || !confirm) {
      setStatus('error')
      setErrorMsg('Please fill in your email and confirm the request.')
      return
    }

    // No backend yet — open a pre-filled support email so the request reaches
    // us with all the context we need to action it within 30 days.
    const subject = encodeURIComponent('Data deletion request — FaithLock')
    const body = encodeURIComponent(
      [
        'Hi FaithLock team,',
        '',
        'I am requesting deletion of my FaithLock account and personal data.',
        '',
        `Email associated with the account: ${email}`,
        userId ? `In-app user ID (if known): ${userId}` : '',
        reason ? `Reason (optional): ${reason}` : '',
        '',
        'I confirm that I am the owner of this account and that I understand the deletion is permanent.',
        '',
        'Thanks.',
      ]
        .filter(Boolean)
        .join('\n'),
    )

    window.location.href = `mailto:${COMPANY.email}?subject=${subject}&body=${body}`
    setStatus('success')
    form.reset()
  }

  return (
    <div className="card p-6 sm:p-8">
      <p className="text-gray-700 mb-6 leading-relaxed">
        Submitting this form will email our privacy team. We may contact the email address
        below to verify your identity before processing the request, in line with our{' '}
        <a href="/privacy" className="text-brand-600 underline decoration-brand-300 underline-offset-2 hover:text-brand-800">
          Privacy Policy
        </a>
        .
      </p>

      <form onSubmit={handleSubmit} className="space-y-5">
        <div>
          <label htmlFor="email" className="block text-sm font-medium text-gray-900 mb-1.5">
            Email used in the app <span className="text-red-500">*</span>
          </label>
          <input
            id="email"
            name="email"
            type="email"
            required
            autoComplete="email"
            className="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm shadow-sm focus:border-brand-500 focus:outline-none focus:ring-2 focus:ring-brand-200"
            placeholder="you@example.com"
          />
        </div>

        <div>
          <label htmlFor="userId" className="block text-sm font-medium text-gray-900 mb-1.5">
            In-app user ID <span className="text-gray-400 font-normal">(optional)</span>
          </label>
          <input
            id="userId"
            name="userId"
            type="text"
            className="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm shadow-sm focus:border-brand-500 focus:outline-none focus:ring-2 focus:ring-brand-200"
            placeholder="If you know your FaithLock user ID, paste it here"
          />
          <p className="mt-1.5 text-xs text-gray-500">
            You can find this in the app under Profile → Settings → About.
          </p>
        </div>

        <div>
          <label htmlFor="reason" className="block text-sm font-medium text-gray-900 mb-1.5">
            Reason <span className="text-gray-400 font-normal">(optional)</span>
          </label>
          <textarea
            id="reason"
            name="reason"
            rows={4}
            className="w-full rounded-lg border border-gray-200 bg-white px-3.5 py-2.5 text-sm shadow-sm focus:border-brand-500 focus:outline-none focus:ring-2 focus:ring-brand-200"
            placeholder="Help us improve — tell us why you're leaving (optional)"
          />
        </div>

        <label className="flex items-start gap-3 text-sm text-gray-700">
          <input
            type="checkbox"
            name="confirm"
            required
            className="mt-1 h-4 w-4 rounded border-gray-300 text-brand-600 focus:ring-brand-500"
          />
          <span>
            I confirm I am the owner of this account and I understand that deletion is
            <strong> permanent</strong> and cannot be undone.
          </span>
        </label>

        {errorMsg && (
          <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
            {errorMsg}
          </div>
        )}

        {status === 'success' && (
          <div className="rounded-lg border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-800">
            Your email client should have opened with a pre-filled message. Send it and we
            will respond within 30 days. If nothing happened, email us directly at{' '}
            <a href={`mailto:${COMPANY.email}`} className="underline">
              {COMPANY.email}
            </a>
            .
          </div>
        )}

        <button
          type="submit"
          disabled={status === 'submitting'}
          className="inline-flex items-center justify-center rounded-lg bg-brand-600 px-5 py-2.5 text-sm font-semibold text-white shadow-sm transition-colors hover:bg-brand-700 focus:outline-none focus:ring-2 focus:ring-brand-500 focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-60"
        >
          {status === 'submitting' ? 'Submitting…' : 'Submit deletion request'}
        </button>
      </form>

      <div className="mt-8 border-t border-gray-100 pt-6 text-sm text-gray-600">
        <p className="mb-2 font-medium text-gray-900">Prefer email?</p>
        <p>
          Email{' '}
          <a
            href={`mailto:${COMPANY.email}?subject=Data%20deletion%20request%20%E2%80%94%20FaithLock`}
            className="text-brand-600 underline decoration-brand-300 underline-offset-2 hover:text-brand-800"
          >
            {COMPANY.email}
          </a>{' '}
          with the subject &ldquo;Data deletion request&rdquo; from the address linked to your
          FaithLock account.
        </p>
      </div>
    </div>
  )
}
