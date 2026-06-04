import React, { createContext, useContext, useState } from 'react';
interface NotificationContextType { notifications: any[]; addNotification: (msg: string) => void; }
const NotificationContext = createContext<NotificationContextType | undefined>(undefined);
export const NotificationProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [notifications, setNotifications] = useState<any[]>([]);
  const addNotification = (msg: string) => setNotifications([...notifications, { id: Date.now(), message: msg }]);
  return <NotificationContext.Provider value={{ notifications, addNotification }}>{children}</NotificationContext.Provider>;
};
export const useNotification = () => { const ctx = useContext(NotificationContext); if (!ctx) throw new Error('useNotification must be used within NotificationProvider'); return ctx; };
