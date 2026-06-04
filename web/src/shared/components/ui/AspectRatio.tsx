import React from 'react';

interface AspectRatioProps {
  ratio?: number;
  children: React.ReactNode;
  className?: string;
}

export default function AspectRatio({ ratio = 16 / 9, className = '', children }: AspectRatioProps) {
  return (
    <div className={`relative w-full overflow-hidden rounded-2xl ${className}`} style={{ paddingTop: `${100 / ratio}%` }}>
      <div className="absolute inset-0">{children}</div>
    </div>
  );
}
