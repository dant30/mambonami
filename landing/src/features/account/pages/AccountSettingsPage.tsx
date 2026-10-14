import { Bell, Clock3, LockKeyhole, Save, Settings2 } from 'lucide-react'
import { FormEvent, useEffect, useState } from 'react'

import { useAuth } from '../../../core/contexts/AuthContext'
import {
	changePassword,
	createNotificationPreference,
	updateNotificationPreference,
	updateTransportProfile,
	useNotificationPreferences,
} from '../../../core/lib'
import type { NotificationPreference } from '../../../core/lib'
import { FormField, FormSection } from '../../../shared/components/forms'
import { Button, Input, PageHeader, Skeleton, Switch } from '../../../shared/components/ui'

type Role = 'buyer' | 'farmer' | 'retailer' | 'transport_provider'
const categoriesByRole: Record<Role, Array<NotificationPreference['category']>> = {
	buyer: ['order', 'delivery', 'payment', 'promotion'],
	farmer: ['order', 'payment', 'review', 'system'],
	retailer: ['order', 'delivery', 'payment', 'promotion'],
	transport_provider: ['order', 'delivery', 'payment', 'system'],
}
const labels: Record<NotificationPreference['category'], string> = {
	order: 'Order updates',
	delivery: 'Delivery updates',
	payment: 'Payment and payout updates',
	dispute: 'Dispute updates',
	review: 'Reviews',
	promotion: 'Marketplace offers',
	verification: 'Verification updates',
	system: 'Account and system alerts',
}

export function AccountSettingsPage({ role }: { role: Role }) {
	const { user } = useAuth()
	const { preferences, isLoading } = useNotificationPreferences()
	const [localPreferences, setLocalPreferences] = useState(preferences)
	const [passwords, setPasswords] = useState({ old_password: '', new_password: '', confirm_password: '' })
	const profile = (user?.transport_profile || {}) as Record<string, unknown>
	const [transportRules, setTransportRules] = useState({
		base_rate_per_km: String(profile.base_rate_per_km ?? '25'),
		waiting_grace_minutes: String(profile.waiting_grace_minutes ?? '15'),
		waiting_rate_per_min: String(profile.waiting_rate_per_min ?? '2'),
	})
	const [saving, setSaving] = useState('')
	const [message, setMessage] = useState('')
	const [error, setError] = useState('')

	useEffect(() => setLocalPreferences(preferences), [preferences])

	const togglePreference = async (category: NotificationPreference['category'], enabled: boolean) => {
		setSaving(category)
		setError('')
		try {
			const current = localPreferences.find((item) => item.category === category && item.channel === 'in_app')
			const input = { category, channel: 'in_app' as const, enabled, language: current?.language || 'en' }
			const saved = current
				? await updateNotificationPreference(current.id, input)
				: await createNotificationPreference(input)
			setLocalPreferences((items) => current ? items.map((item) => item.id === current.id ? saved : item) : [...items, saved])
		} catch {
			setError('Notification preference could not be saved.')
		} finally {
			setSaving('')
		}
	}

	const saveTransportRules = async () => {
		setSaving('transport')
		setError('')
		try {
			await updateTransportProfile({
				base_rate_per_km: Number(transportRules.base_rate_per_km),
				waiting_grace_minutes: Number(transportRules.waiting_grace_minutes),
				waiting_rate_per_min: Number(transportRules.waiting_rate_per_min),
			})
			setMessage('Delivery pricing and waiting rules saved.')
		} catch {
			setError('Delivery rules could not be saved.')
		} finally {
			setSaving('')
		}
	}

	const updatePassword = async (event: FormEvent) => {
		event.preventDefault()
		setMessage('')
		setError('')
		if (passwords.new_password !== passwords.confirm_password) {
			setError('New passwords do not match.')
			return
		}
		setSaving('password')
		try {
			await changePassword(passwords)
			setPasswords({ old_password: '', new_password: '', confirm_password: '' })
			setMessage('Password updated.')
		} catch {
			setError('Password could not be updated. Check your current password.')
		} finally {
			setSaving('')
		}
	}

	const roleLabel = role === 'transport_provider' ? 'Transport provider' : role.charAt(0).toUpperCase() + role.slice(1)

	return (
		<main className="mx-auto max-w-3xl px-4 py-4 sm:px-6 sm:py-8">
			<PageHeader variant="minimal" eyebrow={`${roleLabel} account`} title="Settings" description="Manage alerts, security, and role-specific operating preferences." icon={<Settings2 className="h-5 w-5" />} />
			{message && <p role="status" className="mt-4 rounded-xl bg-primary/10 p-3 text-sm font-medium text-primary">{message}</p>}
			{error && <p role="alert" className="mt-4 rounded-xl bg-destructive/10 p-3 text-sm text-destructive">{error}</p>}

			<section className="mt-4 rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-6">
				<div className="flex items-start gap-3"><Bell className="mt-0.5 h-5 w-5 text-primary" /><div><h2 className="font-semibold text-primary-dark">Notifications</h2><p className="mt-1 text-xs text-muted-foreground">Choose the operational alerts shown in your account.</p></div></div>
				<div className="mt-4 divide-y divide-border">
					{isLoading ? <Skeleton className="h-32 rounded-xl" /> : categoriesByRole[role].map((category) => {
						const preference = localPreferences.find((item) => item.category === category && item.channel === 'in_app')
						return <Switch key={category} checked={preference?.enabled ?? true} onChange={(enabled) => void togglePreference(category, enabled)} disabled={saving === category} label={labels[category]} className="py-3" />
					})}
				</div>
			</section>

			{role === 'transport_provider' && (
				<section className="mt-4 rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-6">
					<FormSection title="Delivery pricing" description="Set your distance rate and when paid waiting time begins." icon={<Clock3 className="h-4 w-4" />} divider={false}>
						<div className="grid grid-cols-2 gap-4">
							<FormField label="Base rate / km" htmlFor="base-rate"><Input id="base-rate" type="number" min="0" value={transportRules.base_rate_per_km} onChange={(event) => setTransportRules({ ...transportRules, base_rate_per_km: event.target.value })} /></FormField>
							<FormField label="Free waiting minutes" htmlFor="waiting-minutes"><Input id="waiting-minutes" type="number" min="0" value={transportRules.waiting_grace_minutes} onChange={(event) => setTransportRules({ ...transportRules, waiting_grace_minutes: event.target.value })} /></FormField>
							<FormField label="Waiting rate / minute" htmlFor="waiting-rate" className="col-span-2"><Input id="waiting-rate" type="number" min="0" value={transportRules.waiting_rate_per_min} onChange={(event) => setTransportRules({ ...transportRules, waiting_rate_per_min: event.target.value })} /></FormField>
						</div>
						<Button type="button" onClick={() => void saveTransportRules()} isLoading={saving === 'transport'} leftIcon={<Save className="h-4 w-4" />} className="w-full sm:w-auto">Save delivery rules</Button>
					</FormSection>
				</section>
			)}

			<form onSubmit={updatePassword} className="mt-4 rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-6">
				<FormSection title="Change password" description="Use at least eight characters." icon={<LockKeyhole className="h-4 w-4" />} divider={false}>
					<div className="grid gap-4">
						<FormField label="Current password" htmlFor={`${role}-current-password`} required><Input id={`${role}-current-password`} required type="password" autoComplete="current-password" value={passwords.old_password} onChange={(event) => setPasswords({ ...passwords, old_password: event.target.value })} /></FormField>
						<div className="grid gap-4 sm:grid-cols-2">
							<FormField label="New password" htmlFor={`${role}-new-password`} required><Input id={`${role}-new-password`} required minLength={8} type="password" autoComplete="new-password" value={passwords.new_password} onChange={(event) => setPasswords({ ...passwords, new_password: event.target.value })} /></FormField>
							<FormField label="Confirm password" htmlFor={`${role}-confirm-password`} required><Input id={`${role}-confirm-password`} required minLength={8} type="password" autoComplete="new-password" value={passwords.confirm_password} onChange={(event) => setPasswords({ ...passwords, confirm_password: event.target.value })} /></FormField>
						</div>
					</div>
					<Button type="submit" isLoading={saving === 'password'} className="w-full sm:w-auto">Update password</Button>
				</FormSection>
			</form>
		</main>
	)
}
