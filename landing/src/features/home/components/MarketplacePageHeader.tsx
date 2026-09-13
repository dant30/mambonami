import { ArrowLeft } from 'lucide-react'
import { Link } from 'react-router-dom'

export function MarketplacePageHeader({ eyebrow, title, description }: { eyebrow: string; title: string; description: string }) {
	return <div className="border-b border-border bg-muted/40"><div className="mx-auto max-w-7xl px-4 py-5 sm:px-6 sm:py-7 lg:px-8"><Link to="/home" className="mb-4 inline-flex items-center gap-2 text-xs font-bold text-primary"><ArrowLeft className="h-3.5 w-3.5" />Back to marketplace</Link><p className="text-[11px] font-bold uppercase tracking-[0.18em] text-primary">{eyebrow}</p><h1 className="mt-1 max-w-3xl text-2xl font-semibold leading-tight text-primary-dark sm:text-3xl">{title}</h1><p className="mt-2 max-w-2xl text-sm leading-6 text-muted-foreground">{description}</p></div></div>
}
