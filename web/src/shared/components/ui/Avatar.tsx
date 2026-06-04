import React from 'react';

interface AvatarProps extends React.ImgHTMLAttributes<HTMLImageElement> {
  name?: string;
  size?: 'sm' | 'md' | 'lg';
}

const sizeMap = {
  sm: 'h-8 w-8 text-sm',
  md: 'h-10 w-10 text-base',
  lg: 'h-14 w-14 text-lg',
};

export default function Avatar({ name = '', src, alt = 'Avatar', size = 'md', className = '', ...props }: AvatarProps) {
  const initials = name
    .split(' ')
    .map((part) => part[0])
    .slice(0, 2)
    .join('')
    .toUpperCase();

  if (src) {
    return (
      <img
        src={src}
        alt={alt}
        className={`rounded-full object-cover ${sizeMap[size]} ${className}`}
        {...props}
      />
    );
  }

  return (
    <div className={`inline-flex items-center justify-center rounded-full bg-slate-200 text-slate-700 ${sizeMap[size]} ${className}`}>
      {initials || 'NA'}
    </div>
  );
}

