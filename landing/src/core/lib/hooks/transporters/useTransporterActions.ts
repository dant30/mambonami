import { useState } from 'react'

import { acceptTransportJob, declineTransportJob, sendTransportLocation, updateTransportAvailability, updateTransportVehicle } from '../../services'
import type { TransportAvailabilityUpdate, TransportVehicle, TripLocationPayload } from '../../types'

export function useTransporterActions() {
	const [busyKey, setBusyKey] = useState<string | null>(null)
	const [error, setError] = useState<unknown>(null)
	const run = async <T,>(key: string, action: () => Promise<T>) => {
		setBusyKey(key)
		setError(null)
		try { return await action() } catch (requestError) { setError(requestError); throw requestError } finally { setBusyKey(null) }
	}
	return {
		busyKey,
		error,
		acceptJob: (uuid: string) => run(`accept:${uuid}`, () => acceptTransportJob(uuid)),
		declineJob: (uuid: string, reason?: string) => run(`decline:${uuid}`, () => declineTransportJob(uuid, reason)),
		sendLocation: (uuid: string, payload: TripLocationPayload) => run(`location:${uuid}`, () => sendTransportLocation(uuid, payload)),
		updateAvailability: (input: TransportAvailabilityUpdate) => run('availability', () => updateTransportAvailability(input)),
		updateVehicle: (input: Partial<TransportVehicle>) => run('vehicle', () => updateTransportVehicle(input)),
	}
}
