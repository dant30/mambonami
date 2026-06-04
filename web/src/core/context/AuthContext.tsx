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
