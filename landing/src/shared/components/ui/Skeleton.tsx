import type { HTMLAttributes } from 'react'
import { cn } from '../../../core/utils/cn'

export interface SkeletonProps extends HTMLAttributes<HTMLDivElement> {
	/** Whether the skeleton should be displayed. */
	loading?: boolean
}


export function Skeleton({ className, loading = true, ...props }: SkeletonProps) {
	if (!loading) return null

	return (
		<div
			{...props}
			role="status"
			aria-label="Loading"
			aria-busy="true"
			className={cn('skeleton-shimmer rounded-md', className)}
		/>
	)
}

export interface SkeletonTextProps extends Omit<SkeletonProps, 'children'> {
	/** Number of text lines to display. */
	lines?: number
	/** Height class applied to each line. */
	lineHeightClassName?: string
	/** Width class applied to non-final lines. */
	lineWidthClassName?: string
	/** Width class applied to the final line. */
	lastLineWidthClassName?: string
	/** Spacing class applied between lines. */
	gapClassName?: string
}

export function SkeletonText({
	lines = 3,
	loading = true,
	className,
	lineHeightClassName = 'h-4',
	lineWidthClassName = 'w-full',
	lastLineWidthClassName = 'w-3/4',
	gapClassName = 'space-y-2',
	...props
}: SkeletonTextProps) {
	if (!loading) return null

	const lineCount = Math.max(1, Math.floor(lines))

	return (
		<div
			{...props}
			role="status"
			aria-label="Loading content"
			aria-busy="true"
			className={cn(gapClassName, className)}
		>
			{Array.from({ length: lineCount }, (_, index) => (
				<Skeleton
					key={`skeleton-line-${index}`}
					className={cn(
						lineHeightClassName,
						index === lineCount - 1 ? lastLineWidthClassName : lineWidthClassName,
					)}
				/>
			))}
			<span className="sr-only">Loading content...</span>
		</div>
	)
}
