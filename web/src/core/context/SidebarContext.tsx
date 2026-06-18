// web/src/core/context/SidebarContext.tsx
import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { useIsMobile } from '@/core/hooks/useIsMobile';

interface SidebarContextType {
  isMobileOpen: boolean;
  setMobileOpen: (open: boolean) => void;
  toggleMobile: () => void;
  isCollapsed: boolean;
  setCollapsed: (collapsed: boolean) => void;
  toggleCollapsed: () => void;
  isMobile: boolean;
}

const SidebarContext = createContext<SidebarContextType | undefined>(undefined);

export function SidebarProvider({ children }: { children: React.ReactNode }) {
  const isMobile = useIsMobile();
  
  // Mobile sheet state
  const [isMobileOpen, setMobileOpen] = useState(false);
  
  // Desktop collapsed state (persisted in localStorage)
  const [isCollapsed, setCollapsedState] = useState(() => {
    if (typeof window !== 'undefined') {
      return localStorage.getItem('sidebar-collapsed') === 'true';
    }
    return false;
  });

  const setCollapsed = useCallback((value: boolean) => {
    setCollapsedState(value);
    if (typeof window !== 'undefined') {
      localStorage.setItem('sidebar-collapsed', String(value));
    }
  }, []);

  const toggleCollapsed = useCallback(() => {
    setCollapsed(!isCollapsed);
  }, [isCollapsed, setCollapsed]);

  const toggleMobile = useCallback(() => {
    setMobileOpen((prev) => !prev);
  }, []);

  // Close mobile sidebar when resizing to desktop
  useEffect(() => {
    if (!isMobile && isMobileOpen) {
      setMobileOpen(false);
    }
  }, [isMobile, isMobileOpen]);

  const value = {
    isMobileOpen,
    setMobileOpen,
    toggleMobile,
    isCollapsed,
    setCollapsed,
    toggleCollapsed,
    isMobile,
  };

  return <SidebarContext.Provider value={value}>{children}</SidebarContext.Provider>;
}

export function useSidebar() {
  const context = useContext(SidebarContext);
  if (!context) {
    throw new Error('useSidebar must be used within a SidebarProvider');
  }
  return context;
}