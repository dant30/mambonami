import { useEffect, useState } from 'react'

export function useMediaQuery(query: string, defaultValue = false): boolean {
  const getMatches = (): boolean => {
    if (typeof window === 'undefined') return defaultValue
    return window.matchMedia(query).matches
  }

  const [matches, setMatches] = useState(getMatches)

  useEffect(() => {
    if (typeof window === 'undefined') return

    const mediaQueryList = window.matchMedia(query)

    const handler = (event: MediaQueryListEvent) => {
      setMatches(event.matches)
    }

    // Set immediately in case query changes
    setMatches(mediaQueryList.matches)

    // Modern browsers
    if (mediaQueryList.addEventListener) {
      mediaQueryList.addEventListener('change', handler)
    } else {
      // Safari / old browsers fallback
      mediaQueryList.addListener(handler)
    }

    return () => {
      if (mediaQueryList.removeEventListener) {
        mediaQueryList.removeEventListener('change', handler)
      } else {
        mediaQueryList.removeListener(handler)
      }
    }
  }, [query])

  return matches
}

export default useMediaQuery
