import { useState } from 'react'

const FloatingButton = () => {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <div className="fixed bottom-6 right-6 z-50">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="bg-primary text-white p-4 rounded-full shadow-lg hover:bg-primary-dark transition-all"
      >
        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      </button>
      {isOpen && (
        <div className="absolute bottom-16 right-0 bg-white rounded-lg shadow-lg p-4 w-48">
          <ul className="space-y-2">
            <li><a href="/contact" className="block hover:text-primary">Contact Support</a></li>
            <li><a href="/faq" className="block hover:text-primary">FAQ</a></li>
            <li><a href="/how-it-works" className="block hover:text-primary">How It Works</a></li>
          </ul>
        </div>
      )}
    </div>
  )
}

export default FloatingButton