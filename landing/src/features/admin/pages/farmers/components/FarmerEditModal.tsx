import { useState, type FormEvent } from 'react'

import { updateAdminFarmer } from '../../../../../core/lib'
import type { AdminFarmer } from '../../../../../core/lib/types/admin'
import { Button, Input, Modal } from '../../../../../shared/components/ui'

export function FarmerEditModal({ farmer, onClose, onSaved }: { farmer: AdminFarmer | null; onClose: () => void; onSaved: () => void }) {
	const [saving, setSaving] = useState(false)
	const [error, setError] = useState('')

	const submit = async (event: FormEvent<HTMLFormElement>) => {
		event.preventDefault()
		if (!farmer) return
		const data = new FormData(event.currentTarget)
		setSaving(true)
		setError('')
		try {
			await updateAdminFarmer(farmer.id, {
				county: String(data.get('county') || '').trim(),
				sub_county: String(data.get('sub_county') || '').trim(),
				ward: String(data.get('ward') || '').trim(),
				village: String(data.get('village') || '').trim(),
				cooperative: String(data.get('cooperative') || '').trim(),
				mpesa_number: String(data.get('mpesa_number') || '').trim(),
				bank_account: String(data.get('bank_account') || '').trim(),
				latitude: String(data.get('latitude') || '').trim() || null,
				longitude: String(data.get('longitude') || '').trim() || null,
			})
			onSaved()
		} catch (requestError) {
			setError(requestError instanceof Error ? requestError.message : 'Could not update farmer details.')
		} finally {
			setSaving(false)
		}
	}

	return <Modal isOpen={Boolean(farmer)} onClose={() => saving ? undefined : onClose()} title="Edit farmer profile" subtitle={farmer?.user_phone} maxWidth="lg">
		{farmer && <form onSubmit={(event) => void submit(event)} className="space-y-4">
			<div className="grid gap-4 sm:grid-cols-2">
				<FormField name="county" label="County" value={farmer.county} />
				<FormField name="sub_county" label="Sub-county" value={farmer.sub_county} />
				<FormField name="ward" label="Ward" value={farmer.ward} />
				<FormField name="village" label="Village" value={farmer.village} />
				<FormField name="cooperative" label="Cooperative" value={farmer.cooperative} />
				<FormField name="mpesa_number" label="M-Pesa number" value={farmer.mpesa_number} />
				<FormField name="latitude" label="Latitude" value={farmer.latitude == null ? '' : String(farmer.latitude)} type="number" />
				<FormField name="longitude" label="Longitude" value={farmer.longitude == null ? '' : String(farmer.longitude)} type="number" />
				<FormField name="bank_account" label="Bank account" value={farmer.bank_account} />
			</div>
			{error && <p role="alert" className="text-sm text-destructive">{error}</p>}
			<div className="flex justify-end gap-2 border-t border-border pt-4"><Button type="button" variant="outline" disabled={saving} onClick={onClose}>Cancel</Button><Button type="submit" isLoading={saving}>Save farmer</Button></div>
		</form>}
	</Modal>
}

function FormField({ name, label, value, type = 'text' }: { name: string; label: string; value?: string | number; type?: string }) {
	return <label className="block text-sm font-semibold">{label}<Input name={name} type={type} defaultValue={value ?? ''} className="mt-1" /></label>
}