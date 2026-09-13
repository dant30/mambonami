import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { requestPasswordReset } from '../../../core/lib'
import { getErrorMessage } from '../../../core/utils'
import { AuthField, AuthLayout, AuthSubmit } from '../components'

export function ForgotPasswordPage() {
	const navigate = useNavigate()
	const [phone, setPhone] = useState('')
	const [error, setError] = useState('')
	const [isSubmitting, setIsSubmitting] = useState(false)
	const submit = async (event: React.FormEvent) => {
		event.preventDefault()
		setError('')
		setIsSubmitting(true)
		try {
			await requestPasswordReset(phone)
			navigate('/reset-password', { state: { phone } })
		} catch (requestError) {
			setError(getErrorMessage(requestError, 'Unable to request a reset code.'))
		} finally {
			setIsSubmitting(false)
		}
	}
	return <AuthLayout title="Reset your password" description="We will send a six-digit code to your MAMBONAMI phone number."><form className="space-y-4" onSubmit={submit}>{error && <p role="alert" className="rounded-xl bg-destructive/10 p-3 text-sm text-destructive">{error}</p>}<AuthField label="Phone number" value={phone} onChange={(event) => setPhone(event.target.value)} required autoComplete="tel" /><AuthSubmit disabled={isSubmitting}>{isSubmitting ? 'Sending code...' : 'Send reset code'}</AuthSubmit></form></AuthLayout>
}
