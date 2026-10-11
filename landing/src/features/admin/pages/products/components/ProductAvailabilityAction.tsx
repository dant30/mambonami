import { Button } from '../../../../../shared/components/ui/Button'
import type { AdminProduct } from '../../../../../core/lib/types/admin'

export function ProductAvailabilityAction({ product, busy, onToggle }: { product: AdminProduct; busy: boolean; onToggle: () => void }) {
	return <Button size="sm" variant={product.is_active ? 'danger' : 'outline'} disabled={busy} onClick={onToggle}>{busy ? 'Saving' : product.is_active ? 'Deactivate' : 'Activate'}</Button>
}