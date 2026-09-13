import { LocateFixed, MapPin } from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'

import { getCurrentLocation, reverseGeocode, type Coordinates } from '../../../core/utils'
import { cn } from '../../../core/utils'

export interface MapPickerProps {
	value?: Coordinates | null
	onChange?: (coordinates: Coordinates) => void
	className?: string
	label?: string
}

const DEFAULT_LOCATION: Coordinates = { latitude: -1.286389, longitude: 36.817223 }

function mapUrl({ latitude, longitude }: Coordinates): string {
	const delta = 0.035
	const bbox = [longitude - delta, latitude - delta, longitude + delta, latitude + delta].join('%2C')
	return `https://www.openstreetmap.org/export/embed.html?bbox=${bbox}&layer=mapnik&marker=${latitude}%2C${longitude}`
}

export function MapPicker({ value, onChange, className, label = 'Delivery location' }: MapPickerProps) {
	const [coordinates, setCoordinates] = useState<Coordinates>(value ?? DEFAULT_LOCATION)
	const [address, setAddress] = useState('')
	const [isLocating, setIsLocating] = useState(false)
	const [error, setError] = useState('')

	useEffect(() => { if (value) setCoordinates(value) }, [value])
	const map = useMemo(() => mapUrl(coordinates), [coordinates])

	const update = (next: Coordinates) => { setCoordinates(next); onChange?.(next) }
	const locate = async () => {
		setIsLocating(true)
		setError('')
		try {
			const next = await getCurrentLocation()
			update(next)
			const result = await reverseGeocode(next)
			setAddress(result.displayName)
		} catch (locationError) {
			setError(locationError instanceof Error ? locationError.message : 'Unable to determine your location.')
		} finally { setIsLocating(false) }
	}

	return <fieldset className={cn('space-y-3', className)}><legend className="text-sm font-semibold text-foreground">{label}</legend><div className="overflow-hidden rounded-2xl border border-border bg-muted"><iframe title="Select a location on the map" src={map} className="h-56 w-full border-0" loading="lazy" /></div><div className="grid grid-cols-2 gap-3"><label className="text-xs font-semibold text-muted-foreground">Latitude<input type="number" step="any" value={coordinates.latitude} onChange={(event) => update({ ...coordinates, latitude: Number(event.target.value) })} className="mt-1 w-full rounded-xl border border-input bg-background px-3 py-2 text-sm text-foreground" /></label><label className="text-xs font-semibold text-muted-foreground">Longitude<input type="number" step="any" value={coordinates.longitude} onChange={(event) => update({ ...coordinates, longitude: Number(event.target.value) })} className="mt-1 w-full rounded-xl border border-input bg-background px-3 py-2 text-sm text-foreground" /></label></div><button type="button" onClick={() => void locate()} disabled={isLocating} className="inline-flex items-center gap-2 rounded-full border border-primary px-4 py-2 text-sm font-semibold text-primary disabled:opacity-60"><LocateFixed className="h-4 w-4" />{isLocating ? 'Finding location...' : 'Use my current location'}</button>{address && <p className="flex items-start gap-2 text-xs text-muted-foreground"><MapPin className="mt-0.5 h-4 w-4 shrink-0 text-primary" />{address}</p>}{error && <p role="alert" className="text-xs text-destructive">{error}</p>}</fieldset>
}
