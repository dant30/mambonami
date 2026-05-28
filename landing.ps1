# landing.ps1
# Run from anywhere, but it will create the landing folder in the same directory as this script.
$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = Get-Location }
$landingRoot = Join-Path $scriptDir "landing"

Write-Host "Creating MAMBONAMI landing website structure in: $landingRoot" -ForegroundColor Green

# Ensure root directory exists
if (-not (Test-Path $landingRoot)) {
    New-Item -ItemType Directory -Path $landingRoot -Force | Out-Null
}

# Helper to create file with content (creates parent dirs automatically)
function Create-File($relativePath, $content) {
    $fullPath = Join-Path $landingRoot $relativePath
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created directory: $dir" -ForegroundColor Cyan
    }
    if (-not (Test-Path $fullPath)) {
        # Use Set-Content with no BOM UTF8
        Set-Content -Path $fullPath -Value $content -Encoding UTF8 -NoNewline
        Write-Host "Created file: $fullPath" -ForegroundColor Yellow
    } else {
        Write-Host "File already exists: $fullPath" -ForegroundColor Gray
    }
}

function Create-Placeholder($relativePath) {
    $fullPath = Join-Path $landingRoot $relativePath
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType File -Path $fullPath -Force | Out-Null
        Write-Host "Created placeholder: $fullPath" -ForegroundColor Yellow
    }
}

# Create directory structure
$directories = @(
    "public\assets\icons",
    "public\assets\fonts",
    "src\components\ui",
    "src\components\sections",
    "src\pages",
    "src\layouts",
    "src\styles"
)

foreach ($dir in $directories) {
    $fullPath = Join-Path $landingRoot $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "Created: $fullPath" -ForegroundColor Cyan
    }
}

# Now create all files (same content as before, but using Create-File)
Create-File "index.html" @'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/png" href="/assets/icons/favicon.png" />
    <link rel="manifest" href="/manifest.json" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>MAMBONAMI – Fresh from Farm to Table</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
'@

Create-File "package.json" @'
{
  "name": "mambonami-landing",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.23.0"
  },
  "devDependencies": {
    "@types/react": "^18.3.2",
    "@types/react-dom": "^18.3.0",
    "@vitejs/plugin-react": "^4.2.1",
    "autoprefixer": "^10.4.19",
    "postcss": "^8.4.38",
    "tailwindcss": "^3.4.3",
    "typescript": "^5.4.5",
    "vite": "^5.2.11"
  }
}
'@

Create-File "tsconfig.json" @'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
'@

Create-File "tsconfig.node.json" @'
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true,
    "strict": true
  },
  "include": ["vite.config.ts"]
}
'@

Create-File "tailwind.config.js" @'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#2E7D32',
        secondary: '#FFA000',
      },
    },
  },
  plugins: [],
}
'@

Create-File "postcss.config.js" @'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
'@

Create-File "vite.config.ts" @'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
  },
})
'@

Create-File ".env.example" @'
VITE_APP_NAME=MAMBONAMI
VITE_CONTACT_EMAIL=hello@mambonami.com
'@

# Public folder files
Create-File "public/manifest.json" @'
{
  "name": "MAMBONAMI",
  "short_name": "MAMBONAMI",
  "description": "Fresh farm produce delivered to your doorstep",
  "start_url": "/",
  "display": "standalone",
  "theme_color": "#2E7D32",
  "background_color": "#ffffff",
  "icons": [
    {
      "src": "/assets/icons/logo192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/assets/icons/logo512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
'@

Create-File "public/service-worker.js" @'
// Simple service worker for offline capability
const CACHE_NAME = 'mambonami-cache-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/offline.html'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => response || fetch(event.request))
      .catch(() => caches.match('/offline.html'))
  );
});
'@

Create-File "public/offline.html" @'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Offline - MAMBONAMI</title>
  <style>
    body { font-family: system-ui; text-align: center; padding: 2rem; }
    h1 { color: #2E7D32; }
  </style>
</head>
<body>
  <h1>You are offline</h1>
  <p>Please check your internet connection and try again.</p>
</body>
</html>
'@

# Placeholder icons
Create-Placeholder "public/assets/icons/.gitkeep"
Create-Placeholder "public/assets/icons/favicon.png"
Create-Placeholder "public/assets/icons/logo192.png"
Create-Placeholder "public/assets/icons/logo512.png"

# Styles
Create-File "src/styles/global.css" @'
@import './variables.css';
@import './components.css';
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html {
    scroll-behavior: smooth;
  }
  body {
    @apply bg-gray-50 text-gray-900;
  }
}
'@

Create-File "src/styles/variables.css" @'
:root {
  --color-primary: #2E7D32;
  --color-primary-dark: #1B5E20;
  --color-secondary: #FFA000;
  --color-secondary-dark: #FF8F00;
  --font-sans: 'Inter', system-ui, -apple-system, sans-serif;
}
'@

Create-File "src/styles/components.css" @'
/* Custom component styles */
.btn-primary {
  @apply bg-primary text-white px-6 py-3 rounded-lg font-semibold hover:bg-primary-dark transition-colors;
}
.btn-secondary {
  @apply bg-secondary text-white px-6 py-3 rounded-lg font-semibold hover:bg-secondary-dark transition-colors;
}
.container-custom {
  @apply container mx-auto px-4 sm:px-6 lg:px-8;
}
'@

# Main entry
Create-File "src/main.tsx" @'
import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App'
import './styles/global.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>,
)
'@

Create-File "src/App.tsx" @'
import { Routes, Route } from 'react-router-dom'
import MainLayout from './layouts/MainLayout'
import Home from './pages/Home'
import About from './pages/About'
import Services from './pages/Services'
import HowItWorks from './pages/HowItWorks'
import Contact from './pages/Contact'
import PrivacyPolicy from './pages/PrivacyPolicy'
import TermsOfService from './pages/TermsOfService'
import FAQ from './pages/FAQ'

function App() {
  return (
    <Routes>
      <Route path="/" element={<MainLayout />}>
        <Route index element={<Home />} />
        <Route path="about" element={<About />} />
        <Route path="services" element={<Services />} />
        <Route path="how-it-works" element={<HowItWorks />} />
        <Route path="contact" element={<Contact />} />
        <Route path="privacy" element={<PrivacyPolicy />} />
        <Route path="terms" element={<TermsOfService />} />
        <Route path="faq" element={<FAQ />} />
      </Route>
    </Routes>
  )
}

export default App
'@

# Layouts
Create-File "src/layouts/MainLayout.tsx" @'
import { Outlet } from 'react-router-dom'
import Header from '../components/sections/Header'
import Footer from '../components/sections/Footer'
import FloatingButton from '../components/ui/FloatingButton'

function MainLayout() {
  return (
    <div className="min-h-screen flex flex-col">
      <Header />
      <main className="flex-grow">
        <Outlet />
      </main>
      <Footer />
      <FloatingButton />
    </div>
  )
}
export default MainLayout
'@

# Sections
Create-File "src/components/sections/Header.tsx" @'
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
'@

Create-File "src/components/sections/Footer.tsx" @'
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
'@

# UI components
Create-File "src/components/ui/FloatingButton.tsx" @'
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
'@

Create-File "src/components/ui/Button.tsx" @'
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline'
  size?: 'sm' | 'md' | 'lg'
  children: React.ReactNode
}

const Button = ({ variant = 'primary', size = 'md', children, className = '', ...props }: ButtonProps) => {
  const baseClasses = 'rounded-lg font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2'
  const variants = {
    primary: 'bg-primary text-white hover:bg-primary-dark focus:ring-primary',
    secondary: 'bg-secondary text-white hover:bg-secondary-dark focus:ring-secondary',
    outline: 'border border-primary text-primary hover:bg-primary hover:text-white focus:ring-primary'
  }
  const sizes = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-6 py-3 text-base',
    lg: 'px-8 py-4 text-lg'
  }
  return (
    <button className={`${baseClasses} ${variants[variant]} ${sizes[size]} ${className}`} {...props}>
      {children}
    </button>
  )
}
export default Button
'@

Create-File "src/components/ui/Card.tsx" @'
interface CardProps {
  children: React.ReactNode
  className?: string
  title?: string
}

const Card = ({ children, className = '', title }: CardProps) => {
  return (
    <div className={`bg-white rounded-xl shadow-md overflow-hidden hover:shadow-lg transition-shadow ${className}`}>
      {title && (
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-xl font-semibold text-gray-800">{title}</h3>
        </div>
      )}
      <div className="p-6">{children}</div>
    </div>
  )
}
export default Card
'@

Create-File "src/components/ui/Hero.tsx" @'
interface HeroProps {
  title: string
  subtitle: string
  ctaText?: string
  ctaLink?: string
  backgroundImage?: string
}

const Hero = ({ title, subtitle, ctaText, ctaLink, backgroundImage }: HeroProps) => {
  return (
    <section className={`bg-primary text-white py-20 ${backgroundImage ? 'bg-cover bg-center' : ''}`} style={backgroundImage ? { backgroundImage: `url(${backgroundImage})` } : {}}>
      <div className="container-custom text-center">
        <h1 className="text-4xl md:text-6xl font-bold mb-4">{title}</h1>
        <p className="text-xl md:text-2xl mb-8 opacity-90">{subtitle}</p>
        {ctaText && ctaLink && (
          <a href={ctaLink} className="bg-white text-primary px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition">
            {ctaText}
          </a>
        )}
      </div>
    </section>
  )
}
export default Hero
'@

Create-File "src/components/ui/FeatureCard.tsx" @'
import { ReactNode } from 'react'

interface FeatureCardProps {
  icon: ReactNode
  title: string
  description: string
}

const FeatureCard = ({ icon, title, description }: FeatureCardProps) => {
  return (
    <div className="text-center p-6">
      <div className="text-primary flex justify-center mb-4">{icon}</div>
      <h3 className="text-xl font-semibold mb-2">{title}</h3>
      <p className="text-gray-600">{description}</p>
    </div>
  )
}
export default FeatureCard
'@

# Pages
Create-File "src/pages/Home.tsx" @'
import Hero from '../components/ui/Hero'
import FeatureCard from '../components/ui/FeatureCard'
import Card from '../components/ui/Card'
import Button from '../components/ui/Button'

export default function Home() {
  return (
    <div>
      <Hero
        title="Fresh from Farm to Table"
        subtitle="Connect directly with farmers, get the freshest produce delivered to your doorstep"
        ctaText="Get Started"
        ctaLink="/contact"
      />
      <section className="py-16 container-custom">
        <h2 className="text-3xl font-bold text-center mb-12">Why MAMBONAMI?</h2>
        <div className="grid md:grid-cols-3 gap-8">
          <FeatureCard icon="🌱" title="For Farmers" description="Fair prices, direct access to markets, no middlemen." />
          <FeatureCard icon="🛒" title="For Buyers" description="Fresh produce, transparent pricing, doorstep delivery." />
          <FeatureCard icon="🚚" title="For Transporters" description="Earn by delivering farm fresh goods." />
        </div>
      </section>
      <section className="bg-gray-100 py-16">
        <div className="container-custom text-center">
          <Card title="Ready to experience fresh produce?" className="max-w-2xl mx-auto">
            <p className="mb-6">Join MAMBONAMI today and enjoy farm-fresh goodness delivered to your home.</p>
            <Button variant="primary" size="lg">Download App</Button>
          </Card>
        </div>
      </section>
    </div>
  )
}
'@

Create-File "src/pages/About.tsx" @'
export default function About() {
  return (
    <div className="container-custom py-16">
      <h1 className="text-4xl font-bold mb-6">About MAMBONAMI</h1>
      <p className="text-lg text-gray-600 mb-4">MAMBONAMI was founded with a mission to connect farmers directly with consumers and retailers, eliminating exploitative middlemen and ensuring fresh, affordable produce reaches every table.</p>
      <p className="text-lg text-gray-600">We believe in fair trade, transparency, and empowering local farmers.</p>
    </div>
  )
}
'@

Create-File "src/pages/Services.tsx" @'
export default function Services() {
  return (
    <div className="container-custom py-16">
      <h1 className="text-4xl font-bold mb-6">Our Services</h1>
      <ul className="list-disc pl-6 space-y-2 text-gray-600">
        <li>Farmer onboarding & cooperative verification</li>
        <li>Product listing & order management</li>
        <li>Logistics coordination with trusted transporters</li>
        <li>Secure escrow payments via M-Pesa</li>
        <li>Dispute resolution & customer support</li>
      </ul>
    </div>
  )
}
'@

Create-File "src/pages/HowItWorks.tsx" @'
export default function HowItWorks() {
  return (
    <div className="container-custom py-16">
      <h1 className="text-4xl font-bold mb-6">How It Works</h1>
      <ol className="list-decimal pl-6 space-y-4 text-gray-600">
        <li>Farmers list their products with harvest date and GPS location.</li>
        <li>Buyers browse, add to cart, and pay via M-Pesa PayBill.</li>
        <li>Funds are held in escrow until delivery.</li>
        <li>Transporters accept the job, pick up from farm, and deliver.</li>
        <li>Buyer confirms delivery with OTP, funds released to farmer & transporter.</li>
      </ol>
    </div>
  )
}
'@

Create-File "src/pages/Contact.tsx" @'
export default function Contact() {
  return (
    <div className="container-custom py-16">
      <h1 className="text-4xl font-bold mb-6">Contact Us</h1>
      <p className="text-gray-600 mb-4">Email: hello@mambonami.com</p>
      <p className="text-gray-600">Phone: +254 700 000 000</p>
    </div>
  )
}
'@

Create-File "src/pages/PrivacyPolicy.tsx" @'
export default function PrivacyPolicy() {
  return (
    <div className="container-custom py-16 prose max-w-none">
      <h1>Privacy Policy</h1>
      <p>Last updated: May 2025</p>
      <p>We value your privacy. This policy explains how we collect, use, and protect your information.</p>
    </div>
  )
}
'@

Create-File "src/pages/TermsOfService.tsx" @'
export default function TermsOfService() {
  return (
    <div className="container-custom py-16 prose max-w-none">
      <h1>Terms of Service</h1>
      <p>By using MAMBONAMI, you agree to these terms.</p>
    </div>
  )
}
'@

Create-File "src/pages/FAQ.tsx" @'
import { useState } from 'react'

const faqs = [
  { q: "How do I register as a farmer?", a: "Download the app, select 'Farmer' role, verify phone, submit cooperative endorsement (or waiver), and start listing products." },
  { q: "How are payments secured?", a: "Payments go into M-Pesa PayBill escrow and are released only after delivery confirmation." },
  { q: "What if I receive damaged goods?", a: "You have 2 hours to raise a dispute with photo evidence. We will review and issue a partial refund if valid." },
]

export default function FAQ() {
  const [open, setOpen] = useState<number | null>(null)
  return (
    <div className="container-custom py-16">
      <h1 className="text-4xl font-bold mb-8 text-center">Frequently Asked Questions</h1>
      <div className="max-w-3xl mx-auto space-y-4">
        {faqs.map((faq, idx) => (
          <div key={idx} className="border rounded-lg">
            <button className="w-full text-left p-4 font-semibold flex justify-between items-center" onClick={() => setOpen(open === idx ? null : idx)}>
              {faq.q}
              <span>{open === idx ? '−' : '+'}</span>
            </button>
            {open === idx && <div className="p-4 pt-0 text-gray-600">{faq.a}</div>}
          </div>
        ))}
      </div>
    </div>
  )
}
'@

Create-Placeholder "public/assets/fonts/.gitkeep"

Write-Host "`n✅ Complete landing website structure created successfully in $landingRoot" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Magenta
Write-Host "1. cd landing" -ForegroundColor Yellow
Write-Host "2. npm install" -ForegroundColor Yellow
Write-Host "3. npm run dev" -ForegroundColor Yellow
Write-Host "4. Open http://localhost:3000" -ForegroundColor Yellow
Write-Host "`nNote: Replace placeholder icons in 'public/assets/icons/' with your actual images." -ForegroundColor Cyan