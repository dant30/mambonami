import { InputOTP, InputOTPGroup, InputOTPSlot } from '../../../shared/components/ui/Input-otp'

export function OtpCodeInput({ value, onChange }: { value: string; onChange: (value: string) => void }) {
	return <InputOTP maxLength={6} value={value} onChange={onChange} inputMode="numeric" aria-label="Six digit verification code"><InputOTPGroup>{[0, 1, 2, 3, 4, 5].map((index) => <InputOTPSlot key={index} index={index} className="h-11 w-11 text-base" />)}</InputOTPGroup></InputOTP>
}

export function OtpMeta({ phone, secondsLeft, onResend, onChangeNumber, canResend, isResending }: { phone: string; secondsLeft: number; onResend: () => void; onChangeNumber: () => void; canResend: boolean; isResending: boolean }) {
	return <div className="space-y-3 text-center text-xs text-muted-foreground"><p>Code sent to <strong className="text-foreground">{phone}</strong></p><div className="flex items-center justify-center gap-3"><button type="button" onClick={onChangeNumber} className="font-bold text-primary hover:underline">Change number</button><span aria-hidden="true">|</span><button type="button" disabled={!canResend || isResending} onClick={onResend} className="font-bold text-primary disabled:cursor-not-allowed disabled:text-muted-foreground">{isResending ? 'Sending...' : canResend ? 'Resend code' : `Resend in ${secondsLeft}s`}</button></div></div>
}
