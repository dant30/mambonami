export interface UserProfile {
	id: number;
	phone: string;
	username: string;
	email?: string | null;
	first_name?: string | null;
	last_name?: string | null;
	role: string;
}

export interface LoginPayload {
	phone: string;
	password: string;
}

export default {};
