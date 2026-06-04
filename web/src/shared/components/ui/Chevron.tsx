
interface ChevronProps {
  direction?: 'up' | 'down' | 'left' | 'right';
  className?: string;
}

const rotations = {
  up: 'rotate-[-90deg]',
  down: 'rotate-90',
  left: 'rotate-180',
  right: 'rotate-0',
};

export default function Chevron({ direction = 'down', className = '' }: ChevronProps) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className={`h-4 w-4 ${rotations[direction]} ${className}`}
    >
      <path d="M6 9l6 6 6-6" />
    </svg>
  );
}

