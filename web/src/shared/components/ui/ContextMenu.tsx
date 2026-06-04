import React from 'react';

interface ContextMenuProps {
  children: React.ReactNode;
}

export default function ContextMenu({ children }: ContextMenuProps) {
  return <div className="relative inline-block">{children}</div>;
}
