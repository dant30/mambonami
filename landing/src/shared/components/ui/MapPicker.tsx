import { LocateFixed, MapPin, Minus, Plus, Search } from 'lucide-react'
import { useCallback, useEffect, useRef, useState } from 'react'
import type { PointerEvent as ReactPointerEvent } from 'react'

import { cn, getCurrentLocation, isWithinKenya, reverseGeocode, roundCoordinate, searchPlaces } from '../../../core/utils'
import type { Coordinates, GeocodeResult } from '../../../core/utils'

export interface MapPickerProps {
	value?: Coordinates | null
	onChange?: (coordinates: Coordinates) => void
	/** Receives the resolved street address for the selected point, when available. */
	onAddressChange?: (address: string) => void
	className?: string
	label?: string
	helperText?: string
	/** Rejects points outside Kenya instead of emitting them. */
	restrictToKenya?: boolean
}

const TILE_SIZE = 256
const MIN_ZOOM = 5
const MAX_ZOOM = 18
const DEFAULT_ZOOM = 12
const DEFAULT_CENTER: Coordinates = { latitude: -1.286389, longitude: 36.817223 }
const DRAG_THRESHOLD_PX = 4

type Point = { x: number; y: number }

function project({ latitude, longitude }: Coordinates, zoom: number): Point {
	const scale = TILE_SIZE * 2 ** zoom
	const sin = Math.sin((Math.max(-85, Math.min(85, latitude)) * Math.PI) / 180)
	return { x: ((longitude + 180) / 360) * scale, y: (0.5 - Math.log((1 + sin) / (1 - sin)) / (4 * Math.PI)) * scale }
}

function unproject({ x, y }: Point, zoom: number): Coordinates {
	const scale = TILE_SIZE * 2 ** zoom
	const n = Math.PI - (2 * Math.PI * y) / scale
	return { latitude: (180 / Math.PI) * Math.atan(0.5 * (Math.exp(n) - Math.exp(-n))), longitude: (x / scale) * 360 - 180 }
}

function normalize(coordinates: Coordinates): Coordinates {
	return { latitude: roundCoordinate(coordinates.latitude), longitude: roundCoordinate(coordinates.longitude) }
}

export function MapPicker({ value, onChange, onAddressChange, className, label = 'Delivery location', helperText = 'Search for a place, tap the map, or use your current location.', restrictToKenya = false }: MapPickerProps) {
	const surfaceRef = useRef<HTMLDivElement>(null)
	const dragRef = useRef<{ startX: number; startY: number; origin: Point; moved: boolean } | null>(null)
	const [size, setSize] = useState({ width: 640, height: 288 })
	const [center, setCenter] = useState<Coordinates>(value ?? DEFAULT_CENTER)
	const [zoom, setZoom] = useState(value ? 15 : DEFAULT_ZOOM)
	const [selected, setSelected] = useState<Coordinates | null>(value ?? null)
	const selectedRef = useRef<Coordinates | null>(value ?? null)
	const [address, setAddress] = useState('')
	const [query, setQuery] = useState('')
	const [results, setResults] = useState<GeocodeResult[]>([])
	const [isSearching, setIsSearching] = useState(false)
	const [isLocating, setIsLocating] = useState(false)
	const [error, setError] = useState('')
	const [draft, setDraft] = useState({ latitude: value ? String(value.latitude) : '', longitude: value ? String(value.longitude) : '' })

	useEffect(() => {
		const element = surfaceRef.current
		if (!element || typeof ResizeObserver === 'undefined') return
		const measure = () => setSize({ width: element.clientWidth || 640, height: element.clientHeight || 288 })
		measure()
		const observer = new ResizeObserver(measure)
		observer.observe(element)
		return () => observer.disconnect()
	}, [])

	const choose = useCallback((coordinates: Coordinates, options: { recenter?: boolean; zoomTo?: number } = {}): boolean => {
		const next = normalize(coordinates)
		if (restrictToKenya && !isWithinKenya(next)) {
			setError('Please choose a location within Kenya.')
			return false
		}
		setError('')
		selectedRef.current = next
		setSelected(next)
		setDraft({ latitude: String(next.latitude), longitude: String(next.longitude) })
		if (options.recenter) setCenter(next)
		if (options.zoomTo) setZoom(options.zoomTo)
		onChange?.(next)
		return true
	}, [onChange, restrictToKenya])

	// Sync externally controlled values (e.g. when editing an existing product) without recentring on every click.
	useEffect(() => {
		if (!value) return
		const next = normalize(value)
		const current = selectedRef.current
		if (current && current.latitude === next.latitude && current.longitude === next.longitude) return
		selectedRef.current = next
		setSelected(next)
		setCenter(next)
		setDraft({ latitude: String(next.latitude), longitude: String(next.longitude) })
	}, [value])

	useEffect(() => {
		if (!selected) return
		let active = true
		const timer = window.setTimeout(() => {
			reverseGeocode(selected)
				.then((result) => {
					if (!active) return
					setAddress(result.displayName)
					onAddressChange?.(result.displayName)
				})
				.catch(() => { if (active) setAddress('') })
		}, 600)
		return () => { active = false; window.clearTimeout(timer) }
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [selected])

	const centerPx = project(center, zoom)
	const topLeft = { x: centerPx.x - size.width / 2, y: centerPx.y - size.height / 2 }
	const tilesPerAxis = 2 ** zoom
	const tiles: Array<{ key: string; src: string; left: number; top: number }> = []
	for (let ty = Math.floor(topLeft.y / TILE_SIZE); ty <= Math.floor((topLeft.y + size.height) / TILE_SIZE); ty += 1) {
		if (ty < 0 || ty >= tilesPerAxis) continue
		for (let tx = Math.floor(topLeft.x / TILE_SIZE); tx <= Math.floor((topLeft.x + size.width) / TILE_SIZE); tx += 1) {
			const wrappedX = ((tx % tilesPerAxis) + tilesPerAxis) % tilesPerAxis
			tiles.push({ key: `${zoom}/${tx}/${ty}`, src: `https://tile.openstreetmap.org/${zoom}/${wrappedX}/${ty}.png`, left: tx * TILE_SIZE - topLeft.x, top: ty * TILE_SIZE - topLeft.y })
		}
	}
	const markerPx = selected ? project(selected, zoom) : null

	const onPointerDown = (event: ReactPointerEvent<HTMLDivElement>) => {
		event.currentTarget.setPointerCapture(event.pointerId)
		dragRef.current = { startX: event.clientX, startY: event.clientY, origin: centerPx, moved: false }
	}
	const onPointerMove = (event: ReactPointerEvent<HTMLDivElement>) => {
		const drag = dragRef.current
		if (!drag) return
		const dx = event.clientX - drag.startX
		const dy = event.clientY - drag.startY
		if (!drag.moved && Math.hypot(dx, dy) < DRAG_THRESHOLD_PX) return
		drag.moved = true
		setCenter(unproject({ x: drag.origin.x - dx, y: drag.origin.y - dy }, zoom))
	}
	const onPointerUp = (event: ReactPointerEvent<HTMLDivElement>) => {
		const drag = dragRef.current
		dragRef.current = null
		if (!drag || drag.moved) return
		const rect = event.currentTarget.getBoundingClientRect()
		choose(unproject({ x: topLeft.x + (event.clientX - rect.left), y: topLeft.y + (event.clientY - rect.top) }, zoom))
	}

	const changeZoom = (delta: number) => setZoom((current) => Math.max(MIN_ZOOM, Math.min(MAX_ZOOM, current + delta)))

	const runSearch = async () => {
		setError('')
		if (query.trim().length < 3) { setError('Type at least 3 characters to search.'); return }
		setIsSearching(true)
		try {
			const found = await searchPlaces(query)
			setResults(found)
			if (found.length === 0) setError('No places found. Try a nearby town, estate or landmark.')
		} catch (searchError) {
			setError(searchError instanceof Error ? searchError.message : 'Place search failed.')
		} finally { setIsSearching(false) }
	}
	const pickResult = (result: GeocodeResult) => {
		if (choose(result, { recenter: true, zoomTo: 16 })) {
			setAddress(result.displayName)
			onAddressChange?.(result.displayName)
			setResults([])
		}
	}
	const locate = async () => {
		setIsLocating(true)
		setError('')
		try {
			choose(await getCurrentLocation(), { recenter: true, zoomTo: 16 })
		} catch (locationError) {
			setError(locationError instanceof Error ? locationError.message : 'Unable to determine your location.')
		} finally { setIsLocating(false) }
	}
	const applyDraft = () => {
		const latitude = Number(draft.latitude)
		const longitude = Number(draft.longitude)
		if (draft.latitude.trim() === '' || draft.longitude.trim() === '' || !Number.isFinite(latitude) || !Number.isFinite(longitude)) return
		if (Math.abs(latitude) > 90 || Math.abs(longitude) > 180) { setError('Coordinates are out of range.'); return }
		choose({ latitude, longitude }, { recenter: true })
	}

	const inputClass = 'mt-1 w-full rounded-xl border border-input bg-background px-3 py-2 text-sm text-foreground'

	return (
		<fieldset className={cn('space-y-3', className)}>
			<legend className="text-sm font-semibold text-foreground">{label}</legend>
			<div className="flex gap-2" role="search">
				<label className="sr-only" htmlFor="map-picker-search">Search for a place</label>
				<input id="map-picker-search" type="search" value={query} onChange={(event) => setQuery(event.target.value)} onKeyDown={(event) => { if (event.key === 'Enter') { event.preventDefault(); void runSearch() } }} placeholder="Search town, estate or landmark" className="min-w-0 flex-1 rounded-xl border border-input bg-background px-3 py-2 text-sm text-foreground" />
				<button type="button" onClick={() => void runSearch()} disabled={isSearching} className="inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-sm font-semibold text-primary-foreground disabled:opacity-60"><Search className="h-4 w-4" />{isSearching ? 'Searching...' : 'Search'}</button>
			</div>
			{results.length > 0 && (
				<ul className="max-h-48 divide-y divide-border overflow-y-auto rounded-xl border border-border bg-card text-sm">
					{results.map((result) => (
						<li key={`${result.latitude},${result.longitude},${result.displayName}`}>
							<button type="button" onClick={() => pickResult(result)} className="flex w-full items-start gap-2 px-3 py-2 text-left hover:bg-muted"><MapPin className="mt-0.5 h-4 w-4 shrink-0 text-primary" /><span>{result.displayName}</span></button>
						</li>
					))}
				</ul>
			)}
			<div className="relative overflow-hidden rounded-2xl border border-border bg-muted">
				<div
					ref={surfaceRef}
					role="application"
					aria-label="Interactive map. Tap to drop a pin, drag to move the map."
					className="relative h-72 w-full cursor-crosshair touch-none select-none overflow-hidden"
					onPointerDown={onPointerDown}
					onPointerMove={onPointerMove}
					onPointerUp={onPointerUp}
					onPointerCancel={() => { dragRef.current = null }}
				>
					{tiles.map((tile) => <img key={tile.key} src={tile.src} alt="" draggable={false} loading="lazy" className="pointer-events-none absolute max-w-none" style={{ left: tile.left, top: tile.top, width: TILE_SIZE, height: TILE_SIZE }} />)}
					{markerPx && <MapPin aria-hidden="true" className="pointer-events-none absolute h-9 w-9 -translate-x-1/2 -translate-y-full fill-primary/20 text-primary drop-shadow" style={{ left: markerPx.x - topLeft.x, top: markerPx.y - topLeft.y }} />}
				</div>
				<div className="absolute right-2 top-2 flex flex-col overflow-hidden rounded-lg border border-border bg-card shadow">
					<button type="button" aria-label="Zoom in" onClick={() => changeZoom(1)} disabled={zoom >= MAX_ZOOM} className="p-2 text-foreground hover:bg-muted disabled:opacity-40"><Plus className="h-4 w-4" /></button>
					<button type="button" aria-label="Zoom out" onClick={() => changeZoom(-1)} disabled={zoom <= MIN_ZOOM} className="border-t border-border p-2 text-foreground hover:bg-muted disabled:opacity-40"><Minus className="h-4 w-4" /></button>
				</div>
				<a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noreferrer" className="absolute bottom-0 right-0 bg-card/80 px-2 py-0.5 text-[10px] text-muted-foreground">© OpenStreetMap contributors</a>
			</div>
			<button type="button" onClick={() => void locate()} disabled={isLocating} className="inline-flex items-center gap-2 rounded-full border border-primary px-4 py-2 text-sm font-semibold text-primary disabled:opacity-60"><LocateFixed className="h-4 w-4" />{isLocating ? 'Finding location...' : 'Use my current location'}</button>
			{selected
				? <p className="flex items-start gap-2 text-xs text-muted-foreground"><MapPin className="mt-0.5 h-4 w-4 shrink-0 text-primary" /><span>{address || 'Resolving address...'}<span className="mt-0.5 block font-mono text-[11px]">{selected.latitude}, {selected.longitude}</span></span></p>
				: <p className="text-xs text-muted-foreground">{helperText}</p>}
			{error && <p role="alert" className="text-xs text-destructive">{error}</p>}
			<details className="text-xs text-muted-foreground">
				<summary className="cursor-pointer font-semibold">Enter coordinates manually</summary>
				<div className="mt-2 grid grid-cols-2 gap-3">
					<label className="font-semibold">Latitude<input type="text" inputMode="decimal" value={draft.latitude} onChange={(event) => setDraft((current) => ({ ...current, latitude: event.target.value }))} onBlur={applyDraft} className={inputClass} /></label>
					<label className="font-semibold">Longitude<input type="text" inputMode="decimal" value={draft.longitude} onChange={(event) => setDraft((current) => ({ ...current, longitude: event.target.value }))} onBlur={applyDraft} className={inputClass} /></label>
				</div>
			</details>
		</fieldset>
	)
}

