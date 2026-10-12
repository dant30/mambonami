import { Search } from 'lucide-react'
import { FormEvent, useState } from 'react'
import { useNavigate } from 'react-router-dom'

export function MarketplaceSearch({ placeholder = 'Search tomatoes, potatoes, onions...' }: { placeholder?: string }) {
	const navigate = useNavigate()
	const [query, setQuery] = useState('')
	const submit = (event: FormEvent) => { event.preventDefault(); const value = query.trim(); navigate(value ? `/products?q=${encodeURIComponent(value)}` : '/products') }
	return <form onSubmit={submit} className="flex w-full items-center gap-1.5 rounded-xl border border-border bg-card p-1.5 text-foreground shadow-soft ring-primary transition focus-within:ring-2 sm:gap-2 sm:rounded-2xl sm:p-2"><Search className="ml-2 h-5 w-5 shrink-0 text-primary sm:ml-3" /><input aria-label="Search fresh produce" value={query} onChange={(event) => setQuery(event.target.value)} placeholder={placeholder} className="min-h-11 min-w-0 flex-1 bg-transparent px-1 py-2 text-base text-foreground outline-none placeholder:text-muted-foreground" /><button type="submit" className="inline-flex min-h-11 shrink-0 items-center justify-center rounded-lg bg-primary px-3 py-2 text-xs font-bold text-primary-foreground transition hover:bg-primary-dark sm:rounded-xl sm:px-5 sm:py-3 sm:text-sm">Search</button></form>
}
