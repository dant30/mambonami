import { Building2, MapPin, Package } from 'lucide-react'

import { useProducts } from '../../../core/lib'

interface Supplier { name: string; phone: string; products: number; location: string }

export function RetailerSuppliersPage() {
	const { products, isLoading, error } = useProducts({ page_size: 100 })
	const suppliers = products.reduce<Supplier[]>((list, product) => {
		const name = product.farmer_name || 'Verified Mambonami supplier'
		const existing = list.find((supplier) => supplier.name === name)
		if (existing) existing.products += 1
		else list.push({ name, phone: product.farmer_phone || 'Contact through Mambonami', products: 1, location: 'Kenya' })
		return list
	}, [])

	return <main className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8"><div className="border-b border-border pb-8"><p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">Your supply network</p><h1 className="mt-2 text-3xl font-semibold text-primary-dark sm:text-4xl">Suppliers</h1><p className="mt-3 text-sm text-muted-foreground">Discover growers and supply partners behind the products available to your business.</p></div>{Boolean(error) && <p role="alert" className="mt-6 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">Unable to load supplier data.</p>}{isLoading ? <div className="mt-8 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">{[1, 2, 3].map((item) => <div key={item} className="h-48 animate-pulse rounded-2xl bg-muted" />)}</div> : suppliers.length === 0 ? <div className="mt-8 rounded-2xl border border-dashed border-border p-12 text-center"><Building2 className="mx-auto h-9 w-9 text-primary" /><h2 className="mt-4 text-xl font-semibold text-primary-dark">Your supplier directory is growing</h2><p className="mt-2 text-sm text-muted-foreground">Suppliers will appear as marketplace products become available.</p></div> : <div className="mt-8 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">{suppliers.map((supplier) => <article key={supplier.name} className="rounded-2xl border border-border bg-card p-6"><span className="flex h-11 w-11 items-center justify-center rounded-full bg-secondary text-primary-dark"><Building2 className="h-5 w-5" /></span><h2 className="mt-5 text-xl font-semibold text-primary-dark">{supplier.name}</h2><p className="mt-2 flex items-center gap-2 text-sm text-muted-foreground"><MapPin className="h-4 w-4" />{supplier.location}</p><p className="mt-2 flex items-center gap-2 text-sm text-muted-foreground"><Package className="h-4 w-4" />{supplier.products} listed products</p><p className="mt-5 border-t border-border pt-4 text-xs font-semibold text-primary">{supplier.phone}</p></article>)}</div>}</main>
}
