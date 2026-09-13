import { useNavigate } from 'react-router-dom'
import { useAuth } from '../../../core/contexts/AuthContext'
import { AuthLayout, AuthSubmit } from '../components'

export function OnboardingPage() {
	const navigate = useNavigate()
	const { user } = useAuth()
	const role = String(user?.role ?? '')

	const roleTitle = role === 'transport_provider' ? 'Transport provider' : role
	const description =
		role === 'buyer'
			? 'Complete your delivery details so you can start shopping.'
			: role === 'farmer'
			? 'Add your farm details, payment information, and verification requirements.'
			: role === 'retailer'
			? 'Add your business details and verification information.'
			: role === 'transport_provider'
			? 'Create your transport profile, then await document review and manual approval.'
			: 'Finish your profile setup.'

	return (
		<AuthLayout title={`Complete your ${roleTitle} profile`} description={description}>
			<div className="space-y-4">
				<p className="rounded-2xl border border-dashed border-primary/50 bg-primary/5 p-4 text-sm leading-6 text-muted-foreground">
					You are signed in and your phone has been verified. This step keeps the flow clean by collecting only the details that matter for your role.
				</p>
				<AuthSubmit type="button" onClick={() => navigate('/')}>
					Continue to marketplace
				</AuthSubmit>
			</div>
		</AuthLayout>
	)
}
