
# Performance Optimization

## Guidelines

1.  **Lazy Loading**: Use `React.lazy()` for all route components to code-split the bundle.
2.  **Image Optimization**: Use the Supabase Image Transformation API (if enabled) or optimized formats (WebP).
3.  **Memoization**: Use `useMemo` and `useCallback` for expensive computations, but avoid premature optimization.
4.  **Virtualization**: For large lists (Tables), consider using virtualization libraries if rows exceed 100+.

## Monitoring
-   Use Chrome DevTools Lighthouse to audit performance.
-   Monitor network requests to Supabase to ensure efficient querying (`.select('id, title')` instead of `.select('*')` when possible).
