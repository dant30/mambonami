import { Check, MapPin, Save, Store, UserCircle } from 'lucide-react'
import { useEffect, useState } from 'react'

import { useAuth } from '../../../core/contexts/AuthContext'
import { updateProfile } from '../../../core/lib'
import { ProfileIdentityPanel } from '../../account/components/ProfileIdentityPanel'
import { VerificationDocumentsPanel } from '../../account/components/VerificationDocumentsPanel'
import { FormField, FormSection } from '../../../shared/components/forms'
import { Button, Input, Select, Textarea } from '../../../shared/components/ui'

const blank = {
	first_name: '', middle_name: '', last_name: '', email: '', phone: '', national_id: '',
	owner_full_name: '', business_name: '', business_phone: '', business_email: '',
	business_address: '', business_type: 'Grocery store', kra_pin: '', bank_account: '',
	business_registration_number: '', latitude: '', longitude: '',
}

export function RetailerProfilePage() {
	const { user } = useAuth()
	const [form, setForm] = useState(blank)
	const [isSaving, setIsSaving] = useState(false)
	const [message, setMessage] = useState('')
	const [error, setError] = useState('')

	useEffect(() => {
		const profile = (user?.retailer_profile || {}) as Record<string, unknown>
		setForm({
			first_name: String(user?.first_name || ''), middle_name: String(user?.middle_name || ''),
			last_name: String(user?.last_name || ''), email: String(user?.email || ''),
			phone: String(user?.phone || ''), national_id: String(user?.national_id || ''),
			owner_full_name: String(profile.owner_full_name || ''), business_name: String(profile.business_name || ''),
			business_phone: String(profile.business_phone || ''), business_email: String(profile.business_email || ''),
			business_address: String(profile.business_address || ''), business_type: String(profile.business_type || 'Grocery store'),
			kra_pin: String(profile.kra_pin || ''), bank_account: String(profile.bank_account || ''),
			business_registration_number: String(profile.business_registration_number || ''),
			latitude: String(profile.latitude || ''), longitude: String(profile.longitude || ''),
		})
	}, [user])

	const update = (field: keyof typeof form, value: string) => setForm((current) => ({ ...current, [field]: value }))
	const submit = async (event: React.FormEvent) => {
		event.preventDefault()
		setIsSaving(true)
		setMessage('')
		setError('')
		try {
			await updateProfile(form)
			setMessage('Retail business profile saved.')
		} catch {
			setError('We could not update your retailer profile.')
		} finally {
			setIsSaving(false)
		}
	}

	return (
		<main className="mx-auto max-w-3xl px-4 py-4 sm:px-6 sm:py-8">
			<ProfileIdentityPanel user={user} roleLabel="Retailer account" />
			<VerificationDocumentsPanel role={user?.role} />
			<form onSubmit={submit} className="mt-4 rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-6">
				<FormSection title="Account owner" description="Personal account details used for verification." icon={<UserCircle className="h-4 w-4" />}>
					<div className="grid gap-4 sm:grid-cols-2">
						<FormField label="First name" htmlFor="retailer-first-name"><Input id="retailer-first-name" value={form.first_name} onChange={(event) => update('first_name', event.target.value)} /></FormField>
						<FormField label="Middle name" htmlFor="retailer-middle-name"><Input id="retailer-middle-name" value={form.middle_name} onChange={(event) => update('middle_name', event.target.value)} /></FormField>
						<FormField label="Last name" htmlFor="retailer-last-name"><Input id="retailer-last-name" value={form.last_name} onChange={(event) => update('last_name', event.target.value)} /></FormField>
						<FormField label="Email" htmlFor="retailer-email"><Input id="retailer-email" type="email" value={form.email} onChange={(event) => update('email', event.target.value)} /></FormField>
						<FormField label="Verified phone" htmlFor="retailer-phone"><Input id="retailer-phone" value={form.phone} readOnly className="bg-muted text-muted-foreground" /></FormField>
						<FormField label="National ID" htmlFor="retailer-national-id"><Input id="retailer-national-id" value={form.national_id} onChange={(event) => update('national_id', event.target.value)} /></FormField>
					</div>
				</FormSection>
				<FormSection title="Business identity" description="Official details shown on procurement and delivery records." icon={<Store className="h-4 w-4" />}>
					<div className="grid gap-4 sm:grid-cols-2">
						<FormField label="Owner full name" htmlFor="owner-name"><Input id="owner-name" value={form.owner_full_name} onChange={(event) => update('owner_full_name', event.target.value)} /></FormField>
						<FormField label="Business name" htmlFor="business-name"><Input id="business-name" value={form.business_name} onChange={(event) => update('business_name', event.target.value)} /></FormField>
						<FormField label="Business type" htmlFor="business-type"><Select id="business-type" aria-label="Business type" value={form.business_type} onChange={(value) => update('business_type', value)} options={['Grocery store', 'Wholesale', 'Supermarket', 'Hotel & restaurant', 'School catering', 'Online retail'].map((type) => ({ value: type, label: type }))} /></FormField>
						<FormField label="Business phone" htmlFor="business-phone"><Input id="business-phone" value={form.business_phone} onChange={(event) => update('business_phone', event.target.value)} /></FormField>
						<FormField label="Business email" htmlFor="business-email"><Input id="business-email" type="email" value={form.business_email} onChange={(event) => update('business_email', event.target.value)} /></FormField>
						<FormField label="Registration number" htmlFor="business-registration"><Input id="business-registration" value={form.business_registration_number} onChange={(event) => update('business_registration_number', event.target.value)} /></FormField>
						<FormField label="KRA PIN" htmlFor="kra-pin"><Input id="kra-pin" value={form.kra_pin} onChange={(event) => update('kra_pin', event.target.value.toUpperCase())} /></FormField>
						<FormField label="Bank account" htmlFor="retailer-bank"><Input id="retailer-bank" value={form.bank_account} onChange={(event) => update('bank_account', event.target.value)} /></FormField>
					</div>
				</FormSection>
				<FormSection title="Business location" description="Used for supplier deliveries and logistics planning." icon={<MapPin className="h-4 w-4" />}>
					<div className="grid gap-4 sm:grid-cols-2">
						<FormField label="Address" htmlFor="business-address" className="sm:col-span-2"><Textarea id="business-address" rows={2} value={form.business_address} onChange={(event) => update('business_address', event.target.value)} /></FormField>
						<FormField label="Latitude" htmlFor="business-latitude"><Input id="business-latitude" type="number" inputMode="decimal" value={form.latitude} onChange={(event) => update('latitude', event.target.value)} /></FormField>
						<FormField label="Longitude" htmlFor="business-longitude"><Input id="business-longitude" type="number" inputMode="decimal" value={form.longitude} onChange={(event) => update('longitude', event.target.value)} /></FormField>
					</div>
				</FormSection>
				{message && <p role="status" className="flex items-center gap-2 rounded-xl bg-primary/10 p-3 text-sm text-primary"><Check className="h-4 w-4" />{message}</p>}
				{error && <p role="alert" className="rounded-xl bg-destructive/10 p-3 text-sm text-destructive">{error}</p>}
				<div className="flex justify-end border-t border-border pt-4"><Button type="submit" isLoading={isSaving} leftIcon={<Save className="h-4 w-4" />} className="w-full sm:w-auto">Save business profile</Button></div>
			</form>
		</main>
	)
}
