import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig(({ mode }) => {
	const env = loadEnv(mode, '.', '')
	const apiTarget = env.VITE_API_PROXY_TARGET || 'http://127.0.0.1:8001'

	return {
		plugins: [react()],
		resolve: {
			alias: {
				'@': new URL('./src', import.meta.url).pathname,
			},
		},
		server: {
			port: 5173,
			strictPort: false,
			proxy: {
				'/api': { target: apiTarget, changeOrigin: true, secure: false, ws: true },
				'/admin-api': { target: apiTarget, changeOrigin: true, secure: false },
			},
		},
		build: {
			target: 'es2020',
			sourcemap: true,
		},
	}
})
