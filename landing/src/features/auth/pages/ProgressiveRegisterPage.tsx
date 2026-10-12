import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { registrationDraftStore, startRegistrationTransaction } from '../../../core/lib'
import type { AuthRole, RegisterInput } from '../../../core/lib'
import { getErrorMessage } from '../../../core/utils'
import { toast } from '../../../shared/components/feedback'
import { AuthField, AuthLayout, AuthSubmit, PasswordStrength } from '../components'

interface RegistrationProgress {
	form: Partial<RegisterInput>
	step: number
}

function draftKey(role: AuthRole) {
	return `mambonami_registration_progress_${role}`
}

function readProgress(role: AuthRole): RegistrationProgress {
	const fallback = { form: { role }, step: 0 }
	if (typeof window === 'undefined') return fallback
	try {
		const raw = window.sessionStorage.getItem(draftKey(role))
		if (!raw) return fallback
		const saved = JSON.parse(raw) as RegistrationProgress
		const step = Math.max(0, Math.min(3, Number(saved.step) || 0))
		return {
			form: { ...saved.form, role, password: '', confirm_password: '' },
			step: step >= 2 ? 2 : step,
		}
	} catch {
		return fallback
	}
}

export function ProgressiveRegisterPage({ role }: { role: AuthRole }) {
	const navigate = useNavigate()
	const [progress, setProgress] = useState(() => readProgress(role))
	const [error, setError] = useState('')
	const [fieldErrors, setFieldErrors] = useState<{ confirm_password?: string }>({})
	const [isSubmitting, setIsSubmitting] = useState(false)
	const { form, step } = progress
	const retailer = role === 'retailer'
	const roleDetailsLabel = role === 'buyer' ? 'Delivery details' : role === 'farmer' ? 'Farm details' : retailer ? 'Business details' : 'Vehicle details'
	const steps = ['Account', roleDetailsLabel, 'Password', 'Review']

	useEffect(() => {
		if (typeof window === 'undefined') return
		const { password: _password, confirm_password: _confirmPassword, ...safeForm } = form
		try {
			window.sessionStorage.setItem(draftKey(role), JSON.stringify({ form: safeForm, step }))
		} catch {
			return
		}
	}, [form, role, step])

	const update = (key: keyof RegisterInput, value: string) => {
		setProgress((current) => {
			const nextForm = { ...current.form, [key]: value } as Partial<RegisterInput>

			if (key === 'password' || key === 'confirm_password') {
				const password = nextForm.password ?? ''
				const confirmPassword = nextForm.confirm_password ?? ''
				const confirmPasswordError = confirmPassword && password && confirmPassword !== password ? 'Passwords do not match.' : ''
				setFieldErrors({ confirm_password: confirmPasswordError })
			}
			return { ...current, form: nextForm }
		})
	}

	const submit = async (event: React.FormEvent) => {
		event.preventDefault()
		setError('')
		const formElement = event.currentTarget as HTMLFormElement
		if (!formElement.reportValidity()) return
		if (step < 3) {
			setProgress((current) => ({ ...current, step: current.step + 1 }))
			return
		}
		setIsSubmitting(true)

		const password = form.password ?? ''
		const confirmPassword = form.confirm_password ?? ''
		const confirmPasswordError = confirmPassword && password && confirmPassword !== password ? 'Passwords do not match.' : ''

		if (confirmPasswordError) {
			setFieldErrors({ confirm_password: confirmPasswordError })
			setError(confirmPasswordError)
			toast.error('Registration incomplete', confirmPasswordError)
			setIsSubmitting(false)
			return
		}

		try {
			const session = await startRegistrationTransaction(form as RegisterInput)
			registrationDraftStore.set(session)
			navigate('/otp')
		} catch (requestError) {
			const message = getErrorMessage(requestError, 'Unable to send verification code.')
			setError(message)
			setFieldErrors((current) => ({
				...current,
				confirm_password: message.includes('Passwords do not match.') ? 'Passwords do not match.' : current.confirm_password,
			}))
			toast.error('Registration failed', message)
		} finally {
			setIsSubmitting(false)
		}
	}

	const roleLabel = role === 'transport_provider' ? 'transport provider' : role
	const reviewFields = [
		['Phone number', form.phone],
		['Username', form.username],
		['Email', form.email],
		['Full name', retailer ? form.owner_full_name : form.full_name],
		['Delivery address', form.delivery_address],
		['M-Pesa number', form.mpesa_number],
		['Farm coordinates', form.latitude !== undefined && form.longitude !== undefined ? `${form.latitude}, ${form.longitude}` : undefined],
		['Business name', form.business_name],
		['Business address', form.business_address],
		['Vehicle type', form.vehicle_type],
		['License plate', form.license_plate],
		['National ID', form.national_id],
	].filter(([, value]) => value !== undefined && value !== '') as Array<[string, string | number]>

	return (
		<AuthLayout
			title={`Create your ${roleLabel} account`}
			description="Create your account in a few short steps. Your progress is saved on this device."
		>
			<div className="mb-5" aria-label={`Step ${step + 1} of ${steps.length}`}>
				<div className="mb-2 flex items-center justify-between text-xs font-semibold text-muted-foreground"><span>Step {step + 1} of {steps.length}</span><span>{steps[step]}</span></div>
				<div className="grid grid-cols-4 gap-1.5" aria-hidden="true">{steps.map((label, index) => <div key={label} className={`h-1.5 rounded-full ${index <= step ? 'bg-primary' : 'bg-border'}`} />)}</div>
			</div>
			<form className="space-y-4" onSubmit={submit}>
				{error && (
					<p role="alert" className="rounded-xl bg-destructive/10 p-3 text-sm text-destructive">
						{error}
					</p>
				)}

				{step === 0 && <div className="space-y-4">
					<AuthField label="Phone number" type="tel" inputMode="tel" value={form.phone ?? ''} onChange={(event) => update('phone', event.target.value)} required autoComplete="tel" />
					<AuthField label="Username" value={form.username ?? ''} onChange={(event) => update('username', event.target.value)} required autoComplete="username" />
					<AuthField label="Email address" type="email" inputMode="email" value={form.email ?? ''} onChange={(event) => update('email', event.target.value)} autoComplete="email" />
				</div>}

				{step === 1 && <div className="space-y-4">
					{role === 'buyer' && <>
						<AuthField label="Full name" value={form.full_name ?? ''} onChange={(event) => update('full_name', event.target.value)} required autoComplete="name" />
						<AuthField label="Delivery address" value={form.delivery_address ?? ''} onChange={(event) => update('delivery_address', event.target.value)} required autoComplete="street-address" />
					</>}
					{role === 'farmer' && <>
						<AuthField label="Full name" value={form.full_name ?? ''} onChange={(event) => update('full_name', event.target.value)} required autoComplete="name" />
						<AuthField label="M-Pesa number" type="tel" inputMode="tel" value={form.mpesa_number ?? ''} onChange={(event) => update('mpesa_number', event.target.value)} required autoComplete="tel" />
						<div className="grid grid-cols-2 gap-3"><AuthField label="Farm latitude" type="number" inputMode="decimal" value={String(form.latitude ?? '')} onChange={(event) => update('latitude', event.target.value)} required /><AuthField label="Farm longitude" type="number" inputMode="decimal" value={String(form.longitude ?? '')} onChange={(event) => update('longitude', event.target.value)} required /></div>
					</>}
					{retailer && <>
						<AuthField label="Owner full name" value={form.owner_full_name ?? ''} onChange={(event) => update('owner_full_name', event.target.value)} required autoComplete="name" />
						<AuthField label="Business name" value={form.business_name ?? ''} onChange={(event) => update('business_name', event.target.value)} required autoComplete="organization" />
						<AuthField label="Business phone" type="tel" inputMode="tel" value={form.business_phone ?? ''} onChange={(event) => update('business_phone', event.target.value)} autoComplete="tel" />
						<AuthField label="Business email" type="email" inputMode="email" value={form.business_email ?? ''} onChange={(event) => update('business_email', event.target.value)} autoComplete="email" />
						<AuthField label="Business address" value={form.business_address ?? ''} onChange={(event) => update('business_address', event.target.value)} required autoComplete="street-address" />
						<AuthField label="Business type" value={form.business_type ?? ''} onChange={(event) => update('business_type', event.target.value)} placeholder="Shop, grocery, restaurant" />
					</>}
					{role === 'transport_provider' && <>
						<AuthField label="Full name" value={form.full_name ?? ''} onChange={(event) => update('full_name', event.target.value)} required autoComplete="name" />
						<AuthField label="National ID" inputMode="numeric" value={form.national_id ?? ''} onChange={(event) => update('national_id', event.target.value)} required />
						<AuthField label="Vehicle type" value={form.vehicle_type ?? ''} onChange={(event) => update('vehicle_type', event.target.value)} placeholder="van, pickup, motorcycle" required />
						<AuthField label="License plate" value={form.license_plate ?? ''} onChange={(event) => update('license_plate', event.target.value)} required autoCapitalize="characters" />
					</>}
				</div>}

				{step === 2 && <div className="space-y-4">
					<AuthField label="Password" type="password" value={form.password ?? ''} onChange={(event) => update('password', event.target.value)} required minLength={8} autoComplete="new-password" />
					<PasswordStrength password={form.password ?? ''} />
					<AuthField label="Confirm password" type="password" value={form.confirm_password ?? ''} onChange={(event) => update('confirm_password', event.target.value)} error={fieldErrors.confirm_password} required autoComplete="new-password" />
					<p className="rounded-xl border border-primary/20 bg-primary/5 p-3 text-xs leading-5 text-muted-foreground">For privacy, passwords are not saved between visits. If you leave this step, enter them again to continue.</p>
				</div>}

				{step === 3 && <div className="space-y-3">
					<p className="text-sm text-muted-foreground">Review your details before sending the phone verification code.</p>
					<dl className="divide-y divide-border rounded-xl border border-border bg-background px-3">
						{reviewFields.map(([label, value]) => <div key={label} className="grid grid-cols-[minmax(0,0.8fr)_minmax(0,1.2fr)] gap-3 py-3 text-sm"><dt className="text-muted-foreground">{label}</dt><dd className="break-words text-right font-semibold text-primary-dark">{value}</dd></div>)}
					</dl>
					<p className="rounded-xl border border-dashed border-primary/40 bg-primary/5 p-3 text-xs leading-5 text-muted-foreground">After verification, you can finish any remaining profile and document details.</p>
				</div>}

				<div className="grid grid-cols-2 gap-2 pt-1">
					{step > 0 && <button type="button" onClick={() => { setError(''); setProgress((current) => ({ ...current, step: current.step - 1 })) }} className="inline-flex min-h-11 items-center justify-center rounded-full border border-border px-4 py-2.5 text-sm font-semibold text-primary-dark">Back</button>}
					<AuthSubmit disabled={isSubmitting}>{step < 2 ? 'Continue' : isSubmitting ? 'Sending code...' : step === 2 ? 'Review details' : 'Send verification code'}</AuthSubmit>
				</div>
			</form>
		</AuthLayout>
	)
}
