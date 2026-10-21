import { ExternalLink, FileCheck2, Upload } from 'lucide-react'
import { useEffect, useRef, useState, type FormEvent } from 'react'

import { listVerificationDocuments, uploadVerificationDocument } from '../../../core/lib'
import type { AuthRole, VerificationDocument, VerificationDocumentType } from '../../../core/lib'
import { Button, Select } from '../../../shared/components/ui'

const roleDocuments: Record<AuthRole, Array<{ value: VerificationDocumentType; label: string }>> = {
	buyer: [{ value: 'national_id', label: 'National ID' }],
	farmer: [{ value: 'national_id', label: 'National ID' }, { value: 'coop_certificate', label: 'Cooperative certificate' }],
	retailer: [{ value: 'national_id', label: 'National ID' }, { value: 'business_license', label: 'Business license' }],
	transport_provider: [{ value: 'national_id', label: 'National ID' }, { value: 'driver_license', label: 'Driver license' }],
}

const statusStyles: Record<string, string> = {
	submitted: 'bg-amber-100 text-amber-800',
	reviewed: 'bg-sky-100 text-sky-800',
	approved: 'bg-emerald-100 text-emerald-800',
	rejected: 'bg-red-100 text-red-800',
}

function isAuthRole(role?: string): role is AuthRole {
	return Boolean(role && Object.prototype.hasOwnProperty.call(roleDocuments, role))
}

function documentLabel(type: string) {
	return type.replaceAll('_', ' ').replace(/\b\w/g, (letter) => letter.toUpperCase())
}

export function VerificationDocumentsPanel({ role }: { role?: string }) {
	const [documents, setDocuments] = useState<VerificationDocument[]>([])
	const [documentType, setDocumentType] = useState<VerificationDocumentType>('national_id')
	const [documentNumber, setDocumentNumber] = useState('')
	const [expiryDate, setExpiryDate] = useState('')
	const [file, setFile] = useState<File | null>(null)
	const [loading, setLoading] = useState(true)
	const [uploading, setUploading] = useState(false)
	const [error, setError] = useState('')
	const [message, setMessage] = useState('')
	const fileInputRef = useRef<HTMLInputElement>(null)
	const supportedRole = isAuthRole(role) ? role : undefined
	const choices = supportedRole ? roleDocuments[supportedRole] : []

	useEffect(() => {
		let active = true
		listVerificationDocuments().then((items) => {
			if (active) setDocuments(items)
		}).catch(() => {
			if (active) setError('Verification documents could not be loaded.')
		}).finally(() => {
			if (active) setLoading(false)
		})
		return () => { active = false }
	}, [])

	useEffect(() => {
		if (choices.length && !choices.some((choice) => choice.value === documentType)) setDocumentType(choices[0].value)
	}, [choices, documentType])

	const upload = async (event: FormEvent<HTMLFormElement>) => {
		event.preventDefault()
		if (!file || !supportedRole) return
		setUploading(true)
		setError('')
		setMessage('')
		try {
			const document = await uploadVerificationDocument({
				document_type: documentType,
				document_number: documentNumber.trim(),
				expiry_date: expiryDate,
				file,
			})
			setDocuments((current) => [document, ...current])
			setFile(null)
			setDocumentNumber('')
			setExpiryDate('')
			if (fileInputRef.current) fileInputRef.current.value = ''
			setMessage('Document submitted for review.')
		} catch {
			setError('Document upload failed. Check the file and try again.')
		} finally {
			setUploading(false)
		}
	}

	return <section className="mt-4 rounded-xl border border-border bg-card p-4 shadow-sm sm:rounded-2xl sm:p-5">
		<div className="flex items-start gap-3">
			<span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary"><FileCheck2 className="h-5 w-5" /></span>
			<div><h2 className="text-base font-semibold text-primary-dark">Verification documents</h2><p className="mt-1 text-xs text-muted-foreground">Upload role-specific documents and check their review status.</p></div>
		</div>
		{supportedRole && <form onSubmit={(event) => void upload(event)} className="mt-4 grid gap-3 border-t border-border pt-4 sm:grid-cols-2">
			<label className="block text-xs font-semibold text-foreground">Document type<Select aria-label="Document type" value={documentType} onChange={(value) => setDocumentType(value as VerificationDocumentType)} options={choices} className="mt-1" /></label>
			<label className="block text-xs font-semibold text-foreground">Document number <input value={documentNumber} onChange={(event) => setDocumentNumber(event.target.value)} maxLength={50} className="mt-1 min-h-10 w-full rounded-lg border border-border bg-background px-3 text-sm font-normal" /></label>
			<label className="block text-xs font-semibold text-foreground">Expiry date, if applicable <input type="date" value={expiryDate} onChange={(event) => setExpiryDate(event.target.value)} className="mt-1 min-h-10 w-full rounded-lg border border-border bg-background px-3 text-sm font-normal" /></label>
			<label className="block text-xs font-semibold text-foreground">File <input ref={fileInputRef} name="verification-file" type="file" accept="image/jpeg,image/png,image/webp,application/pdf" required onChange={(event) => setFile(event.target.files?.[0] ?? null)} className="mt-1 block min-h-10 w-full rounded-lg border border-border bg-background px-2 py-2 text-xs file:mr-3 file:rounded-md file:border-0 file:bg-muted file:px-2 file:py-1 file:text-xs file:font-semibold" /></label>
			<div className="sm:col-span-2"><Button type="submit" size="sm" disabled={!file || uploading} leftIcon={<Upload className="h-4 w-4" />}>{uploading ? 'Uploading…' : 'Upload document'}</Button></div>
		</form>}
		{message && <p role="status" className="mt-3 text-xs font-medium text-emerald-700">{message}</p>}
		{error && <p role="alert" className="mt-3 text-xs font-medium text-destructive">{error}</p>}
		<div className="mt-4 border-t border-border">
			{loading ? <p className="py-4 text-sm text-muted-foreground">Loading documents…</p> : documents.length === 0 ? <p className="py-4 text-sm text-muted-foreground">No verification documents submitted.</p> : documents.map((document) => <div key={document.uuid} className="flex flex-wrap items-center justify-between gap-3 border-b border-border py-3 last:border-b-0">
				<div className="min-w-0"><p className="text-sm font-semibold text-foreground">{documentLabel(document.document_type)}{document.document_number ? ` · ${document.document_number}` : ''}</p><p className="mt-1 text-xs text-muted-foreground">Submitted {new Date(document.created_at).toLocaleDateString()}</p>{document.notes && <p className="mt-1 text-xs text-destructive">{document.notes}</p>}</div>
				<div className="flex items-center gap-2"><span className={`rounded-full px-2.5 py-1 text-[10px] font-bold capitalize ${statusStyles[document.status] ?? 'bg-muted text-muted-foreground'}`}>{document.status}</span>{document.file && <a href={document.file} target="_blank" rel="noreferrer" className="inline-flex h-9 w-9 items-center justify-center rounded-md border border-border text-primary hover:bg-muted" aria-label={`View ${documentLabel(document.document_type)}`}><ExternalLink className="h-4 w-4" /></a>}</div>
			</div>)}
		</div>
	</section>
}