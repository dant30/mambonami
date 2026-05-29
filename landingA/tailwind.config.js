/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#2E7D32',
          dark: '#1B5E20'
        },
        secondary: {
          DEFAULT: '#FFA000',
          dark: '#FF8F00'
        },
      },
    },
  },
  plugins: [],
}