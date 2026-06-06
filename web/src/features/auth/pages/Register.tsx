import { useEffect, useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { useAuth } from '../../../core/hooks/useAuth';
import {
  registerInit as registerInitRequest,
  registerVerify as registerVerifyRequest,
} from '../services/authService';
import Input from '../../../shared/components/ui/Input';
import Select from '../../../shared/components/ui/Select';
import Alert from '../../../shared/components/ui/Alert';
import FormField from '../../../shared/components/forms/FormField';
import FormActions from '../../../shared/components/forms/FormActions';
import Card from '../../../shared/components/cards/Card';

const initSchema = z.object({
  phone: z.string().nonempty('Phone is required').min(9, 'Enter a valid phone number'),
  role: z.enum(['buyer', 'farmer', 'transport_provider'], {
    errorMap: () => ({ message: 'Role is required' }),
  }),
});

const verifySchema = z
  .object({
    phone: z.string().nonempty('Phone is required'),
    role: z.enum(['buyer', 'farmer', 'transport_provider']),
    username: z.string().nonempty('Username is required'),
    password: z.string().nonempty('Password is required').min(6, 'Password must be at least 6 characters'),
    confirm_password: z.string().nonempty('Please confirm your password'),
    otp_code: z.string().nonempty('OTP code is required'),
    first_name: z.string().optional(),
    last_name: z.string().optional(),
  })
  .refine((data) => data.password === data.confirm_password, {
    message: 'Passwords must match',
    path: ['confirm_password'],
  });

type InitValues = z.infer<typeof initSchema>;
type VerifyValues = z.infer<typeof verifySchema>;

export default function Register() {
  const navigate = useNavigate();
  const { login } = useAuth();
  const [phase, setPhase] = useState<'init' | 'verify'>('init');
  const [serverMessage, setServerMessage] = useState<string | null>(null);
  const [savedPhone, setSavedPhone] = useState('');
  const [savedRole, setSavedRole] = useState<'buyer' | 'farmer' | 'transport_provider'>('buyer');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset,
  } = useForm<InitValues>({ resolver: zodResolver(initSchema) });

  const onInitSubmit = async (values: InitValues) => {
    setServerMessage(null);
    try {
      await registerInitRequest(values);
      setSavedPhone(values.phone);
      setSavedRole(values.role);
      setPhase('verify');
      reset({ phone: values.phone, role: values.role });
    } catch (error) {
      setServerMessage('Unable to start registration. Please try again.');
    }
  };

  const {
    register: verifyRegister,
    handleSubmit: handleVerifySubmit,
    reset: resetVerify,
    formState: { errors: verifyErrors, isSubmitting: isVerifying },
  } = useForm<VerifyValues>({
    defaultValues: { phone: savedPhone, role: savedRole },
    resolver: zodResolver(verifySchema),
  });

  useEffect(() => {
    if (phase === 'verify') {
      resetVerify({ phone: savedPhone, role: savedRole });
    }
  }, [phase, resetVerify, savedPhone, savedRole]);

  const onVerifySubmit = async (values: VerifyValues) => {
    setServerMessage(null);
    try {
      const data = await registerVerifyRequest(values);
      login(data.tokens.access, data.user);
      navigate('/');
    } catch (error) {
      setServerMessage('Unable to complete registration. Please validate your OTP and try again.');
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-emerald-100 to-green-50 text-slate-900 p-6 md:p-12">
      <div className="mx-auto max-w-5xl space-y-8">
        <Card className="border border-slate-200 bg-white/95 p-8 shadow-soft backdrop-blur-xl dark:border-slate-700 dark:bg-slate-950/95">
          <div className="space-y-3">
          <p className="text-sm uppercase tracking-[0.25em] text-emerald-600 dark:text-emerald-200">Create your account</p>
          <h1 className="text-3xl font-semibold">Register for MAMBONAMI</h1>
          <p className="text-sm text-slate-300">
              Begin with a quick registration step then verify your account using the OTP code we send. Your admin experience starts after verification.
            </p>
          </div>
        </Card>

        <Card className="grid gap-8 lg:grid-cols-[0.94fr_0.86fr] p-8 border border-slate-200 bg-white/95 shadow-soft dark:border-slate-700 dark:bg-slate-950/95">
          <div className="space-y-6">
            {phase === 'init' ? (
              <div>
                <h2 className="text-2xl font-semibold">Step 1 — Phone and role</h2>
                <p className="mt-2 text-sm text-slate-300">
                  We will send a verification code to your phone before completing registration.
                </p>
              </div>
            ) : (
              <div>
                <h2 className="text-2xl font-semibold">Step 2 — Verify and finish</h2>
                <p className="mt-2 text-sm text-slate-300">
                  Enter your verification code and create a password for your secure admin profile.
                </p>
              </div>
            )}

            <div className="rounded-3xl border border-slate-200 bg-slate-50 p-5 dark:border-slate-700 dark:bg-slate-900/80">
              <p className="text-sm font-semibold text-slate-900 dark:text-slate-100">Registration tips</p>
              <ul className="mt-3 list-disc space-y-2 pl-5 text-sm text-slate-300">
                <li>Use a valid phone number so you can receive the OTP code.</li>
                <li>Create a password you can remember, but don’t reuse it elsewhere.</li>
                <li>Complete the verification step immediately for faster access.</li>
              </ul>
            </div>
          </div>

          <div>
            {serverMessage ? <Alert variant="destructive">{serverMessage}</Alert> : null}
            {phase === 'init' ? (
              <form className="space-y-5" onSubmit={handleSubmit(onInitSubmit)}>
                <FormField id="phone" label="Phone" errors={errors.phone?.message}>
                  <Input
                    id="phone"
                    type="tel"
                    placeholder="0712 345 678"
                    autoComplete="tel"
                    className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500"
                    {...register('phone')}
                  />
                </FormField>
                <FormField id="role" label="Role" errors={errors.role?.message}>
                  <Select
                    id="role"
                    options={[
                      { value: 'buyer', label: 'Buyer' },
                      { value: 'farmer', label: 'Farmer' },
                      { value: 'transport_provider', label: 'Transport Provider' },
                    ]}
                    className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500"
                    {...register('role')}
                  />
                </FormField>
                <FormActions
                  primaryLabel={isSubmitting ? 'Sending OTP...' : 'Send verification code'}
                  primaryProps={{ type: 'submit', disabled: isSubmitting, className: 'w-full bg-emerald-600 text-white shadow-soft hover:bg-emerald-500' }}
                />
                <p className="text-sm text-slate-300">
                  Already have an account?{' '}
                  <Link to="/login" className="font-semibold text-emerald-300 hover:text-emerald-100">
                    Sign in
                  </Link>
                </p>
              </form>
            ) : (
              <form className="space-y-5" onSubmit={handleVerifySubmit(onVerifySubmit)}>
                <FormField id="phone" label="Phone">
                  <Input
                    id="phone"
                    type="tel"
                    readOnly
                    defaultValue={savedPhone}
                    className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500"
                    {...verifyRegister('phone')}
                  />
                </FormField>
                <FormField id="role" label="Role">
                  <Input
                    id="role"
                    readOnly
                    defaultValue={savedRole}
                    className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500"
                    {...verifyRegister('role')}
                  />
                </FormField>
                <FormField id="otp_code" label="OTP Code" errors={verifyErrors.otp_code?.message}>
                  <Input
                    id="otp_code"
                    type="text"
                    placeholder="Enter OTP"
                    className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500"
                    {...verifyRegister('otp_code')}
                  />
                </FormField>
                <FormField id="username" label="Username" errors={verifyErrors.username?.message}>
                  <Input
                    id="username"
                    type="text"
                    placeholder="Choose a username"
                    className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500"
                    {...verifyRegister('username')}
                  />
                </FormField>
                <FormField id="password" label="Password" errors={verifyErrors.password?.message}>
                  <div className="relative">
                    <Input
                      id="password"
                      type={showPassword ? 'text' : 'password'}
                      placeholder="Create a password"
                      className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500"
                      {...verifyRegister('password')}
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword((prev) => !prev)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 rounded-full bg-slate-100/90 px-3 py-1 text-xs font-semibold text-slate-900 transition hover:bg-slate-200"
                    >
                      {showPassword ? 'Hide' : 'Show'}
                    </button>
                  </div>
                </FormField>
                <FormField id="confirm_password" label="Confirm Password" errors={verifyErrors.confirm_password?.message}>
                  <div className="relative">
                    <Input
                      id="confirm_password"
                      type={showConfirmPassword ? 'text' : 'password'}
                      placeholder="Confirm your password"
                      className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500"
                      {...verifyRegister('confirm_password')}
                    />
                    <button
                      type="button"
                      onClick={() => setShowConfirmPassword((prev) => !prev)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 rounded-full bg-slate-100/90 px-3 py-1 text-xs font-semibold text-slate-900 transition hover:bg-slate-200"
                    >
                      {showConfirmPassword ? 'Hide' : 'Show'}
                    </button>
                  </div>
                </FormField>
                <FormActions
                  primaryLabel={isVerifying ? 'Completing registration...' : 'Complete registration'}
                  primaryProps={{ type: 'submit', disabled: isVerifying, className: 'w-full bg-emerald-600 text-white shadow-soft hover:bg-emerald-500' }}
                />
                <p className="text-sm text-slate-300">
                  Already registered?{' '}
                  <Link to="/login" className="font-semibold text-emerald-300 hover:text-emerald-100">
                    Sign in
                  </Link>
                </p>
              </form>
            )}
          </div>
        </Card>
      </div>
    </div>
  );
}
