import { Building2, Check, Mail, MapPin, Save, Store, UserCircle } from 'lucide-react'
import { useEffect, useState } from 'react'

import { useAuth } from '../../../core/contexts/AuthContext'
import { updateProfile } from '../../../core/lib'
import { FormField, FormSection } from '../../../shared/components/forms'
import { Button, Input, PageHeader, Select } from '../../../shared/components/ui'

type RetailerProfileForm = {
	owner_full_name: string
	business_name: string
	business_phone: string
	business_email: string
	business_address: string
	business_type: string
}

const emptyForm: RetailerProfileForm = {
	owner_full_name: '',
	business_name: '',
	business_phone: '',
	business_email: '',
	business_address: '',
	business_type: 'Grocery store',
}

export function RetailerProfilePage() {
	const { user } = useAuth()
	const [form, setForm] = useState<RetailerProfileForm>(emptyForm)
	const [isSaving, setIsSaving] = useState(false)
	const [message, setMessage] = useState('')
	const [error, setError] = useState('')

	useEffect(() => {
		setForm({
			owner_full_name: String(user?.owner_full_name ?? user?.first_name ?? ''),
			business_name: String(user?.business_name ?? ''),
			business_phone: String(user?.business_phone ?? user?.phone ?? ''),
			business_email: String(user?.business_email ?? user?.email ?? ''),
			business_address: String(user?.business_address ?? ''),
			business_type: String(user?.business_type ?? 'Grocery store'),
		})
	}, [user])

	const updateField = <K extends keyof RetailerProfileForm>(field: K, value: RetailerProfileForm[K]) => {
		setForm((current) => ({ ...current, [field]: value }))
	}

	const submit = async (event: React.FormEvent) => {
		event.preventDefault()
		setIsSaving(true)
		setMessage('')
		setError('')
		try {
			await updateProfile({
				owner_full_name: form.owner_full_name,
				business_name: form.business_name,
				business_phone: form.business_phone,
				business_email: form.business_email,
				business_address: form.business_address,
				business_type: form.business_type,
			})
			setMessage('Retail profile updated successfully.')
		} catch {
			setError('We could not update your retail profile. Please try again.')
		} finally {
			setIsSaving(false)
		}
	}

	return (
		<main className="mx-auto max-w-5xl px-4 py-8 sm:px-6 lg:px-8">
			<PageHeader
				eyebrow="Retailer workspace"
				title="Your business profile"
				description="Keep details current so suppliers and customers know how to reach your store."
				icon={<Store className="h-5 w-5" />}
				variant="light"
			/>

			<form onSubmit={submit} className="mt-6 space-y-6">
				<FormSection title="Business identity" description="Your retailer account should reflect the real owner and store details." icon={<UserCircle className="h-4 w-4" />}>
					<div className="grid gap-4 md:grid-cols-2">
						<FormField label="Owner full name" htmlFor="retailer-owner-name">
							<Input id="retailer-owner-name" value={form.owner_full_name} onChange={(event) => updateField('owner_full_name', event.target.value)} placeholder="Grace Njeri" />
						</FormField>
						<FormField label="Business name" htmlFor="retailer-business-name">
							<Input id="retailer-business-name" value={form.business_name} onChange={(event) => updateField('business_name', event.target.value)} placeholder="Njeri Foods" />
						</FormField>
						<FormField label="Business type" htmlFor="retailer-business-type">
							<Select id="retailer-business-type" aria-label="Business type" value={form.business_type} onChange={(value) => updateField('business_type', value)} options={['Grocery store', 'Wholesale', 'Supermarket', 'Hotel & restaurant', 'School catering', 'Online retail'].map((type) => ({ value: type, label: type }))} />
						</FormField>
						<FormField label="Business phone" htmlFor="retailer-business-phone">
							<Input id="retailer-business-phone" value={form.business_phone} onChange={(event) => updateField('business_phone', event.target.value)} placeholder="0712345678" />
						</FormField>
						<FormField label="Business email" htmlFor="retailer-business-email" className="md:col-span-2">
							<Input id="retailer-business-email" type="email" value={form.business_email} onChange={(event) => updateField('business_email', event.target.value)} placeholder="hello@store.co.ke" />
						</FormField>
					</div>
				</FormSection>

				<FormSection title="Location and contact" description="Customers and suppliers use this address to confirm deliveries and visits." icon={<MapPin className="h-4 w-4" />}>
					<FormField label="Business address" htmlFor="retailer-address">
						<Input id="retailer-address" value={form.business_address} onChange={(event) => updateField('business_address', event.target.value)} placeholder="Westlands, Nairobi" />
					</FormField>
				</FormSection>

				{message && <p role="status" className="flex items-center gap-2 rounded-xl bg-primary/10 p-3 text-sm text-primary"><Check className="h-4 w-4" />{message}</p>}
				{error && <p role="alert" className="rounded-xl bg-destructive/10 p-3 text-sm text-destructive">{error}</p>}

				<div className="flex justify-end">
					<Button type="submit" isLoading={isSaving} leftIcon={<Save className="h-4 w-4" />}>
						{isSaving ? 'Saving profile...' : 'Save changes'}
					</Button>
				</div>
			</form>
		</main>
	)
}
