import { Eye, EyeOff } from 'lucide-react'
import { useId, useState } from 'react'
import { FormField } from '../../../shared/components/forms/FormField'

interface AuthFieldProps extends React.InputHTMLAttributes<HTMLInputElement> {
	label: string
	error?: string
}

export function AuthField({ label, error, ...props }: AuthFieldProps) {
	const [visible, setVisible] = useState(false)
	const generatedId = useId()
	const isPassword = props.type === 'password'
	return <FormField label={label} htmlFor={props.id ?? generatedId} required={props.required} error={error}><div className="relative"><input {...props} id={props.id ?? generatedId} type={isPassword && visible ? 'text' : props.type} aria-invalid={Boolean(error)} className={`w-full rounded-xl border border-input bg-background px-3.5 py-3 text-sm outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/20 ${isPassword ? 'pr-11' : ''}`} />{isPassword && <button type="button" onClick={() => setVisible((current) => !current)} className="absolute inset-y-0 right-0 flex w-11 items-center justify-center text-muted-foreground hover:text-foreground" aria-label={visible ? `Hide ${label.toLowerCase()}` : `Show ${label.toLowerCase()}`}><span className="sr-only">{visible ? 'Hide password' : 'Show password'}</span>{visible ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}</button>}</div></FormField>
}