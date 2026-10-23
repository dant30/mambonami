import { LocateFixed, MapPin, X } from 'lucide-react'

import { useBuyerDeliveryLocation } from '../../../core/hooks'
import { Button } from '../../../shared/components/ui'

export function DeliveryAreaControl({ className = '' }: { className?: string }) {
	const { location, requestCurrentLocation, setLocation, isLocating, error } = useBuyerDeliveryLocation()

	return <div className={`flex flex-wrap items-center justify-between gap-3 ${className}`}>
		<div className="flex min-w-0 items-start gap-2.5">
			<MapPin className="mt-0.5 h-4 w-4 shrink-0 text-primary" aria-hidden="true" />
			<div className="min-w-0">
				<p className="text-sm font-semibold text-foreground">Delivery area</p>
				<p className="text-xs text-muted-foreground" aria-live="polite">
					{location
						? `Nearby produce around ${location.latitude.toFixed(3)}, ${location.longitude.toFixed(3)}`
						: 'Set your location to see farms within the delivery area.'}
				</p>
				{error && <p className="mt-1 text-xs text-destructive" role="alert">{error}</p>}
			</div>
		</div>
		<div className="flex shrink-0 items-center gap-2">
			{location && <Button type="button" variant="ghost" size="sm" aria-label="Clear delivery location" title="Clear delivery location" onClick={() => setLocation(null)} className="h-9 w-9 px-0">
				<X className="h-4 w-4" aria-hidden="true" />
			</Button>}
			<Button type="button" variant="outline" size="sm" isLoading={isLocating} onClick={() => void requestCurrentLocation()} leftIcon={<LocateFixed className="h-4 w-4" />}>
				{location ? 'Update location' : 'Use my location'}
			</Button>
		</div>
	</div>
}