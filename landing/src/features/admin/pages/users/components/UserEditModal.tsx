import { useState, type FormEvent } from 'react'

import { updateAdminUser } from '../../../../../core/lib'
import type { AdminUser } from '../../../../../core/lib/types/admin'
import { Button, Modal } from '../../../../../shared/components/ui'

export function UserEditModal({ user, onClose, onSaved }: { user: AdminUser | null; onClose: () => void; onSaved: () => void }) {
	const [saving, setSaving] = useState(false)
	const [error, setError] = useState('')

	const submit = async (event: FormEvent<HTMLFormElement>) => {
		event.preventDefault()
		if (!user) return
		const formData = new FormData(event.currentTarget)
		setSaving(true)
		setError('')
		try {
			await updateAdminUser(user.id, {
				first_name: String(formData.get('first_name') || '').trim(),
				middle_name: String(formData.get('middle_name') || '').trim(),
				last_name: String(formData.get('last_name') || '').trim(),
				username: String(formData.get('username') || '').trim(),
				email: String(formData.get('email') || '').trim(),
			})
			onSaved()
		} catch (requestError) {
			setError(requestError instanceof Error ? requestError.message : 'Could not save user changes.')
		} finally {
			setSaving(false)
		}
	}

	return <Modal isOpen={Boolean(user)} onClose={() => saving ? undefined : onClose()} title="Edit user" subtitle={user?.phone} maxWidth="md">
		{user && <form className="space-y-4" onSubmit={(event) => void submit(event)}>
			<div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
				<FormField name="first_name" label="First name" value={user.first_name} />
				<FormField name="middle_name" label="Middle name" value={user.middle_name} />
				<FormField name="last_name" label="Last name" value={user.last_name} />
				<FormField name="username" label="Username" value={user.username} />
				<FormField name="email" label="Email" type="email" value={user.email} />
			</div>
			{error && <p role="alert" className="text-sm text-destructive">{error}</p>}
			<div className="flex justify-end gap-2 border-t border-border pt-4"><Button type="button" variant="outline" disabled={saving} onClick={onClose}>Cancel</Button><Button type="submit" isLoading={saving}>Save changes</Button></div>
		</form>}
	</Modal>
}

function FormField({ name, label, value, type = 'text' }: { name: string; label: string; value?: string; type?: string }) {
	return <label className="block text-sm font-semibold">{label}<input name={name} type={type} defaultValue={value || ''} className="mt-1 min-h-10 w-full rounded-md border border-border bg-background px-3 text-sm font-normal" /></label>
}