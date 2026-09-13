import { Link } from 'react-router-dom'
import { AuthLayout } from '../components'

export function SessionExpiredPage() {
	return <AuthLayout title="Session expired" description="Your verification session has expired. Start again to receive a fresh code."><Link to="/role-select" className="block w-full rounded-full bg-primary px-5 py-3 text-center text-sm font-bold text-primary-foreground">Start again</Link></AuthLayout>
}
