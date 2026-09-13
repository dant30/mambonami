import { beforeEach, describe, expect, it } from 'vitest'

import { adminStore } from '../src/core/lib/stores/admin/adminStore'
import type { AdminFarmer, AdminTransportProvider, AdminUser } from '../src/core/lib/types/admin/admin'

describe('admin library state', () => {
	beforeEach(() => adminStore.clear())

	it('stores and clears all admin resource collections', () => {
		const user: AdminUser = { id: 1, phone: '+254700000000', role: 'buyer', is_active: true, is_staff: false, is_superuser: false }
		const farmer: AdminFarmer = { id: 2, user: 1 }
		const provider: AdminTransportProvider = { id: 3, user: 1 }
		adminStore.setUsers([user])
		adminStore.setFarmers([farmer])
		adminStore.setTransportProviders([provider])
		expect(adminStore.getUsers()).toHaveLength(1)
		expect(adminStore.getFarmers()).toHaveLength(1)
		expect(adminStore.getTransportProviders()).toHaveLength(1)
		adminStore.clear()
		expect(adminStore.getUsers()).toEqual([])
		expect(adminStore.getFarmers()).toEqual([])
		expect(adminStore.getTransportProviders()).toEqual([])
	})
})
