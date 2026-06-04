import React from 'react';

interface FormProps extends React.FormHTMLAttributes<HTMLFormElement> {}

export default function Form({ className = '', children, ...props }: FormProps) {
  return (
    <form className={`space-y-4 ${className}`} {...props}>
      {children}
    </form>
  );
}
