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
