import { useState } from 'react'

import { DataTable } from '../../../../shared/components/tables/DataTable'
import { StatCard } from '../../../../shared/components/cards'
import { Modal } from '../../../../shared/components/ui/Modal'
import { AdminPageLayout } from '../../components'
import { activateAdminUser, adminResourceCaches, createAdminStaff, listAdminStaff, suspendAdminUser, updateAdminStaff, useAdminResource } from '../../../../core/lib'
import type { AdminStaffInput, AdminUser } from '../../../../core/lib/types/admin'
import { StaffAccountStatus } from './components/StaffAccountStatus'
import { StaffEditorForm } from './components/StaffEditorForm'

export function StaffAdminPage() {
	const { data, loading, error, notice, busy, refresh, runAction } = useAdminResource(listAdminStaff, adminResourceCaches.staff)
	const [editor, setEditor] = useState<AdminUser | 'create' | null>(null)
	const [saving, setSaving] = useState(false)
	const [formError, setFormError] = useState('')
	const staff = data ?? []
	const activeCount = staff.filter((member) => member.is_active).length
	const toggle = (member: AdminUser) => {
		const suspend = member.is_active
		if (!window.confirm(`${suspend ? 'Suspend' : 'Activate'} ${member.display_name || member.phone}?`)) return
		void runAction(String(member.id), () => suspend ? suspendAdminUser(member.id) : activateAdminUser(member.id), suspend ? 'Staff account suspended.' : 'Staff account activated.')
	}
	const submitStaff = async (input: AdminStaffInput) => {
		setSaving(true)
		setFormError('')
		try {
			if (editor === 'create') await createAdminStaff(input)
			else if (editor) await updateAdminStaff(editor.id, input)
			setEditor(null)
			refresh()
		} catch (submitError) {
			setFormError(submitError instanceof Error ? submitError.message : 'Unable to save staff details.')
		} finally {
			setSaving(false)
		}
	}
	const columns = [
		{ header: 'Staff member', render: (member: AdminUser) => <div><p className="font-semibold">{member.display_name || member.username || member.phone}</p><p className="text-xs text-muted-foreground">{member.phone} · {member.email || 'No email'}</p></div> },
		{ header: 'Access', render: (member: AdminUser) => member.is_superuser ? 'Superuser' : 'Staff' },
		{ header: 'Account', render: (member: AdminUser) => member.is_active ? 'Active' : 'Suspended' },
		{ header: 'Last seen', render: (member: AdminUser) => member.last_seen ? new Date(member.last_seen).toLocaleString() : 'Not recorded' },
		{ header: 'Action', render: (member: AdminUser) => <StaffAccountStatus member={member} busy={busy === String(member.id)} onToggle={() => toggle(member)} onEdit={() => { setFormError(''); setEditor(member) }} /> },
	]
	return <AdminPageLayout section="staff" title="Staff" loading={loading} error={error} notice={notice} onRefresh={refresh}>
		<div className="mb-4 grid grid-cols-2 gap-3 sm:mb-6 sm:gap-4 xl:grid-cols-4"><StatCard title="Staff accounts" value={staff.length} subtitle="Admin workspace users" variant="flat" /><StatCard title="Active" value={activeCount} subtitle="Can sign in" variant="flat" /><StatCard title="Suspended" value={staff.length - activeCount} subtitle="Access disabled" variant="flat" /><StatCard title="Last seen" value={staff.filter((member) => Boolean(member.last_seen)).length} subtitle="Accounts with activity recorded" variant="flat" /></div>
		<div className="mb-4 flex justify-end"><button type="button" onClick={() => { setFormError(''); setEditor('create') }} className="min-h-10 rounded-md bg-primary px-4 text-sm font-semibold text-primary-foreground hover:brightness-95">Create staff account</button></div>
		<Modal isOpen={editor !== null} onClose={() => setEditor(null)} title={editor === 'create' ? 'Create staff account' : 'Edit staff member'} subtitle="Roles and permissions are managed separately." maxWidth="2xl">
			{editor && <StaffEditorForm key={editor === 'create' ? 'create' : editor.id} staff={editor === 'create' ? undefined : editor} saving={saving} error={formError} onCancel={() => setEditor(null)} onSubmit={submitStaff} />}
		</Modal>
		<DataTable data={staff} columns={columns} keyExtractor={(member) => String(member.id)} emptyMessage="No staff accounts found." />
	</AdminPageLayout>
}