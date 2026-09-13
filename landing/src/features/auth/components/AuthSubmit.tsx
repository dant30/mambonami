import type { ReactNode } from 'react'
import { Button, type ButtonProps } from '../../../shared/components/ui/Button'

interface AuthSubmitProps extends ButtonProps {
	children: ReactNode
}

export function AuthSubmit({ children, disabled = false, ...props }: AuthSubmitProps) {
	return <Button type="submit" size="lg" className="w-full justify-center rounded-full" disabled={disabled} {...props}>{children}</Button>
}
