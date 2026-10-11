import { EmptyState } from '../../../../shared/components/feedback/EmptyState'
import { AdminPageLayout } from '../../components'
import { adminResourceCaches, listAdminDisputes, resolveAdminDispute, useAdminResource } from '../../../../core/lib'
import type { Dispute, DisputeResolutionInput } from '../../../../core/lib/types/disputes'
import { DisputeResolutionForm } from './components/DisputeResolutionForm'

export function DisputesAdminPage() {
	const { data, loading, error, notice, busy, refresh, runAction } = useAdminResource(listAdminDisputes, adminResourceCaches.disputes)
	const disputes = data ?? []
	const submitResolution = (dispute: Dispute, input: DisputeResolutionInput) => {
		if (!window.confirm(`Resolve dispute ${dispute.uuid} with ${input.resolution.replaceAll('_', ' ')}?`)) return
		void runAction(dispute.uuid, () => resolveAdminDispute(dispute.uuid, input), 'Dispute resolved.')
	}
	return <AdminPageLayout section="disputes" title="Disputes" loading={loading} error={error} notice={notice} onRefresh={refresh}>
		{disputes.map((dispute) => <article key={dispute.uuid} className="border-b border-border py-5">
			<div className="flex flex-wrap items-start justify-between gap-3">
				<div><p className="text-xs font-bold uppercase text-primary">{dispute.uuid} · Order #{dispute.order}</p><h2 className="mt-1 font-semibold text-foreground">{dispute.reason.replaceAll('_', ' ')} · {dispute.status.replaceAll('_', ' ')}</h2><p className="mt-1 max-w-3xl text-sm text-muted-foreground">{dispute.description}</p></div>
				<p className="text-sm font-semibold text-muted-foreground">{dispute.priority || 'Normal'} · {dispute.created_at ? new Date(dispute.created_at).toLocaleDateString() : 'Date unavailable'}</p>
			</div>
			{['open', 'under_review'].includes(dispute.status) ? <DisputeResolutionForm busy={busy === dispute.uuid} onResolve={(input) => submitResolution(dispute, input)} /> : <p className="mt-4 text-sm text-muted-foreground">Resolution: {dispute.resolution?.replaceAll('_', ' ') || 'Not recorded'} {dispute.resolution_notes ? `· ${dispute.resolution_notes}` : ''}</p>}
		</article>)}
		{disputes.length === 0 && <EmptyState size="sm" title="No disputes found" description="Open disputes will appear here for review." />}
	</AdminPageLayout>
}