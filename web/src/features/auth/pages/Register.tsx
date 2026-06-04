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
import Button from '../../../shared/components/ui/Button';
import Input from '../../../shared/components/ui/Input';
import Label from '../../../shared/components/ui/Label';
import Alert from '../../../shared/components/ui/Alert';

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

  if (phase === 'verify') {
    return (
      <div className="mx-auto max-w-md p-6 bg-white rounded-xl shadow-sm">
        <h1 className="text-2xl font-semibold mb-4">Verify Registration</h1>
        {serverMessage ? <Alert variant="destructive">{serverMessage}</Alert> : null}
        <form className="space-y-4" onSubmit={handleVerifySubmit(onVerifySubmit)}>
          <div>
            <Label htmlFor="phone">Phone</Label>
            <Input id="phone" type="tel" readOnly defaultValue={savedPhone} {...verifyRegister('phone')} />
          </div>
          <div>
            <Label htmlFor="role">Role</Label>
            <Input id="role" readOnly defaultValue={savedRole} {...verifyRegister('role')} />
          </div>
          <div>
            <Label htmlFor="otp_code">OTP Code</Label>
            <Input id="otp_code" type="text" placeholder="Enter OTP" {...verifyRegister('otp_code')} />
            {verifyErrors.otp_code ? <p className="text-sm text-red-600 mt-1">{verifyErrors.otp_code.message}</p> : null}
          </div>
          <div>
            <Label htmlFor="username">Username</Label>
            <Input id="username" type="text" placeholder="Choose a username" {...verifyRegister('username')} />
            {verifyErrors.username ? <p className="text-sm text-red-600 mt-1">{verifyErrors.username.message}</p> : null}
          </div>
          <div>
            <Label htmlFor="password">Password</Label>
            <Input id="password" type="password" placeholder="Create a password" {...verifyRegister('password')} />
            {verifyErrors.password ? <p className="text-sm text-red-600 mt-1">{verifyErrors.password.message}</p> : null}
          </div>
          <div>
            <Label htmlFor="confirm_password">Confirm Password</Label>
            <Input id="confirm_password" type="password" placeholder="Confirm your password" {...verifyRegister('confirm_password')} />
            {verifyErrors.confirm_password ? <p className="text-sm text-red-600 mt-1">{verifyErrors.confirm_password.message}</p> : null}
          </div>
          <Button type="submit" disabled={isVerifying} className="w-full">
            {isVerifying ? 'Completing registration...' : 'Complete registration'}
          </Button>
        </form>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-md p-6 bg-white rounded-xl shadow-sm">
      <h1 className="text-2xl font-semibold mb-4">Register</h1>
      {serverMessage ? <Alert variant="destructive">{serverMessage}</Alert> : null}
      <form className="space-y-4" onSubmit={handleSubmit(onInitSubmit)}>
        <div>
          <Label htmlFor="phone">Phone</Label>
          <Input id="phone" type="tel" placeholder="Enter your phone" {...register('phone')} />
          {errors.phone ? <p className="text-sm text-red-600 mt-1">{errors.phone.message}</p> : null}
        </div>
        <div>
          <Label htmlFor="role">Role</Label>
          <select id="role" className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" {...register('role')}>
            <option value="buyer">Buyer</option>
            <option value="farmer">Farmer</option>
            <option value="transport_provider">Transport Provider</option>
          </select>
          {errors.role ? <p className="text-sm text-red-600 mt-1">{errors.role.message}</p> : null}
        </div>
        <Button type="submit" disabled={isSubmitting} className="w-full">
          {isSubmitting ? 'Sending OTP...' : 'Send verification code'}
        </Button>
      </form>
      <div className="mt-4 text-sm text-slate-600">
        <p>
          Already have an account? <Link to="/login" className="text-blue-600 hover:underline">Sign in</Link>
        </p>
      </div>
    </div>
  );
}
