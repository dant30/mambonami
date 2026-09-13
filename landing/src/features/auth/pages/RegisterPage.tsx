import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { registrationDraftStore, startRegistrationTransaction } from '../../../core/lib'
import type { AuthRole, RegisterInput } from '../../../core/lib'
import { getErrorMessage } from '../../../core/utils'
import { AuthField, AuthLayout, AuthSubmit, PasswordStrength } from '../components'

export function RegisterPage({ role }: { role: AuthRole }) {
	const navigate = useNavigate()
	const [form, setForm] = useState<Partial<RegisterInput>>({ role })
	const [error, setError] = useState('')
	const [isSubmitting, setIsSubmitting] = useState(false)
	const update = (key: keyof RegisterInput, value: string) => setForm((current) => ({ ...current, [key]: value }))
	const submit = async (event: React.FormEvent) => {
		event.preventDefault()
		setError('')
		setIsSubmitting(true)
		try {
			const session = await startRegistrationTransaction(form as RegisterInput)
			registrationDraftStore.set(session)
			navigate('/otp')
		} catch (requestError) {
			setError(getErrorMessage(requestError, 'Unable to send verification code.'))
		} finally {
			setIsSubmitting(false)
		}
	}
	const farmer = role === 'farmer'
	const transport = role === 'transport_provider'
	const retailer = role === 'retailer'
	return <AuthLayout title={`Create your ${transport ? 'transport' : role} account`} description="Enter your details. We will verify your phone next."><form className="space-y-4" onSubmit={submit}>{error && <p role="alert" className="rounded-xl bg-destructive/10 p-3 text-sm text-destructive">{error}</p>}<AuthField label="Phone number" value={form.phone ?? ''} onChange={(event) => update('phone', event.target.value)} required autoComplete="tel" /><AuthField label="Username" value={form.username ?? ''} onChange={(event) => update('username', event.target.value)} required /><AuthField label="Email" type="email" value={form.email ?? ''} onChange={(event) => update('email', event.target.value)} /><AuthField label={retailer ? 'Owner full name' : 'Full name'} value={(retailer ? form.owner_full_name : form.full_name) ?? ''} onChange={(event) => update(retailer ? 'owner_full_name' : 'full_name', event.target.value)} required={retailer} />{retailer && <><AuthField label="Business name" value={form.business_name ?? ''} onChange={(event) => update('business_name', event.target.value)} required /><AuthField label="Business address" value={form.business_address ?? ''} onChange={(event) => update('business_address', event.target.value)} /></>}{farmer && <><AuthField label="M-Pesa number" value={form.mpesa_number ?? ''} onChange={(event) => update('mpesa_number', event.target.value)} required /><div className="grid grid-cols-2 gap-3"><AuthField label="Latitude" value={form.latitude ?? ''} onChange={(event) => update('latitude', event.target.value)} required /><AuthField label="Longitude" value={form.longitude ?? ''} onChange={(event) => update('longitude', event.target.value)} required /></div></>}{transport && <><AuthField label="Vehicle type" placeholder="van, pickup, motorcycle" value={form.vehicle_type ?? ''} onChange={(event) => update('vehicle_type', event.target.value)} required /><AuthField label="License plate" value={form.license_plate ?? ''} onChange={(event) => update('license_plate', event.target.value)} required /></>}{role === 'buyer' && <AuthField label="Delivery address" value={form.delivery_address ?? ''} onChange={(event) => update('delivery_address', event.target.value)} required />}<AuthField label="Password" type="password" value={form.password ?? ''} onChange={(event) => update('password', event.target.value)} required autoComplete="new-password" /><PasswordStrength password={form.password ?? ''} /><AuthField label="Confirm password" type="password" value={form.confirm_password ?? ''} onChange={(event) => update('confirm_password', event.target.value)} required autoComplete="new-password" /><AuthSubmit disabled={isSubmitting}>{isSubmitting ? 'Sending code...' : 'Continue to verification'}</AuthSubmit></form></AuthLayout>
}
