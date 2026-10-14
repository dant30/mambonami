import { Check, MapPin, Save, UserCircle } from 'lucide-react'
import { FormEvent, useEffect, useState } from 'react'

import { useAuth } from '../../../core/contexts/AuthContext'
import { updateProfile } from '../../../core/lib'
import { ProfileIdentityPanel } from '../../account/components/ProfileIdentityPanel'
import { FormField, FormSection } from '../../../shared/components/forms'
import { Button, Input, Textarea } from '../../../shared/components/ui'

export function BuyerProfilePage() {
	const { user } = useAuth()
	const [form, setForm] = useState({
		first_name: '',
		middle_name: '',
		last_name: '',
		email: '',
		phone: '',
		national_id: '',
		delivery_address: '',
		delivery_instructions: '',
		bank_account: '',
	})
	const [isSaving, setIsSaving] = useState(false)
	const [message, setMessage] = useState('')
	const [error, setError] = useState('')

	useEffect(() => {
		const profile = (user?.buyer_profile || {}) as Record<string, unknown>
		setForm({
			first_name: String(user?.first_name || ''),
			middle_name: String(user?.middle_name || ''),
			last_name: String(user?.last_name || ''),
			email: String(user?.email || ''),
			phone: String(user?.phone || ''),
			national_id: String(user?.national_id || ''),
			delivery_address: String(profile.delivery_address || ''),
			delivery_instructions: String(profile.delivery_instructions || ''),
			bank_account: String(profile.bank_account || ''),
		})
	}, [user])

	const update = (field: keyof typeof form, value: string) => setForm((current) => ({ ...current, [field]: value }))
	const submit = async (event: FormEvent) => {
		event.preventDefault()
		setIsSaving(true)
		setMessage('')
		setError('')
		try {
			await updateProfile(form)
			setMessage('Profile and delivery details saved.')
		} catch {
			setError('We could not save your profile. Please try again.')
		} finally {
			setIsSaving(false)
		}
	}

	return (
		<main className="mx-auto max-w-3xl px-4 py-4 sm:px-6 sm:py-8">
			<ProfileIdentityPanel user={user} roleLabel="Buyer account" />
			<form onSubmit={submit} className="mt-4 rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-6">
				<FormSection title="Personal details" description="Your verified phone is the account login and cannot be changed here." icon={<UserCircle className="h-4 w-4" />}>
					<div className="grid gap-4 sm:grid-cols-2">
						<FormField label="First name" htmlFor="buyer-first-name" required><Input id="buyer-first-name" required value={form.first_name} onChange={(event) => update('first_name', event.target.value)} /></FormField>
						<FormField label="Middle name" htmlFor="buyer-middle-name"><Input id="buyer-middle-name" value={form.middle_name} onChange={(event) => update('middle_name', event.target.value)} /></FormField>
						<FormField label="Last name" htmlFor="buyer-last-name" required><Input id="buyer-last-name" required value={form.last_name} onChange={(event) => update('last_name', event.target.value)} /></FormField>
						<FormField label="Email" htmlFor="buyer-email"><Input id="buyer-email" type="email" value={form.email} onChange={(event) => update('email', event.target.value)} /></FormField>
						<FormField label="Verified phone" htmlFor="buyer-phone"><Input id="buyer-phone" value={form.phone} readOnly className="bg-muted text-muted-foreground" /></FormField>
						<FormField label="National ID" htmlFor="buyer-national-id"><Input id="buyer-national-id" value={form.national_id} onChange={(event) => update('national_id', event.target.value)} /></FormField>
					</div>
				</FormSection>
				<FormSection title="Delivery defaults" description="Used to prefill checkout; each order can still use a different address." icon={<MapPin className="h-4 w-4" />}>
					<div className="grid gap-4">
						<FormField label="Default delivery address" htmlFor="buyer-address"><Textarea id="buyer-address" rows={2} value={form.delivery_address} onChange={(event) => update('delivery_address', event.target.value)} /></FormField>
						<FormField label="Delivery instructions" htmlFor="buyer-instructions"><Textarea id="buyer-instructions" rows={2} value={form.delivery_instructions} onChange={(event) => update('delivery_instructions', event.target.value)} placeholder="Gate, landmark, preferred call instructions..." /></FormField>
						<FormField label="Refund bank account" htmlFor="buyer-refund-account" helperText="Optional account used only when a bank refund is required."><Input id="buyer-refund-account" value={form.bank_account} onChange={(event) => update('bank_account', event.target.value)} /></FormField>
					</div>
				</FormSection>
				{message && <p role="status" className="flex items-center gap-2 rounded-xl bg-primary/10 p-3 text-sm text-primary"><Check className="h-4 w-4" />{message}</p>}
				{error && <p role="alert" className="rounded-xl bg-destructive/10 p-3 text-sm text-destructive">{error}</p>}
				<div className="flex justify-end border-t border-border pt-4"><Button type="submit" isLoading={isSaving} leftIcon={<Save className="h-4 w-4" />} className="w-full sm:w-auto">Save profile</Button></div>
			</form>
		</main>
	)
}
