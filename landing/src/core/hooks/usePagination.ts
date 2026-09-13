import { useMemo } from 'react'

export interface PaginationOptions {
	page?: number
	pageSize?: number
	totalCount?: number
	siblingCount?: number
}

export type PaginationItem = number | '...'

export function usePagination({
  page = 1,
  pageSize = 20,
  totalCount = 0,
  siblingCount = 1,
}: PaginationOptions = {}) {
  const safePage = Number.isFinite(page) ? Math.max(1, Math.floor(page)) : 1
  const safePageSize = Number.isFinite(pageSize) ? Math.max(1, Math.floor(pageSize)) : 20
  const safeTotalCount = Number.isFinite(totalCount) ? Math.max(0, Math.floor(totalCount)) : 0
  const safeSiblingCount = Number.isFinite(siblingCount) ? Math.max(0, Math.floor(siblingCount)) : 1
  const totalPages = Math.max(1, Math.ceil(safeTotalCount / safePageSize))
  const currentPage = Math.min(safePage, totalPages)

  const range = useMemo(() => {
    const totalNumbers = safeSiblingCount * 2 + 5
    if (totalPages <= totalNumbers) {
      return Array.from({ length: totalPages }, (_, index) => index + 1)
    }
    const leftSibling = Math.max(currentPage - safeSiblingCount, 1)
    const rightSibling = Math.min(currentPage + safeSiblingCount, totalPages)
    const showLeftDots = leftSibling > 2
    const showRightDots = rightSibling < totalPages - 1
    const pages: PaginationItem[] = [1]

    if (showLeftDots) {
      pages.push('...')
    } else {
      for (let index = 2; index < leftSibling; index += 1) pages.push(index)
    }

    for (let index = leftSibling; index <= rightSibling; index += 1) {
      if (!pages.includes(index)) pages.push(index)
    }

    if (showRightDots) {
      pages.push('...')
    } else {
      for (let index = rightSibling + 1; index < totalPages; index += 1) pages.push(index)
    }

    if (!pages.includes(totalPages)) pages.push(totalPages)
    return pages
  }, [currentPage, safeSiblingCount, totalPages])

  return {
    currentPage,
    pageSize: safePageSize,
    totalCount: safeTotalCount,
    totalPages,
    hasPreviousPage: currentPage > 1,
    hasNextPage: currentPage < totalPages,
    range,
  }
}

export default usePagination
