import { USER_ENDPOINTS, apiClient } from '../../../api'
import type { VerificationDocument, VerificationDocumentStatus, VerificationDocumentType } from '../../types'

export async function listVerificationDocuments(userId?: number): Promise<VerificationDocument[]> {
	const response = await apiClient.get<VerificationDocument[] | { results?: VerificationDocument[] }>(
		USER_ENDPOINTS.verificationDocuments,
		{ params: userId === undefined ? undefined : { user_id: userId } },
	)
	return Array.isArray(response) ? response : response.results ?? []
}

export function uploadVerificationDocument(input: {
	document_type: VerificationDocumentType
	document_number?: string
	expiry_date?: string
	file: File
}): Promise<VerificationDocument> {
	const body = new FormData()
	body.append('document_type', input.document_type)
	body.append('file', input.file)
	if (input.document_number) body.append('document_number', input.document_number)
	if (input.expiry_date) body.append('expiry_date', input.expiry_date)
	return apiClient.post<VerificationDocument>(USER_ENDPOINTS.verificationDocuments, body)
}

export function reviewVerificationDocument(
	uuid: string,
	input: { status: VerificationDocumentStatus; notes?: string },
): Promise<VerificationDocument> {
	return apiClient.post<VerificationDocument>(USER_ENDPOINTS.reviewVerificationDocument(uuid), input)
}