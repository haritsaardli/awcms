import React from 'react';
import type { z } from 'zod';
import type { SectionSchema } from '../../registry';

type SectionProps = z.infer<typeof SectionSchema> & {
    children?: React.ReactNode;
    className?: string;
};

const variantClasses = {
    default: 'bg-background text-foreground',
    secondary: 'bg-secondary text-secondary-foreground',
    dark: 'bg-slate-900 text-white',
    accent: 'bg-primary/10 text-foreground',
};

const paddingYClasses = {
    none: 'py-0',
    sm: 'py-8',
    md: 'py-12',
    lg: 'py-16',
    xl: 'py-24',
};

/**
 * Section - Theme-aware section wrapper
 * Supports background variants and padding options
 */
export const Section: React.FC<SectionProps> = ({
    variant = 'default',
    paddingY = 'lg',
    fullWidth = false,
    children,
    className = '',
}) => {
    return (
        <section
            className={`
                awtemplate01-section
                ${variantClasses[variant]}
                ${paddingYClasses[paddingY]}
                ${className}
            `}
        >
            {fullWidth ? (
                children
            ) : (
                <div className="mx-auto max-w-screen-xl px-6">
                    {children}
                </div>
            )}
        </section>
    );
};
