import { ArrowLeft, Pencil, ShieldCheck, UserRound } from 'lucide-react'
import { useEffect, useState } from 'react'
import { Link, useParams } from 'react-router-dom'

import { StatCard } from '../../../../shared/components/cards'
import { Avatar, Button, ConfirmDialog } from '../../../../shared/components/ui'
import { AdminPageLayout } from '../../components'
import { activateAdminUser, getAdminStaff, suspendAdminUser, updateAdminStaff } from '../../../../core/lib'
import type { AdminStaffInput, AdminUser } from '../../../../core/lib/types/admin'
import { StaffEditorForm } from './components/StaffEditorForm'

export function StaffDetailsPage() {
	const { id = '' } = useParams()
	const staffId = Number(id)
	const [staff, setStaff] = useState<AdminUser | null>(null)
	const [loading, setLoading] = useState(true)
	const [error, setError] = useState('')
	const [notice, setNotice] = useState('')
	const [editing, setEditing] = useState(false)
	const [confirming, setConfirming] = useState(false)
	const [saving, setSaving] = useState(false)
	const [reloadKey, setReloadKey] = useState(0)

	useEffect(() => {
		let active = true
		setLoading(true)
		setError('')
		getAdminStaff(staffId).then((result) => {
			if (active) setStaff(result)
		}).catch((requestError) => {
			if (active) setError(requestError instanceof Error ? requestError.message : 'Could not load staff details.')
		}).finally(() => {
			if (active) setLoading(false)
		})
		return () => { active = false }
	}, [staffId, reloadKey])

	const refresh = () => setReloadKey((current) => current + 1)
	const save = async (input: AdminStaffInput) => {
		if (!staff) return
		setSaving(true)
		setError('')
		try {
			await updateAdminStaff(staff.id, input)
			setEditing(false)
			setNotice('Staff details updated.')
			refresh()
		} catch (requestError) {
			setError(requestError instanceof Error ? requestError.message : 'Could not update staff details.')
		} finally {
			setSaving(false)
		}
	}
	const setAccountStatus = async (suspend: boolean) => {
		if (!staff) return
		setSaving(true)
		setError('')
		try {
			if (suspend) await suspendAdminUser(staff.id)
			else await activateAdminUser(staff.id)
			setConfirming(false)
			setNotice(suspend ? 'Staff account suspended.' : 'Staff account activated.')
			refresh()
		} catch (requestError) {
			setError(requestError instanceof Error ? requestError.message : 'Could not update the staff account.')
		} finally {
			setSaving(false)
		}
	}

	return <AdminPageLayout section="staff" title={staff?.display_name || staff?.username || staff?.phone || 'Staff details'} loading={loading} error={error} notice={notice} onRefresh={refresh}>
		{staff && <div className="space-y-5">
			<div className="flex flex-wrap items-center justify-between gap-3"><Link to="/app/admin/staff" className="inline-flex min-h-10 items-center gap-2 text-sm font-semibold text-primary"><ArrowLeft className="h-4 w-4" />All staff</Link><div className="flex items-center gap-2"><Button type="button" variant="outline" size="sm" leftIcon={<Pencil className="h-4 w-4" />} disabled={staff.is_superuser} onClick={() => setEditing(true)}>Edit details</Button>{staff.is_active ? <Button type="button" variant="danger" size="sm" disabled={staff.is_superuser} onClick={() => setConfirming(true)}>Suspend</Button> : <Button type="button" size="sm" isLoading={saving} onClick={() => void setAccountStatus(false)}>Activate</Button>}</div></div>
			<div className="flex items-center gap-4 rounded-xl border border-border bg-card p-4"><Avatar src={staff.avatar_url} name={staff.display_name || staff.phone} size="xl" /><div><p className="text-xs font-bold uppercase text-primary">Staff account</p><h2 className="mt-1 text-xl font-semibold text-primary-dark">{staff.display_name || staff.username || staff.phone}</h2><p className="mt-1 text-sm text-muted-foreground">{staff.phone} · {staff.email || 'No email'}</p></div></div>
			<div className="grid grid-cols-2 gap-3 sm:grid-cols-4 sm:gap-4"><StatCard title="Access" value={staff.is_superuser ? 'Superuser' : 'Staff'} subtitle="Administrative role" variant="flat" /><StatCard title="Account" value={staff.is_active ? 'Active' : 'Suspended'} subtitle={staff.is_active ? 'Can access admin workspace' : 'Access disabled'} variant="flat" /><StatCard title="Joined" value={staff.date_joined ? new Date(staff.date_joined).toLocaleDateString() : 'Unknown'} subtitle="Account creation date" variant="flat" /><StatCard title="Last seen" value={staff.last_seen ? new Date(staff.last_seen).toLocaleDateString() : 'No activity'} subtitle={staff.last_seen ? new Date(staff.last_seen).toLocaleTimeString() : 'No recent activity'} variant="flat" /></div>
			<section className="rounded-xl border border-border bg-card p-4 sm:p-5"><h2 className="flex items-center gap-2 text-base font-semibold text-primary-dark"><UserRound className="h-4 w-4" />Account details</h2><dl className="mt-4 grid gap-4 text-sm sm:grid-cols-2 lg:grid-cols-3"><Detail label="First name" value={staff.first_name} /><Detail label="Middle name" value={staff.middle_name} /><Detail label="Last name" value={staff.last_name} /><Detail label="Username" value={staff.username} /><Detail label="Phone" value={staff.phone} /><Detail label="Email" value={staff.email} /><Detail label="Phone verified" value={staff.is_phone_verified ? 'Yes' : 'No'} /><Detail label="Email verified" value={staff.is_email_verified ? 'Yes' : 'No'} /></dl></section>
		</div>}
		<Modal isOpen={editing} onClose={() => !saving && setEditing(false)} title="Edit staff member" subtitle={staff?.phone} maxWidth="2xl">{staff && <StaffEditorForm staff={staff} saving={saving} error={error} onCancel={() => setEditing(false)} onSubmit={(input) => void save(input)} />}</Modal>
		<ConfirmDialog isOpen={confirming} title="Suspend staff account" message={<>Suspend {staff?.display_name || staff?.phone}? They will lose access to the admin workspace.</>} confirmLabel="Suspend account" variant="danger" loading={saving} onCancel={() => !saving && setConfirming(false)} onConfirm={() => void setAccountStatus(true)} />
	</AdminPageLayout>
}

function Detail({ label, value }: { label: string; value?: string | null }) {
	return <div><dt className="text-xs text-muted-foreground">{label}</dt><dd className="mt-1 break-words font-medium text-foreground">{value || 'Not provided'}</dd></div>
}
