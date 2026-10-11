import { Link } from 'react-router-dom'

import { StatCard } from '../../../../../shared/components/cards/StatCard'

export function DashboardMetric({ title, value, subtitle, to }: { title: string; value: number; subtitle: string; to: string }) {
	return <Link to={to} className="block rounded-md focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary"><StatCard title={title} value={value} subtitle={subtitle} variant="flat" /></Link>
}