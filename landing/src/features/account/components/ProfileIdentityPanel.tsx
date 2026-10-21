import { Camera, Check, CheckCircle2, Clock3, Copy, Share2, ShieldCheck } from 'lucide-react'
import { useRef, useState } from 'react'

import { uploadAvatar } from '../../../core/lib'
import { Avatar, Badge, Button } from '../../../shared/components/ui'

function statusVariant(value: string) {
	return ['active', 'verified', 'approved'].includes(value.toLowerCase()) ? 'success' : value.toLowerCase() === 'rejected' ? 'danger' : 'warning'
}

type ProfileUser = {
	first_name?: string
	middle_name?: unknown
	last_name?: string
	username?: string
	phone?: string
	email?: string
	avatar_url?: unknown
	is_phone_verified?: unknown
	is_email_verified?: unknown
	is_active?: unknown
	account_status?: unknown
	kyc_status?: unknown
	referral_code?: unknown
}

export function ProfileIdentityPanel({ user, roleLabel }: { user: ProfileUser | null; roleLabel: string }) {
	const inputRef = useRef<HTMLInputElement>(null)
	const [avatarUrl, setAvatarUrl] = useState<string | null>(String(user?.avatar_url || '') || null)
	const [uploading, setUploading] = useState(false)
	const [error, setError] = useState('')
	const [referralMessage, setReferralMessage] = useState('')
	const displayName = [user?.first_name, user?.middle_name, user?.last_name].filter(Boolean).join(' ') || user?.username || 'Mambonami member'
	const accountStatus = String(user?.account_status || 'pending')
	const kycStatus = String(user?.kyc_status || 'pending')
	const referralCode = String(user?.referral_code || '')
	const referralLink = typeof window === 'undefined' || !referralCode
		? ''
		: `${window.location.origin}/role-select?ref=${encodeURIComponent(referralCode)}`

	const copyReferralLink = async () => {
		try {
			await navigator.clipboard.writeText(referralLink)
			setReferralMessage('Referral link copied.')
		} catch {
			setReferralMessage('Could not copy the referral link. Please copy it from the field.')
		}
	}

	const shareReferralLink = async () => {
		if (navigator.share) {
			try {
				await navigator.share({ title: 'Join Mambonami', text: 'Join me on Mambonami.', url: referralLink })
				setReferralMessage('Referral link shared.')
			} catch (shareError) {
				if (shareError instanceof Error && shareError.name === 'AbortError') return
				await copyReferralLink()
			}
			return
		}
		await copyReferralLink()
	}

	const upload = async (file?: File) => {
		if (!file) return
		setUploading(true)
		setError('')
		try {
			const nextUser = await uploadAvatar(file)
			setAvatarUrl(String(nextUser.avatar_url || '') || URL.createObjectURL(file))
		} catch {
			setError('Profile photo could not be uploaded.')
		} finally {
			setUploading(false)
		}
	}

	return (
		<section className="rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-5">
			<div className="flex items-center gap-4">
				<div className="group relative shrink-0">
					<Avatar src={avatarUrl} name={String(displayName)} size="2xl" isVerified={Boolean(user?.is_phone_verified)} />
					<Button type="button" size="sm" variant="navy" onClick={() => inputRef.current?.click()} disabled={uploading} aria-label="Change profile photo" className="absolute inset-0 h-20 w-20 rounded-full px-0 opacity-0 transition group-hover:opacity-95 group-focus-within:opacity-95">
						<Camera className="h-5 w-5" />
					</Button>
					<input ref={inputRef} type="file" accept="image/jpeg,image/png,image/webp" className="sr-only" onChange={(event) => void upload(event.target.files?.[0])} />
				</div>
				<div className="min-w-0">
					<p className="text-[10px] font-bold uppercase tracking-wider text-primary">{roleLabel}</p>
					<h1 className="mt-1 truncate text-xl font-semibold text-primary-dark sm:text-2xl">{displayName}</h1>
					<p className="mt-1 truncate text-sm text-muted-foreground">{user?.phone || user?.email || 'Contact details pending'}</p>
				</div>
			</div>
			<div className="mt-4 flex flex-wrap gap-2 border-t border-border pt-3">
				<Badge variant={user?.is_phone_verified ? 'success' : 'warning'} size="sm" icon={user?.is_phone_verified ? <CheckCircle2 className="h-3.5 w-3.5" /> : <Clock3 className="h-3.5 w-3.5" />}>Phone {user?.is_phone_verified ? 'verified' : 'pending'}</Badge>
				<Badge variant={user?.is_email_verified ? 'success' : 'neutral'} size="sm" icon={user?.is_email_verified ? <CheckCircle2 className="h-3.5 w-3.5" /> : undefined}>Email {user?.is_email_verified ? 'verified' : 'unverified'}</Badge>
				<Badge variant={statusVariant(accountStatus)} size="sm">Account {accountStatus.replaceAll('_', ' ')}</Badge>
				<Badge variant={user?.is_active === false ? 'danger' : 'success'} size="sm">{user?.is_active === false ? 'Inactive' : 'Active'}</Badge>
				<Badge variant={statusVariant(kycStatus)} size="sm" icon={<ShieldCheck className="h-3.5 w-3.5" />}>KYC {kycStatus.replaceAll('_', ' ')}</Badge>
			</div>
			{referralLink && <div className="mt-4 border-t border-border pt-4">
				<div className="flex flex-wrap items-center justify-between gap-3">
					<div><h2 className="text-sm font-semibold text-primary-dark">Your referral link</h2><p className="mt-1 text-xs text-muted-foreground">Invite someone to choose any Mambonami account type.</p></div>
					<div className="flex shrink-0 gap-2">
						<Button type="button" size="sm" variant="outline" onClick={() => void copyReferralLink()} aria-label="Copy referral link"><Copy className="h-4 w-4" /><span className="sr-only">Copy</span></Button>
						<Button type="button" size="sm" variant="navy" onClick={() => void shareReferralLink()} aria-label="Share referral link"><Share2 className="h-4 w-4" /><span className="sr-only">Share</span></Button>
					</div>
				</div>
				<div className="mt-3 flex min-w-0 items-center gap-2">
					<input aria-label="Referral link" readOnly value={referralLink} onFocus={(event) => event.currentTarget.select()} className="min-w-0 flex-1 rounded-lg border border-border bg-background px-3 py-2 text-xs text-muted-foreground" />
				</div>
				{referralMessage && <p role="status" className="mt-2 flex items-center gap-1 text-xs text-primary"><Check className="h-3.5 w-3.5" />{referralMessage}</p>}
			</div>}
			{error && <p role="alert" className="mt-3 text-xs text-destructive">{error}</p>}
		</section>
	)
}
