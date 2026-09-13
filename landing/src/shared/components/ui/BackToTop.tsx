// frontend/src/shared/components/ui/BackToTop.tsx
import React, { useState, useEffect } from 'react'
import { ArrowUp } from 'lucide-react'

interface BackToTopProps {
  threshold?: number
  className?: string
}

export const BackToTop: React.FC<BackToTopProps> = ({
  threshold = 300,
  className = '',
}) => {
  const [isVisible, setIsVisible] = useState(false)

  useEffect(() => {
    const handleScroll = () => setIsVisible(window.scrollY > threshold)

    window.addEventListener('scroll', handleScroll, { passive: true })
    handleScroll()
    return () => window.removeEventListener('scroll', handleScroll)
  }, [threshold])

  const scrollToTop = () => {
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  if (!isVisible) return null

  return (
    <button
      onClick={scrollToTop}
      aria-label="Scroll to top"
      id="back-to-top-btn"
      className={`group fixed bottom-[calc(9.5rem+env(safe-area-inset-bottom))] right-4 z-40 flex h-11 w-11 items-center justify-center rounded-full border-2 border-primary-foreground/20 bg-primary text-primary-foreground shadow-xl transition-all duration-300 hover:-translate-y-1 hover:bg-primary-dark hover:shadow-2xl active:translate-y-0 sm:bottom-20 sm:right-6 ${className}`}
    >
      <ArrowUp className="w-5 h-5 transition-transform group-hover:-translate-y-0.5" />
    </button>
  )
}
