import React from 'react';

interface SeparatorProps extends React.HTMLAttributes<HTMLHRElement> {
  vertical?: boolean;
}

export default function Separator({ vertical = false, className = '', ...props }: SeparatorProps) {
  return (
    <hr
      className={`border-slate-200 ${vertical ? 'h-full border-l' : 'w-full border-t'} ${className}`}
      {...props}
    />
  );
}
