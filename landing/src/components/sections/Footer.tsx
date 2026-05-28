import { Link } from 'react-router-dom'

const Footer = () => {
  return (
    <footer className="bg-gray-800 text-white py-8">
      <div className="container-custom text-center">
        <p>&copy; {new Date().getFullYear()} MAMBONAMI. All rights reserved.</p>
        <div className="mt-2 space-x-4">
          <Link to="/privacy" className="hover:underline">Privacy</Link>
          <Link to="/terms" className="hover:underline">Terms</Link>
          <Link to="/contact" className="hover:underline">Contact</Link>
        </div>
      </div>
    </footer>
  )
}

export default Footer