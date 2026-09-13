import type { ReactNode } from 'react'
import { ArrowLeft } from 'lucide-react'
import { Link, useNavigate } from 'react-router-dom'

export function AuthLayout({ title, description, children }: { title: string; description?: string; children: ReactNode }) {
	const navigate = useNavigate()
	return <section className="min-h-[calc(100vh-8rem)] bg-[#f2eadc] px-4 py-10 sm:px-6"><div className="mx-auto max-w-md"><button type="button" onClick={() => navigate(-1)} className="mb-5 inline-flex items-center gap-2 text-sm font-semibold text-primary hover:underline"><ArrowLeft className="h-4 w-4" />Back</button><section className="rounded-[1.5rem] border border-border bg-card p-6 shadow-soft sm:p-8"><h1 className="text-3xl font-semibold text-primary-dark">{title}</h1>{description && <p className="mt-2 text-sm leading-6 text-muted-foreground">{description}</p>}<div className="mt-7">{children}</div></section><Link to="/" className="mt-5 block text-center text-xs font-semibold text-muted-foreground hover:text-primary">Return to marketplace</Link></div></section>
}