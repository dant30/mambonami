import React from 'react'
import { ChevronLeft, ChevronRight } from 'lucide-react'

export interface PaginationProps {
  page: number
  pageSize: number
  total: number
  onPageChange: (page: number) => void
  className?: string
}

export const Pagination: React.FC<PaginationProps> = ({
  page,
  pageSize,
  total,
  onPageChange,
  className = '',
}) => {
  const pageCount = Math.max(1, Math.ceil(total / pageSize))
  if (total <= pageSize) return null

  const currentPage = Math.min(Math.max(page, 1), pageCount)
  const pages: Array<number | 'start-ellipsis' | 'end-ellipsis'> = []
  const addPageRange = (start: number, end: number) => {
    for (let pageNumber = start; pageNumber <= end; pageNumber += 1) {
      pages.push(pageNumber)
    }
  }

  if (pageCount <= 7) {
    addPageRange(1, pageCount)
  } else {
    pages.push(1)

    if (currentPage > 4) pages.push('start-ellipsis')

    addPageRange(
      Math.max(2, currentPage - 1),
      Math.min(pageCount - 1, currentPage + 1),
    )

    if (currentPage < pageCount - 3) pages.push('end-ellipsis')
    pages.push(pageCount)
  }

  return (
    <nav className={`flex items-center justify-between gap-4 border-t border-slate-200 pt-4 ${className}`} aria-label="Pagination">
      <p className="text-xs text-slate-500">
        Showing {((currentPage - 1) * pageSize) + 1}-{Math.min(currentPage * pageSize, total)} of {total}
      </p>
      <div className="flex items-center gap-1">
        <button
          type="button"
          disabled={currentPage === 1}
          onClick={() => onPageChange(currentPage - 1)}
          className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 text-slate-600 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
          aria-label="Previous page"
        >
          <ChevronLeft className="h-4 w-4" />
        </button>
        {pages.map((pageNumber, index) => pageNumber === 'start-ellipsis' || pageNumber === 'end-ellipsis' ? (
          <span key={pageNumber} className="inline-flex h-9 min-w-9 items-center justify-center px-1 text-xs text-slate-400" aria-hidden="true">
            ...
          </span>
        ) : (
          <button
            type="button"
            key={`${pageNumber}-${index}`}
            aria-current={pageNumber === currentPage ? 'page' : undefined}
            onClick={() => onPageChange(pageNumber)}
            className={`h-9 min-w-9 rounded-lg px-2 text-xs font-bold transition ${pageNumber === currentPage ? 'bg-[#0A2540] text-white' : 'text-slate-600 hover:bg-slate-50'}`}
          >
            {pageNumber}
          </button>
        ))}
        <button
          type="button"
          disabled={currentPage === pageCount}
          onClick={() => onPageChange(currentPage + 1)}
          className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-slate-200 text-slate-600 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
          aria-label="Next page"
        >
          <ChevronRight className="h-4 w-4" />
        </button>
      </div>
    </nav>
  )
}
