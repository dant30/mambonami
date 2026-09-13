import React, { useState, useRef } from 'react'
import { UploadCloud, File, X, CheckCircle2, AlertCircle } from 'lucide-react'

export interface FileUploadProps {
  label?: string
  description?: string
  accept?: string
  maxSizeMB?: number
  multiple?: boolean
  value?: File[]
  onChange?: (files: File[]) => void
  onUpload?: (files: File[]) => Promise<void> | void
  error?: string
  className?: string
}

export const FileUpload: React.FC<FileUploadProps> = ({
  label = 'Upload documents or certificates',
  description = 'PNG, JPG, PDF up to 10MB',
  accept = '.png,.jpg,.jpeg,.pdf,.doc,.docx',
  maxSizeMB = 10,
  multiple = false,
  onChange,
  error: externalError,
  className = '',
}) => {
  const [dragOver, setDragOver] = useState(false)
  const [selectedFiles, setSelectedFiles] = useState<File[]>([])
  const [uploadError, setUploadError] = useState<string | null>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleFiles = (incoming: FileList | null) => {
    if (!incoming || incoming.length === 0) return

    setUploadError(null)
    const valid: File[] = []
    const maxBytes = maxSizeMB * 1024 * 1024

    for (let i = 0; i < incoming.length; i++) {
      const file = incoming[i]
      if (file.size > maxBytes) {
        setUploadError(`"${file.name}" exceeds the maximum size limit of ${maxSizeMB}MB.`)
        continue
      }
      valid.push(file)
      if (!multiple) break
    }

    if (valid.length > 0) {
      const updated = multiple ? [...selectedFiles, ...valid] : valid
      setSelectedFiles(updated)
      if (onChange) onChange(updated)
    }
  }

  const handleRemove = (index: number) => {
    const updated = selectedFiles.filter((_, i) => i !== index)
    setSelectedFiles(updated)
    if (onChange) onChange(updated)
  }

  return (
    <div className={`space-y-3 ${className}`}>
      {label && (
        <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider">
          {label}
        </label>
      )}

      {/* Drag & Drop Box */}
      <div
        onDragOver={(e) => {
          e.preventDefault()
          setDragOver(true)
        }}
        onDragLeave={() => setDragOver(false)}
        onDrop={(e) => {
          e.preventDefault()
          setDragOver(false)
          handleFiles(e.dataTransfer.files)
        }}
        onClick={() => fileInputRef.current?.click()}
        className={`relative flex flex-col items-center justify-center p-6 border-2 border-dashed rounded-2xl cursor-pointer transition-all duration-200 text-center ${
          dragOver
            ? 'border-[#FF6B00] bg-orange-50/60 scale-[1.01]'
            : 'border-slate-300 bg-slate-50/50 hover:bg-slate-50 hover:border-slate-400'
        }`}
      >
        <input
          ref={fileInputRef}
          type="file"
          accept={accept}
          multiple={multiple}
          onChange={(e) => handleFiles(e.target.files)}
          className="hidden"
        />

        <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-white shadow-sm border border-slate-200 text-[#FF6B00] mb-3">
          <UploadCloud className="h-6 w-6" />
        </div>

        <p className="text-xs font-bold text-slate-900">
          Click to upload <span className="font-normal text-slate-500">or drag and drop</span>
        </p>
        <p className="text-[11px] text-slate-400 mt-1">{description}</p>
      </div>

      {/* Error state */}
      {(uploadError || externalError) && (
        <div className="flex items-center gap-1.5 text-xs text-rose-600 font-medium">
          <AlertCircle className="h-3.5 w-3.5 shrink-0" />
          <span>{uploadError || externalError}</span>
        </div>
      )}

      {/* Uploaded files preview list */}
      {selectedFiles.length > 0 && (
        <div className="space-y-2">
          {selectedFiles.map((file, idx) => (
            <div
              key={idx}
              className="flex items-center justify-between p-2.5 rounded-xl border border-slate-200 bg-white shadow-xs"
            >
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-slate-100 text-[#0A2540] shrink-0">
                  <File className="h-4 w-4" />
                </div>
                <div className="truncate">
                  <p className="text-xs font-bold text-slate-800 truncate">{file.name}</p>
                  <p className="text-[10px] text-slate-400">
                    {(file.size / (1024 * 1024)).toFixed(2)} MB
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 text-emerald-600" />
                <button
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation()
                    handleRemove(idx)
                  }}
                  className="p-1 text-slate-400 hover:text-rose-600 transition-colors"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
