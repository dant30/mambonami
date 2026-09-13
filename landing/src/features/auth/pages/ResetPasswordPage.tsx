import { useEffect, useState } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import { requestPasswordReset, resetPassword, verifyPasswordResetCode } from '../../../core/lib'
import { getErrorMessage } from '../../../core/utils'
import { AuthField, AuthLayout, AuthSubmit, OtpCodeInput, OtpMeta, PasswordStrength } from '../components'

export function ResetPasswordPage() {
	const navigate = useNavigate()
	const location = useLocation()
	const phone = (location.state as { phone?: string } | null)?.phone ?? ''
	const [form, setForm] = useState({ otp: '', new_password: '', confirm_password: '' })
	const [error, setError] = useState('')
	const [secondsLeft, setSecondsLeft] = useState(300)
	const [isResending, setIsResending] = useState(false)
	const [isVerifying, setIsVerifying] = useState(false)
	const [isSubmitting, setIsSubmitting] = useState(false)
	const [codeVerified, setCodeVerified] = useState(false)
	useEffect(() => { if (secondsLeft <= 0) return; const timer = window.setInterval(() => setSecondsLeft((seconds) => Math.max(0, seconds - 1)), 1000); return () => window.clearInterval(timer) }, [secondsLeft])
	if (!phone) return <AuthLayout title="Reset session expired" description="Request a new password reset code."><button type="button" onClick={() => navigate('/forgot-password')} className="w-full rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground">Request a new code</button></AuthLayout>
	const verifyCode = async () => { setIsVerifying(true); setError(''); try { await verifyPasswordResetCode({ phone, otp: form.otp }); setCodeVerified(true) } catch (requestError) { setCodeVerified(false); setError(getErrorMessage(requestError, 'That code is invalid or expired.')) } finally { setIsVerifying(false) } }
	const submit = async (event: React.FormEvent) => {
		event.preventDefault()
		setError('')
		setIsSubmitting(true)
		try {
			await resetPassword({ phone, ...form })
			navigate('/success', { state: { message: 'Your password has been reset.' } })
		} catch (requestError) {
			setError(getErrorMessage(requestError, 'Unable to reset your password.'))
		} finally {
			setIsSubmitting(false)
		}
	}
	const resend = async () => { setIsResending(true); setError(''); try { await requestPasswordReset(phone); setSecondsLeft(300); setForm((current) => ({ ...current, otp: '' })) } catch (requestError) { setError(getErrorMessage(requestError, 'Unable to resend the code.')) } finally { setIsResending(false) } }
	return <AuthLayout title="Choose a new password"><form className="space-y-4" onSubmit={submit}>{error && <p role="alert" className="rounded-xl bg-destructive/10 p-3 text-sm text-destructive">{error}</p>}<OtpCodeInput value={form.otp} onChange={(otp) => { setCodeVerified(false); setForm({ ...form, otp }) }} /><OtpMeta phone={phone} secondsLeft={secondsLeft} onResend={() => void resend()} onChangeNumber={() => navigate('/forgot-password', { replace: true })} canResend={secondsLeft === 0} isResending={isResending} />{!codeVerified ? <AuthSubmit type="button" disabled={form.otp.length !== 6 || isVerifying} onClick={() => void verifyCode()}>{isVerifying ? 'Checking code...' : 'Verify code'}</AuthSubmit> : <><AuthField label="New password" type="password" value={form.new_password} onChange={(event) => setForm({ ...form, new_password: event.target.value })} required autoComplete="new-password" /><PasswordStrength password={form.new_password} /><AuthField label="Confirm password" type="password" value={form.confirm_password} onChange={(event) => setForm({ ...form, confirm_password: event.target.value })} required autoComplete="new-password" /><AuthSubmit disabled={isSubmitting}>{isSubmitting ? 'Resetting password...' : 'Reset password'}</AuthSubmit></>}</form></AuthLayout>
}
