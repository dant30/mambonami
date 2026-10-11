import { useMemo, useState } from 'react'

import { StatCard } from '../../../../shared/components/cards/StatCard'
import { DataTable } from '../../../../shared/components/tables/DataTable'
import { AdminPageLayout } from '../../components'
import { listAdminDisputes, listAdminUsers, resolveAdminDispute, startAdminDisputeReview, useAdminResource } from '../../../../core/lib'
import type { AdminUser } from '../../../../core/lib/types/admin'
import type { Dispute, DisputeResolutionInput } from '../../../../core/lib/types/disputes'
import { Select } from '../../../../shared/components/ui/Select'
import { DisputeQueueRow } from './components/DisputeQueueRow'
import { DisputeReviewModal } from './components/DisputeReviewModal'

const statusOptions = [
	{ value: 'all', label: 'All statuses' },
	{ value: 'open', label: 'Open' },
	{ value: 'under_review', label: 'Under review' },
	{ value: 'waiting_customer', label: 'Waiting for customer' },
	{ value: 'waiting_farmer', label: 'Waiting for farmer' },
	{ value: 'waiting_provider', label: 'Waiting for provider' },
	{ value: 'escalated', label: 'Escalated' },
	{ value: 'resolved', label: 'Resolved' },
	{ value: 'rejected', label: 'Rejected' },
	{ value: 'closed', label: 'Closed' },
]

interface DisputeQueueData {
	disputes: Dispute[]
	users: AdminUser[]
}

async function loadDisputeQueue(): Promise<DisputeQueueData> {
	const [disputes, users] = await Promise.all([listAdminDisputes(), listAdminUsers()])
	return { disputes, users }
}

export function DisputesAdminPage() {
	const { data, loading, error, refresh } = useAdminResource(loadDisputeQueue)
	const [selected, setSelected] = useState<Dispute | null>(null)
	const [statusFilter, setStatusFilter] = useState('all')
	const [search, setSearch] = useState('')
	const [resolvingId, setResolvingId] = useState<string | null>(null)
	const [notice, setNotice] = useState('')
	const disputes = data?.disputes ?? []
	const users = data?.users ?? []
	const openCount = disputes.filter((dispute) => dispute.status === 'open').length
	const reviewCount = disputes.filter((dispute) => dispute.status === 'under_review').length
	const urgentCount = disputes.filter((dispute) => dispute.priority === 'urgent' && !['resolved', 'rejected', 'closed'].includes(dispute.status)).length
	const visibleDisputes = useMemo(() => disputes.filter((dispute) => {
		const matchesStatus = statusFilter === 'all' || dispute.status === statusFilter
		const query = search.trim().toLowerCase()
		const matchesSearch = !query || `${dispute.uuid} ${dispute.order} ${dispute.raised_by_phone ?? ''} ${dispute.reason} ${dispute.description}`.toLowerCase().includes(query)
		return matchesStatus && matchesSearch
	}), [disputes, search, statusFilter])
	const submitResolution = async (dispute: Dispute, input: DisputeResolutionInput) => {
		if (!window.confirm(`Resolve dispute ${dispute.uuid} with ${input.resolution.replaceAll('_', ' ')}?`)) return false
		setResolvingId(dispute.uuid)
		setNotice('')
		try {
			await resolveAdminDispute(dispute.uuid, input)
			setNotice(`Dispute ${dispute.uuid} resolved.`)
			refresh()
			return true
		} finally {
			setResolvingId(null)
		}
	}
	const startReview = async (dispute: Dispute) => {
		if (!window.confirm(`Assign dispute ${dispute.uuid} to you and mark it under review?`)) return false
		setResolvingId(dispute.uuid)
		setNotice('')
		try {
			await startAdminDisputeReview(dispute.uuid)
			setNotice(`Dispute ${dispute.uuid} is now assigned to you.`)
			refresh()
			return true
		} finally {
			setResolvingId(null)
		}
	}
	const columns = [{ header: 'Dispute', render: (dispute: Dispute) => <DisputeQueueRow dispute={dispute} onReview={() => setSelected(dispute)} /> }]

	return <AdminPageLayout section="disputes" title="Disputes" loading={loading} error={error} notice={notice} onRefresh={refresh}>
		<div className="mb-6 grid gap-4 sm:grid-cols-3"><StatCard title="Open" value={openCount} subtitle="Awaiting review" variant="flat" /><StatCard title="Under review" value={reviewCount} subtitle="Currently being handled" variant="flat" /><StatCard title="Urgent" value={urgentCount} subtitle="Unresolved urgent cases" variant="flat" /></div>
		{notice && <p role="status" className="mb-4 border-l-4 border-emerald-600 bg-emerald-50 p-4 text-sm text-emerald-900">{notice}</p>}
		<div className="mb-4 grid gap-3 sm:grid-cols-[1fr_14rem]"><input aria-label="Search disputes" value={search} onChange={(event) => setSearch(event.target.value)} placeholder="Search case, order, buyer, issue" className="min-h-10 rounded-md border border-border bg-background px-3 text-sm" /><Select aria-label="Filter disputes by status" options={statusOptions} value={statusFilter} onChange={setStatusFilter} /></div>
		<DataTable data={visibleDisputes} columns={columns} keyExtractor={(dispute) => dispute.uuid} emptyMessage="No disputes match these filters." />
		<DisputeReviewModal key={selected?.uuid ?? 'closed'} dispute={selected} users={users} busy={resolvingId === selected?.uuid} onClose={() => setSelected(null)} onStartReview={() => selected ? startReview(selected) : Promise.resolve(false)} onResolve={(input) => selected ? submitResolution(selected, input) : Promise.resolve(false)} />
	</AdminPageLayout>
}