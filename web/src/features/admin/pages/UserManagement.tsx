import { useMemo, useState } from 'react';
import { Download, Users } from 'lucide-react';
import Card from '../../../shared/components/cards/Card';
import Button from '../../../shared/components/ui/Button';
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from '../../../shared/components/tables/Table';
import { useUsers } from '../hooks/useAdminData';
import { activateUser, suspendUser } from '../services/adminService';
import { downloadCsv } from '../utils/reportExport';
import type { AdminUser } from '../types';

const statusOptions = ['all', 'active', 'inactive'] as const;

export default function UserManagement() {
  const [filter, setFilter] = useState<typeof statusOptions[number]>('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedUserIds, setSelectedUserIds] = useState<number[]>([]);
  const [loadingAction, setLoadingAction] = useState(false);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const { users, loading, error, refetch } = useUsers(filter);
  const safeUsers = Array.isArray(users) ? users : [];

  const filteredUsers = useMemo(() => {
    const normalized = searchTerm.trim().toLowerCase();
    return safeUsers.filter((user) => {
      if (!normalized) return true;
      return [user.username, user.email, user.phone, user.user_type]
        .filter(Boolean)
        .some((value) => String(value).toLowerCase().includes(normalized));
    });
  }, [safeUsers, searchTerm]);

  const selectedUsers = useMemo(
    () => filteredUsers.filter((user) => selectedUserIds.includes(user.id)),
    [filteredUsers, selectedUserIds],
  );

  const toggleRow = (userId: number) => {
    setSelectedUserIds((prev) =>
      prev.includes(userId) ? prev.filter((id) => id !== userId) : [...prev, userId],
    );
  };

  const toggleSelectAll = () => {
    if (selectedUserIds.length === filteredUsers.length) {
      setSelectedUserIds([]);
      return;
    }
    setSelectedUserIds(filteredUsers.map((user) => user.id));
  };

  const handleAction = async (action: 'activate' | 'suspend', targetUsers: AdminUser[]) => {
    setLoadingAction(true);
    setSuccessMessage(null);
    try {
      await Promise.all(
        targetUsers.map((user) =>
          action === 'activate' ? activateUser(user.id) : suspendUser(user.id),
        ),
      );
      setSuccessMessage(
        action === 'activate'
          ? 'Selected users have been activated.'
          : 'Selected users have been suspended.',
      );
      setSelectedUserIds([]);
      refetch();
    } catch (err) {
      console.error('Failed bulk update users:', err);
    } finally {
      setLoadingAction(false);
    }
  };

  const handleExportCsv = () => {
    downloadCsv(
      'admin-users.csv',
      filteredUsers.map((user) => ({
        ID: user.id,
        Username: user.username,
        Email: user.email,
        Phone: user.phone,
        Type: user.user_type,
        Active: user.is_active ? 'Yes' : 'No',
        CreatedAt: user.created_at,
      })),
      ['ID', 'Username', 'Email', 'Phone', 'Type', 'Active', 'CreatedAt'],
    );
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-semibold text-slate-900">User Management</h1>
          <p className="mt-2 text-sm text-slate-600">
            Suspend, activate, and review administrator and platform user accounts.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <Button
            type="button"
            variant="secondary"
            className="rounded-full"
            onClick={() => refetch()}
          >
            Refresh
          </Button>
          <Button type="button" variant="secondary" onClick={handleExportCsv} className="rounded-full">
            <Download className="mr-2 h-4 w-4" /> Export CSV
          </Button>
        </div>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <div>
          <label className="block text-sm font-medium text-slate-900">Filter status</label>
          <select
            value={filter}
            onChange={(event) => setFilter(event.target.value as typeof statusOptions[number])}
            className="mt-1 block w-full rounded border border-slate-300 bg-white px-3 py-2 text-slate-900"
          >
            {statusOptions.map((option) => (
              <option key={option} value={option}>
                {option === 'all' ? 'All users' : option === 'active' ? 'Active' : 'Inactive'}
              </option>
            ))}
          </select>
        </div>
        <div className="sm:col-span-2">
          <label className="block text-sm font-medium text-slate-900">Search users</label>
          <input
            type="text"
            placeholder="Search by username, email, phone, or role"
            value={searchTerm}
            onChange={(event) => setSearchTerm(event.target.value)}
            className="mt-1 block w-full rounded border border-slate-300 px-3 py-2 text-slate-900"
          />
        </div>
      </div>

      {successMessage && (
        <div className="rounded-lg border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-700">
          {successMessage}
        </div>
      )}
      {error && (
        <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {error}
        </div>
      )}

      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-2 text-sm text-slate-600">
          <Users className="h-4 w-4" />
          {filteredUsers.length} users found
        </div>
        <div className="flex flex-wrap gap-2">
          <Button
            type="button"
            variant="outline"
            onClick={() => handleAction('activate', selectedUsers)}
            disabled={selectedUsers.length === 0 || loadingAction}
          >
            Activate selected
          </Button>
          <Button
            type="button"
            variant="destructive"
            onClick={() => handleAction('suspend', selectedUsers)}
            disabled={selectedUsers.length === 0 || loadingAction}
          >
            Suspend selected
          </Button>
        </div>
      </div>

      {loading ? (
        <Card className="p-6 text-center">Loading users...</Card>
      ) : filteredUsers.length === 0 ? (
        <Card className="p-6 text-center text-slate-600">No users match the current filters.</Card>
      ) : (
        <Card className="overflow-hidden p-0">
          <Table className="min-w-full text-left text-sm text-slate-700">
            <TableHeader className="bg-slate-50 text-slate-900">
              <TableRow>
                <TableHead className="px-4 py-4">
                  <input
                    type="checkbox"
                    checked={selectedUserIds.length === filteredUsers.length}
                    onChange={toggleSelectAll}
                  />
                </TableHead>
                <TableHead className="px-4 py-4">Username</TableHead>
                <TableHead className="px-4 py-4">Email</TableHead>
                <TableHead className="px-4 py-4">Phone</TableHead>
                <TableHead className="px-4 py-4">Role</TableHead>
                <TableHead className="px-4 py-4">Status</TableHead>
                <TableHead className="px-4 py-4">Action</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredUsers.map((user) => (
                <TableRow key={user.id}>
                  <TableCell className="px-4 py-4">
                    <input
                      type="checkbox"
                      checked={selectedUserIds.includes(user.id)}
                      onChange={() => toggleRow(user.id)}
                    />
                  </TableCell>
                  <TableCell className="px-4 py-4 font-medium text-slate-900">{user.username}</TableCell>
                  <TableCell className="px-4 py-4 text-slate-600">{user.email}</TableCell>
                  <TableCell className="px-4 py-4 text-slate-600">{user.phone || '—'}</TableCell>
                  <TableCell className="px-4 py-4 text-slate-600">{user.user_type}</TableCell>
                  <TableCell className="px-4 py-4">
                    <span
                      className={`inline-flex rounded-full px-3 py-1 text-xs font-medium ${
                        user.is_active ? 'bg-emerald-100 text-emerald-700' : 'bg-amber-100 text-amber-800'
                      }`}
                    >
                      {user.is_active ? 'Active' : 'Inactive'}
                    </span>
                  </TableCell>
                  <TableCell className="px-4 py-4">
                    {user.is_active ? (
                      <Button
                        size="sm"
                        variant="destructive"
                        onClick={() => handleAction('suspend', [user])}
                        disabled={loadingAction}
                      >
                        Suspend
                      </Button>
                    ) : (
                      <Button
                        size="sm"
                        variant="primary"
                        onClick={() => handleAction('activate', [user])}
                        disabled={loadingAction}
                      >
                        Activate
                      </Button>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Card>
      )}
    </div>
  );
}

