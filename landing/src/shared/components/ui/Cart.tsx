import { useCartItemCount } from '../../../core/lib'

export function CartCountBadge() {
	const count = useCartItemCount()
	if (count < 1) return null

	return (
		<span
			aria-label={`${count} item${count === 1 ? '' : 's'} in cart`}
			className="absolute -right-1 -top-1 flex h-[18px] min-w-[18px] items-center justify-center rounded-full border-2 border-background bg-destructive px-1 text-[9px] font-bold leading-none text-destructive-foreground"
		>
			{count > 99 ? '99+' : count}
		</span>
	)
}
