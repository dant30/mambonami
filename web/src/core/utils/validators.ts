import { PHONE_REGEX } from './constants';

/** Validate Kenyan phone numbers that start with 07 and have 10 digits total */
export const validatePhone = (phone?: string | null): boolean => {
	if (!phone) return false;
	return PHONE_REGEX.test(phone.trim());
};

/** Basic email validation */
export const validateEmail = (email?: string | null): boolean => {
	if (!email) return false;
	return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim());
};

export const isNonEmptyString = (value?: string | null): boolean => {
	return !!value && value.trim().length > 0;
};

export const isPositiveNumber = (v?: number | null): boolean => {
	return typeof v === 'number' && Number.isFinite(v) && v > 0;
};
