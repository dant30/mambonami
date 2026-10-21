import { Check, Save, Truck, UserCircle, Wallet } from 'lucide-react'
import { useEffect, useState } from 'react'

import { useAuth } from '../../../core/contexts/AuthContext'
import { updateProfile, updateTransportProfile } from '../../../core/lib'
import { ProfileIdentityPanel } from '../../account/components/ProfileIdentityPanel'
import { VerificationDocumentsPanel } from '../../account/components/VerificationDocumentsPanel'
import { FormField, FormSection } from '../../../shared/components/forms'
import { Badge, Button, Input, Select } from '../../../shared/components/ui'

type TransporterProfileForm = {
	first_name: string
	middle_name: string
	last_name: string
	email: string
	phone: string
	national_id: string
	vehicle_type: string
	license_plate: string
	driver_license: string
	capacity_kg: string
	bank_account: string
}

const emptyForm: TransporterProfileForm = {
	first_name: '', middle_name: '', last_name: '', email: '', phone: '', national_id: '',
	vehicle_type: 'van', license_plate: '', driver_license: '', capacity_kg: '100', bank_account: '',
}

export function TransporterProfilePage() {
	const { user } = useAuth()
	const [form, setForm] = useState<TransporterProfileForm>(emptyForm)
	const [isSaving, setIsSaving] = useState(false)
	const [message, setMessage] = useState('')
	const [error, setError] = useState('')

	useEffect(() => {
		const profile = (user?.transport_profile ?? {}) as Record<string, unknown>
		setForm({
			first_name: String(user?.first_name || ''),
			middle_name: String(user?.middle_name || ''),
			last_name: String(user?.last_name || ''),
			email: String(user?.email || ''),
			phone: String(user?.phone || ''),
			national_id: String(user?.national_id || ''),
			vehicle_type: String(profile.vehicle_type || 'van'),
			license_plate: String(profile.license_plate || ''),
			driver_license: String(profile.driver_license || ''),
			capacity_kg: String(profile.capacity_kg || '100'),
			bank_account: String(profile.bank_account || ''),
		})
	}, [user])

	const update = (field: keyof TransporterProfileForm, value: string) => setForm((current) => ({ ...current, [field]: value }))
	const submit = async (event: React.FormEvent) => {
		event.preventDefault()
		setIsSaving(true)
		setMessage('')
		setError('')
		try {
			await updateProfile({ first_name: form.first_name, middle_name: form.middle_name, last_name: form.last_name, email: form.email, national_id: form.national_id })
			await updateTransportProfile({ vehicle_type: form.vehicle_type, license_plate: form.license_plate, driver_license: form.driver_license, capacity_kg: Number(form.capacity_kg || 0), bank_account: form.bank_account })
			setMessage('Driver and vehicle profile saved.')
		} catch {
			setError('We could not update your transport profile.')
		} finally {
			setIsSaving(false)
		}
	}

	return (
		<main className="mx-auto max-w-3xl px-4 py-4 sm:px-6 sm:py-8">
			<ProfileIdentityPanel user={user} roleLabel="Transport provider" />
			<VerificationDocumentsPanel role={user?.role} />
			<div className="mt-3 grid grid-cols-2 gap-2 rounded-xl border border-border bg-card p-3">
				<div><p className="text-[10px] font-bold uppercase text-muted-foreground">Provider approval</p><Badge variant={(user?.transport_profile as Record<string, unknown> | undefined)?.is_approved ? 'success' : 'warning'} size="sm" className="mt-1">{(user?.transport_profile as Record<string, unknown> | undefined)?.is_approved ? 'Approved' : 'Pending review'}</Badge></div>
				<div><p className="text-[10px] font-bold uppercase text-muted-foreground">Provider deposit</p><Badge variant={(user?.transport_profile as Record<string, unknown> | undefined)?.deposit_paid ? 'success' : 'warning'} size="sm" className="mt-1">{(user?.transport_profile as Record<string, unknown> | undefined)?.deposit_paid ? 'Paid' : 'Payment pending'}</Badge></div>
			</div>
			<form onSubmit={submit} className="mt-4 rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-6">
				<FormSection title="Driver identity" description="Verified account information used for dispatch and customer trust." icon={<UserCircle className="h-4 w-4" />}>
					<div className="grid gap-4 sm:grid-cols-2">
						<FormField label="First name" htmlFor="driver-first-name" required><Input id="driver-first-name" required value={form.first_name} onChange={(event) => update('first_name', event.target.value)} /></FormField>
						<FormField label="Middle name" htmlFor="driver-middle-name"><Input id="driver-middle-name" value={form.middle_name} onChange={(event) => update('middle_name', event.target.value)} /></FormField>
						<FormField label="Last name" htmlFor="driver-last-name" required><Input id="driver-last-name" required value={form.last_name} onChange={(event) => update('last_name', event.target.value)} /></FormField>
						<FormField label="Email" htmlFor="driver-email"><Input id="driver-email" type="email" value={form.email} onChange={(event) => update('email', event.target.value)} /></FormField>
						<FormField label="Verified phone" htmlFor="driver-phone"><Input id="driver-phone" value={form.phone} readOnly className="bg-muted text-muted-foreground" /></FormField>
						<FormField label="National ID" htmlFor="driver-national-id"><Input id="driver-national-id" value={form.national_id} onChange={(event) => update('national_id', event.target.value)} /></FormField>
					</div>
				</FormSection>
				<FormSection title="Primary vehicle" description="Used to match capacity and route requirements." icon={<Truck className="h-4 w-4" />}>
					<div className="grid gap-4 sm:grid-cols-2">
						<FormField label="Vehicle type" htmlFor="vehicle-type"><Select id="vehicle-type" aria-label="Vehicle type" value={form.vehicle_type} onChange={(value) => update('vehicle_type', value)} options={['motorcycle', 'pickup', 'van', 'lorry'].map((type) => ({ value: type, label: type === 'pickup' ? 'Pickup truck' : type.charAt(0).toUpperCase() + type.slice(1) }))} /></FormField>
						<FormField label="Capacity (kg)" htmlFor="capacity-kg"><Input id="capacity-kg" type="number" min="1" value={form.capacity_kg} onChange={(event) => update('capacity_kg', event.target.value)} /></FormField>
						<FormField label="License plate" htmlFor="license-plate"><Input id="license-plate" value={form.license_plate} onChange={(event) => update('license_plate', event.target.value.toUpperCase())} /></FormField>
						<FormField label="Driver licence" htmlFor="driver-license"><Input id="driver-license" value={form.driver_license} onChange={(event) => update('driver_license', event.target.value)} /></FormField>
					</div>
				</FormSection>
				<FormSection title="Payout account" description="Bank account used when a payout cannot be completed through the primary payment channel." icon={<Wallet className="h-4 w-4" />}>
					<FormField label="Bank account" htmlFor="transport-bank-account"><Input id="transport-bank-account" value={form.bank_account} onChange={(event) => update('bank_account', event.target.value)} /></FormField>
				</FormSection>
				{message && <p role="status" className="flex items-center gap-2 rounded-xl bg-primary/10 p-3 text-sm text-primary"><Check className="h-4 w-4" />{message}</p>}
				{error && <p role="alert" className="rounded-xl bg-destructive/10 p-3 text-sm text-destructive">{error}</p>}
				<div className="flex justify-end border-t border-border pt-4"><Button type="submit" isLoading={isSaving} leftIcon={<Save className="h-4 w-4" />} className="w-full sm:w-auto">Save profile</Button></div>
			</form>
		</main>
	)
}
