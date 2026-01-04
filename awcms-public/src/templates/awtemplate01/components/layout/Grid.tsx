import React from 'react';
import type { z } from 'zod';
import type { GridSchema } from '../../registry';

type GridProps = z.infer<typeof GridSchema> & {
    children?: React.ReactNode;
    className?: string;
};

const gapClasses = {
    none: 'gap-0',
    sm: 'gap-4',
    md: 'gap-6',
    lg: 'gap-8',
};

/**
 * Grid - CSS Grid utility component
 * Responsive grid with configurable columns
 */
export const Grid: React.FC<GridProps> = ({
    columns = 3,
    gap = 'md',
    responsive = true,
    children,
    className = '',
}) => {
    // Generate responsive grid classes
    const gridCols = responsive
        ? `grid-cols-1 sm:grid-cols-2 lg:grid-cols-${Math.min(columns, 4)} xl:grid-cols-${columns}`
        : `grid-cols-${columns}`;

    return (
        <div
            className={`
                grid
                ${gridCols}
                ${gapClasses[gap]}
                ${className}
            `}
            style={{
                // Fallback for columns > 4 (Tailwind doesn't have utilities for all)
                ...(columns > 4 && !responsive ? { gridTemplateColumns: `repeat(${columns}, minmax(0, 1fr))` } : {}),
            }}
        >
            {children}
        </div>
    );
};
