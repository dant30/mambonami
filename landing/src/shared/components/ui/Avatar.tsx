import React, { useState } from 'react'
import { CheckCircle2, User } from 'lucide-react'

export interface AvatarProps {
  src?: string | null
  name?: string
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl'
  isVerified?: boolean
  isOnline?: boolean
  className?: string
  alt?: string
}

export const Avatar: React.FC<AvatarProps> = ({
  src,
  name = 'User',
  size = 'md',
  isVerified = false,
  isOnline = false,
  className = '',
  alt,
}) => {
  const [imgError, setImgError] = useState(false)

  const sizeClasses = {
    xs: 'h-6 w-6 text-[10px]',
    sm: 'h-8 w-8 text-xs',
    md: 'h-10 w-10 text-sm',
    lg: 'h-12 w-12 text-base',
    xl: 'h-16 w-16 text-lg',
    '2xl': 'h-20 w-20 text-xl',
  }

  const badgeSizeClasses = {
    xs: 'h-2 w-2 right-0 bottom-0',
    sm: 'h-2.5 w-2.5 right-0 bottom-0',
    md: 'h-3.5 w-3.5 right-0 bottom-0',
    lg: 'h-4 w-4 right-0 bottom-0',
    xl: 'h-5 w-5 right-0.5 bottom-0.5',
    '2xl': 'h-6 w-6 right-1 bottom-1',
  }

  const getInitials = (n: string) => {
    if (!n) return 'U'
    const parts = n.trim().split(' ')
    if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase()
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
  }

  return (
    <div className={`relative inline-flex shrink-0 ${className}`}>
      <div
        className={`flex items-center justify-center rounded-full overflow-hidden font-bold select-none border border-slate-200 shadow-sm ${sizeClasses[size]} ${
          src && !imgError
            ? 'bg-slate-100'
            : 'bg-gradient-to-br from-[#0A2540] to-[#153B64] text-white'
        }`}
      >
        {src && !imgError ? (
          <img
            src={src}
            alt={alt || name}
            onError={() => setImgError(true)}
            className="h-full w-full object-cover"
          />
        ) : name ? (
          <span>{getInitials(name)}</span>
        ) : (
          <User className="h-1/2 w-1/2 opacity-80" />
        )}
      </div>

      {isVerified && (
        <span
          className={`absolute rounded-full bg-[#0A2540] text-white border-2 border-white flex items-center justify-center ${badgeSizeClasses[size]}`}
          title="Verified Profile"
        >
          <CheckCircle2 className="w-full h-full text-[#FF6B00]" />
        </span>
      )}

      {isOnline && !isVerified && (
        <span
          className={`absolute rounded-full bg-emerald-500 border-2 border-white ${badgeSizeClasses[size]}`}
          title="Online"
        />
      )}
    </div>
  )
}
