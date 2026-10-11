import { Save, Truck } from 'lucide-react'
import { useEffect, useState } from 'react'

import { getProfile, updateTransportProfile } from '../../../core/lib'
import type { TransportProfile } from '../../../core/lib'
import { Select } from '../../../shared/components/ui'

type VehicleForm = Required<Pick<TransportProfile, 'vehicle_type' | 'license_plate' | 'driver_license' | 'capacity_kg'>>

const emptyVehicle: VehicleForm = { vehicle_type: 'van', license_plate: '', driver_license: '', capacity_kg: 100 }

export function TransportVehiclesPage() {
	const [form, setForm] = useState<VehicleForm>(emptyVehicle)
	const [isLoading, setIsLoading] = useState(true)
	const [isSaving, setIsSaving] = useState(false)
	const [message, setMessage] = useState('')
	const [error, setError] = useState('')

	useEffect(() => {
		getProfile().then((profile) => {
			const vehicle = profile.transport_profile as TransportProfile | null | undefined
			if (vehicle) setForm({ vehicle_type: vehicle.vehicle_type || 'van', license_plate: vehicle.license_plate || '', driver_license: vehicle.driver_license || '', capacity_kg: Number(vehicle.capacity_kg || 100) })
		}).catch(() => setError('Vehicle details could not be loaded.')).finally(() => setIsLoading(false))
	}, [])

	const update = (field: keyof VehicleForm, value: string) => setForm((current) => ({ ...current, [field]: field === 'capacity_kg' ? Number(value) : value }))
	const submit = async (event: React.FormEvent) => {
		event.preventDefault()
		setIsSaving(true)
		setMessage('')
		setError('')
		try { await updateTransportProfile(form); setMessage('Vehicle details saved.') } catch { setError('Vehicle details could not be saved. Please try again.') } finally { setIsSaving(false) }
	}

	if (isLoading) return <main className="mx-auto max-w-3xl px-4 py-16 sm:px-6 lg:px-8"><div className="h-96 animate-pulse rounded-2xl bg-muted" /></main>
	return <main className="mx-auto max-w-3xl px-4 py-8 sm:px-6 lg:px-8"><div className="border-b border-border pb-8"><p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Fleet profile</p><h1 className="mt-2 text-3xl font-semibold text-primary-dark sm:text-4xl">Vehicle management</h1><p className="mt-3 text-sm text-muted-foreground">Keep the vehicle details used for job matching and delivery records up to date.</p></div><form onSubmit={submit} className="mt-8 rounded-2xl border border-border bg-card p-6 shadow-sm sm:p-8"><div className="flex items-center gap-3"><Truck className="h-5 w-5 text-primary" /><h2 className="font-semibold text-primary-dark">Primary vehicle</h2></div>{message && <p role="status" className="mt-5 rounded-xl bg-primary/10 p-3 text-sm text-primary-dark">{message}</p>}{error && <p role="alert" className="mt-5 rounded-xl bg-destructive/10 p-3 text-sm text-destructive">{error}</p>}<div className="mt-6 grid gap-5 sm:grid-cols-2"><label className="text-sm font-semibold text-primary-dark">Vehicle type<Select aria-label="Vehicle type" value={form.vehicle_type} onChange={(value) => update('vehicle_type', value)} className="mt-2" options={[{ value: 'motorcycle', label: 'Motorcycle' }, { value: 'pickup', label: 'Pickup truck' }, { value: 'van', label: 'Van' }, { value: 'lorry', label: 'Lorry' }]} /></label><label className="text-sm font-semibold text-primary-dark">Capacity (kg)<input required min="1" type="number" value={form.capacity_kg} onChange={(event) => update('capacity_kg', event.target.value)} className="mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 font-normal" /></label><label className="text-sm font-semibold text-primary-dark">License plate<input required value={form.license_plate} onChange={(event) => update('license_plate', event.target.value)} className="mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 font-normal" /></label><label className="text-sm font-semibold text-primary-dark">Driver license<input required value={form.driver_license} onChange={(event) => update('driver_license', event.target.value)} className="mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 font-normal" /></label></div><button type="submit" disabled={isSaving} className="mt-7 inline-flex items-center gap-2 rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground disabled:opacity-60"><Save className="h-4 w-4" />{isSaving ? 'Saving...' : 'Save vehicle details'}</button></form></main>
}
