import { useEffect, useRef, useState, type ReactNode } from 'react';

interface LazySectionProps {
  children: ReactNode;
  /** How many pixels before the section enters the viewport to start rendering */
  rootMargin?: string;
  /** Minimum height for the placeholder to prevent layout shift */
  minHeight?: string;
}

/**
 * Defers rendering of children until the section scrolls near the viewport.
 * This prevents all Supabase queries from firing at once on page load.
 */
export function LazySection({ children, rootMargin = '200px', minHeight = '200px' }: LazySectionProps) {
  const ref = useRef<HTMLDivElement>(null);
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsVisible(true);
          observer.disconnect();
        }
      },
      { rootMargin }
    );

    observer.observe(el);
    return () => observer.disconnect();
  }, [rootMargin]);

  if (isVisible) {
    return <>{children}</>;
  }

  return <div ref={ref} style={{ minHeight }} />;
}
