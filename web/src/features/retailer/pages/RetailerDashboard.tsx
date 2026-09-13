import { useAuth } from '@/features/auth/hooks/useAuth';
import { getTimeGreeting } from '@/core/utils/date';

export default function RetailerDashboard() {
  const { user } = useAuth();
  const displayName = user?.first_name || 'Retailer';
  const greeting = getTimeGreeting();

  return <div>{greeting}, {displayName}.</div>;
}

