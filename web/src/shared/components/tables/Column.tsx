import React from 'react';

export interface TableColumn<T> {
  key: keyof T | string;
  title: string;
  render?: (value: T[keyof T], row: T, index: number) => React.ReactNode;
  className?: string;
}
