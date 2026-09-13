export function formatRelativeTime(value?: string | number | Date): string {
  if (!value) return 'Recently'
  const timestamp = value instanceof Date ? value.getTime() : new Date(value).getTime()
  if (Number.isNaN(timestamp)) return 'Recently'
  const elapsedSeconds = Math.floor((Date.now() - timestamp) / 1000)
  if (elapsedSeconds < 0) return 'Just now'
  if (elapsedSeconds < 60) return 'Just now'
  const elapsedMinutes = Math.floor(elapsedSeconds / 60)
  if (elapsedMinutes < 60) return `${elapsedMinutes} minute${elapsedMinutes === 1 ? '' : 's'} ago`
  const elapsedHours = Math.floor(elapsedMinutes / 60)
  if (elapsedHours < 24) return `${elapsedHours} hour${elapsedHours === 1 ? '' : 's'} ago`
  const elapsedDays = Math.floor(elapsedHours / 24)
  if (elapsedDays < 7) return `${elapsedDays} day${elapsedDays === 1 ? '' : 's'} ago`
  const elapsedWeeks = Math.floor(elapsedDays / 7)
  if (elapsedWeeks < 5) return `${elapsedWeeks} week${elapsedWeeks === 1 ? '' : 's'} ago`
  return new Intl.DateTimeFormat(undefined, { dateStyle: 'medium' }).format(new Date(timestamp))
}

export function getTimeGreeting(date = new Date()): string {
  const hour = date.getHours()
  if (hour < 12) return '🌄 Morning'
  if (hour < 18) return '🌤️ Afternoon'
  return '🌛 Evening'
}