import React from 'react';
import type { z } from 'zod';
import type { BreadcrumbsSchema } from '../../registry';

type BreadcrumbsProps = z.infer<typeof BreadcrumbsSchema> & {
    items?: { label: string; url?: string }[];
};

/**
 * Breadcrumbs - Navigation path indicator
 * Automatically generates from current URL if items not provided
 */
export const Breadcrumbs: React.FC<BreadcrumbsProps> = ({
    separator = '/',
    showHome = true,
    items,
}) => {
    // If no items provided, generate from current path
    const breadcrumbItems = items || [];

    const allItems = showHome
        ? [{ label: 'Home', url: '/' }, ...breadcrumbItems]
        : breadcrumbItems;

    if (allItems.length <= 1) {
        return null;
    }

    return (
        <nav aria-label="Breadcrumb" className="awt01-breadcrumbs py-4">
            <ol className="flex items-center gap-2 text-sm text-muted-foreground">
                {allItems.map((item, index) => {
                    const isLast = index === allItems.length - 1;

                    return (
                        <li key={index} className="flex items-center gap-2">
                            {index > 0 && (
                                <span className="text-muted-foreground/50" aria-hidden="true">
                                    {separator}
                                </span>
                            )}
                            {isLast || !item.url ? (
                                <span
                                    className={isLast ? 'text-foreground font-medium' : ''}
                                    aria-current={isLast ? 'page' : undefined}
                                >
                                    {item.label}
                                </span>
                            ) : (
                                <a
                                    href={item.url}
                                    className="hover:text-foreground transition-colors"
                                >
                                    {item.label}
                                </a>
                            )}
                        </li>
                    );
                })}
            </ol>
        </nav>
    );
};
