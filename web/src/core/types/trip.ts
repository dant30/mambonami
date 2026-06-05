/**
 * Trip / ride domain types
 */

export type TripStatus = 'requested' | 'accepted' | 'in_progress' | 'completed' | 'cancelled';

export interface LocationPoint {
	lat: number;
	lng: number;
	address?: string | null;
}

export interface Trip {
	id: string | number;
	riderId?: string | number | null;
	driverId?: string | number | null;
	origin: LocationPoint;
	destination: LocationPoint;
	fare: number;
	currency?: string;
	distanceKm?: number;
	durationSeconds?: number;
	status: TripStatus;
	startedAt?: string | null;
	endedAt?: string | null;
	createdAt?: string;
}
