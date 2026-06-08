// web/src/core/context/AuthContext.tsx

import React, { createContext, useContext, useEffect, useState, useCallback } from 'react';
import { apiClient } from '../api/client';
import { UserProfile } from '../api/types';
import { getToken, setToken, setRefreshToken, clearAllTokens } from '../storage/secureStorage';
import type { Role } from '@/lib/types';

interface AuthContextType {
  user: UserProfile | null;
  loading: boolean;
  login: (accessToken: string, refreshTokenOrUser: string | UserProfile, user?: UserProfile) => void;
  logout: () => void;
  refreshProfile: () => Promise<void>;
  updateUser: (user: UserProfile) => void;
  hasRole: (role: Role | Role[]) => boolean;
}

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);

  const login = (
    accessToken: string,
    refreshTokenOrUser: string | UserProfile,
    userProfile?: UserProfile,
  ) => {
    setToken(accessToken);

    if (typeof refreshTokenOrUser === 'string') {
      setRefreshToken(refreshTokenOrUser);
      if (userProfile) {
        setUser(userProfile);
      }
    } else {
      setUser(refreshTokenOrUser);
    }
  };

  const logout = useCallback(() => {
    clearAllTokens();
    setUser(null);
  }, []);

  const updateUser = useCallback((profile: UserProfile) => {
    setUser(profile);
  }, []);

  const hasRole = useCallback((roles: Role | Role[]) => {
    if (!user) return false;
    const userRole = user.role as Role;
    if (Array.isArray(roles)) return roles.includes(userRole);
    return userRole === roles;
  }, [user]);

  const refreshProfile = useCallback(async () => {
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
      console.error('Failed to refresh profile:', error);
      clearAllTokens();
      setUser(null);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    let mounted = true;
    const initializeAuth = async () => {
      if (!mounted) return;
      await refreshProfile();
    };
    initializeAuth();
    return () => { mounted = false; };
  }, [refreshProfile]);

  return (
    <AuthContext.Provider value={{ user, loading, login, logout, refreshProfile, updateUser, hasRole }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};