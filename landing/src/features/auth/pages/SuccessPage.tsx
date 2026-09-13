import { Link, useLocation } from 'react-router-dom'
import { AuthLayout } from '../components'

export function SuccessPage() {
	const location = useLocation()
	const message = (location.state as { message?: string } | null)?.message ?? 'Your MAMBONAMI account is ready.'
	return <AuthLayout title="You are all set" description={message}><Link to="/" className="block w-full rounded-full bg-primary px-5 py-3 text-center text-sm font-bold text-primary-foreground">Go to marketplace</Link></AuthLayout>
}
