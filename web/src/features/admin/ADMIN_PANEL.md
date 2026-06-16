# Admin Panel Documentation

## Overview

The Mambonami admin panel is a comprehensive management interface for platform administrators to handle approvals, disputes, payouts, and audit logging.

## Features

### 1. Dashboard
**Location**: `/admin` or `/admin/dashboard`

The central hub for admin operations showing:
- Pending farmer approvals count
- Pending transport provider approvals count
- Open disputes count
- Pending payouts count
- Quick action buttons for each major function
- Platform overview with key metrics

**Key Components**:
- Real-time statistics aggregation
- Quick access navigation
- System information alerts

---

### 2. Farmer Approval
**Location**: `/admin/farmers` or `/admin/farmer-approval`

**Purpose**: Review and approve farmers with verified farm information.

**Features**:
- Filter by status: `pending` or `approved`
- Display farmer information:
  - Username and contact
  - Farm GPS coordinates
  - Cooperative name and verification status
  - M-Pesa number for payouts
  - Sales history and rating
- One-click approval workflow
- Success notifications

**API Endpoint Used**: 
- `POST /admin-api/users/farmers/{id}/approve/`

**User Flow**:
1. Navigate to Farmers page
2. Review pending farmer details
3. Click "Approve" button
4. System processes approval and updates status

---

### 3. Transport Provider Approval
**Location**: `/admin/transport-providers`

**Purpose**: Approve transport providers who have paid their deposit and passed verification.

**Features**:
- Filter by status: `pending` or `approved`
- Display provider information:
  - Provider name and phone
  - Vehicle type and license plate
  - Deposit amount and payment status
  - M-Pesa transaction ID
- Requirements verification (deposit_paid = true)
- Batch approval capability

**API Endpoint Used**:
- `POST /admin-api/users/transport-providers/{id}/approve/`

**Requirements**:
- Deposit must be paid
- Verification documents must be submitted
- License plate must be valid

---

### 4. Dispute Resolution
**Location**: `/admin/disputes`

**Purpose**: Review and resolve disputes between buyers and farmers/providers.

**Features**:
- Two-panel layout:
  - Left: List of disputes with status indicators
  - Right: Detail view and resolution form
- Status filters: `open`, `under_review`, `resolved`
- Display dispute information:
  - Order number and details
  - Raised by and contact information
  - Reason and description
  - Evidence photos and timestamps
- Resolution options:
  - `full_refund`: Refund entire order amount
  - `partial_refund`: Refund specified amount
  - `penalty`: Apply penalty to provider
  - `no_action`: Close without action
- Optional resolution notes

**API Endpoint Used**:
- `POST /admin-api/disputes/{uuid}/resolve/`

**Resolution Request Format**:
```typescript
{
  resolution_type: 'full_refund' | 'partial_refund' | 'penalty' | 'no_action',
  resolved_amount?: number,  // For partial_refund or penalty
  notes?: string
}
```

**Workflow**:
1. View list of open disputes
2. Click dispute to view details
3. Complete resolution form
4. Submit resolution
5. System processes refund/penalty automatically

---

### 5. Audit Log Viewer
**Location**: `/admin/audit` or `/admin/audit-log`

**Purpose**: Track all admin actions for compliance and auditing.

**Features**:
- Search and filter by:
  - Admin username
  - Action type
  - Model name (Farmer, Dispute, Payout, etc.)
- Display log information:
  - Admin who performed action
  - Action type
  - Model and object details
  - Timestamp
  - Changes made (expandable)
- Read-only interface
- Export capability (future)

**API Endpoint Used**:
- `GET /admin-api/audit/logs/`

**Use Cases**:
- Investigate who made changes
- Track approval history
- Compliance reporting
- Troubleshooting issues

---

### 6. Payouts Manager
**Location**: `/admin/payouts`

**Purpose**: Manage farmer payouts and track M-Pesa transactions.

**Features**:
- Status filters: `pending`, `processing`, `completed`, `failed`
- Display payout information:
  - Farmer name and phone
  - Payout amount
  - Transaction status with color coding
  - M-Pesa transaction ID
  - Creation date
  - Error message (for failed payouts)
- Retry failed payouts
- Summary cards:
  - Total payouts amount
  - Completed amount
  - Pending/Failed amount

**API Endpoints Used**:
- `GET /admin-api/payouts/`
- Retry mechanism (if available)

**Status Breakdown**:
- `pending`: Awaiting processing
- `processing`: Currently being processed
- `completed`: Successfully sent
- `failed`: Error during processing

---

## Technical Architecture

### File Structure
```
src/features/admin/
├── pages/
│   ├── Dashboard.tsx
│   ├── FarmerApproval.tsx
│   ├── TransportProviderApproval.tsx
│   ├── DisputeResolution.tsx
│   ├── AuditLog.tsx
│   ├── PayoutsManager.tsx
│   └── Settings.tsx (existing)
├── hooks/
│   ├── useAdminData.ts
│   └── index.ts
├── services/
│   └── adminService.ts
├── stores/
│   └── (state management, future)
└── types/
    └── index.ts
```

### Data Flow
1. **Hooks** (`useAdminData.ts`): Fetch data and manage loading/error states
2. **Services** (`adminService.ts`): API calls to backend
3. **Pages**: Display UI and handle user interactions
4. **Types**: TypeScript interfaces for data structures

### Key Hooks

#### `useFarmers(filter?)`
```typescript
const { farmers, loading, error, refetch } = useFarmers('pending');
```

#### `useTransportProviders(filter?)`
```typescript
const { providers, loading, error, refetch } = useTransportProviders('pending');
```

#### `useDisputes(filter?)`
```typescript
const { disputes, loading, error, refetch } = useDisputes('open');
```

#### `useAuditLogs(filter?)`
```typescript
const { logs, loading, error, refetch } = useAuditLogs({
  user: 'admin_username',
  action: 'approve',
  model: 'Farmer'
});
```

#### `usePayouts(filter?)`
```typescript
const { payouts, loading, error, refetch } = usePayouts('pending');
```

---

## API Integration

### Base Configuration
- Base URL: Configured in `src/core/api/endpoints.ts`
- Authentication: JWT token via `AuthContext`
- Admin endpoints prefix: `/admin-api/`

### Error Handling
- Network errors: Displayed as user-friendly messages
- Validation errors: Shown in form validation
- Authorization: Handled by route guards

### Response Format
```typescript
{
  results: T[],
  count: number,
  next?: string,
  previous?: string
}
```

---

## Security Considerations

1. **Authentication**: All admin routes require admin role verification
2. **Authorization**: Backend validates admin permissions for each action
3. **Audit Trail**: Every action is logged with admin information
4. **Data Validation**: Frontend and backend validation on all inputs
5. **Rate Limiting**: Backend rate limits on sensitive operations

---

## Usage Examples

### Approving a Farmer
```typescript
import { useFarmers } from '@/features/admin/hooks';
import { approveFarmer } from '@/features/admin/services/adminService';

// In component
const { farmers, refetch } = useFarmers('pending');

const handleApprove = async (farmerId: number) => {
  try {
    await approveFarmer(farmerId);
    await refetch();
  } catch (error) {
    console.error('Approval failed', error);
  }
};
```

### Resolving a Dispute
```typescript
import { resolveDispute } from '@/features/admin/services/adminService';

const resolution = {
  resolution_type: 'partial_refund',
  resolved_amount: 5000,
  notes: 'Partial refund approved for damaged goods'
};

await resolveDispute(disputeUuid, resolution);
```

---

## Future Enhancements

### Secondary Features (Planned)
- **User Management**: Suspend/activate farmers, providers, buyers
- **Order Overview**: Search orders by ID, buyer phone, status
- **Basic Dashboard**: Enhanced with charts and trends
- **Bulk Operations**: Approve/reject multiple items at once
- **Report Generation**: Export logs and statistics
- **Notification System**: Alert admins of pending approvals

### UI/UX Improvements
- Dark mode support
- Advanced filtering and sorting
- Data export (CSV, PDF)
- Dashboard customization
- Keyboard shortcuts

---

## Troubleshooting

### "Failed to load farmers"
- Check network connection
- Verify authentication token is valid
- Check backend API is running
- Review browser console for detailed error

### Approval not working
- Ensure farmer meets all requirements
- Verify admin has proper permissions
- Check for backend validation errors
- Review audit logs for failure reason

### Disputes not showing
- Verify disputes exist on backend
- Check date filters
- Ensure API endpoint is accessible
- Check for data filtering issues

---

## Support

For issues or questions about the admin panel:
1. Check the audit logs for related actions
2. Review backend logs for API errors
3. Contact platform support with issue details
4. Include browser console logs when reporting bugs
