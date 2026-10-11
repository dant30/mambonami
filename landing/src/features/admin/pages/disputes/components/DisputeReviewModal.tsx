import { useState, type FormEvent } from 'react'

import type { AdminUser } from '../../../../../core/lib/types/admin'
import type { Dispute, DisputeResolutionInput } from '../../../../../core/lib/types/disputes'
import { FormActions } from '../../../../../shared/components/forms/FormActions'
import { FormField } from '../../../../../shared/components/forms/FormField'
import { FormSection } from '../../../../../shared/components/forms/FormSection'
import { ValidationErrors } from '../../../../../shared/components/forms/ValidationErrors'
import { Badge } from '../../../../../shared/components/ui/Badge'
import { Button } from '../../../../../shared/components/ui/Button'
import { Input } from '../../../../../shared/components/ui/Input'
import { Modal } from '../../../../../shared/components/ui/Modal'
import { Select } from '../../../../../shared/components/ui/Select'
import { Textarea } from '../../../../../shared/components/ui/Textarea'

const resolutionOptions = [
	{ value: 'full_refund', label: 'Full refund' },
	{ value: 'partial_refund', label: 'Partial refund' },
	{ value: 'replacement', label: 'Replacement' },
	{ value: 'store_credit', label: 'Store credit' },
	{ value: 'compensate_farmer', label: 'Compensate farmer' },
	{ value: 'compensate_provider', label: 'Compensate transport provider' },
	{ value: 'no_action', label: 'No action' },
]

interface DisputeReviewModalProps {
	dispute: Dispute | null
	users: AdminUser[]
	busy: boolean
	onClose: () => void
	onStartReview: () => Promise<boolean>
	onResolve: (input: DisputeResolutionInput) => Promise<boolean>
}

function getEvidenceLink(item: unknown): { label: string; href?: string } {
	if (typeof item === 'string') {
		const isRelative = item.startsWith('/')
		const isHttp = /^https?:\/\//i.test(item)
		return { label: item, href: isRelative || isHttp ? item : undefined }
	}
	if (item && typeof item === 'object') {
		const evidence = item as Record<string, unknown>
		const rawUrl = evidence.url ?? evidence.file_url ?? evidence.file
		const rawLabel = evidence.name ?? evidence.caption ?? evidence.type
		const href = typeof rawUrl === 'string' && (rawUrl.startsWith('/') || /^https?:\/\//i.test(rawUrl)) ? rawUrl : undefined
		return { label: typeof rawLabel === 'string' ? rawLabel : href ?? JSON.stringify(item), href }
	}
	return { label: String(item) }
}

function getOrderValue(dispute: Dispute, key: string): string | null {
	const value = dispute.order_detail?.[key]
	return typeof value === 'string' || typeof value === 'number' ? String(value) : null
}

export function DisputeReviewModal({ dispute, users, busy, onClose, onStartReview, onResolve }: DisputeReviewModalProps) {
	const [resolution, setResolution] = useState<DisputeResolutionInput['resolution']>('no_action')
	const [refundAmount, setRefundAmount] = useState('')
	const [penaltyAmount, setPenaltyAmount] = useState('')
	const [penaltyUserId, setPenaltyUserId] = useState('')
	const [notes, setNotes] = useState('')
	const [errors, setErrors] = useState<string[]>([])
	if (!dispute) return null

	const evidence = Array.isArray(dispute.evidence) ? dispute.evidence : []
	const refundRequired = resolution === 'full_refund' || resolution === 'partial_refund'
	const orderTotal = getOrderValue(dispute, 'total_amount')
	const penaltyUsers = users.filter((user) => resolution === 'compensate_farmer'
		? user.role === 'farmer'
		: resolution === 'compensate_provider'
			? user.role === 'transport_provider'
			: user.role === 'farmer' || user.role === 'transport_provider')
	const changeResolution = (value: string) => {
		const nextResolution = value as DisputeResolutionInput['resolution']
		setResolution(nextResolution)
		if (nextResolution === 'full_refund' && orderTotal && !refundAmount) setRefundAmount(orderTotal)
		setPenaltyUserId('')
	}
	const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
		event.preventDefault()
		const nextErrors: string[] = []
		const refundValue = refundAmount.trim() ? Number(refundAmount) : 0
		const penaltyValue = penaltyAmount.trim() ? Number(penaltyAmount) : 0
		const penaltyTarget = penaltyUserId.trim() ? Number(penaltyUserId) : null
		if (refundRequired && (!Number.isFinite(refundValue) || refundValue <= 0)) nextErrors.push('Enter a refund amount greater than zero for this resolution.')
		if (!refundRequired && refundAmount.trim() && (!Number.isFinite(refundValue) || refundValue < 0)) nextErrors.push('Refund amount must be zero or greater.')
		if (resolution === 'full_refund' && orderTotal && refundValue > Number(orderTotal)) nextErrors.push(`Full refund cannot exceed the order total of KES ${orderTotal}.`)
		if (penaltyAmount.trim() && (!Number.isFinite(penaltyValue) || penaltyValue < 0)) nextErrors.push('Penalty amount must be zero or greater.')
		if (['compensate_farmer', 'compensate_provider'].includes(resolution) && penaltyValue <= 0) nextErrors.push('Enter a penalty amount for compensation resolutions.')
		if (penaltyValue > 0 && (!penaltyTarget || !Number.isInteger(penaltyTarget))) nextErrors.push('Choose a numeric user ID to receive the penalty.')
		if (nextErrors.length) {
			setErrors(nextErrors)
			return
		}

		setErrors([])
		const input: DisputeResolutionInput = {
			resolution,
			refund_amount: refundValue,
			penalty_amount: penaltyValue,
			penalty_user_id: penaltyTarget,
			resolution_notes: notes.trim(),
		}
		if (await onResolve(input)) onClose()
	}
	const handleStartReview = async () => {
		setErrors([])
		try {
			if (await onStartReview()) onClose()
		} catch (requestError) {
			setErrors([requestError instanceof Error ? requestError.message : 'Unable to assign this dispute for review.'])
		}
	}

	return <Modal isOpen={Boolean(dispute)} onClose={busy ? () => undefined : onClose} title="Review dispute" subtitle={`${dispute.uuid} · Order #${dispute.order}`} maxWidth="2xl">
		<div className="space-y-6">
			<section className="grid gap-4 sm:grid-cols-2">
				<div><p className="text-xs font-bold uppercase text-muted-foreground">Issue</p><p className="mt-1 font-semibold capitalize">{dispute.reason.replaceAll('_', ' ')}</p></div>
				<div><p className="text-xs font-bold uppercase text-muted-foreground">Raised by</p><p className="mt-1 font-semibold">{dispute.raised_by_phone || `User #${dispute.raised_by}`}</p></div>
				<div><p className="text-xs font-bold uppercase text-muted-foreground">Status and priority</p><div className="mt-1 flex flex-wrap items-center gap-2"><Badge size="sm" variant={dispute.status === 'open' ? 'danger' : 'warning'}>{dispute.status.replaceAll('_', ' ')}</Badge><span className="text-sm capitalize">{dispute.priority || 'medium'}</span></div>{dispute.assigned_to_phone && <p className="mt-1 text-xs text-muted-foreground">Assigned to {dispute.assigned_to_phone}</p>}</div>
				<div><p className="text-xs font-bold uppercase text-muted-foreground">Order total and status</p><p className="mt-1 font-semibold">{getOrderValue(dispute, 'total_amount') ? `KES ${getOrderValue(dispute, 'total_amount')}` : 'Order detail unavailable'}{getOrderValue(dispute, 'status') ? ` · ${getOrderValue(dispute, 'status')}` : ''}</p></div>
			</section>

			<FormSection title="Customer report" description={dispute.created_at ? `Submitted ${new Date(dispute.created_at).toLocaleString()}` : undefined}>
				<p className="whitespace-pre-wrap text-sm leading-relaxed text-foreground">{dispute.description}</p>
				{evidence.length > 0 && <div><h3 className="mb-2 text-xs font-bold uppercase text-muted-foreground">Evidence</h3><ul className="space-y-2">{evidence.map((item, index) => {
					const link = getEvidenceLink(item)
					return <li key={`${index}-${link.label}`} className="break-all text-sm">{link.href ? <a href={link.href} target="_blank" rel="noreferrer" className="font-semibold text-primary underline">{link.label}</a> : <code className="whitespace-pre-wrap text-xs text-muted-foreground">{link.label}</code>}</li>
				})}</ul></div>}
				{evidence.length === 0 && <p className="text-xs text-muted-foreground">No evidence attached.</p>}
			</FormSection>
			{(dispute.events?.length ?? 0) > 0 && <FormSection title="Case timeline" description="Recorded case actions.">
				<ol className="space-y-3">{dispute.events?.map((event) => <li key={event.id} className="border-l-2 border-border pl-3"><p className="text-sm font-semibold capitalize">{event.event_type.replaceAll('_', ' ')}</p><p className="mt-0.5 text-xs text-muted-foreground">{event.actor_phone || 'System'}{event.created_at ? ` · ${new Date(event.created_at).toLocaleString()}` : ''}</p>{event.details && <p className="mt-1 whitespace-pre-wrap text-sm text-foreground">{event.details}</p>}</li>)}</ol>
			</FormSection>}

			{dispute.status === 'open' && <div className="flex justify-end"><Button variant="outline" disabled={busy} onClick={() => void handleStartReview()}>Start review and assign to me</Button></div>}
			{['open', 'under_review'].includes(dispute.status) ? <FormSection title="Resolution" description="Financial adjustments are executed by the backend when submitted.">
				<form id={`resolve-dispute-${dispute.id}`} onSubmit={handleSubmit} className="space-y-4">
					<FormField label="Outcome" htmlFor={`resolution-${dispute.id}`} required><Select id={`resolution-${dispute.id}`} options={resolutionOptions} value={resolution} onChange={changeResolution} /></FormField>
					<div className="grid gap-4 sm:grid-cols-2">
						<FormField label="Refund amount (KES)" htmlFor={`refund-${dispute.id}`} required={refundRequired} helperText={refundRequired ? 'Required for full and partial refunds.' : 'Leave at zero if no refund is due.'}><Input id={`refund-${dispute.id}`} type="number" min="0" step="0.01" value={refundAmount} onChange={(event) => setRefundAmount(event.target.value)} /></FormField>
						<FormField label="Penalty amount (KES)" htmlFor={`penalty-${dispute.id}`} helperText="When above zero, select the affected user below."><Input id={`penalty-${dispute.id}`} type="number" min="0" step="0.01" value={penaltyAmount} onChange={(event) => setPenaltyAmount(event.target.value)} /></FormField>
					</div>
					<FormField label="Penalty target" htmlFor={`penalty-user-${dispute.id}`} helperText="Only farmers or transport providers can be targeted."><Select id={`penalty-user-${dispute.id}`} options={[{ value: '', label: 'No penalty target' }, ...penaltyUsers.map((user) => ({ value: String(user.id), label: `${user.display_name || user.phone} · ${user.role.replaceAll('_', ' ')}` }))]} value={penaltyUserId} onChange={setPenaltyUserId} searchable /></FormField>
					<FormField label="Resolution notes" htmlFor={`resolution-notes-${dispute.id}`}><Textarea id={`resolution-notes-${dispute.id}`} rows={3} value={notes} onChange={(event) => setNotes(event.target.value)} placeholder="Document the reason for this decision." /></FormField>
					<ValidationErrors errors={errors} />
					<FormActions formId={`resolve-dispute-${dispute.id}`} submitLabel="Resolve dispute" loading={busy} onCancel={onClose} />
				</form>
			</FormSection> : <FormSection title="Recorded resolution" divider={false}>
				<p className="text-sm font-semibold capitalize">{dispute.resolution?.replaceAll('_', ' ') || 'No resolution recorded'}</p>
				{dispute.resolution_notes && <p className="mt-2 whitespace-pre-wrap text-sm text-muted-foreground">{dispute.resolution_notes}</p>}
				<p className="mt-2 text-sm text-muted-foreground">Refund: KES {dispute.refund_amount ?? 0} · Penalty: KES {dispute.penalty_amount ?? 0}</p>
			</FormSection>}
		</div>
	</Modal>
}