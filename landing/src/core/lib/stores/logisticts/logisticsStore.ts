import type { Trip } from '../../types'

let availableOrders: Trip[] = []
let myTrips: Trip[] = []
let adminTrips: Trip[] = []
let currentTrip: Trip | null = null
let buyerTrip: Trip | null = null

export const logisticsStore = {
	getAvailableOrders(): Trip[] {
		return availableOrders
	},
	setAvailableOrders(trips: Trip[]) {
		availableOrders = trips
	},
	getMyTrips(): Trip[] {
		return myTrips
	},
	setMyTrips(trips: Trip[]) {
		myTrips = trips
	},
	getAdminTrips(): Trip[] {
		return adminTrips
	},
	setAdminTrips(trips: Trip[]) {
		adminTrips = trips
	},
	getCurrentTrip(): Trip | null {
		return currentTrip
	},
	setCurrentTrip(trip: Trip | null) {
		currentTrip = trip
	},
	getBuyerTrip(): Trip | null {
		return buyerTrip
	},
	setBuyerTrip(trip: Trip | null) {
		buyerTrip = trip
	},
	clear() {
		availableOrders = []
		myTrips = []
		adminTrips = []
		currentTrip = null
		buyerTrip = null
	},
}
