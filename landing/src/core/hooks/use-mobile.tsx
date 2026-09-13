import { useEffect, useState } from 'react'

const MOBILE_BREAKPOINT = 768

export function useIsMobile(): boolean {
  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    if (typeof window === 'undefined') return

    const mediaQuery = window.matchMedia(`(max-width: ${MOBILE_BREAKPOINT - 1}px)`)
    const onChange = (event: MediaQueryListEvent) => setIsMobile(event.matches)
    setIsMobile(mediaQuery.matches)
    if (mediaQuery.addEventListener) {
      mediaQuery.addEventListener('change', onChange)
    } else {
      mediaQuery.addListener(onChange)
    }

    return () => {
      if (mediaQuery.removeEventListener) {
        mediaQuery.removeEventListener('change', onChange)
      } else {
        mediaQuery.removeListener(onChange)
      }
    }
  }, [])

  return isMobile
}
