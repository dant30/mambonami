import * as React from 'react';
import * as TooltipPrimitive from '@radix-ui/react-tooltip';
import { cn } from '@/lib/utils';

const Tooltip = TooltipPrimitive.Root;
const TooltipTrigger = TooltipPrimitive.Trigger;
const TooltipProvider = TooltipPrimitive.Provider;

const TooltipContent = React.forwardRef<
  React.ElementRef<typeof TooltipPrimitive.Content>,
  React.ComponentPropsWithoutRef<typeof TooltipPrimitive.Content>
>(({ className, side = 'top', align = 'center', ...props }, ref) => (
  <TooltipPrimitive.Content
    ref={ref}
    side={side}
    align={align}
    className={cn(
      'z-50 overflow-hidden rounded-md border border-border bg-popover px-3 py-2 text-sm text-popover-foreground shadow-large',
      className,
    )}
    sideOffset={4}
    {...props}
  />
));
TooltipContent.displayName = TooltipPrimitive.Content.displayName;

export { Tooltip, TooltipProvider, TooltipTrigger, TooltipContent };
export default Tooltip;

