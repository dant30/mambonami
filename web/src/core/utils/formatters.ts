import { DEFAULT_CURRENCY, DEFAULT_LOCALE, DATE_DISPLAY_OPTIONS } from './constants';

/**
 * Format a numeric amount as a localized currency string.
 * Returns an empty string for invalid input.
 */
export const formatCurrency = (
	amount: number | null | undefined,
	currency: string = DEFAULT_CURRENCY,
	locale: string = DEFAULT_LOCALE,
) => {
	if (amount == null || Number.isNaN(Number(amount))) return '';
	try {
		return new Intl.NumberFormat(locale, { style: 'currency', currency }).format(amount);
	} catch (e) {
		return `${currency} ${Number(amount).toLocaleString()}`;
	}
};

/**
 * Format an ISO date string (or Date) into a readable representation.
 * Returns an empty string for invalid input.
 */
export const formatDate = (
	value?: string | Date | null,
	locale: string = DEFAULT_LOCALE,
	options: Intl.DateTimeFormatOptions = DATE_DISPLAY_OPTIONS,
) => {
	if (!value) return '';
	const d = typeof value === 'string' ? new Date(value) : value;
	if (Number.isNaN(d.getTime())) return '';
	return d.toLocaleDateString(locale, options);
};

/**
 * Simple helper to render a human-friendly relative time (e.g., "2d ago").
 */
export const formatTimeAgo = (date?: string | Date | null) => {
	if (!date) return '';
	const t = typeof date === 'string' ? new Date(date).getTime() : date.getTime();
	if (Number.isNaN(t)) return '';
	const seconds = Math.floor((Date.now() - t) / 1000);
	if (seconds < 60) return `${seconds}s ago`;
	const mins = Math.floor(seconds / 60);
	if (mins < 60) return `${mins}m ago`;
	const hours = Math.floor(mins / 60);
	if (hours < 24) return `${hours}h ago`;
	const days = Math.floor(hours / 24);
	return `${days}d ago`;
};
