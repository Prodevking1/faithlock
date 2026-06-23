import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './lib/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        // Deep indigo - trust, spirituality, depth
        brand: {
          50: '#eef2ff',
          100: '#e0e7ff',
          200: '#c7d2fe',
          300: '#a5b4fc',
          400: '#818cf8',
          500: '#6366f1',
          600: '#4f46e5',
          700: '#4338ca',
          800: '#3730a3',
          900: '#312e81',
          950: '#1e1b4b',
        },
        // Warm amber/gold - faith, warmth, light
        warm: {
          50: '#fffbeb',
          100: '#fef3c7',
          200: '#fde68a',
          300: '#fcd34d',
          400: '#fbbf24',
          500: '#f59e0b',
          600: '#d97706',
          700: '#b45309',
          800: '#92400e',
          900: '#78350f',
        },
        // Sage green - hope, growth
        sage: {
          50: '#f0fdf4',
          100: '#dcfce7',
          200: '#bbf7d0',
          300: '#86efac',
          400: '#4ade80',
          500: '#22c55e',
          600: '#16a34a',
          700: '#15803d',
          800: '#166534',
          900: '#14532d',
        },
        // Dark slate (landing page)
        slate: {
          850: '#151e2e',
        },
        // ── Cozy design system (blog/resources) ──
        // Mirrors the Flutter CozyColors palette: warm/chunky, terracotta-led.
        cozy: {
          primary: '#D68A4E', // terracotta — CTAs, active states
          'primary-dark': '#C0763C',
          'primary-light': '#E8B488',
          gold: '#C9A962', // warm gold accent
          peach: '#F3D9BE', // pastel chip fill
          sage: '#CFDDC3', // pastel chip fill
          cream: '#FBF3E2', // page canvas
          surface: '#FFFDF8', // card / elevated surface
          'surface-muted': '#F3E7CE', // subtle beige surface
          beige: '#E8DCC4',
          ink: '#3D2B1F', // warm brown text + signature outline
          'ink-muted': '#9C8773',
          border: '#EAD9BC',
          divider: '#EFE3CC',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
        serif: ['Georgia', 'Cambria', 'serif'],
        display: ['Inter', 'system-ui', 'sans-serif'],
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        'hero-pattern': 'linear-gradient(135deg, #1e1b4b 0%, #312e81 50%, #4338ca 100%)',
        'cta-gradient': 'linear-gradient(135deg, #4f46e5 0%, #7c3aed 50%, #6366f1 100%)',
        'warm-gradient': 'linear-gradient(135deg, #fef3c7 0%, #fde68a 50%, #fcd34d 100%)',
      },
      animation: {
        'fade-in': 'fadeIn 0.6s ease-out',
        'slide-up': 'slideUp 0.6s ease-out',
        'float': 'float 8s ease-in-out infinite',
        'float-delayed': 'float 8s ease-in-out 4s infinite',
        'pulse-slow': 'pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'slide-hint': 'slideHint 3s ease-in-out infinite',
        'typewriter': 'blink 1s step-end infinite',
        'glow-pulse': 'glowPulse 2s ease-in-out infinite alternate',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-20px)' },
        },
        slideHint: {
          '0%, 100%': { transform: 'translateX(0)', opacity: '0.5' },
          '50%': { transform: 'translateX(10px)', opacity: '1' },
        },
        blink: {
          '0%, 100%': { opacity: '1' },
          '50%': { opacity: '0' },
        },
        glowPulse: {
          from: { boxShadow: '0 0 10px rgba(99, 102, 241, 0.2)' },
          to: { boxShadow: '0 0 20px rgba(99, 102, 241, 0.6)' },
        },
      },
      boxShadow: {
        'soft': '0 2px 15px -3px rgba(0, 0, 0, 0.07), 0 10px 20px -2px rgba(0, 0, 0, 0.04)',
        'glow': '0 0 20px rgba(99, 102, 241, 0.15)',
        'card': '0 1px 3px rgba(0,0,0,0.05), 0 20px 25px -5px rgba(0,0,0,0.05), 0 10px 10px -5px rgba(0,0,0,0.02)',
        // Cozy "lifted sticker" — solid offset shadow, no blur (Flutter shadowHard)
        'cozy-hard': '3px 5px 0 0 #3D2B1F',
        'cozy-hard-sm': '2px 3px 0 0 #3D2B1F',
        'cozy-hard-lg': '5px 7px 0 0 #3D2B1F',
        'cozy-soft': '0 6px 16px rgba(61, 43, 31, 0.06)',
      },
      borderRadius: {
        '2xl': '1rem',
        '3xl': '1.5rem',
        // Cozy generous squircle-ish radii (Flutter CozyTokens)
        'cozy-sm': '16px',
        'cozy': '22px',
        'cozy-lg': '32px',
      },
    },
  },
  plugins: [],
}

export default config
