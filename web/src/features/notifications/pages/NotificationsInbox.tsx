import { useMemo, useState } from 'react';
import Card from '../../../shared/components/cards/Card';
import Button from '../../../shared/components/ui/Button';
import { useNotifications } from '../hooks/useNotifications';
import type { NotificationChannel, NotificationFilters, NotificationStatus } from '../types';

const statusOptions: Array<'all' | NotificationStatus> = ['all', 'pending', 'sent', 'failed', 'read'];
const channelOptions: Array<'all' | NotificationChannel> = ['all', 'push', 'email', 'sms', 'whatsapp'];

export default function NotificationsInbox() {
  const [status, setStatus] = useState<'all' | NotificationStatus>('all');
  const [channel, setChannel] = useState<'all' | NotificationChannel>('all');
  const [search, setSearch] = useState('');

  const filters = useMemo<NotificationFilters>(
    () => ({
      status,
      channel,
      search: search.trim(),
    }),
    [channel, search, status],
  );

  const { notifications, loading, error, summary, refetch, selectNotification, selectedNotification, markRead } =
    useNotifications(filters);

  const safeNotifications = Array.isArray(notifications) ? notifications : [];

  const unreadIds = safeNotifications.filter((notification) => !notification.read_at && notification.status !== 'read').map((notification) => notification.id);

  const handleMarkAllRead = async () => {
    if (unreadIds.length === 0) return;
    await markRead(unreadIds);
    await refetch();
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-semibold text-slate-900">Notifications</h1>
        <p className="mt-2 text-sm text-slate-600">Review delivery status and read state for user notifications.</p>
      </div>

      <div className="grid gap-4 sm:grid-cols-4">
        <Card className="p-4"><p className="text-sm text-slate-600">Total</p><p className="mt-2 text-2xl font-semibold text-slate-900">{summary.total}</p></Card>
        <Card className="p-4"><p className="text-sm text-slate-600">Unread</p><p className="mt-2 text-2xl font-semibold text-slate-900">{summary.unread}</p></Card>
        <Card className="p-4"><p className="text-sm text-slate-600">Sent</p><p className="mt-2 text-2xl font-semibold text-slate-900">{summary.sent}</p></Card>
        <Card className="p-4"><p className="text-sm text-slate-600">Failed</p><p className="mt-2 text-2xl font-semibold text-slate-900">{summary.failed}</p></Card>
      </div>

      <div className="grid gap-4 sm:grid-cols-4">
        <div>
          <label className="block text-sm font-medium text-slate-900">Search</label>
          <input
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            className="mt-1 block w-full rounded border border-slate-300 px-3 py-2 text-slate-900"
            placeholder="Title, body, email, phone..."
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-900">Status</label>
          <select value={status} onChange={(event) => setStatus(event.target.value as 'all' | NotificationStatus)} className="mt-1 block w-full rounded border border-slate-300 bg-white px-3 py-2 text-slate-900">
            {statusOptions.map((option) => (
              <option key={option} value={option}>{option === 'all' ? 'All statuses' : option}</option>
            ))}
          </select>
        </div>
        <div>
          <label className="block text-sm font-medium text-slate-900">Channel</label>
          <select value={channel} onChange={(event) => setChannel(event.target.value as 'all' | NotificationChannel)} className="mt-1 block w-full rounded border border-slate-300 bg-white px-3 py-2 text-slate-900">
            {channelOptions.map((option) => (
              <option key={option} value={option}>{option === 'all' ? 'All channels' : option}</option>
            ))}
          </select>
        </div>
        <div className="flex items-end gap-2">
          <Button type="button" variant="secondary" onClick={() => refetch()} className="w-full">Refresh</Button>
          <Button type="button" variant="outline" onClick={handleMarkAllRead} className="w-full" disabled={unreadIds.length === 0}>Mark all read</Button>
        </div>
      </div>

      {error && <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">{error}</div>}

      {loading ? (
        <Card className="p-6 text-center">Loading notifications...</Card>
      ) : safeNotifications.length === 0 ? (
        <Card className="p-6 text-center text-slate-600">No notifications found</Card>
      ) : (
        <div className="grid gap-3 lg:grid-cols-2">
          {safeNotifications.map((notification) => (
            <Card key={notification.id} className="p-4">
              <div className="flex items-start justify-between gap-4">
                <div>
                  <p className="font-medium text-slate-900">{notification.title}</p>
                  <p className="mt-1 text-sm text-slate-600">{notification.body}</p>
                </div>
                <span className={`rounded-full px-3 py-1 text-xs font-medium ${notification.status === 'failed' ? 'bg-red-100 text-red-700' : notification.status === 'sent' ? 'bg-green-100 text-green-700' : notification.status === 'read' ? 'bg-blue-100 text-blue-700' : 'bg-yellow-100 text-yellow-700'}`}>
                  {notification.status}
                </span>
              </div>
              <div className="mt-4 grid gap-2 text-sm text-slate-600 sm:grid-cols-2">
                <div><p className="text-xs uppercase tracking-wide text-slate-500">Channel</p><p>{notification.channel}</p></div>
                <div><p className="text-xs uppercase tracking-wide text-slate-500">Created</p><p>{new Date(notification.created_at).toLocaleString()}</p></div>
                <div><p className="text-xs uppercase tracking-wide text-slate-500">Recipient</p><p>{notification.user_email || notification.user_phone || notification.user_id}</p></div>
                <div><p className="text-xs uppercase tracking-wide text-slate-500">Delivered</p><p>{notification.delivered_at ? new Date(notification.delivered_at).toLocaleString() : '-'}</p></div>
              </div>
              {notification.error_message && <p className="mt-3 text-sm text-red-600">{notification.error_message}</p>}
              <div className="mt-4 flex gap-2">
                <Button type="button" variant="outline" size="sm" onClick={() => selectNotification(notification.id)}>View</Button>
                {!notification.read_at && notification.status !== 'read' && (
                  <Button type="button" variant="secondary" size="sm" onClick={async () => { await markRead([notification.id]); await refetch(); }}>
                    Mark read
                  </Button>
                )}
              </div>
            </Card>
          ))}
        </div>
      )}

      {selectedNotification && (
        <Card className="p-6">
          <h3 className="text-lg font-semibold text-slate-900">Selected Notification</h3>
          <p className="mt-2 text-sm text-slate-600">{selectedNotification.title}</p>
        </Card>
      )}
    </div>
  );
}