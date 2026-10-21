import { useEffect, useMemo, useState } from 'react'
import { Activity, AlertTriangle, Check, CheckCircle2, CircleAlert, ShieldAlert } from 'lucide-react'

import { Card } from '../../../../shared/components/cards'
import { StatCard } from '../../../../shared/components/cards'
import { DataTable } from '../../../../shared/components/tables/DataTable'
import { Button, Input, Select, Tabs, Textarea } from '../../../../shared/components/ui'
import { listAdminAuditLogs, listAdminSecurityEvents, updateAdminSecurityEvent, useAdminResource } from '../../../../core/lib'
import type { AdminAuditLog, AdminSecurityEvent } from '../../../../core/lib/types/admin'
import { AdminPageLayout } from '../../components'
import { AuditActionLabel, SecuritySeverityLabel } from './components'

type AuditTab = 'activity' | 'security'
type EventStatusFilter = 'unresolved' | 'reviewed' | 'resolved' | 'all'

function formatDate(value?: string | null) {
	return value ? new Date(value).toLocaleString() : 'Not recorded'
}

function readableEventType(value: string) {
	return value.replaceAll('_', ' ')
}

export function AuditAdminPage() {
	const activity = useAdminResource(listAdminAuditLogs)
	const security = useAdminResource(listAdminSecurityEvents)
	const [tab, setTab] = useState<AuditTab>('activity')
	const [severityFilter, setSeverityFilter] = useState('all')
	const [statusFilter, setStatusFilter] = useState<EventStatusFilter>('unresolved')
	const [search, setSearch] = useState('')
	const [selectedUuid, setSelectedUuid] = useState<string | null>(null)
	const [notes, setNotes] = useState('')
	const [saving, setSaving] = useState(false)
	const [actionError, setActionError] = useState('')
	const [actionNotice, setActionNotice] = useState('')

	const logs = activity.data ?? []
	const events = security.data ?? []
	const selectedEvent = events.find((event) => event.uuid === selectedUuid) ?? null
	const unresolvedCount = events.filter((event) => !event.investigated).length
	const elevatedCount = events.filter((event) => ['high', 'critical'].includes(event.severity) && !event.resolved_at).length
	const pageError = actionError || activity.error || security.error

	useEffect(() => {
		if (selectedEvent) setNotes(selectedEvent.investigation_notes || '')
	}, [selectedEvent?.uuid, selectedEvent?.investigation_notes])

	const filteredEvents = useMemo(() => {
		const normalizedSearch = search.trim().toLowerCase()
		return events.filter((event) => {
			const matchesSeverity = severityFilter === 'all' || event.severity === severityFilter
			const matchesStatus = statusFilter === 'all'
				|| (statusFilter === 'unresolved' && !event.investigated)
				|| (statusFilter === 'reviewed' && event.investigated && !event.resolved_at)
				|| (statusFilter === 'resolved' && Boolean(event.resolved_at))
			const matchesSearch = !normalizedSearch || [event.event_type, event.description, event.actor_phone, event.ip_address, event.request_id]
				.some((value) => value?.toLowerCase().includes(normalizedSearch))
			return matchesSeverity && matchesStatus && matchesSearch
		})
	}, [events, search, severityFilter, statusFilter])

	const refresh = () => {
		activity.refresh()
		security.refresh()
	}

	const saveInvestigation = async (resolve: boolean) => {
		if (!selectedEvent) return
		setSaving(true)
		setActionError('')
		setActionNotice('')
		try {
			await updateAdminSecurityEvent(selectedEvent.uuid, {
				investigated: true,
				investigation_notes: notes,
				resolved_at: resolve ? new Date().toISOString() : selectedEvent.resolved_at ?? null,
			})
			setActionNotice(resolve ? 'Security event resolved.' : 'Investigation notes saved.')
			security.refresh()
		} catch (error) {
			setActionError(error instanceof Error ? error.message : 'The investigation update could not be saved.')
		} finally {
			setSaving(false)
		}
	}

	const activityColumns = [
		{ header: 'Action', mobileRole: 'title' as const, render: (log: AdminAuditLog) => <AuditActionLabel action={log.action} /> },
		{ header: 'Actor', mobileRole: 'summary' as const, render: (log: AdminAuditLog) => log.actor_phone || `User ${log.actor ?? 'system'}` },
		{ header: 'Resource', mobileRole: 'detail' as const, render: (log: AdminAuditLog) => `${log.resource_type || 'Resource'} ${log.resource_id ?? ''}` },
		{ header: 'Description', mobileRole: 'detail' as const, render: (log: AdminAuditLog) => log.description || 'Not recorded' },
		{ header: 'When', mobileRole: 'detail' as const, render: (log: AdminAuditLog) => formatDate(log.created_at) },
	]

	const securityColumns = [
		{ header: 'Event', mobileRole: 'title' as const, render: (event: AdminSecurityEvent) => <span className="font-semibold capitalize text-foreground">{readableEventType(event.event_type)}</span> },
		{ header: 'Severity', mobileRole: 'summary' as const, render: (event: AdminSecurityEvent) => <SecuritySeverityLabel severity={event.severity} /> },
		{ header: 'Source', mobileRole: 'detail' as const, render: (event: AdminSecurityEvent) => <span className="text-sm text-muted-foreground">{event.actor_phone || event.ip_address || 'Unknown source'}</span> },
		{ header: 'State', mobileRole: 'status' as const, render: (event: AdminSecurityEvent) => <span className="text-sm font-medium text-foreground">{event.resolved_at ? 'Resolved' : event.investigated ? 'Reviewed' : 'Needs review'}</span> },
		{ header: 'When', mobileRole: 'detail' as const, render: (event: AdminSecurityEvent) => formatDate(event.created_at) },
		{ header: '', mobileRole: 'action' as const, render: (event: AdminSecurityEvent) => <Button type="button" size="sm" variant="outline" onClick={() => setSelectedUuid(event.uuid)}>{event.uuid === selectedUuid ? 'Selected' : 'Review'}</Button> },
	]

	const tabs = [
		{ id: 'activity' as const, label: 'Activity log', icon: Activity, badge: logs.length, badgeVariant: 'neutral' as const },
		{ id: 'security' as const, label: 'Security events', icon: ShieldAlert, badge: unresolvedCount, badgeVariant: unresolvedCount ? 'warning' as const : 'success' as const },
	]
	const loading = activity.loading || security.loading

	return (
		<AdminPageLayout section="audit" title="Audit & security" loading={loading} error={pageError} notice={actionNotice} onRefresh={refresh}>
			<div className="mb-4 grid grid-cols-2 gap-3 sm:mb-6 sm:grid-cols-4 sm:gap-4"><StatCard title="Audit records" value={logs.length} subtitle="Administrative activity" variant="flat" /><StatCard title="Security events" value={events.length} subtitle="Recorded security signals" variant="flat" /><StatCard title="Needs review" value={unresolvedCount} subtitle="Uninvestigated events" variant="flat" /><StatCard title="High or critical" value={elevatedCount} subtitle="Unresolved elevated severity" variant="flat" /></div>
			<Tabs tabs={tabs} activeTab={tab} onChange={setTab} variant="underline" ariaLabel="Audit views" />
			{tab === 'activity' ? (
				<section aria-label="Audit activity" className="mt-5">
					<p className="mb-4 text-sm text-muted-foreground">Immutable record of sign-ins and administrative changes.</p>
					<DataTable data={logs} columns={activityColumns} keyExtractor={(log) => log.uuid} emptyMessage="No audit activity recorded." />
				</section>
			) : (
				<section aria-label="Security events" className="mt-5 space-y-5">
					<div className="grid gap-5 xl:grid-cols-[minmax(0,1.4fr)_minmax(18rem,0.8fr)]">
						<div className="min-w-0 space-y-4">
							<div className="grid gap-3 sm:grid-cols-3">
								<Input aria-label="Search security events" placeholder="Search event, phone, IP, request ID" value={search} onChange={(event) => setSearch(event.target.value)} />
								<Select aria-label="Filter by severity" value={severityFilter} onChange={setSeverityFilter} options={[{ value: 'all', label: 'All severities' }, 'low', 'medium', 'high', 'critical']} />
								<Select aria-label="Filter by status" value={statusFilter} onChange={(value) => setStatusFilter(value as EventStatusFilter)} options={[{ value: 'unresolved', label: 'Needs review' }, { value: 'reviewed', label: 'Reviewed' }, { value: 'resolved', label: 'Resolved' }, { value: 'all', label: 'All states' }]} />
							</div>
							<DataTable data={filteredEvents} columns={securityColumns} keyExtractor={(event) => event.uuid} emptyMessage="No security events match these filters." />
						</div>
						{selectedEvent ? (
							<Card padding="md" className="h-fit">
								<div className="flex items-start justify-between gap-3">
									<div><p className="text-xs font-bold uppercase tracking-[0.14em] text-primary">Investigation</p><h2 className="mt-1 text-lg font-semibold capitalize text-foreground">{readableEventType(selectedEvent.event_type)}</h2></div>
									<SecuritySeverityLabel severity={selectedEvent.severity} />
								</div>
								<p className="mt-3 text-sm leading-6 text-muted-foreground">{selectedEvent.description}</p>
								<dl className="mt-4 grid grid-cols-2 gap-3 text-xs">
									<Detail label="Source" value={selectedEvent.actor_phone || selectedEvent.ip_address || 'Unknown'} />
									<Detail label="Request ID" value={selectedEvent.request_id || 'Not available'} />
									<Detail label="Reported" value={formatDate(selectedEvent.created_at)} />
									<Detail label="State" value={selectedEvent.resolved_at ? 'Resolved' : selectedEvent.investigated ? 'Reviewed' : 'Needs review'} />
								</dl>
								<label htmlFor="security-investigation-notes" className="mt-5 block text-sm font-semibold text-foreground">Investigation notes</label>
								<Textarea id="security-investigation-notes" rows={4} value={notes} onChange={(event) => setNotes(event.target.value)} placeholder="Record what was checked and any follow-up required." className="mt-2" />
								<div className="mt-4 flex flex-wrap gap-2">
									<Button type="button" variant="outline" size="sm" isLoading={saving} disabled={Boolean(selectedEvent.resolved_at)} leftIcon={<Check className="h-4 w-4" />} onClick={() => void saveInvestigation(false)}>Save review</Button>
									<Button type="button" variant="primary" size="sm" isLoading={saving} disabled={Boolean(selectedEvent.resolved_at)} leftIcon={<CheckCircle2 className="h-4 w-4" />} onClick={() => void saveInvestigation(true)}>Resolve event</Button>
								</div>
							</Card>
						) : (
							<div className="flex min-h-52 items-center justify-center rounded-2xl border border-dashed border-border px-6 text-center text-sm text-muted-foreground">Choose a security event to review its source and add investigation notes.</div>
						)}
					</div>
				</section>
			)}
		</AdminPageLayout>
	)
}

function Detail({ label, value }: { label: string; value: string }) {
	return <div className="min-w-0"><dt className="text-muted-foreground">{label}</dt><dd className="mt-1 break-words font-medium text-foreground">{value}</dd></div>
}