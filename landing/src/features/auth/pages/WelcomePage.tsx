import { Link } from 'react-router-dom'
import { AuthLayout } from '../components'

export function WelcomePage() {
	return <AuthLayout title="Welcome to MAMBONAMI" description="A fairer, fresher marketplace connecting Kenyan growers with the people who need their harvest."><div className="space-y-3"><Link to="/role-select" className="block w-full rounded-full bg-primary px-5 py-3 text-center text-sm font-bold text-primary-foreground">Create an account</Link><Link to="/login" className="block w-full rounded-full border border-primary px-5 py-3 text-center text-sm font-bold text-primary">Log in</Link></div></AuthLayout>
}
