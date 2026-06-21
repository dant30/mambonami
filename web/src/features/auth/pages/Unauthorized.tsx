// web/src/features/auth/pages/Unauthorized.tsx
import { Link } from 'react-router-dom';
import { Button } from '@/shared/components/ui';

export default function Unauthorized() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center p-4 text-center">
      <h1 className="text-4xl font-bold text-destructive">401</h1>
      <h2 className="mt-2 text-2xl font-semibold">Unauthorized</h2>
      <p className="mt-4 text-muted-foreground max-w-md">
        You do not have permission to access this dashboard. Only admin users are allowed.
      </p>
      <div className="mt-6 flex gap-4">
        <Button asChild>
          <Link to="/login">Go to Login</Link>
        </Button>
      </div>
    </div>
  );
}