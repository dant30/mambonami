import React from 'react';

interface SliderProps extends React.InputHTMLAttributes<HTMLInputElement> {
  min?: number;
  max?: number;
  step?: number;
}

export default function Slider({ min = 0, max = 100, step = 1, className = '', ...props }: SliderProps) {
  return <input type="range" min={min} max={max} step={step} className={`w-full ${className}`} {...props} />;
}
