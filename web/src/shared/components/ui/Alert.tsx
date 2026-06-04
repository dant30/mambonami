import React from 'react';

interface AlertProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'destructive';
}

const variantStyles = {
  default: 'bg-blue-50 border border-blue-200 text-blue-900',
  destructive: 'bg-red-50 border border-red-200 text-red-900',
};

export default function Alert({ variant = 'default', className = '', children, ...props }: AlertProps) {
  return (
    <div
      role="alert"
      className={`rounded-lg px-4 py-3 text-sm shadow-sm ${variantStyles[variant]} ${className}`}
      {...props}
    >
      {children}
    </div>
  );
}

