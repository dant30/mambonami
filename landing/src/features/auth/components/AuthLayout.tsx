import type { ReactNode } from 'react'
import { ArrowLeft } from 'lucide-react'
import { Link, useNavigate } from 'react-router-dom'

export function AuthLayout({ title, description, children }: { title: string; description?: string; children: ReactNode }) {
	const navigate = useNavigate()
	return <section className="min-h-[calc(100dvh-7rem)] bg-muted px-4 py-5 sm:min-h-[calc(100vh-8rem)] sm:px-6 sm:py-10"><div className="mx-auto max-w-md"><button type="button" onClick={() => navigate(-1)} className="mb-3 inline-flex min-h-10 items-center gap-2 text-sm font-semibold text-primary hover:underline sm:mb-5"><ArrowLeft className="h-4 w-4" />Back</button><section className="rounded-2xl border border-border bg-card p-5 shadow-soft sm:rounded-[1.5rem] sm:p-8"><h1 className="text-2xl font-semibold text-primary-dark sm:text-3xl">{title}</h1>{description && <p className="mt-1.5 text-sm leading-6 text-muted-foreground sm:mt-2">{description}</p>}<div className="mt-5 sm:mt-7">{children}</div></section><Link to="/" className="mt-4 block text-center text-xs font-semibold text-muted-foreground hover:text-primary sm:mt-5">Return to marketplace</Link></div></section>
}