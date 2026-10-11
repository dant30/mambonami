import { useState, type FormEvent } from 'react'

import type { AdminStaffInput, AdminUser } from '../../../../../core/lib/types/admin'
import { FormField } from '../../../../../shared/components/forms/FormField'
import { Button } from '../../../../../shared/components/ui/Button'
import { Input } from '../../../../../shared/components/ui/Input'

interface StaffEditorFormProps {
	staff?: AdminUser
	saving: boolean
	error?: string
	onCancel: () => void
	onSubmit: (input: AdminStaffInput) => void
}

export function StaffEditorForm({ staff, saving, error, onCancel, onSubmit }: StaffEditorFormProps) {
	const [values, setValues] = useState<AdminStaffInput>({
		phone: staff?.phone ?? '',
		username: staff?.username ?? '',
		first_name: staff?.first_name ?? '',
		middle_name: staff?.middle_name ?? '',
		last_name: staff?.last_name ?? '',
		email: staff?.email ?? '',
	})
	const update = (field: keyof AdminStaffInput, value: string) => setValues((current) => ({ ...current, [field]: value }))
	const handleSubmit = (event: FormEvent<HTMLFormElement>) => {
		event.preventDefault()
		onSubmit(values)
	}

	return <form onSubmit={handleSubmit} className="border-y border-border py-5">
		<div className="mb-4 flex items-start justify-between gap-3">
			<div><h2 className="text-lg font-semibold text-primary-dark">{staff ? 'Edit staff member' : 'Create staff account'}</h2><p className="mt-1 text-sm text-muted-foreground">Roles and permissions are managed separately.</p></div>
			<Button type="button" variant="ghost" size="sm" onClick={onCancel}>Cancel</Button>
		</div>
		<div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
			<FormField label="Phone" htmlFor="staff-phone" required><Input id="staff-phone" type="tel" autoComplete="tel" required value={values.phone} onChange={(event) => update('phone', event.target.value)} /></FormField>
			<FormField label="Username" htmlFor="staff-username" required><Input id="staff-username" autoComplete="username" required value={values.username} onChange={(event) => update('username', event.target.value)} /></FormField>
			<FormField label="Email" htmlFor="staff-email"><Input id="staff-email" type="email" autoComplete="email" value={values.email ?? ''} onChange={(event) => update('email', event.target.value)} /></FormField>
			<FormField label="First name" htmlFor="staff-first-name"><Input id="staff-first-name" autoComplete="given-name" value={values.first_name ?? ''} onChange={(event) => update('first_name', event.target.value)} /></FormField>
			<FormField label="Middle name" htmlFor="staff-middle-name"><Input id="staff-middle-name" value={values.middle_name ?? ''} onChange={(event) => update('middle_name', event.target.value)} /></FormField>
			<FormField label="Last name" htmlFor="staff-last-name"><Input id="staff-last-name" autoComplete="family-name" value={values.last_name ?? ''} onChange={(event) => update('last_name', event.target.value)} /></FormField>
			<FormField label={staff ? 'New password' : 'Password'} htmlFor="staff-password" required={!staff} helperText={staff ? 'Leave blank to keep the current password.' : 'At least 8 characters.'}>
				<Input id="staff-password" type="password" autoComplete="new-password" required={!staff} minLength={8} value={values.password ?? ''} onChange={(event) => update('password', event.target.value)} />
			</FormField>
		</div>
		{error && <p role="alert" className="mt-3 text-sm text-destructive">{error}</p>}
		<div className="mt-5 flex justify-end"><Button type="submit" isLoading={saving}>{staff ? 'Save changes' : 'Create staff account'}</Button></div>
	</form>
}