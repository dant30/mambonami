export function getRoleDashboardPath(role: unknown, isAdmin = false) {
	if (isAdmin) return '/app/admin'

	switch (role) {
		case 'buyer':
			return '/app/buyer'
		case 'farmer':
			return '/app/farmer'
		case 'retailer':
			return '/app/retailer'
		case 'transport_provider':
			return '/app/transport'
		default:
			return '/app/buyer'
	}
}

export function getRoleNotificationsPath(role: unknown, isAdmin = false) {
	if (isAdmin) return '/app/admin/notifications'

	switch (role) {
		case 'farmer':
			return '/app/farmer/notifications'
		case 'retailer':
			return '/app/retailer/notifications'
		case 'transport_provider':
			return '/app/transport/notifications'
		case 'buyer':
		default:
			return '/app/buyer/notifications'
	}
}
