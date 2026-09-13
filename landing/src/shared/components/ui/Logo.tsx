import React from 'react';

interface LogoProps {
  size?: 'sm' | 'md' | 'lg' | 'xl';
  variant?: 'full' | 'icon-only' | 'white-text';
  className?: string;
}

export const Logo: React.FC<LogoProps> = ({ size = 'md', variant = 'full', className = '' }) => {
  const iconDimensions = {
    sm: 'w-7 h-7',
    md: 'w-9 h-9',
    lg: 'w-12 h-12',
    xl: 'w-16 h-16',
  }[size];

  const textSizes = {
    sm: 'text-lg',
    md: 'text-2xl',
    lg: 'text-3xl',
    xl: 'text-4xl',
  }[size];

  return (
    <div className={`inline-flex items-center gap-2.5 select-none ${className}`}>
      {/* Official Handshake Link Icon */}
      <div className={`relative ${iconDimensions} rounded-xl bg-white p-1 shadow-sm border border-slate-200/80 flex items-center justify-center overflow-hidden shrink-0`}>
        <svg viewBox="0 0 512 512" className="w-full h-full">
          {/* Left Person Head - Navy */}
          <circle cx="150" cy="135" r="42" fill="#0A2540" />
          
          {/* Right Person Head - Orange */}
          <circle cx="362" cy="135" r="42" fill="#FF6B00" />
          
          {/* Left Figure Body Loop - Navy */}
          <path
            d="M 100,240 C 100,195 135,160 180,160 C 225,160 250,195 250,240 L 250,265 C 250,290 230,310 205,310 L 175,310 C 150,310 135,290 135,265 L 135,240 C 135,215 155,200 180,200 C 205,200 215,215 215,240"
            fill="none"
            stroke="#0A2540"
            strokeWidth="42"
            strokeLinecap="round"
            strokeLinejoin="round"
          />

          {/* Right Figure Body Loop - Orange */}
          <path
            d="M 412,240 C 412,195 377,160 332,160 C 287,160 262,195 262,240 L 262,265 C 262,290 282,310 307,310 L 337,310 C 362,310 377,290 377,265 L 377,240 C 377,215 357,200 332,200 C 307,200 297,215 297,240"
            fill="none"
            stroke="#FF6B00"
            strokeWidth="42"
            strokeLinecap="round"
            strokeLinejoin="round"
          />

          {/* Interlocking Link Bottom Outer - Navy */}
          <path
            d="M 120,260 L 120,330 C 120,370 155,400 195,400 L 245,400"
            fill="none"
            stroke="#0A2540"
            strokeWidth="42"
            strokeLinecap="round"
          />

          {/* Interlocking Link Bottom Outer - Orange */}
          <path
            d="M 392,260 L 392,330 C 392,370 357,400 317,400 L 267,400"
            fill="none"
            stroke="#FF6B00"
            strokeWidth="42"
            strokeLinecap="round"
          />

          {/* Handshake Fingers clasping */}
          <circle cx="215" cy="335" r="11" fill="#FF6B00" />
          <circle cx="230" cy="352" r="11" fill="#FF6B00" />
          <circle cx="248" cy="366" r="11" fill="#FF6B00" />
          <circle cx="268" cy="375" r="11" fill="#FF6B00" />
          
          <path d="M 230,305 L 285,360" stroke="#0A2540" strokeWidth="32" strokeLinecap="round" />
        </svg>
      </div>

      {variant !== 'icon-only' && (
        <div className="flex flex-col leading-none">
          <div className={`font-black tracking-tight ${textSizes}`}>
            <span className={variant === 'white-text' ? 'text-white' : 'text-[#0A2540]'}>Kazi</span>
            <span className="text-[#FF6B00]">Link</span>
          </div>
          <span className="text-[10px] tracking-wider uppercase font-semibold text-slate-400">
            Kenya Verified
          </span>
        </div>
      )}
    </div>
  );
};
