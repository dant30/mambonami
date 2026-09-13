import { sessionStorageStore } from '../../../storage'
import type { RegistrationStartResponse } from '../../types'

const KEY = 'mambonami_registration_draft'

export const registrationDraftStore = {
	get(): RegistrationStartResponse | null {
		return sessionStorageStore.get<RegistrationStartResponse>(KEY)
	},
	set(session: RegistrationStartResponse): void {
		sessionStorageStore.set(KEY, session)
	},
	clear(): void {
		sessionStorageStore.remove(KEY)
	},
}
