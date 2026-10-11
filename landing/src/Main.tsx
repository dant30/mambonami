import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'

import { App } from './App'
import './index.css'

const root = document.getElementById('root')
if (!root) throw new Error('The application root element is missing.')

createRoot(root).render(
	<StrictMode>
		<App />
	</StrictMode>,
)

if (import.meta.env.PROD && 'serviceWorker' in navigator) {
	window.addEventListener('load', () => {
		navigator.serviceWorker.register('/service-worker.js').catch((error: unknown) => {
			console.error('Service worker registration failed:', error)
		})
	}, { once: true })
}
