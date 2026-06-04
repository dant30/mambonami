import React from 'react';

interface SonnerProps {
  children: React.ReactNode;
}

export default function Sonner({ children }: SonnerProps) {
  return <div>{children}</div>;
}
