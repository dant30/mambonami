// web/src/core/context/NotificationContext.tsx
import React, { createContext, useContext, useState, useCallback } from 'react';
import { Toast } from '../../shared/components/ui';

export type NotificationType = 'success' | 'error' | 'info' | 'warning';

export interface Notification {
  id: string;
  type: NotificationType;
  message: string;
  title?: string;
}

interface NotificationContextType {
  notifications: Notification[];
  showNotification: (type: NotificationType, message: string, title?: string, timeout?: number) => void;
  removeNotification: (id: string) => void;
}

const NotificationContext = createContext<NotificationContextType | undefined>(undefined);

export const NotificationProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [notifications, setNotifications] = useState<Notification[]>([]);

  const removeNotification = useCallback((id: string) => {
    setNotifications(prev => prev.filter(n => n.id !== id));
  }, []);

  const showNotification = useCallback(
    (type: NotificationType, message: string, title?: string, timeout = 5000) => {
      const id = Math.random().toString(36).substring(2, 9);
      const newNotification: Notification = { id, type, message, title };
      setNotifications(prev => [...prev, newNotification]);
      if (timeout > 0) {
        setTimeout(() => removeNotification(id), timeout);
      }
    },
    [removeNotification]
  );

  return (
    <NotificationContext.Provider value={{ notifications, showNotification, removeNotification }}>
      {children}
      <div className="pointer-events-none fixed inset-x-0 top-4 z-50 flex flex-col items-end gap-3 px-4 sm:px-6">
        {notifications.map((notification) => (
          <Toast
            key={notification.id}
            message={notification.message}
            title={notification.title}
            type={notification.type}
            onClose={() => removeNotification(notification.id)}
          />
        ))}
      </div>
    </NotificationContext.Provider>
  );
};

export const useNotification = () => {
  const ctx = useContext(NotificationContext);
  if (!ctx) throw new Error('useNotification must be used within NotificationProvider');
  return ctx;
};