import { ExternalLink, FileCheck2 } from 'lucide-react'
import { useEffect, useState } from 'react'

import { listVerificationDocuments, reviewVerificationDocument } from '../../../../../core/lib'
import type { VerificationDocument, VerificationDocumentStatus } from '../../../../../core/lib'

function label(value: string) {
	return value.replaceAll('_', ' ').replace(/\b\w/g, (letter) => letter.toUpperCase())
}

export function AdminVerificationDocumentsPanel({ userId }: { userId: number }) {
	const [documents, setDocuments] = useState<VerificationDocument[]>([])
	const [notes, setNotes] = useState<Record<string, string>>({})
	const [loading, setLoading] = useState(true)
	const [busy, setBusy] = useState<string | null>(null)
	const [error, setError] = useState('')
	const [message, setMessage] = useState('')

	useEffect(() => {
		let active = true
		setLoading(true)
		listVerificationDocuments(userId).then((items) => {
			if (active) setDocuments(items)
		}).catch(() => {
			if (active) setError('Could not load verification documents.')
		}).finally(() => {
			if (active) setLoading(false)
		})
		return () => { active = false }
	}, [userId])

	const review = async (document: VerificationDocument, status: VerificationDocumentStatus) => {
		setBusy(document.uuid)
		setError('')
		setMessage('')
		try {
			const updated = await reviewVerificationDocument(document.uuid, { status, notes: notes[document.uuid] ?? document.notes ?? '' })
			setDocuments((current) => current.map((item) => item.uuid === updated.uuid ? updated : item))
			setMessage(`${label(document.document_type)} marked ${status}.`)
		} catch {
			setError('The document review could not be saved.')
		} finally {
			setBusy(null)
		}
	}

	return <section className="border-t border-border pt-4">
		<h3 className="flex items-center gap-2 text-sm font-semibold"><FileCheck2 className="h-4 w-4" />Verification documents</h3>
		{loading ? <p className="mt-3 text-sm text-muted-foreground">Loading documents…</p> : documents.length === 0 ? <p className="mt-3 text-sm text-muted-foreground">No documents submitted.</p> : <div className="mt-3 space-y-3">{documents.map((document) => <article key={document.uuid} className="rounded-lg border border-border p-3">
			<div className="flex flex-wrap items-start justify-between gap-2"><div><p className="text-sm font-semibold">{label(document.document_type)}</p><p className="mt-1 text-xs text-muted-foreground">{document.document_number || 'No document number'} · {document.status}</p></div>{document.file && <a href={document.file} target="_blank" rel="noreferrer" className="inline-flex h-8 w-8 items-center justify-center rounded-md border border-border text-primary hover:bg-muted" aria-label={`Open ${label(document.document_type)}`}><ExternalLink className="h-4 w-4" /></a>}</div>
			<textarea aria-label={`Review notes for ${label(document.document_type)}`} rows={2} value={notes[document.uuid] ?? document.notes ?? ''} onChange={(event) => setNotes((current) => ({ ...current, [document.uuid]: event.target.value }))} placeholder="Review note for the account holder" className="mt-3 w-full rounded-md border border-border bg-background px-3 py-2 text-sm" />
			<div className="mt-2 flex flex-wrap gap-2">
				<button type="button" disabled={busy === document.uuid} onClick={() => void review(document, 'approved')} className="min-h-9 rounded-md bg-emerald-700 px-3 text-xs font-semibold text-white hover:bg-emerald-800 disabled:opacity-50">Approve</button>
				<button type="button" disabled={busy === document.uuid} onClick={() => void review(document, 'rejected')} className="min-h-9 rounded-md bg-red-700 px-3 text-xs font-semibold text-white hover:bg-red-800 disabled:opacity-50">Reject</button>
				<button type="button" disabled={busy === document.uuid} onClick={() => void review(document, 'reviewed')} className="min-h-9 rounded-md border border-border px-3 text-xs font-semibold hover:bg-muted disabled:opacity-50">Mark reviewed</button>
			</div>
		</article>)}</div>}
		{message && <p role="status" className="mt-3 text-xs font-medium text-emerald-700">{message}</p>}
		{error && <p role="alert" className="mt-3 text-xs font-medium text-destructive">{error}</p>}
	</section>
}