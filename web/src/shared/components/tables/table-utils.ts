// frontend/src/shared/components/tables/table-utils.ts

/**
 * Generate a unique row key for table rows.
 * @param prefix - Prefix for the key (e.g., 'user', 'trip')
 * @param id - Unique identifier (string or number)
 * @returns Combined key string like "user-123"
 */
export function createRowKey(prefix: string, id: string | number): string {
  return `${prefix}-${id}`;
}

/**
 * Safely get a value from a row by dot notation (optional, for complex tables).
 * @param row - Data row object
 * @param path - Dot-separated path (e.g., 'user.profile.name')
 * @returns Value or undefined
 */
export function getNestedValue<T = any>(row: Record<string, any>, path: string): T | undefined {
  return path.split('.').reduce((obj, key) => obj?.[key], row) as T | undefined;
}
