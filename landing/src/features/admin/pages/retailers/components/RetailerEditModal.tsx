import { useState, type FormEvent } from 'react'

import { updateAdminUser } from '../../../../../core/lib'
import type { AdminUserDetail } from '../../../../../core/lib/types/admin'
import { Button, Input, Modal, Textarea } from '../../../../../shared/components/ui'

function value(profile: Record<string, unknown> | null | undefined, key: string) {
	const field = profile?.[key]
	return field === null || field === undefined ? '' : String(field)
}

export function RetailerEditModal({ user, onClose, onSaved }: { user: AdminUserDetail | null; onClose: () => void; onSaved: () => void }) {
	const [saving, setSaving] = useState(false)
	const [error, setError] = useState('')
	const profile = user?.role_profile

	const submit = async (event: FormEvent<HTMLFormElement>) => {
		event.preventDefault()
		if (!user) return
		const data = new FormData(event.currentTarget)
		setSaving(true)
		setError('')
		try {
			await updateAdminUser(user.id, {
				first_name: String(data.get('first_name') || '').trim(),
				middle_name: String(data.get('middle_name') || '').trim(),
				last_name: String(data.get('last_name') || '').trim(),
				email: String(data.get('email') || '').trim(),
				role_profile: {
					business_name: String(data.get('business_name') || '').trim(),
					owner_full_name: String(data.get('owner_full_name') || '').trim(),
					business_phone: String(data.get('business_phone') || '').trim(),
					business_email: String(data.get('business_email') || '').trim(),
					business_address: String(data.get('business_address') || '').trim(),
					business_type: String(data.get('business_type') || '').trim(),
					kra_pin: String(data.get('kra_pin') || '').trim(),
					business_registration_number: String(data.get('business_registration_number') || '').trim(),
					bank_account: String(data.get('bank_account') || '').trim(),
					latitude: String(data.get('latitude') || '').trim() || null,
					longitude: String(data.get('longitude') || '').trim() || null,
				},
			})
			onSaved()
		} catch (requestError) {
			setError(requestError instanceof Error ? requestError.message : 'Could not update retailer details.')
		} finally {
			setSaving(false)
		}
	}

	return <Modal isOpen={Boolean(user)} onClose={() => saving ? undefined : onClose()} title="Edit retailer details" subtitle={user?.phone} maxWidth="2xl">
		{user && <form onSubmit={(event) => void submit(event)} className="space-y-5">
			<section><h2 className="text-sm font-semibold text-primary-dark">Account owner</h2><div className="mt-3 grid gap-4 sm:grid-cols-2"><Field name="first_name" label="First name" value={user.first_name} /><Field name="middle_name" label="Middle name" value={user.middle_name} /><Field name="last_name" label="Last name" value={user.last_name} /><Field name="email" label="Account email" value={user.email} type="email" /></div></section>
			<section className="border-t border-border pt-4"><h2 className="text-sm font-semibold text-primary-dark">Business</h2><div className="mt-3 grid gap-4 sm:grid-cols-2"><Field name="business_name" label="Business name" value={value(profile, 'business_name')} /><Field name="owner_full_name" label="Owner name" value={value(profile, 'owner_full_name')} /><Field name="business_phone" label="Business phone" value={value(profile, 'business_phone')} type="tel" /><Field name="business_email" label="Business email" value={value(profile, 'business_email')} type="email" /><Field name="business_type" label="Business type" value={value(profile, 'business_type')} /><Field name="kra_pin" label="KRA PIN" value={value(profile, 'kra_pin')} /><Field name="business_registration_number" label="Registration number" value={value(profile, 'business_registration_number')} /><Field name="bank_account" label="Bank account" value={value(profile, 'bank_account')} /><Field name="latitude" label="Latitude" value={value(profile, 'latitude')} type="number" step="0.000001" /><Field name="longitude" label="Longitude" value={value(profile, 'longitude')} type="number" step="0.000001" /><label className="block text-sm font-semibold sm:col-span-2">Business address<Textarea name="business_address" defaultValue={value(profile, 'business_address')} rows={2} className="mt-1" /></label></div></section>
			{error && <p role="alert" className="text-sm text-destructive">{error}</p>}
			<div className="flex justify-end gap-2 border-t border-border pt-4"><Button type="button" variant="outline" disabled={saving} onClick={onClose}>Cancel</Button><Button type="submit" isLoading={saving}>Save retailer</Button></div>
		</form>}
	</Modal>
}

function Field({ name, label, value, type = 'text', step }: { name: string; label: string; value?: string; type?: string; step?: string }) {
	return <label className="block text-sm font-semibold text-foreground">{label}<Input name={name} type={type} step={step} defaultValue={value || ''} className="mt-1" /></label>
}