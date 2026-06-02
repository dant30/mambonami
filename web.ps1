# web.ps1
# Run this script from the 'mambonami' directory.
# It creates the complete web dashboard structure with placeholder files.

$webRoot = ".\web"

Write-Host "Creating web dashboard structure under $webRoot ..." -ForegroundColor Green

# ----- Define all directories to create (relative to $webRoot) -----
$directories = @(
    "public\icons",
    "src\styles",
    "src\core\api",
    "src\core\context",
    "src\core\hooks",
    "src\core\utils",
    "src\core\locale",
    "src\core\storage",
    "src\core\types",
    "src\router",
    "src\features\auth\pages",
    "src\features\auth\services",
    "src\features\auth\types",
    "src\features\auth\hooks",
    "src\features\auth\stores",
    "src\features\orders\pages",
    "src\features\orders\services",
    "src\features\orders\types",
    "src\features\orders\hooks",
    "src\features\orders\stores",
    "src\features\products\pages",
    "src\features\products\services",
    "src\features\products\types",
    "src\features\products\hooks",
    "src\features\products\stores",
    "src\features\transport\pages",
    "src\features\transport\services",
    "src\features\transport\types",
    "src\features\transport\hooks",
    "src\features\transport\stores",
    "src\features\disputes\pages",
    "src\features\disputes\services",
    "src\features\disputes\types",
    "src\features\disputes\hooks",
    "src\features\disputes\stores",
    "src\features\payouts\pages",
    "src\features\payouts\services",
    "src\features\payouts\types",
    "src\features\payouts\hooks",
    "src\features\payouts\stores",
    "src\features\analytics\pages",
    "src\features\analytics\services",
    "src\features\analytics\types",
    "src\features\analytics\hooks",
    "src\features\analytics\stores",
    "src\features\admin\pages",
    "src\features\admin\services",
    "src\features\admin\types",
    "src\features\admin\hooks",
    "src\features\admin\stores",
    "src\features\retailer\pages",
    "src\features\retailer\services",
    "src\features\retailer\types",
    "src\features\retailer\hooks",
    "src\features\retailer\stores",
    "src\features\not-found",
    "src\shared\components\ui",
    "src\shared\components\tables",
    "src\shared\components\charts",
    "src\shared\components\forms",
    "src\shared\layout"
)

# Create directories
foreach ($dir in $directories) {
    $fullPath = Join-Path $webRoot $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "Created: $fullPath" -ForegroundColor Cyan
    } else {
        Write-Host "Already exists: $fullPath" -ForegroundColor Gray
    }
}

# ----- Helper function to create file with placeholder content -----
function Create-File($relativePath, $content) {
    $fullPath = Join-Path $webRoot $relativePath
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    if (-not (Test-Path $fullPath)) {
        Set-Content -Path $fullPath -Value $content -Encoding utf8
        Write-Host "Created file: $fullPath" -ForegroundColor Yellow
    } else {
        Write-Host "File already exists: $fullPath" -ForegroundColor Gray
    }
}

# ----- Root configuration files -----
Create-File "package.json" @"
{
  "name": "mambonami-web",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "test": "vitest",
    "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0",
    "axios": "^1.6.0",
    "zustand": "^4.4.0",
    "react-query": "^3.39.0",
    "date-fns": "^2.30.0",
    "recharts": "^2.9.0",
    "react-hook-form": "^7.47.0",
    "zod": "^3.22.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "@vitejs/plugin-react": "^4.0.0",
    "autoprefixer": "^10.4.0",
    "eslint": "^8.45.0",
    "postcss": "^8.4.0",
    "tailwindcss": "^3.3.0",
    "typescript": "^5.0.0",
    "vite": "^4.4.0",
    "vitest": "^0.34.0"
  }
}
"@

# 🔁 REMOVED: Create-File "pnpm-lock.yaml" "# placeholder"   (now removed)

Create-File ".env.example" @"
VITE_API_BASE_URL=http://localhost:8001
VITE_WS_URL=ws://localhost:8001/ws
"@

Create-File ".prettierrc" @"
{
  "singleQuote": true,
  "trailingComma": "all",
  "tabWidth": 2,
  "semi": true
}
"@

Create-File ".eslintrc.js" @"
module.exports = {
  env: { browser: true, es2020: true },
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react-hooks/recommended',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: { ecmaVersion: 'latest', sourceType: 'module' },
  plugins: ['react-refresh'],
  rules: {
    'react-refresh/only-export-components': 'warn',
  },
};
"@

Create-File "vitest.config.ts" @"
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
  },
});
"@

Create-File "babel.config.js" @"
module.exports = {
  presets: [
    '@babel/preset-env',
    ['@babel/preset-react', { runtime: 'automatic' }],
    '@babel/preset-typescript',
  ],
};
"@

Create-File "index.html" @"
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/png" href="/icons/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>MAMBONAMI Dashboard</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
"@

Create-File "tsconfig.json" @"
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
"@

Create-File "tsconfig.node.json" @"
{
  "compilerOptions": {
    "composite": true,
    "skipLibCheck": true,
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowSyntheticDefaultImports": true
  },
  "include": ["vite.config.ts"]
}
"@

Create-File "tailwind.config.ts" @"
import type { Config } from 'tailwindcss';

export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {},
  },
  plugins: [],
} satisfies Config;
"@

Create-File "postcss.config.js" @"
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
"@

# ----- Added: Dockerfile -----
Create-File "Dockerfile" @"
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install
COPY . .
RUN pnpm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
"@

# ----- Added: vite.config.ts -----
Create-File "vite.config.ts" @"
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8001',
        changeOrigin: true,
      },
    },
  },
  build: {
    outDir: 'dist',
  },
});
"@

# ----- Public files -----
Create-File "public\manifest.json" @"
{
  "name": "MAMBONAMI",
  "short_name": "MAMBONAMI",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "icons": [
    { "src": "icons/logo192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "icons/logo512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
"@

Create-File "public\service-worker.js" "// Placeholder service worker"
Create-File "public\offline.html" "<!DOCTYPE html><html><head><title>Offline</title></head><body><h1>You are offline</h1></body></html>"

# Placeholder icons (empty files – user must add real images)
Create-File "public\icons\favicon.ico" ""
Create-File "public\icons\logo192.png" ""
Create-File "public\icons\logo512.png" ""

# ----- src root files -----
Create-File "src\main.tsx" @"
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
"@

Create-File "src\App.tsx" @"
import { BrowserRouter } from 'react-router-dom';
import AppRouter from './router';
import { AuthProvider } from './core/context/AuthContext';
import { ThemeProvider } from './core/context/ThemeContext';

function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <BrowserRouter>
          <AppRouter />
        </BrowserRouter>
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;
"@

Create-File "src\index.css" @"
@tailwind base;
@tailwind components;
@tailwind utilities;
"@

# ----- styles -----
Create-File "src\styles\global.css" "/* Global styles */"
Create-File "src\styles\variables.css" "/* CSS variables */"
Create-File "src\styles\animations.css" "/* Animations */"
Create-File "src\styles\components.css" "/* Component styles */"

# ----- core/api -----
Create-File "src\core\api\endpoints.ts" "export const API_BASE = import.meta.env.VITE_API_BASE_URL;"
Create-File "src\core\api\client.ts" @"
import axios from 'axios';
import { API_BASE } from './endpoints';

export const apiClient = axios.create({
  baseURL: API_BASE,
  headers: { 'Content-Type': 'application/json' },
});

apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('access_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});
"@
Create-File "src\core\api\types.ts" "// API response types"

# ----- core/context -----
Create-File "src\core\context\ThemeContext.tsx" @"
import React, { createContext, useState, useContext } from 'react';

type Theme = 'light' | 'dark';
interface ThemeContextType {
  theme: Theme;
  toggleTheme: () => void;
}
const ThemeContext = createContext<ThemeContextType | undefined>(undefined);
export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [theme, setTheme] = useState<Theme>('light');
  const toggleTheme = () => setTheme(theme === 'light' ? 'dark' : 'light');
  return <ThemeContext.Provider value={{ theme, toggleTheme }}>{children}</ThemeContext.Provider>;
};
export const useTheme = () => { const ctx = useContext(ThemeContext); if (!ctx) throw new Error('useTheme must be used within ThemeProvider'); return ctx; };
"@

Create-File "src\core\context\AuthContext.tsx" @"
import React, { createContext, useState, useContext } from 'react';

interface AuthContextType {
  user: any;
  login: (token: string) => void;
  logout: () => void;
}
const AuthContext = createContext<AuthContextType | undefined>(undefined);
export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState(null);
  const login = (token: string) => { localStorage.setItem('access_token', token); };
  const logout = () => { localStorage.removeItem('access_token'); setUser(null); };
  return <AuthContext.Provider value={{ user, login, logout }}>{children}</AuthContext.Provider>;
};
export const useAuth = () => { const ctx = useContext(AuthContext); if (!ctx) throw new Error('useAuth must be used within AuthProvider'); return ctx; };
"@

Create-File "src\core\context\NotificationContext.tsx" @"
import React, { createContext, useContext, useState } from 'react';
interface NotificationContextType { notifications: any[]; addNotification: (msg: string) => void; }
const NotificationContext = createContext<NotificationContextType | undefined>(undefined);
export const NotificationProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [notifications, setNotifications] = useState<any[]>([]);
  const addNotification = (msg: string) => setNotifications([...notifications, { id: Date.now(), message: msg }]);
  return <NotificationContext.Provider value={{ notifications, addNotification }}>{children}</NotificationContext.Provider>;
};
export const useNotification = () => { const ctx = useContext(NotificationContext); if (!ctx) throw new Error('useNotification must be used within NotificationProvider'); return ctx; };
"@

# ----- core/hooks -----
Create-File "src\core\hooks\useAuth.ts" @"
import { useContext } from 'react';
import { AuthContext } from '../context/AuthContext';
export const useAuth = () => useContext(AuthContext);
"@
Create-File "src\core\hooks\useLocalStorage.ts" @"
import { useState } from 'react';
export function useLocalStorage<T>(key: string, initialValue: T): [T, (value: T) => void] {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try { const item = window.localStorage.getItem(key); return item ? JSON.parse(item) : initialValue; } catch { return initialValue; }
  });
  const setValue = (value: T) => { try { setStoredValue(value); window.localStorage.setItem(key, JSON.stringify(value)); } catch {} };
  return [storedValue, setValue];
}
"@
Create-File "src\core\hooks\useDebounce.ts" @"
import { useEffect, useState } from 'react';
export function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => { const handler = setTimeout(() => setDebounced(value), delay); return () => clearTimeout(handler); }, [value, delay]);
  return debounced;
}
"@
Create-File "src\core\hooks\useWebSocket.ts" @"
import { useEffect, useRef, useState } from 'react';
export const useWebSocket = (url: string) => {
  const [lastMessage, setLastMessage] = useState<any>(null);
  const ws = useRef<WebSocket | null>(null);
  useEffect(() => {
    ws.current = new WebSocket(url);
    ws.current.onmessage = (event) => setLastMessage(JSON.parse(event.data));
    return () => ws.current?.close();
  }, [url]);
  const send = (data: any) => ws.current?.send(JSON.stringify(data));
  return { lastMessage, send };
};
"@

# ----- core/utils -----
Create-File "src\core\utils\formatters.ts" @"
export const formatCurrency = (amount: number) => `KES ${amount.toLocaleString()}`;
export const formatDate = (date: string) => new Date(date).toLocaleDateString();
"@
Create-File "src\core\utils\validators.ts" @"
export const validatePhone = (phone: string) => /^07[0-9]{8}$/.test(phone);
export const validateEmail = (email: string) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
"@
Create-File "src\core\utils\constants.ts" "export const APP_NAME = 'MAMBONAMI';"

# ----- core/locale -----
Create-File "src\core\locale\en.json" "{}"
Create-File "src\core\locale\sw.json" "{}"

# ----- core/storage -----
Create-File "src\core\storage\index.ts" "export * from './secureStorage';"
Create-File "src\core\storage\secureStorage.ts" @"
export const setToken = (token: string) => localStorage.setItem('access_token', token);
export const getToken = () => localStorage.getItem('access_token');
export const removeToken = () => localStorage.removeItem('access_token');
"@
Create-File "src\core\storage\types.ts" "// storage types"

# ----- core/types -----
$typeFiles = @("user.ts", "order.ts", "product.ts", "trip.ts", "payout.ts", "dispute.ts", "api.ts")
foreach ($file in $typeFiles) {
    Create-File "src\core\types\$file" "// Type definitions for $file"
}

# ----- router -----
Create-File "src\router\index.tsx" @"
import { useRoutes } from 'react-router-dom';
import { publicRoutes } from './public.routes';
import { guardedRoutes } from './guarded.routes';
export default function AppRouter() {
  const isAuthenticated = !!localStorage.getItem('access_token');
  const routes = isAuthenticated ? guardedRoutes : publicRoutes;
  return useRoutes(routes);
}
"@
Create-File "src\router\public.routes.tsx" @"
import { RouteObject } from 'react-router-dom';
import Login from '../features/auth/pages/Login';
import Register from '../features/auth/pages/Register';
import ForgotPassword from '../features/auth/pages/ForgotPassword';

export const publicRoutes: RouteObject[] = [
  { path: '/login', element: <Login /> },
  { path: '/register', element: <Register /> },
  { path: '/forgot-password', element: <ForgotPassword /> },
  { path: '*', element: <Login /> },
];
"@
Create-File "src\router\guarded.routes.tsx" @"
import { RouteObject } from 'react-router-dom';
import MainLayout from '../shared/layout/MainLayout';
import Dashboard from '../features/analytics/pages/Dashboard';
import OrderList from '../features/orders/pages/OrderList';
import ProductList from '../features/products/pages/ProductList';
import ProviderList from '../features/transport/pages/ProviderList';
import DisputeList from '../features/disputes/pages/DisputeList';
import PayoutList from '../features/payouts/pages/PayoutList';
import FarmerApproval from '../features/admin/pages/FarmerApproval';
import AuditLog from '../features/admin/pages/AuditLog';

export const guardedRoutes: RouteObject[] = [
  {
    path: '/',
    element: <MainLayout />,
    children: [
      { index: true, element: <Dashboard /> },
      { path: 'orders', element: <OrderList /> },
      { path: 'products', element: <ProductList /> },
      { path: 'transport', element: <ProviderList /> },
      { path: 'disputes', element: <DisputeList /> },
      { path: 'payouts', element: <PayoutList /> },
      { path: 'admin/farmer-approval', element: <FarmerApproval /> },
      { path: 'admin/audit-log', element: <AuditLog /> },
    ],
  },
];
"@
Create-File "src\router\PublicRoute.tsx" @"
import { Navigate, Outlet } from 'react-router-dom';
export const PublicRoute = () => {
  const token = localStorage.getItem('access_token');
  return token ? <Navigate to="/" replace /> : <Outlet />;
};
"@
Create-File "src\router\GuardedRoute.tsx" @"
import { Navigate, Outlet } from 'react-router-dom';
export const GuardedRoute = () => {
  const token = localStorage.getItem('access_token');
  return token ? <Outlet /> : <Navigate to="/login" replace />;
};
"@

# ----- features/auth pages -----
Create-File "src\features\auth\pages\Login.tsx" @"
import React from 'react';
export default function Login() { return <div>Login Page</div>; }
"@
Create-File "src\features\auth\pages\Register.tsx" "export default function Register() { return <div>Register Page</div>; }"
Create-File "src\features\auth\pages\ForgotPassword.tsx" "export default function ForgotPassword() { return <div>Forgot Password</div>; }"
Create-File "src\features\auth\pages\Profile.tsx" "export default function Profile() { return <div>Profile</div>; }"
Create-File "src\features\auth\services\authService.ts" "// Auth API service"
Create-File "src\features\auth\types\index.ts" "// Auth types"
Create-File "src\features\auth\hooks\useAuthForm.ts" "// useAuthForm hook"
Create-File "src\features\auth\stores\authStore.ts" "// Zustand store for auth"

# ----- features/orders -----
Create-File "src\features\orders\pages\OrderList.tsx" "export default function OrderList() { return <div>Order List</div>; }"
Create-File "src\features\orders\pages\OrderDetail.tsx" "export default function OrderDetail() { return <div>Order Detail</div>; }"
Create-File "src\features\orders\pages\CreateOrder.tsx" "export default function CreateOrder() { return <div>Create Order</div>; }"
Create-File "src\features\orders\services\orderService.ts" "// Order service"
Create-File "src\features\orders\types\index.ts" "// Order types"
Create-File "src\features\orders\hooks\useOrders.ts" "// useOrders hook"
Create-File "src\features\orders\hooks\useOrderStatus.ts" "// useOrderStatus hook"
Create-File "src\features\orders\stores\orderStore.ts" "// Order store"

# ----- features/products -----
Create-File "src\features\products\pages\ProductList.tsx" "export default function ProductList() { return <div>Product List</div>; }"
Create-File "src\features\products\pages\ProductDetail.tsx" "export default function ProductDetail() { return <div>Product Detail</div>; }"
Create-File "src\features\products\pages\ProductCreate.tsx" "export default function ProductCreate() { return <div>Create Product</div>; }"
Create-File "src\features\products\pages\ProductEdit.tsx" "export default function ProductEdit() { return <div>Edit Product</div>; }"
Create-File "src\features\products\services\productService.ts" "// Product service"
Create-File "src\features\products\types\index.ts" "// Product types"
Create-File "src\features\products\hooks\useProducts.ts" "// useProducts"
Create-File "src\features\products\stores\productStore.ts" "// Product store"

# ----- features/transport -----
Create-File "src\features\transport\pages\ProviderList.tsx" "export default function ProviderList() { return <div>Transport Providers</div>; }"
Create-File "src\features\transport\pages\ProviderDetail.tsx" "export default function ProviderDetail() { return <div>Provider Detail</div>; }"
Create-File "src\features\transport\pages\ProviderApproval.tsx" "export default function ProviderApproval() { return <div>Provider Approval</div>; }"
Create-File "src\features\transport\pages\ProviderTrips.tsx" "export default function ProviderTrips() { return <div>Provider Trips</div>; }"
Create-File "src\features\transport\services\transportService.ts" "// Transport service"
Create-File "src\features\transport\types\index.ts" "// Transport types"
Create-File "src\features\transport\hooks\useTransport.ts" "// useTransport"
Create-File "src\features\transport\stores\transportStore.ts" "// Transport store"

# ----- features/disputes -----
Create-File "src\features\disputes\pages\DisputeList.tsx" "export default function DisputeList() { return <div>Disputes</div>; }"
Create-File "src\features\disputes\pages\DisputeDetail.tsx" "export default function DisputeDetail() { return <div>Dispute Detail</div>; }"
Create-File "src\features\disputes\pages\DisputeResolution.tsx" "export default function DisputeResolution() { return <div>Resolve Dispute</div>; }"
Create-File "src\features\disputes\services\disputeService.ts" "// Dispute service"
Create-File "src\features\disputes\types\index.ts" "// Dispute types"
Create-File "src\features\disputes\hooks\useDisputes.ts" "// useDisputes"
Create-File "src\features\disputes\stores\disputeStore.ts" "// Dispute store"

# ----- features/payouts -----
Create-File "src\features\payouts\pages\PayoutList.tsx" "export default function PayoutList() { return <div>Payouts</div>; }"
Create-File "src\features\payouts\pages\PayoutDetail.tsx" "export default function PayoutDetail() { return <div>Payout Detail</div>; }"
Create-File "src\features\payouts\services\payoutService.ts" "// Payout service"
Create-File "src\features\payouts\types\index.ts" "// Payout types"
Create-File "src\features\payouts\hooks\usePayouts.ts" "// usePayouts"
Create-File "src\features\payouts\stores\payoutStore.ts" "// Payout store"

# ----- features/analytics -----
Create-File "src\features\analytics\pages\Dashboard.tsx" @"
import React from 'react';
export default function Dashboard() {
  return (
    <div>
      <h1 className='text-2xl font-bold'>Dashboard</h1>
      <div className='grid grid-cols-4 gap-4 mt-6'>
        <div className='bg-white p-4 rounded shadow'>Total Orders: 0</div>
        <div className='bg-white p-4 rounded shadow'>Revenue: KES 0</div>
        <div className='bg-white p-4 rounded shadow'>Farmers: 0</div>
        <div className='bg-white p-4 rounded shadow'>Providers: 0</div>
      </div>
    </div>
  );
}
"@
Create-File "src\features\analytics\pages\Reports.tsx" "export default function Reports() { return <div>Reports</div>; }"
Create-File "src\features\analytics\pages\ExportData.tsx" "export default function ExportData() { return <div>Export Data</div>; }"
Create-File "src\features\analytics\services\analyticsService.ts" "// Analytics service"
Create-File "src\features\analytics\types\index.ts" "// Analytics types"
Create-File "src\features\analytics\hooks\useAnalytics.ts" "// useAnalytics"
Create-File "src\features\analytics\stores\analyticsStore.ts" "// Analytics store"

# ----- features/admin -----
Create-File "src\features\admin\pages\FarmerApproval.tsx" "export default function FarmerApproval() { return <div>Farmer Approval</div>; }"
Create-File "src\features\admin\pages\DisputeResolution.tsx" "export default function DisputeResolution() { return <div>Dispute Resolution</div>; }"
Create-File "src\features\admin\pages\AuditLog.tsx" "export default function AuditLog() { return <div>Audit Log</div>; }"
Create-File "src\features\admin\pages\NotificationsList.tsx" "export default function NotificationsList() { return <div>Notifications</div>; }"
Create-File "src\features\admin\pages\UserManagement.tsx" "export default function UserManagement() { return <div>User Management</div>; }"
Create-File "src\features\admin\pages\Settings.tsx" "export default function Settings() { return <div>Settings</div>; }"
Create-File "src\features\admin\services\adminService.ts" "// Admin service"
Create-File "src\features\admin\types\index.ts" "// Admin types"
Create-File "src\features\admin\hooks\useAdmin.ts" "// useAdmin"
Create-File "src\features\admin\stores\adminStore.ts" "// Admin store"

# ----- features/retailer (future) -----
Create-File "src\features\retailer\pages\RetailerDashboard.tsx" "export default function RetailerDashboard() { return <div>Retailer Dashboard</div>; }"
Create-File "src\features\retailer\pages\BulkOrder.tsx" "export default function BulkOrder() { return <div>Bulk Order</div>; }"
Create-File "src\features\retailer\pages\InvoiceList.tsx" "export default function InvoiceList() { return <div>Invoices</div>; }"
Create-File "src\features\retailer\services\retailerService.ts" "// Retailer service"
Create-File "src\features\retailer\types\index.ts" "// Retailer types"
Create-File "src\features\retailer\hooks\useRetailer.ts" "// useRetailer"
Create-File "src\features\retailer\stores\retailerStore.ts" "// Retailer store"

# ----- not-found -----
Create-File "src\features\not-found\NotFound.tsx" "export default function NotFound() { return <div>404 - Page Not Found</div>; }"

# ----- shared/components/ui (50+ components) -----
$uiComponents = @(
    "Button.tsx", "Card.tsx", "Input.tsx", "Modal.tsx", "Dropdown.tsx",
    "Chevron.tsx", "Spinner.tsx", "Tabs.tsx", "Tooltip.tsx", "Avatar.tsx",
    "Badge.tsx", "Alert.tsx", "ProgressBar.tsx", "Loader.tsx", "Toast.tsx",
    "Switch.tsx", "Checkbox.tsx", "Radio.tsx", "Select.tsx", "Textarea.tsx",
    "DatePicker.tsx", "TimePicker.tsx", "FileUpload.tsx", "ImageUpload.tsx",
    "Pagination.tsx", "Skeleton.tsx"
)
foreach ($comp in $uiComponents) {
    $name = $comp -replace "\.tsx$", ""
    $content = @"
import React from 'react';
export const $name: React.FC<{ children?: React.ReactNode }> = ({ children }) => {
  return <div className="$name">{children}</div>;
};
"@
    Create-File "src\shared\components\ui\$comp" $content
}

# ----- shared/components/tables -----
Create-File "src\shared\components\tables\DataTable.tsx" @"
import React from 'react';
export const DataTable: React.FC<{ columns: any[]; data: any[] }> = ({ columns, data }) => {
  return <table className='min-w-full'><thead><tr>{columns.map(col => <th key={col.key}>{col.title}</th>)}</thead><tbody>{data.map((row, i) => <tr key={i}>{columns.map(col => <td key={col.key}>{row[col.key]}</td>)}</tr>)}</tbody></table>;
};
"@
Create-File "src\shared\components\tables\Column.tsx" "// Column definition"
Create-File "src\shared\components\tables\Pagination.tsx" "// Pagination component"

# ----- shared/components/charts -----
Create-File "src\shared\components\charts\LineChart.tsx" "// LineChart"
Create-File "src\shared\components\charts\BarChart.tsx" "// BarChart"
Create-File "src\shared\components\charts\PieChart.tsx" "// PieChart"
Create-File "src\shared\components\charts\MetricsCard.tsx" "// MetricsCard"

# ----- shared/components/forms -----
Create-File "src\shared\components\forms\Form.tsx" "// Form wrapper"
Create-File "src\shared\components\forms\FormInput.tsx" "// FormInput"
Create-File "src\shared\components\forms\FormSelect.tsx" "// FormSelect"
Create-File "src\shared\components\forms\FormValidation.ts" "// Validation helpers"

# ----- shared/layout -----
Create-File "src\shared\layout\MainLayout.tsx" @"
import React from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from './Sidebar';
import Header from './Header';
import Footer from './Footer';

export default function MainLayout() {
  return (
    <div className='flex h-screen'>
      <Sidebar />
      <div className='flex-1 flex flex-col'>
        <Header />
        <main className='flex-1 p-6 overflow-y-auto'>
          <Outlet />
        </main>
        <Footer />
      </div>
    </div>
  );
}
"@
Create-File "src\shared\layout\Sidebar.tsx" @"
import React from 'react';
import { NavLink } from 'react-router-dom';
export default function Sidebar() {
  return (
    <aside className='w-64 bg-gray-800 text-white'>
      <nav className='p-4'>
        <NavLink to='/' className='block py-2'>Dashboard</NavLink>
        <NavLink to='/orders' className='block py-2'>Orders</NavLink>
        <NavLink to='/products' className='block py-2'>Products</NavLink>
        <NavLink to='/transport' className='block py-2'>Transport Providers</NavLink>
        <NavLink to='/disputes' className='block py-2'>Disputes</NavLink>
        <NavLink to='/payouts' className='block py-2'>Payouts</NavLink>
        <NavLink to='/admin/farmer-approval' className='block py-2'>Farmer Approval</NavLink>
        <NavLink to='/admin/audit-log' className='block py-2'>Audit Log</NavLink>
      </nav>
    </aside>
  );
}
"@
Create-File "src\shared\layout\Header.tsx" @"
import React from 'react';
export default function Header() {
  return <header className='bg-white shadow p-4 flex justify-between items-center'><h1 className='text-xl'>MAMBONAMI Admin</h1><button onClick={() => { localStorage.removeItem('access_token'); window.location.href = '/login'; }}>Logout</button></header>;
}
"@
Create-File "src\shared\layout\Footer.tsx" "export default function Footer() { return <footer className='bg-white shadow p-2 text-center text-sm'>© 2025 MAMBONAMI</footer>; }"
Create-File "src\shared\layout\FloatingActionButton.tsx" "export default function FloatingActionButton() { return null; }"

Write-Host "`n✅ Web dashboard structure created successfully under $webRoot" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Magenta
Write-Host "1. cd web" -ForegroundColor Yellow
Write-Host "2. pnpm install" -ForegroundColor Yellow
Write-Host "3. pnpm run dev" -ForegroundColor Yellow