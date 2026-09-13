import type { Config } from 'tailwindcss'

const config: Config = {
	darkMode: 'class',
	content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
	theme: {
		extend: {
			colors: {
				background: 'var(--background)',
				foreground: 'var(--foreground)',
				card: 'var(--card)',
				'card-foreground': 'var(--card-foreground)',
				popover: 'var(--popover)',
				'popover-foreground': 'var(--popover-foreground)',
				primary: 'var(--primary)',
				'primary-foreground': 'var(--primary-foreground)',
				'primary-dark': 'var(--primary-dark)',
				secondary: 'var(--secondary)',
				'secondary-foreground': 'var(--secondary-foreground)',
				muted: 'var(--muted)',
				'muted-foreground': 'var(--muted-foreground)',
				accent: 'var(--accent)',
				'accent-foreground': 'var(--accent-foreground)',
				destructive: 'var(--destructive)',
				'destructive-foreground': 'var(--destructive-foreground)',
				border: 'var(--border)',
				input: 'var(--input)',
				ring: 'var(--ring)',
			},
			fontFamily: {
				display: ['Fraunces', 'Georgia', 'serif'],
				sans: ['Space Grotesk', 'system-ui', 'sans-serif'],
			},
			backgroundImage: {
				'gradient-hero': 'var(--gradient-hero)',
				'gradient-warm': 'var(--gradient-warm)',
			},
			boxShadow: {
				soft: 'var(--shadow-soft)',
				glow: 'var(--shadow-glow)',
			},
			borderRadius: {
				'sm': 'var(--radius-sm)',
				md: 'var(--radius-md)',
				lg: 'var(--radius-lg)',
				xl: 'var(--radius-xl)',
				'2xl': 'var(--radius-2xl)',
				'3xl': 'var(--radius-3xl)',
			},
		},
	},
	plugins: [],
}

export default config
