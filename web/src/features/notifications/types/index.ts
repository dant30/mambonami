export type NotificationChannel = 'push' | 'email' | 'sms' | 'whatsapp';
export type NotificationStatus = 'pending' | 'sent' | 'failed' | 'read';

export interface NotificationRecord {
  id: number;
  user_id: number;
  user_phone?: string;
  user_email?: string;
  title: string;
  body: string;
  channel: NotificationChannel;
  status: NotificationStatus;
  metadata?: Record<string, unknown> | null;
  external_id?: string | null;
  error_message?: string | null;
  delivered_at?: string | null;
  read_at?: string | null;
  created_at: string;
  updated_at?: string;
}

export interface NotificationFilters {
  status?: NotificationStatus | 'all';
  channel?: NotificationChannel | 'all';
  search?: string;
}

export interface NotificationSummary {
  total: number;
  unread: number;
  sent: number;
  failed: number;
}