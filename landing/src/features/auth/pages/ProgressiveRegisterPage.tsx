import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { registrationDraftStore, startRegistrationTransaction } from '../../../core/lib'
import type { AuthRole, RegisterInput } from '../../../core/lib'
import { getErrorMessage } from '../../../core/utils'
import { toast } from '../../../shared/components/feedback'
import { AuthField, AuthLayout, AuthSubmit, PasswordStrength } from '../components'

export function ProgressiveRegisterPage({ role }: { role: AuthRole }) {
	const navigate = useNavigate()
	const [form, setForm] = useState<Partial<RegisterInput>>({ role })
	const [error, setError] = useState('')
	const [fieldErrors, setFieldErrors] = useState<{ confirm_password?: string }>({})
	const [isSubmitting, setIsSubmitting] = useState(false)

	const update = (key: keyof RegisterInput, value: string) => {
		const nextForm = { ...form, [key]: value }
		setForm(nextForm)

		if (key === 'password' || key === 'confirm_password') {
			const password = nextForm.password ?? ''
			const confirmPassword = nextForm.confirm_password ?? ''
			const confirmPasswordError = confirmPassword && password && confirmPassword !== password ? 'Passwords do not match.' : ''
			setFieldErrors((current) => ({
				...current,
				confirm_password: confirmPasswordError,
			}))
		}
	}

	const submit = async (event: React.FormEvent) => {
		event.preventDefault()
		setError('')
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
	const retailer = role === 'retailer'

	return (
		<AuthLayout
			title={`Create your ${roleLabel} account`}
			description="Start with the basics. Once your phone is verified, you can finish your profile step by step."
		>
			<form className="space-y-4" onSubmit={submit}>
				{error && (
					<p role="alert" className="rounded-xl bg-destructive/10 p-3 text-sm text-destructive">
						{error}
					</p>
				)}

				<AuthField
					label="Phone number"
					value={form.phone ?? ''}
					onChange={(event) => update('phone', event.target.value)}
					required
					autoComplete="tel"
				/>

				<AuthField
					label="Username"
					value={form.username ?? ''}
					onChange={(event) => update('username', event.target.value)}
					required
				/>

				<AuthField
					label="Password"
					type="password"
					value={form.password ?? ''}
					onChange={(event) => update('password', event.target.value)}
					required
					autoComplete="new-password"
				/>
				<PasswordStrength password={form.password ?? ''} />

				<AuthField
					label="Confirm password"
					type="password"
					value={form.confirm_password ?? ''}
					onChange={(event) => update('confirm_password', event.target.value)}
					error={fieldErrors.confirm_password}
					required
					autoComplete="new-password"
				/>

				{retailer && (
					<div className="space-y-4 rounded-2xl border border-border bg-muted/40 p-4">
						<p className="text-xs font-bold uppercase tracking-[0.16em] text-primary">Business details</p>
						<AuthField
							label="Owner full name"
							value={form.owner_full_name ?? ''}
							onChange={(event) => update('owner_full_name', event.target.value)}
							required
							autoComplete="name"
						/>
						<AuthField
							label="Business name"
							value={form.business_name ?? ''}
							onChange={(event) => update('business_name', event.target.value)}
							required
						/>
						<AuthField
							label="Business address"
							value={form.business_address ?? ''}
							onChange={(event) => update('business_address', event.target.value)}
							required
						/>
					</div>
				)}

				<p className="rounded-2xl border border-dashed border-primary/50 bg-primary/5 p-3 text-xs leading-6 text-muted-foreground">
					After verification, you will be guided through the remaining profile details for your role.
				</p>

				<AuthSubmit disabled={isSubmitting}>{isSubmitting ? 'Sending code...' : 'Send verification code'}</AuthSubmit>
			</form>
		</AuthLayout>
	)
}
