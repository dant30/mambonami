// web/src/shared/components/forms/FormValidation.tsx
export type ValidationError = { message?: string | string[] } | undefined;

export function getErrorMessage(error?: ValidationError): string | undefined {
  if (!error) return undefined;
  if (typeof error.message === 'string') return error.message;
  if (Array.isArray(error.message)) return error.message.join(', ');
  return undefined;
}

export function hasError(error?: ValidationError): boolean {
  return Boolean(getErrorMessage(error));
}