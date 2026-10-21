import { Link, useLocation } from 'react-router-dom'
import type { AuthRole } from '../../../core/lib'
import { AuthLayout } from '../components'

const roles: Array<[AuthRole, string, string]> = [['buyer', 'Buyer', 'Shop for your household'], ['farmer', 'Farmer', 'Sell farm produce'], ['retailer', 'Retailer', 'Buy for your business'], ['transport_provider', 'Transport provider', 'Deliver marketplace orders']]

export function RoleSelectPage() {
	const location = useLocation()
	return <AuthLayout title="How will you use MAMBONAMI?" description="Choose the path that fits you best."><div className="space-y-3">{roles.map(([role, label, description]) => <Link key={role} to={`/register/${role}${location.search}`} className="block rounded-2xl border border-border bg-background p-4 transition hover:border-primary hover:shadow-soft"><span className="block font-bold text-primary-dark">{label}</span><span className="mt-1 block text-sm text-muted-foreground">{description}</span></Link>)}</div></AuthLayout>
}
