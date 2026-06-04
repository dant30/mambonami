
interface SpinnerProps {
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

const dimensions = {
  sm: 'h-5 w-5',
  md: 'h-8 w-8',
  lg: 'h-12 w-12',
};

export default function Spinner({ size = 'md', className = '' }: SpinnerProps) {
  return <div className={`${dimensions[size]} animate-spin rounded-full border-4 border-blue-500 border-t-transparent ${className}`} />;
}

