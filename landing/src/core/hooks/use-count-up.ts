import { useEffect, useRef, useState } from 'react'

function parseTarget(raw: string): { target: number; suffix: string; prefix: string; decimals: number } {
  const trimmed = raw.trim()
  let prefix = ''
  let suffix = ''
  let numeric = trimmed

  const prefixMatch = numeric.match(/^([^\d\s.,+-]+)/)
  if (prefixMatch) {
    prefix = prefixMatch[1]
    numeric = numeric.slice(prefix.length)
  }

  const numericMatch = numeric.match(/^([+-]?[\d,]+(?:\.\d+)?)([KMB])?([^\d\s.,]*)$/i)
  if (!numericMatch) return { target: 0, suffix: '', prefix, decimals: 0 }

  numeric = numericMatch[1]
  const magnitude = numericMatch[2]?.toUpperCase()
  suffix = numericMatch[3]

  const multiplier = magnitude === 'K' ? 1_000 : magnitude === 'M' ? 1_000_000 : magnitude === 'B' ? 1_000_000_000 : 1
  const target = Number(numeric.replace(/,/g, '')) * multiplier
  const decimals = numeric.includes('.') ? numeric.split('.')[1].length : 0

  if (!Number.isFinite(target)) {
    return { target: 0, suffix: '', prefix, decimals: 0 }
  }

  return { target, suffix, prefix, decimals }
}

export function useCountUp(value: string, duration = 2000): { display: string; ref: React.RefObject<HTMLDivElement> } {
  const [display, setDisplay] = useState('0')
  const ref = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const el = ref.current;
    if (!el || typeof IntersectionObserver === 'undefined') {
      setDisplay(value)
      return
    }

    const { target, suffix, prefix, decimals } = parseTarget(value)
    let animationFrame = 0
    let hasAnimated = false

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting && !hasAnimated) {
            hasAnimated = true
            const startTime = performance.now()

            const tick = (now: number) => {
              const elapsed = now - startTime
              const progress = duration <= 0 ? 1 : Math.min(elapsed / duration, 1)
              const eased = 1 - Math.pow(1 - progress, 4)
              const current = target * eased

              let formatted: string
              if (target >= 1000) {
                formatted = Math.floor(current).toLocaleString()
              } else {
                formatted = current.toFixed(decimals)
              }

              setDisplay(`${prefix}${formatted}${suffix}`)

              if (progress < 1) {
                animationFrame = requestAnimationFrame(tick)
              } else {
                setDisplay(`${prefix}${target.toLocaleString(undefined, { maximumFractionDigits: decimals })}${suffix}`)
              }
            }

            animationFrame = requestAnimationFrame(tick)
          }
        });
      },
      { threshold: 0.3 }
    )

    observer.observe(el)
    return () => {
      observer.disconnect()
      cancelAnimationFrame(animationFrame)
    }
  }, [value, duration])

  return { display, ref }
}
