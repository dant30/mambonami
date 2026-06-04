import React from 'react';

interface FileUploadProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
}

export default function FileUpload({ label = 'Upload file', className = '', ...props }: FileUploadProps) {
  return (
    <label className={`flex min-h-[3rem] items-center justify-center rounded-lg border border-dashed border-slate-300 bg-slate-50 px-4 py-5 text-sm text-slate-700 ${className}`}>
      <input type="file" className="sr-only" {...props} />
      <span>{label}</span>
    </label>
  );
}

