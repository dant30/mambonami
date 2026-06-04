import { useEffect, useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import {
  passwordResetInit as forgotPasswordInitRequest,
  passwordResetVerify as forgotPasswordVerifyRequest,
} from '../services/authService';
import Button from '../../../shared/components/ui/Button';
import Input from '../../../shared/components/ui/Input';
import Label from '../../../shared/components/ui/Label';
import Alert from '../../../shared/components/ui/Alert';
import Card from '../../../shared/components/ui/Card';

const initSchema = z.object({
  phone: z.string().nonempty('Phone is required').min(9, 'Enter a valid phone number'),
});

const verifySchema = z
  .object({
    phone: z.string().nonempty('Phone is required'),
    otp_code: z.string().nonempty('OTP code is required'),
    new_password: z.string().nonempty('Password is required').min(6, 'Password must be at least 6 characters'),
    confirm_password: z.string().nonempty('Please confirm your password'),
  })
  .refine((data) => data.new_password === data.confirm_password, {
    message: 'Passwords must match',
    path: ['confirm_password'],
  });

type InitValues = z.infer<typeof initSchema>;
type VerifyValues = z.infer<typeof verifySchema>;

export default function ForgotPassword() {
  const navigate = useNavigate();
  const [phase, setPhase] = useState<'init' | 'verify'>('init');
  const [savedPhone, setSavedPhone] = useState('');
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<InitValues>({ resolver: zodResolver(initSchema) });

  const {
    register: verifyRegister,
    handleSubmit: handleVerifySubmit,
    reset: resetVerify,
    formState: { errors: verifyErrors, isSubmitting: isVerifying },
  } = useForm<VerifyValues>({ resolver: zodResolver(verifySchema), defaultValues: { phone: savedPhone } });

  useEffect(() => {
    if (phase === 'verify') {
      resetVerify({ phone: savedPhone });
    }
  }, [phase, resetVerify, savedPhone]);

  const onInitSubmit = async (values: InitValues) => {
    setErrorMessage(null);
    try {
      await forgotPasswordInitRequest(values);
      setSavedPhone(values.phone);
      setPhase('verify');
    } catch (error) {
      setErrorMessage('Unable to send reset code. Please check your phone and try again.');
    }
  };

  const onVerifySubmit = async (values: VerifyValues) => {
    setErrorMessage(null);
    try {
      await forgotPasswordVerifyRequest(values);
      navigate('/login');
    } catch (error) {
      setErrorMessage('Unable to reset password. Please check your OTP and try again.');
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-emerald-100 to-green-50 text-slate-900 p-6 md:p-12">
      <div className="mx-auto max-w-4xl">
        <Card className="grid gap-8 lg:grid-cols-[0.95fr_0.85fr] p-8 border border-slate-200 bg-white/95 shadow-soft dark:border-slate-700 dark:bg-slate-950/95">
          <div className="space-y-5">
            <div>
              <p className="text-sm uppercase tracking-[0.24em] text-emerald-200/80">Security first</p>
              <h1 className="text-3xl font-semibold">Reset your password</h1>
              <p className="mt-3 text-sm text-slate-300">
                Securely update your password using a code sent to your phone. You’ll be able to log in again once the reset is complete.
              </p>
            </div>
            <div className="rounded-3xl border border-slate-200 bg-slate-50 p-5 dark:border-slate-700 dark:bg-slate-900/80">
              <p className="text-sm font-semibold text-slate-900 dark:text-slate-100">Need help?</p>
              <p className="mt-2 text-sm text-slate-300">
                If you don’t receive an OTP, check your phone number and try again. Contact support if the issue persists.
              </p>
            </div>
          </div>

          <div>
            {errorMessage ? <Alert variant="destructive">{errorMessage}</Alert> : null}
            {phase === 'init' ? (
              <form className="space-y-5" onSubmit={handleSubmit(onInitSubmit)}>
                <div className="space-y-2">
                  <Label htmlFor="phone">Phone</Label>
                  <Input
                    id="phone"
                    type="tel"
                    placeholder="0712 345 678"
                    className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500"
                    {...register('phone')}
                  />
                  {errors.phone ? <p className="text-sm text-destructive mt-1">{errors.phone.message}</p> : null}
                </div>
                <Button
                  type="submit"
                  disabled={isSubmitting}
                  variant="default"
                  className="w-full bg-emerald-600 text-white shadow-soft hover:bg-emerald-500"
                >
                  {isSubmitting ? 'Sending code...' : 'Send reset code'}
                </Button>
                <p className="text-sm text-slate-300">
                  Remembered your password?{' '}
                  <Link to="/login" className="font-semibold text-emerald-300 hover:text-emerald-100">
                    Sign in
                  </Link>
                </p>
              </form>
            ) : (
              <form className="space-y-5" onSubmit={handleVerifySubmit(onVerifySubmit)}>
                <div>
                  <Label htmlFor="phone">Phone</Label>
                  <Input
                    id="phone"
                    type="tel"
                    readOnly
                    defaultValue={savedPhone}
                    className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500"
                    {...verifyRegister('phone')}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="otp_code">OTP Code</Label>
                  <Input
                    id="otp_code"
                    type="text"
                    placeholder="Enter OTP code"
                    className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500"
                    {...verifyRegister('otp_code')}
                  />
                  {verifyErrors.otp_code ? <p className="text-sm text-destructive mt-1">{verifyErrors.otp_code.message}</p> : null}
                </div>
                <div className="space-y-2">
                  <Label htmlFor="new_password">New Password</Label>
                  <div className="relative">
                    <Input
                      id="new_password"
                      type={showPassword ? 'text' : 'password'}
                      placeholder="New password"
                      className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500"
                      {...verifyRegister('new_password')}
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword((prev) => !prev)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 rounded-full bg-slate-100/90 px-3 py-1 text-xs font-semibold text-slate-900 transition hover:bg-slate-200 dark:bg-slate-800/90 dark:text-slate-100 dark:hover:bg-slate-700"
                    >
                      {showPassword ? 'Hide' : 'Show'}
                    </button>
                  </div>
                  {verifyErrors.new_password ? <p className="text-sm text-destructive mt-1">{verifyErrors.new_password.message}</p> : null}
                </div>
                <div className="space-y-2">
                  <Label htmlFor="confirm_password">Confirm Password</Label>
                  <div className="relative">
                    <Input
                      id="confirm_password"
                      type={showConfirmPassword ? 'text' : 'password'}
                      placeholder="Confirm password"
                      className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500"
                      {...verifyRegister('confirm_password')}
                    />
                    <button
                      type="button"
                      onClick={() => setShowConfirmPassword((prev) => !prev)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 rounded-full bg-slate-100/90 px-3 py-1 text-xs font-semibold text-slate-900 transition hover:bg-slate-200 dark:bg-slate-800/90 dark:text-slate-100 dark:hover:bg-slate-700"
                    >
                      {showConfirmPassword ? 'Hide' : 'Show'}
                    </button>
                  </div>
                  {verifyErrors.confirm_password ? <p className="text-sm text-destructive mt-1">{verifyErrors.confirm_password.message}</p> : null}
                </div>
                <Button
                  type="submit"
                  disabled={isVerifying}
                  variant="default"
                  className="w-full bg-emerald-600 text-white shadow-soft hover:bg-emerald-500"
                >
                  {isVerifying ? 'Resetting...' : 'Reset password'}
                </Button>
              </form>
            )}
          </div>
        </Card>
      </div>
    </div>
  );
}

