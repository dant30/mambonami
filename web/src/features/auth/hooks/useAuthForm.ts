import { useForm, type UseFormProps } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import type { ZodTypeAny } from 'zod';

export const useAuthForm = <T extends Record<string, unknown>>(schema: ZodTypeAny, options?: UseFormProps<T>) => {
	return useForm<T>({ resolver: zodResolver(schema), mode: options?.mode ?? 'onSubmit', ...options });
};

export default useAuthForm;
