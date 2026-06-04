import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { useAuth } from '../../../core/hooks/useAuth';
import { login as loginRequest } from '../services/authService';
import Input from '../../../shared/components/ui/Input';
import Button from '../../../shared/components/ui/Button';
import Label from '../../../shared/components/ui/Label';
import Alert from '../../../shared/components/ui/Alert';

const loginSchema = z.object({
  phone: z.string().nonempty('Phone is required').min(9, 'Enter a valid phone number'),
  password: z.string().nonempty('Password is required').min(6, 'Password must be at least 6 characters'),
});

type LoginFormValues = z.infer<typeof loginSchema>;

export default function Login() {
  const navigate = useNavigate();
  const { login } = useAuth();
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

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
    <div className="mx-auto max-w-md p-6 bg-white rounded-xl shadow-sm">
      <h1 className="text-2xl font-semibold mb-4">Login</h1>
      {errorMessage ? <Alert variant="destructive">{errorMessage}</Alert> : null}
      <form className="space-y-4" onSubmit={handleSubmit(onSubmit)}>
        <div>
          <Label htmlFor="phone">Phone</Label>
          <Input id="phone" type="tel" placeholder="Enter your phone" {...register('phone')} />
          {errors.phone ? <p className="text-sm text-red-600 mt-1">{errors.phone.message}</p> : null}
        </div>
        <div>
          <Label htmlFor="password">Password</Label>
          <Input id="password" type="password" placeholder="Enter your password" {...register('password')} />
          {errors.password ? <p className="text-sm text-red-600 mt-1">{errors.password.message}</p> : null}
        </div>
        <Button type="submit" disabled={isSubmitting} className="w-full">
          {isSubmitting ? 'Signing in...' : 'Sign in'}
        </Button>
      </form>
      <div className="mt-4 text-sm text-slate-600">
        <p>
          New here? <Link to="/register" className="text-blue-600 hover:underline">Create an account</Link>
        </p>
        <p>
          <Link to="/forgot-password" className="text-blue-600 hover:underline">Forgot password?</Link>
        </p>
      </div>
    </div>
  );
}
