import { Check, UserCircle } from 'lucide-react'
import { FormEvent, useState } from 'react'

import { useAuth } from '../../../core/contexts/AuthContext'
import { updateProfile } from '../../../core/lib'

export function BuyerProfilePage() {
	const { user } = useAuth()
	const [form, setForm] = useState({ first_name: user?.first_name || '', last_name: user?.last_name || '', email: user?.email || '', phone: user?.phone || '' })
	const [message, setMessage] = useState('')
	const [error, setError] = useState('')
	const [isSaving, setIsSaving] = useState(false)
	const submit = async (event: FormEvent) => {
		event.preventDefault(); setIsSaving(true); setMessage(''); setError('')
		try { await updateProfile(form); setMessage('Profile updated successfully.') } catch { setError('We could not update your profile. Please try again.') } finally { setIsSaving(false) }
	}
	return <main className="mx-auto max-w-3xl px-4 py-8 sm:px-6 lg:px-8"><div className="flex items-center gap-4 border-b border-border pb-6"><div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-primary/10"><UserCircle className="h-8 w-8 text-primary" /></div><div><p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Buyer workspace</p><h1 className="mt-1 text-3xl font-semibold text-primary-dark">Your profile</h1><p className="mt-2 text-sm text-muted-foreground">Keep your account details ready for smooth delivery.</p></div></div><form onSubmit={submit} className="mt-8 rounded-2xl border border-border bg-card p-5 shadow-sm sm:p-7"><div className="grid gap-5 sm:grid-cols-2"><label className="text-sm font-semibold text-primary-dark">First name<input value={form.first_name} onChange={(event) => setForm({ ...form, first_name: event.target.value })} className="mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 font-normal outline-none focus:ring-2 focus:ring-primary" /></label><label className="text-sm font-semibold text-primary-dark">Last name<input value={form.last_name} onChange={(event) => setForm({ ...form, last_name: event.target.value })} className="mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 font-normal outline-none focus:ring-2 focus:ring-primary" /></label><label className="text-sm font-semibold text-primary-dark">Email<input type="email" value={form.email} onChange={(event) => setForm({ ...form, email: event.target.value })} className="mt-2 w-full rounded-xl border border-border bg-background px-4 py-3 font-normal outline-none focus:ring-2 focus:ring-primary" /></label><label className="text-sm font-semibold text-primary-dark">Phone<input value={form.phone} readOnly className="mt-2 w-full rounded-xl border border-border bg-muted px-4 py-3 font-normal text-muted-foreground" /></label></div>{message && <p role="status" className="mt-5 flex items-center gap-2 text-sm text-primary"><Check className="h-4 w-4" />{message}</p>}{error && <p role="alert" className="mt-5 text-sm text-destructive">{error}</p>}<button type="submit" disabled={isSaving} className="mt-6 rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground disabled:opacity-60">{isSaving ? 'Saving...' : 'Save changes'}</button></form></main>
}
