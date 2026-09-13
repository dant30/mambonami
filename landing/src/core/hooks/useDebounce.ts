import { useEffect, useState } from 'react'

export function useDebounce<T>(value: T, delay = 300): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    if (delay <= 0) {
      setDebouncedValue(value)
      return undefined
    }
    const timer = window.setTimeout(() => {
      setDebouncedValue(value);
    }, delay);
    return () => window.clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}

export default useDebounce;
