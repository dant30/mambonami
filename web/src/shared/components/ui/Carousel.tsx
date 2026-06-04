import React, { useRef } from 'react';

interface CarouselProps {
  children: React.ReactNode[];
}

export default function Carousel({ children }: CarouselProps) {
  const scrollRef = useRef<HTMLDivElement | null>(null);

  return (
    <div className="relative">
      <div ref={scrollRef} className="flex gap-3 overflow-x-auto pb-2">
        {children.map((child, index) => (
          <div key={index} className="min-w-[220px] shrink-0 rounded-2xl bg-white p-4 shadow-sm">
            {child}
          </div>
        ))}
      </div>
    </div>
  );
}
