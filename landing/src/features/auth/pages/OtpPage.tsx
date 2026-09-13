import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { registrationDraftStore, resendRegistration, verifyRegistrationTransaction } from '../../../core/lib'
import { useAuth } from '../../../core/contexts/AuthContext'
import { getErrorMessage } from '../../../core/utils'
import { AuthLayout, AuthSubmit, OtpCodeInput, OtpMeta } from '../components'

export function OtpPage() {
	const navigate = useNavigate()
	const { setSession } = useAuth()
	const registration = registrationDraftStore.get()
	const [otp, setOtp] = useState('')
	const [error, setError] = useState('')
	const [secondsLeft, setSecondsLeft] = useState(300)
	const [isResending, setIsResending] = useState(false)
	const [isSubmitting, setIsSubmitting] = useState(false)
	useEffect(() => { if (secondsLeft <= 0) return; const timer = window.setInterval(() => setSecondsLeft((seconds) => Math.max(0, seconds - 1)), 1000); return () => window.clearInterval(timer) }, [secondsLeft])
	if (!registration) return <AuthLayout title="Verification expired" description="Start registration again to request a new code."><button type="button" onClick={() => navigate('/role-select')} className="w-full rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground">Choose a role</button></AuthLayout>
	const submit = async (event: React.FormEvent) => {
		event.preventDefault()
		setError('')
		setIsSubmitting(true)
		try {
			const response = await verifyRegistrationTransaction({ registration_id: registration.registration_id, otp })
			registrationDraftStore.clear()
			setSession(response.user, response.tokens ?? null)
			navigate('/onboarding', { replace: true })
		} catch (requestError) {
			setError(getErrorMessage(requestError, 'Invalid or expired code.'))
		} finally {
			setIsSubmitting(false)
		}
	}
	const resend = async () => { setIsResending(true); setError(''); try { await resendRegistration(registration.registration_id); setSecondsLeft(300); setOtp('') } catch (requestError) { setError(getErrorMessage(requestError, 'Unable to resend the code.')) } finally { setIsResending(false) } }
	return <AuthLayout title="Verify your phone" description="Enter the six-digit code sent to your phone."><form className="space-y-5" onSubmit={submit}>{error && <p role="alert" className="rounded-xl bg-destructive/10 p-3 text-sm text-destructive">{error}</p>}<OtpCodeInput value={otp} onChange={setOtp} /><OtpMeta phone={registration.phone} secondsLeft={secondsLeft} onResend={() => void resend()} onChangeNumber={() => navigate(`/register/${registration.role}`, { replace: true })} canResend={secondsLeft === 0} isResending={isResending} /><AuthSubmit disabled={otp.length !== 6 || isSubmitting}>{isSubmitting ? 'Creating account...' : 'Verify and create account'}</AuthSubmit></form></AuthLayout>
}
