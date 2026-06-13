import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { useAuth } from '../../../core/hooks/useAuth';
import { login as loginRequest } from '../services/authService';
import Input from '../../../shared/components/ui/Input';
import Alert from '../../../shared/components/ui/Alert';
import Checkbox from '../../../shared/components/ui/Checkbox';
import FormField from '../../../shared/components/forms/FormField';
import FormActions from '../../../shared/components/forms/FormActions';
import Card from '../../../shared/components/cards/Card';

const loginSchema = z.object({
  phone: z.string().nonempty('Phone is required').min(9, 'Enter a valid phone number'),
  password: z.string().nonempty('Password is required').min(6, 'Password must be at least 6 characters'),
});

type LoginFormValues = z.infer<typeof loginSchema>;

export default function Login() {
  const navigate = useNavigate();
  const { login } = useAuth();
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginFormValues>({ resolver: zodResolver(loginSchema) });

  const onSubmit = async (values: LoginFormValues) => {
    setErrorMessage(null);
    try {
      const data = await loginRequest(values);
      login(data.tokens.access, data.user);
      navigate('/');
    } catch (error) {
      setErrorMessage('Invalid credentials. Please check your phone number and password.');
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-emerald-100 to-green-50 text-slate-900 p-6 md:p-12">
      <div className="mx-auto grid max-w-6xl gap-8 xl:grid-cols-[1.2fr_1fr]">
        <Card className="bg-gradient-to-br from-emerald-700 via-green-900 to-teal-700 text-white shadow-glow p-10">
          <div className="space-y-6">
            <div>
              <p className="mb-3 text-sm uppercase tracking-[0.3em] text-emerald-200/80">Welcome back</p>
              <h1 className="text-4xl font-semibold leading-tight">Secure access to your MAMBONAMI dashboard</h1>
              <p className="mt-4 max-w-xl text-sm leading-7 text-emerald-100/90">
                Access orders, transports, disputes, payouts and reports in one polished admin experience.
              </p>
            </div>
          </div>
        </Card>

        <Card className="p-8 bg-white/95 border border-slate-200 shadow-soft dark:bg-slate-950/95 dark:border-slate-700">
          <div className="space-y-6">
            <div>
              <h2 className="text-3xl font-semibold">Sign in</h2>
              <p className="mt-2 text-sm text-slate-600 dark:text-slate-300">
                Enter your phone and password to continue. Your session will be preserved if you keep "Remember me" checked.
              </p>
            </div>
            {errorMessage ? <Alert variant="destructive">{errorMessage}</Alert> : null}
            <form className="space-y-5" onSubmit={handleSubmit(onSubmit)}>
              <FormField id="phone" label="Phone number" errors={errors.phone?.message}>
                <Input
                  id="phone"
                  type="tel"
                  placeholder="0712 345 678"
                  autoComplete="tel"
                  className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500"
                  {...register('phone')}
                />
              </FormField>

              <FormField id="password" label="Password" errors={errors.password?.message}>
                <div className="relative">
                  <Input
                    id="password"
                    type={showPassword ? 'text' : 'password'}
                    placeholder="Enter your password"
                    className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500"
                    {...register('password')}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((prev) => !prev)}
                    className="absolute right-3 top-1/2 -translate-y-1/2 rounded-full bg-slate-100/90 px-3 py-1 text-xs font-semibold text-slate-900 transition hover:bg-slate-200 dark:bg-slate-800/90 dark:text-slate-100 dark:hover:bg-slate-700"
                  >
                    {showPassword ? 'Hide' : 'Show'}
                  </button>
                </div>
              </FormField>

              <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
                <Checkbox label="Remember me" checked={rememberMe} onChange={(event) => setRememberMe(event.target.checked)} />
                <Link to="/forgot-password" className="text-sm font-medium text-emerald-300 hover:text-emerald-100">
                  Forgot password?
                </Link>
              </div>

              <FormActions
                primaryLabel={isSubmitting ? 'Signing in...' : 'Sign in'}
                secondaryLabel=""
                primaryProps={{ type: 'submit', disabled: isSubmitting, className: 'w-full bg-emerald-600 text-white shadow-soft hover:bg-emerald-500' }}
              />
            </form>
            <div className="border-t border-border pt-4 text-sm text-slate-300">
              Accounts are provisioned by the admin team. Contact support if you need access.
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
}
