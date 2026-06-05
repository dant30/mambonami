import React, { createContext, useContext, useEffect, useState } from 'react';
import { apiClient } from '../api/client';
import { UserProfile } from '../api';
import { getToken, removeToken, setToken } from '../storage/secureStorage';

interface AuthContextType {
  user: UserProfile | null;
  loading: boolean;
  login: (token: string, profile: UserProfile) => void;
  logout: () => void;
  refreshProfile: () => Promise<void>;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);

  const login = (token: string, profile: UserProfile) => {
    setToken(token);
    setUser(profile);
  };

  const logout = () => {
    removeToken();
    setUser(null);
  };

  const refreshProfile = async () => {
    const token = getToken();
    if (!token) {
      setUser(null);
      setLoading(false);
      return;
    }

    try {
      const response = await apiClient.get<UserProfile>('/api/users/profile/');
      setUser(response.data);
    } catch (error) {
      removeToken();
      setUser(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refreshProfile();
  }, []);

  return (
    <AuthContext.Provider value={{ user, loading, login, logout, refreshProfile }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return ctx;
};
