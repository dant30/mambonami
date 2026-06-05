import type { Config } from 'tailwindcss';

export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  darkMode: 'class',
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
        sidebar: 'var(--sidebar)',
        'sidebar-foreground': 'var(--sidebar-foreground)',
        'sidebar-primary': 'var(--sidebar-primary)',
        'sidebar-primary-foreground': 'var(--sidebar-primary-foreground)',
        'sidebar-accent': 'var(--sidebar-accent)',
        'sidebar-accent-foreground': 'var(--sidebar-accent-foreground)',
        'sidebar-border': 'var(--sidebar-border)',
        'sidebar-ring': 'var(--sidebar-ring)',
      },
      borderRadius: {
        DEFAULT: 'var(--radius)',
      },
      fontFamily: {
        display: ['Fraunces', 'Georgia', 'serif'],
        sans: ['Inter', 'system-ui', 'sans-serif'],
        body: ['Inter', 'system-ui', 'sans-serif'],
      },
      animation: {
        float: 'float 4s ease-in-out infinite',
        'fade-in-up': 'fade-in-up 0.7s ease-out both',
        'fade-in': 'fade-in 0.4s ease-out both',
        'ping-slow': 'ping-slow 2.2s cubic-bezier(0,0,0.2,1) infinite',
        marquee: 'marquee 30s linear infinite',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-8px)' },
        },
        'fade-in-up': {
          'from': { opacity: '0', transform: 'translateY(24px)' },
          'to': { opacity: '1', transform: 'translateY(0)' },
        },
        'fade-in': {
          'from': { opacity: '0', transform: 'translateY(6px)' },
          'to': { opacity: '1', transform: 'translateY(0)' },
        },
        'ping-slow': {
          '0%': { transform: 'scale(1)', opacity: '0.6' },
          '80%, 100%': { transform: 'scale(1.8)', opacity: '0' },
        },
        'marquee': {
          'from': { transform: 'translateX(0)' },
          'to': { transform: 'translateX(-50%)' },
        },
      },
      boxShadow: {
        soft: 'var(--shadow-soft)',
        glow: 'var(--shadow-glow)',
        card: '0 24px 54px rgba(15, 23, 42, 0.08)',
      },
    },
  },
  plugins: [],
} satisfies Config;