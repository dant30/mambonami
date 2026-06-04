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

  if (phase === 'verify') {
    return (
      <div className="mx-auto max-w-md p-6 bg-white rounded-xl shadow-sm">
        <h1 className="text-2xl font-semibold mb-4">Reset Password</h1>
        {errorMessage ? <Alert variant="destructive">{errorMessage}</Alert> : null}
        <form className="space-y-4" onSubmit={handleVerifySubmit(onVerifySubmit)}>
          <div>
            <Label htmlFor="phone">Phone</Label>
            <Input id="phone" type="tel" readOnly defaultValue={savedPhone} {...verifyRegister('phone')} />
          </div>
          <div>
            <Label htmlFor="otp_code">OTP Code</Label>
            <Input id="otp_code" type="text" placeholder="Enter OTP code" {...verifyRegister('otp_code')} />
            {verifyErrors.otp_code ? <p className="text-sm text-red-600 mt-1">{verifyErrors.otp_code.message}</p> : null}
          </div>
          <div>
            <Label htmlFor="new_password">New Password</Label>
            <Input id="new_password" type="password" placeholder="New password" {...verifyRegister('new_password')} />
            {verifyErrors.new_password ? <p className="text-sm text-red-600 mt-1">{verifyErrors.new_password.message}</p> : null}
          </div>
          <div>
            <Label htmlFor="confirm_password">Confirm Password</Label>
            <Input id="confirm_password" type="password" placeholder="Confirm password" {...verifyRegister('confirm_password')} />
            {verifyErrors.confirm_password ? <p className="text-sm text-red-600 mt-1">{verifyErrors.confirm_password.message}</p> : null}
          </div>
          <Button type="submit" disabled={isVerifying} className="w-full">
            {isVerifying ? 'Resetting...' : 'Reset password'}
          </Button>
        </form>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-md p-6 bg-white rounded-xl shadow-sm">
      <h1 className="text-2xl font-semibold mb-4">Forgot Password</h1>
      {errorMessage ? <Alert variant="destructive">{errorMessage}</Alert> : null}
      <form className="space-y-4" onSubmit={handleSubmit(onInitSubmit)}>
        <div>
          <Label htmlFor="phone">Phone</Label>
          <Input id="phone" type="tel" placeholder="Enter your phone" {...register('phone')} />
          {errors.phone ? <p className="text-sm text-red-600 mt-1">{errors.phone.message}</p> : null}
        </div>
        <Button type="submit" disabled={isSubmitting} className="w-full">
          {isSubmitting ? 'Send code...' : 'Send reset code'}
        </Button>
      </form>
      <div className="mt-4 text-sm text-slate-600">
        <p>
          Remembered your password? <Link to="/login" className="text-blue-600 hover:underline">Sign in</Link>
        </p>
      </div>
    </div>
  );
}

