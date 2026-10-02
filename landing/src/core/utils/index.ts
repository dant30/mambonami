export { cn } from './cn'
export { installNotificationSoundUnlock, playNotificationSound } from './notificationSound'
export { isValidKenyanPhone, normalizeKenyanPhone } from './phone'
export { evaluatePasswordStrength } from './passwordStrength'
export type { PasswordStrengthLevel, PasswordStrengthResult } from './passwordStrength'
export { formatRelativeTime, getTimeGreeting } from './date'
export { getErrorMessage, isApiError, normalizeError } from './errorHandler'
export type { NormalizedError } from './errorHandler'
export { logError, logger } from './logger'
export { captureVideoFrame, requestCameraStream, stopCameraStream } from './camera'
export type { CameraOptions } from './camera'
export { getCurrentLocation, isWithinKenya, reverseGeocode, roundCoordinate, searchPlaces } from './location'
export type { Coordinates, GeocodeResult, SearchPlacesOptions } from './location'
export {
	siteUrl,
	siteName,
	defaultTitle,
	defaultDescription,
	defaultImage,
	absoluteUrl,
	buildBreadcrumbJsonLd,
	buildProductJsonLd,
	buildTitle,
	seoMeta,
	seoLinks,
	truncate,
	organizationJsonLd,
	websiteJsonLd,
	marketplaceJsonLd,
} from './seo'
export type { ProductJsonLdInput, SeoLinkTag, SeoMetaTag } from './seo'
export { resolveRouteSeo } from './routeSeo'
export type { RouteSeoConfig } from './routeSeo'