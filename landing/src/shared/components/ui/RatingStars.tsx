import { Star } from 'lucide-react'

export interface RatingStarsProps {
  rating?: number | string | null
  reviews?: number
  size?: 'sm' | 'md'
  showValue?: boolean
  emptyClassName?: string
  className?: string
}

export function RatingStars({ rating = 0, reviews = 0, size = 'sm', showValue = true, emptyClassName = 'text-slate-500', className = '' }: RatingStarsProps) {
  const score = Number(rating) || 0
  const iconClass = size === 'md' ? 'h-5 w-5' : 'h-3.5 w-3.5'
  const label = `${score.toFixed(1)} out of 5 stars from ${reviews} reviews`

  return (
    <div className={`flex items-center gap-2 ${className}`} aria-label={label}>
      <span className="flex items-center gap-0.5" aria-hidden="true">
        {Array.from({ length: 5 }, (_, index) => (
          <Star
            key={index}
            className={`${iconClass} ${index < Math.round(score) ? 'fill-amber-400 text-amber-400' : emptyClassName}`}
          />
        ))}
      </span>
      {showValue && <span>{score.toFixed(1)} · {reviews} reviews</span>}
    </div>
  )
}
