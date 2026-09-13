import { useState } from 'react'
import { Link, useNavigate, useLocation } from 'react-router-dom'
import { useAuth } from '../../../core/contexts/AuthContext'
import { getErrorMessage } from '../../../core/utils'
import { AuthField, AuthLayout, AuthSubmit } from '../components'

/**
 * ✅✅ POST-LOGIN ROUTING LOGIC:
 * Routes users to their role-specific workspace under /app/{role}
 * - /app/buyer for buyers
 * - /app/farmer for farmers
 * - /app/retailer for retailers
 * - /app/transport for transport providers
 * - /app/admin for admins
 */
export function determinePostLoginDestination(user: Record<string, unknown> | null | undefined) {
	const role = String(user?.role ?? '')
	const isAdmin = Boolean(user?.is_staff || user?.is_superuser)

	// ✅✅ Admin routes to /app/admin
	if (isAdmin) return '/app/admin'

	// ✅✅ Role-based routing to /app/{role}
	if (role === 'buyer') return '/app/buyer'
	if (role === 'farmer') return '/app/farmer'
	if (role === 'retailer') return '/app/retailer'
	if (role === 'transport_provider') return '/app/transport'

	// Fallback to buyer if role not found
	return '/app/buyer'
}

export function LoginPage() {
	const navigate = useNavigate()
	const location = useLocation()
	const { login, isLoading } = useAuth()
	const [phone, setPhone] = useState('')
	const [password, setPassword] = useState('')
	const [error, setError] = useState('')

	// ✅✅ Preserve user's intended destination
	// If user came from /checkout, they'll return to /checkout after login
	const returnTo = (location.state as Record<string, string> | null)?.returnTo

	const submit = async (event: React.FormEvent) => {
		event.preventDefault()
		setError('')
		try {
			const response = await login({ phone, password })
			// Redirect to intended destination or role dashboard
			const destination = returnTo || determinePostLoginDestination(response.user ?? null)
			navigate(destination, { replace: true })
		} catch (requestError) {
			setError(getErrorMessage(requestError, 'Unable to log in.'))
		}
	}

	return (
		<AuthLayout title="Welcome back" description="Log in to manage your harvests, orders, or deliveries.">
			<form className="space-y-4" onSubmit={submit}>
				{error && (
					<p role="alert" className="rounded-xl bg-destructive/10 p-3 text-sm text-destructive">
						{error}
					</p>
				)}
				<AuthField
					label="Phone number"
					value={phone}
					onChange={(event) => setPhone(event.target.value)}
					required
					autoComplete="tel"
				/>
				<AuthField
					label="Password"
					type="password"
					value={password}
					onChange={(event) => setPassword(event.target.value)}
					required
					autoComplete="current-password"
				/>
				<div className="text-right">
					<Link to="/forgot-password" className="text-xs font-bold text-primary">
						Forgot password?
					</Link>
				</div>
				<AuthSubmit disabled={isLoading}>{isLoading ? 'Logging in...' : 'Log in'}</AuthSubmit>
				<p className="text-center text-sm text-muted-foreground">
					New here?{' '}
					<Link to="/role-select" className="font-bold text-primary">
						Create an account
					</Link>
				</p>
			</form>
		</AuthLayout>
	)
}
