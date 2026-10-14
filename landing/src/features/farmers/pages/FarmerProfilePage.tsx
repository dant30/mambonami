import { Check, MapPin, Save, Sprout, UserCircle } from 'lucide-react'
import { useEffect, useState } from 'react'

import { useAuth } from '../../../core/contexts/AuthContext'
import { updateProfile } from '../../../core/lib'
import { ProfileIdentityPanel } from '../../account/components/ProfileIdentityPanel'
import { FormField, FormSection } from '../../../shared/components/forms'
import { Badge, Button, Input } from '../../../shared/components/ui'

const blank = {
	first_name: '', middle_name: '', last_name: '', email: '', phone: '', national_id: '',
	county: '', sub_county: '', ward: '', village: '', cooperative: '', latitude: '', longitude: '',
	mpesa_number: '', bank_account: '',
}

export function FarmerProfilePage() {
	const { user } = useAuth()
	const [form, setForm] = useState(blank)
	const [isSaving, setIsSaving] = useState(false)
	const [message, setMessage] = useState('')
	const [error, setError] = useState('')

	useEffect(() => {
		const profile = (user?.farm_profile || {}) as Record<string, unknown>
		setForm({
			first_name: String(user?.first_name || ''), middle_name: String(user?.middle_name || ''),
			last_name: String(user?.last_name || ''), email: String(user?.email || ''),
			phone: String(user?.phone || ''), national_id: String(user?.national_id || ''),
			county: String(profile.county || ''), sub_county: String(profile.sub_county || ''),
			ward: String(profile.ward || ''), village: String(profile.village || ''),
			cooperative: String(profile.cooperative || ''), latitude: String(profile.latitude || ''),
			longitude: String(profile.longitude || ''), mpesa_number: String(profile.mpesa_number || ''),
			bank_account: String(profile.bank_account || ''),
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
			setMessage('Farm profile saved.')
		} catch {
			setError('We could not update your farm profile.')
		} finally {
			setIsSaving(false)
		}
	}

	return (
		<main className="mx-auto max-w-3xl px-4 py-4 sm:px-6 sm:py-8">
			<ProfileIdentityPanel user={user} roleLabel="Farmer account" />
			{Boolean((user?.farm_profile as Record<string, unknown> | undefined)?.cooperative) && (
				<div className="mt-3 flex items-center justify-between rounded-xl border border-border bg-card px-4 py-3 text-sm">
					<span className="text-muted-foreground">Cooperative endorsement</span>
					<Badge variant={(user?.farm_profile as Record<string, unknown>).coop_verified ? 'success' : 'warning'} size="sm">
						{(user?.farm_profile as Record<string, unknown>).coop_verified ? 'Verified' : 'Pending review'}
					</Badge>
				</div>
			)}
			<form onSubmit={submit} className="mt-4 rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-6">
				<FormSection title="Farmer identity" description="Account details used for buyer trust, support, and verification." icon={<UserCircle className="h-4 w-4" />}>
					<div className="grid gap-4 sm:grid-cols-2">
						<FormField label="First name" htmlFor="farmer-first-name"><Input id="farmer-first-name" value={form.first_name} onChange={(event) => update('first_name', event.target.value)} /></FormField>
						<FormField label="Middle name" htmlFor="farmer-middle-name"><Input id="farmer-middle-name" value={form.middle_name} onChange={(event) => update('middle_name', event.target.value)} /></FormField>
						<FormField label="Last name" htmlFor="farmer-last-name"><Input id="farmer-last-name" value={form.last_name} onChange={(event) => update('last_name', event.target.value)} /></FormField>
						<FormField label="Email" htmlFor="farmer-email"><Input id="farmer-email" type="email" value={form.email} onChange={(event) => update('email', event.target.value)} /></FormField>
						<FormField label="Verified phone" htmlFor="farmer-phone"><Input id="farmer-phone" value={form.phone} readOnly className="bg-muted text-muted-foreground" /></FormField>
						<FormField label="National ID" htmlFor="farmer-national-id"><Input id="farmer-national-id" value={form.national_id} onChange={(event) => update('national_id', event.target.value)} /></FormField>
					</div>
				</FormSection>
				<FormSection title="Farm location" description="Precise location improves pickup planning and delivery pricing." icon={<MapPin className="h-4 w-4" />}>
					<div className="grid gap-4 sm:grid-cols-2">
						<FormField label="County" htmlFor="farm-county"><Input id="farm-county" value={form.county} onChange={(event) => update('county', event.target.value)} /></FormField>
						<FormField label="Sub-county" htmlFor="farm-sub-county"><Input id="farm-sub-county" value={form.sub_county} onChange={(event) => update('sub_county', event.target.value)} /></FormField>
						<FormField label="Ward" htmlFor="farm-ward"><Input id="farm-ward" value={form.ward} onChange={(event) => update('ward', event.target.value)} /></FormField>
						<FormField label="Village" htmlFor="farm-village"><Input id="farm-village" value={form.village} onChange={(event) => update('village', event.target.value)} /></FormField>
						<FormField label="Latitude" htmlFor="farm-latitude"><Input id="farm-latitude" type="number" inputMode="decimal" value={form.latitude} onChange={(event) => update('latitude', event.target.value)} /></FormField>
						<FormField label="Longitude" htmlFor="farm-longitude"><Input id="farm-longitude" type="number" inputMode="decimal" value={form.longitude} onChange={(event) => update('longitude', event.target.value)} /></FormField>
					</div>
				</FormSection>
				<FormSection title="Farm business" description="Cooperative membership and payout details." icon={<Sprout className="h-4 w-4" />}>
					<div className="grid gap-4 sm:grid-cols-2">
						<FormField label="Cooperative or group" htmlFor="farm-cooperative"><Input id="farm-cooperative" value={form.cooperative} onChange={(event) => update('cooperative', event.target.value)} /></FormField>
						<FormField label="M-Pesa payout number" htmlFor="farm-mpesa"><Input id="farm-mpesa" value={form.mpesa_number} onChange={(event) => update('mpesa_number', event.target.value)} /></FormField>
						<FormField label="Bank account" htmlFor="farm-bank" className="sm:col-span-2"><Input id="farm-bank" value={form.bank_account} onChange={(event) => update('bank_account', event.target.value)} /></FormField>
					</div>
				</FormSection>
				{message && <p role="status" className="flex items-center gap-2 rounded-xl bg-primary/10 p-3 text-sm text-primary"><Check className="h-4 w-4" />{message}</p>}
				{error && <p role="alert" className="rounded-xl bg-destructive/10 p-3 text-sm text-destructive">{error}</p>}
				<div className="flex justify-end border-t border-border pt-4"><Button type="submit" isLoading={isSaving} leftIcon={<Save className="h-4 w-4" />} className="w-full sm:w-auto">Save profile</Button></div>
			</form>
		</main>
	)
}
