// web/src/App.tsx
import { BrowserRouter } from 'react-router-dom';
import AppRouter from './router';
import { AuthProvider } from './core/context/AuthContext';
import { ThemeProvider } from './core/context/ThemeContext';
import { NotificationProvider } from './core/context/NotificationContext';

function App() {
  return (
    <ThemeProvider>
      <NotificationProvider>
        <AuthProvider>
          <BrowserRouter>
            <AppRouter />
          </BrowserRouter>
        </AuthProvider>
      </NotificationProvider>
    </ThemeProvider>
  );
}

export default App;