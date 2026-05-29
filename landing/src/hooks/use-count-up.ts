import { useEffect, useRef, useState } from "react";

function parseTarget(raw: string): { target: number; suffix: string; prefix: string; decimals: number } {
  const trimmed = raw.trim();
  let prefix = "";
  let suffix = "";
  let numeric = trimmed;

  // Extract prefix like "$" or "Ksh"
  const prefixMatch = trimmed.match(/^([^\d\s.,+-]+)/);
  if (prefixMatch) {
    prefix = prefixMatch[1];
    numeric = numeric.slice(prefix.length);
  }

  // Extract suffix like "+", "h", "%", etc.
  const suffixMatch = numeric.match(/([^\d\s.,]+)$/);
  if (suffixMatch) {
    suffix = suffixMatch[1];
    numeric = numeric.slice(0, -suffix.length);
  }

  // Remove commas
  numeric = numeric.replace(/,/g, "");

  // Handle K/M suffixes inside numeric (e.g., 2.5K)
  let multiplier = 1;
  if (numeric.endsWith("K")) {
    multiplier = 1000;
    numeric = numeric.slice(0, -1);
  } else if (numeric.endsWith("M")) {
    multiplier = 1000000;
    numeric = numeric.slice(0, -1);
  }

  const target = parseFloat(numeric) * multiplier;
  const decimals = numeric.includes(".") ? numeric.split(".")[1].length : 0;

  return { target, suffix, prefix, decimals };
}

export function useCountUp(value: string, duration = 2000) {
  const [display, setDisplay] = useState("0");
  const ref = useRef<HTMLDivElement>(null);
  const hasAnimated = useRef(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const { target, suffix, prefix, decimals } = parseTarget(value);

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting && !hasAnimated.current) {
            hasAnimated.current = true;
            const startTime = performance.now();

            const tick = (now: number) => {
              const elapsed = now - startTime;
              const progress = Math.min(elapsed / duration, 1);
              // easeOutQuart
              const eased = 1 - Math.pow(1 - progress, 4);
              const current = target * eased;

              let formatted: string;
              if (target >= 1000) {
                formatted = Math.floor(current).toLocaleString();
              } else {
                formatted = current.toFixed(decimals);
              }

              setDisplay(`${prefix}${formatted}${suffix}`);

              if (progress < 1) {
                requestAnimationFrame(tick);
              } else {
                setDisplay(value);
              }
            };

            requestAnimationFrame(tick);
          }
        });
      },
      { threshold: 0.3 }
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, [value, duration]);

  return { display, ref };
}
