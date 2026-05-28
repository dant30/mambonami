import { useState } from 'react'
import { Link } from 'react-router-dom'

const Header = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false)

  return (
    <header className="bg-white shadow-md sticky top-0 z-50">
      <div className="container-custom py-4 flex justify-between items-center">
        <Link to="/" className="text-2xl font-bold text-primary">MAMBONAMI</Link>
        
        <nav className="hidden md:flex space-x-6">
          <NavLinks />
        </nav>

        <button className="md:hidden" onClick={() => setIsMenuOpen(!isMenuOpen)}>
          <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
      </div>

      {isMenuOpen && (
        <div className="md:hidden bg-white border-t py-4">
          <nav className="flex flex-col space-y-3 container-custom">
            <NavLinks onClick={() => setIsMenuOpen(false)} />
          </nav>
        </div>
      )}
    </header>
  )
}

const NavLinks = ({ onClick }: { onClick?: () => void }) => (
  <>
    <Link to="/" onClick={onClick} className="hover:text-primary transition">Home</Link>
    <Link to="/about" onClick={onClick} className="hover:text-primary transition">About</Link>
    <Link to="/services" onClick={onClick} className="hover:text-primary transition">Services</Link>
    <Link to="/how-it-works" onClick={onClick} className="hover:text-primary transition">How It Works</Link>
    <Link to="/faq" onClick={onClick} className="hover:text-primary transition">FAQ</Link>
    <Link to="/contact" onClick={onClick} className="hover:text-primary transition">Contact</Link>
  </>
)

export default Header