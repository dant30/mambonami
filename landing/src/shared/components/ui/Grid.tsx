import React, { forwardRef, memo, useEffect, useMemo, useRef, type CSSProperties, type ReactNode } from 'react'

export type GridViewMode = 'grid' | 'list'
export type GridColumns = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 'auto'

export interface GridRenderItemProps<T> {
	item: T
	index: number
	selected: boolean
	disabled: boolean
}

export interface GridProps<T> {
	items: T[]
	renderItem: (props: GridRenderItemProps<T>) => ReactNode
	keyExtractor: (item: T, index: number) => string | number
	view?: GridViewMode
	columns?: GridColumns
	smColumns?: GridColumns
	mdColumns?: GridColumns
	lgColumns?: GridColumns
	xlColumns?: GridColumns
	'2xlColumns'?: GridColumns
	gap?: number
	columnGap?: number
	rowGap?: number
	loading?: boolean
	skeletonCount?: number
	renderSkeleton?: (index: number) => ReactNode
	emptyState?: ReactNode
	error?: ReactNode
	onRetry?: () => void
	selectedKeys?: Array<string | number>
	onSelect?: (item: T, index: number) => void
	isItemDisabled?: (item: T, index: number) => boolean
	className?: string
	itemClassName?: string
	containerClassName?: string
	maxWidth?: string
	hasMore?: boolean
	loadingMore?: boolean
	onLoadMore?: () => void
	loadMoreThreshold?: number
	footer?: ReactNode
	header?: ReactNode
	toolbar?: ReactNode
	errorTitle?: string
	errorDescription?: string
	retryLabel?: string
	emptyTitle?: string
	emptyDescription?: string
	emptyIcon?: ReactNode
	emptyClassName?: string
	animate?: boolean
	animationDelay?: number
	shimmer?: boolean
	infiniteScroll?: boolean
	ariaLabel?: string
	testId?: string
}

const cn = (...classes: Array<string | false | null | undefined>) => classes.filter(Boolean).join(' ')

function columnsClass(columns: GridColumns | undefined, fallback: GridColumns = 1) {
	const value = columns ?? fallback
	return value === 'auto' ? 'grid-cols-[repeat(auto-fit,minmax(240px,1fr))]' : `grid-cols-${value}`
}

function responsiveClasses<T>(props: Pick<GridProps<T>, 'columns' | 'smColumns' | 'mdColumns' | 'lgColumns' | 'xlColumns' | '2xlColumns'>) {
	return cn(
		columnsClass(props.columns, 'auto'),
		props.smColumns && `sm:${columnsClass(props.smColumns)}`,
		props.mdColumns && `md:${columnsClass(props.mdColumns)}`,
		props.lgColumns && `lg:${columnsClass(props.lgColumns)}`,
		props.xlColumns && `xl:${columnsClass(props.xlColumns)}`,
		props['2xlColumns'] && `2xl:${columnsClass(props['2xlColumns'])}`,
	)
}

const Shimmer = memo(function Shimmer({ list = false }: { list?: boolean }) {
	return <div aria-hidden="true" className={cn('animate-pulse rounded-2xl border border-slate-200/70 bg-white p-4 shadow-sm dark:border-slate-800 dark:bg-slate-900', list ? 'flex min-h-24 items-center gap-4' : '')}><div className={cn('rounded-xl bg-slate-200 dark:bg-slate-800', list ? 'h-16 w-16 shrink-0' : 'aspect-[4/3] w-full')} /><div className={cn('space-y-3', list ? 'min-w-0 flex-1' : 'mt-4')}><div className="h-4 w-3/4 rounded bg-slate-200 dark:bg-slate-800" /><div className="h-3 w-full rounded bg-slate-200 dark:bg-slate-800" /></div></div>
})

function GridInner<T>({
	items, renderItem, keyExtractor, view = 'grid', columns = 'auto', smColumns, mdColumns, lgColumns, xlColumns, '2xlColumns': twoXlColumns,
	gap = 4, columnGap, rowGap, loading = false, skeletonCount = 8, renderSkeleton, emptyState, error, onRetry, selectedKeys = [], onSelect, isItemDisabled,
	className, itemClassName, containerClassName, maxWidth, hasMore = false, loadingMore = false, onLoadMore, footer, header, toolbar,
	errorTitle = 'Something went wrong', errorDescription = 'We could not load this information. Please try again.', retryLabel = 'Try again',
	emptyTitle = 'Nothing here yet', emptyDescription = 'There are currently no items to display.', emptyIcon, emptyClassName, animate = true, animationDelay = 40,
	shimmer = true, infiniteScroll = false, ariaLabel, testId, loadMoreThreshold = 4,
}: GridProps<T>, ref: React.ForwardedRef<HTMLDivElement>) {
	const loadMoreRef = useRef<HTMLDivElement>(null)
	const selectedSet = useMemo(() => new Set(selectedKeys.map(String)), [selectedKeys])
	const gridClasses = useMemo(() => view === 'list' ? 'flex flex-col' : cn('grid', responsiveClasses({ columns, smColumns, mdColumns, lgColumns, xlColumns, '2xlColumns': twoXlColumns })), [view, columns, smColumns, mdColumns, lgColumns, xlColumns, twoXlColumns])
	const spacingStyle = useMemo<CSSProperties>(() => view === 'list' ? { rowGap: `${(rowGap ?? gap) * 4}px` } : { gap: `${gap * 4}px`, columnGap: columnGap === undefined ? undefined : `${columnGap * 4}px`, rowGap: rowGap === undefined ? undefined : `${rowGap * 4}px` }, [view, gap, columnGap, rowGap])

	useEffect(() => {
		if (!infiniteScroll || !hasMore || loadingMore || !onLoadMore || !loadMoreRef.current || typeof IntersectionObserver === 'undefined') return
		const observer = new IntersectionObserver(([entry]) => { if (entry?.isIntersecting) onLoadMore() }, { rootMargin: `${Math.max(1, loadMoreThreshold) * 75}px` })
		observer.observe(loadMoreRef.current)
		return () => observer.disconnect()
	}, [infiniteScroll, hasMore, loadingMore, onLoadMore, loadMoreThreshold])

	const skeletons = Array.from({ length: Math.max(0, skeletonCount) }, (_, index) => renderSkeleton ? <React.Fragment key={index}>{renderSkeleton(index)}</React.Fragment> : shimmer ? <Shimmer key={index} list={view === 'list'} /> : <div key={index} className="h-48 animate-pulse rounded-2xl bg-slate-200 dark:bg-slate-800" />)
	const empty = emptyState ?? <div className={cn('flex min-h-[280px] flex-col items-center justify-center rounded-2xl border border-dashed border-slate-300 bg-slate-50/70 px-6 py-12 text-center dark:border-slate-700 dark:bg-slate-900/40', emptyClassName)}>{emptyIcon && <div className="mb-4">{emptyIcon}</div>}<h3 className="text-base font-bold text-slate-900 dark:text-white">{emptyTitle}</h3><p className="mt-2 max-w-md text-sm leading-6 text-slate-500 dark:text-slate-400">{emptyDescription}</p></div>
	const errorContent = error ?? <div role="alert" className="flex min-h-[280px] flex-col items-center justify-center rounded-2xl border border-red-200 bg-red-50/60 px-6 py-12 text-center"><h3 className="text-base font-bold text-red-900">{errorTitle}</h3><p className="mt-2 text-sm text-red-700">{errorDescription}</p>{onRetry && <button type="button" onClick={onRetry} className="mt-5 rounded-xl bg-slate-900 px-4 py-2.5 text-sm font-semibold text-white">{retryLabel}</button>}</div>

	return <section ref={ref} className={cn('w-full', maxWidth && 'mx-auto', containerClassName, className)} style={maxWidth ? { maxWidth } : undefined} aria-label={ariaLabel} data-testid={testId}>
		{header && <div className="mb-5">{header}</div>}{toolbar && <div className="mb-5">{toolbar}</div>}
		{error ? errorContent : loading ? <div className={cn(gridClasses, 'w-full')} style={spacingStyle} aria-busy="true" aria-label="Loading">{skeletons}</div> : items.length === 0 ? empty : <>
			<div className={cn(gridClasses, 'w-full')} style={spacingStyle} role={onSelect ? 'listbox' : undefined} aria-label={ariaLabel}>{items.map((item, index) => { const key = keyExtractor(item, index); const selected = selectedSet.has(String(key)); const disabled = isItemDisabled?.(item, index) ?? false; return <div key={key} className={cn('min-w-0', view === 'list' && 'w-full', animate && 'animate-grid-item', onSelect && !disabled && 'cursor-pointer', disabled && 'cursor-not-allowed opacity-60', selected && 'relative rounded-2xl ring-2 ring-slate-900 ring-offset-2', itemClassName)} style={animate ? { '--grid-animation-delay': `${index * animationDelay}ms` } as CSSProperties : undefined} onClick={() => !disabled && onSelect?.(item, index)} aria-selected={onSelect ? selected : undefined} aria-disabled={disabled || undefined}>{renderItem({ item, index, selected, disabled })}</div> })}</div>
			{infiniteScroll && <div ref={loadMoreRef} className="h-1 w-full" aria-hidden="true" />}{loadingMore && <div className="flex items-center justify-center py-8 text-sm text-slate-500">Loading more...</div>}{!infiniteScroll && hasMore && onLoadMore && <div className="flex justify-center pt-8"><button type="button" onClick={onLoadMore} disabled={loadingMore} className="rounded-xl border border-slate-200 bg-white px-5 py-2.5 text-sm font-semibold text-slate-800 disabled:opacity-60">{loadingMore ? 'Loading...' : 'Load more'}</button></div>}{footer && <div className="mt-8">{footer}</div>}
		</>}
	</section>
}

export const Grid = forwardRef(GridInner) as <T>(props: GridProps<T> & { ref?: React.ForwardedRef<HTMLDivElement> }) => React.ReactElement
export default Grid
