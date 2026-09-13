type ClassValue =
  | string
  | number
  | bigint
  | boolean
  | null
  | undefined
  | ClassValue[]
  | { [className: string]: boolean | null | undefined }

function toClassNames(value: ClassValue): string[] {
  if (!value) return []
  if (typeof value === 'string' || typeof value === 'number' || typeof value === 'bigint') {
    return [String(value)]
  }
  if (Array.isArray(value)) return value.flatMap(toClassNames)
  return Object.entries(value)
    .filter(([, enabled]) => enabled)
    .map(([className]) => className)
}

export function cn(...inputs: ClassValue[]): string {
  return inputs.flatMap(toClassNames).join(' ')
}

export default cn