import { Search } from 'lucide-react'
import { FormEvent, useState } from 'react'
import { useNavigate } from 'react-router-dom'

export function MarketplaceSearch({ placeholder = 'Search tomatoes, potatoes, onions...' }: { placeholder?: string }) {
	const navigate = useNavigate()
	const [query, setQuery] = useState('')
	const submit = (event: FormEvent) => { event.preventDefault(); const value = query.trim(); navigate(value ? `/products?q=${encodeURIComponent(value)}` : '/products') }
	return <form onSubmit={submit} className="flex w-full items-center gap-2 rounded-2xl border border-border bg-card p-2 text-foreground shadow-soft ring-primary transition focus-within:ring-2"><Search className="ml-3 h-5 w-5 shrink-0 text-primary" /><input aria-label="Search fresh produce" value={query} onChange={(event) => setQuery(event.target.value)} placeholder={placeholder} className="min-w-0 flex-1 bg-transparent px-1 py-3 text-base text-foreground outline-none placeholder:text-muted-foreground" /><button type="submit" className="inline-flex min-h-11 shrink-0 items-center justify-center rounded-xl bg-primary px-5 py-3 text-sm font-bold text-primary-foreground transition hover:bg-primary-dark">Search</button></form>
}
