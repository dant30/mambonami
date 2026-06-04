import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { useAuth } from '../../../core/hooks/useAuth';
import { apiClient } from '../../../core/api/client';
import { AUTH_ENDPOINTS } from '../../../core/api/endpoints';
import Button from '../../../shared/components/ui/Button';
import Input from '../../../shared/components/ui/Input';
import Label from '../../../shared/components/ui/Label';
import Alert from '../../../shared/components/ui/Alert';

const profileSchema = z.object({
  username: z.string().optional(),
  first_name: z.string().optional(),
  last_name: z.string().optional(),
  email: z.string().email('Enter a valid email').optional(),
});

type ProfileFormValues = z.infer<typeof profileSchema>;

export default function Profile() {
  const { user, refreshProfile } = useAuth();
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<ProfileFormValues>({
    resolver: zodResolver(profileSchema),
    defaultValues: {
      username: user?.username ?? '',
      first_name: user?.first_name ?? '',
      last_name: user?.last_name ?? '',
      email: user?.email ?? '',
    },
  });

  const onSubmit = async (values: ProfileFormValues) => {
    setMessage(null);
    setError(null);
    try {
      await apiClient.patch(AUTH_ENDPOINTS.profile, values);
      setMessage('Your profile has been updated.');
      refreshProfile();
    } catch (err) {
      setError('Unable to save profile. Please try again later.');
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-emerald-100 to-green-50 text-slate-900 p-6 md:p-12 dark:text-slate-100">
      <div className="mx-auto max-w-lg p-6 bg-white/90 text-slate-900 rounded-2xl border border-emerald-200 shadow-soft backdrop-blur-sm dark:bg-slate-950/95 dark:text-slate-100 dark:border-slate-700">
        <h1 className="text-2xl font-semibold mb-4 text-emerald-900 dark:text-emerald-200">Profile</h1>
        {message ? <Alert>{message}</Alert> : null}
        {error ? <Alert variant="destructive">{error}</Alert> : null}
        <form className="space-y-4" onSubmit={handleSubmit(onSubmit)}>
          <div>
            <Label htmlFor="username">Username</Label>
            <Input id="username" type="text" className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500" {...register('username')} />
            {errors.username ? <p className="text-sm text-red-600 mt-1">{errors.username.message}</p> : null}
          </div>
          <div>
            <Label htmlFor="first_name">First Name</Label>
            <Input id="first_name" type="text" className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500" {...register('first_name')} />
            {errors.first_name ? <p className="text-sm text-red-600 mt-1">{errors.first_name.message}</p> : null}
          </div>
          <div>
            <Label htmlFor="last_name">Last Name</Label>
            <Input id="last_name" type="text" className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500" {...register('last_name')} />
            {errors.last_name ? <p className="text-sm text-red-600 mt-1">{errors.last_name.message}</p> : null}
          </div>
          <div>
            <Label htmlFor="email">Email</Label>
            <Input id="email" type="email" className="bg-white/95 border-slate-200 text-slate-900 placeholder:text-slate-500 dark:bg-slate-950 dark:border-slate-700 dark:text-slate-100 dark:placeholder:text-slate-500" {...register('email')} />
            {errors.email ? <p className="text-sm text-red-600 mt-1">{errors.email.message}</p> : null}
          </div>
          <Button type="submit" disabled={isSubmitting} variant="default" className="w-full bg-emerald-600 text-white shadow-soft hover:bg-emerald-500">
            {isSubmitting ? 'Saving...' : 'Save profile'}
          </Button>
        </form>
      </div>
    </div>
  );
}

