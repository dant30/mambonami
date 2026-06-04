import React, { useEffect, useState } from 'react';

interface ImageUploadProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  onFileSelect?: (file: File | null) => void;
}

export default function ImageUpload({ label = 'Upload image', onFileSelect, className = '', ...props }: ImageUploadProps) {
  const [preview, setPreview] = useState<string | null>(null);

  const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0] ?? null;
    if (file) {
      setPreview(URL.createObjectURL(file));
    } else {
      setPreview(null);
    }
    onFileSelect?.(file);
  };

  useEffect(() => {
    return () => {
      if (preview) {
        URL.revokeObjectURL(preview);
      }
    };
  }, [preview]);

  return (
    <div className={className}>
      <label className="mb-2 block text-sm font-medium text-slate-700">{label}</label>
      <div className="flex flex-col gap-3">
        <input type="file" accept="image/*" onChange={handleChange} {...props} />
        {preview ? <img src={preview} alt="Preview" className="max-h-48 rounded-lg object-cover" /> : null}
      </div>
    </div>
  );
}

