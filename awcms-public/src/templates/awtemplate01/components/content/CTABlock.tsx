import React from 'react';
import type { z } from 'zod';
import type { CTABlockSchema } from '../../registry';

type CTABlockProps = z.infer<typeof CTABlockSchema>;

const variantClasses = {
    primary: 'bg-primary text-primary-foreground hover:bg-primary/90',
    secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
    outline: 'border-2 border-primary text-primary hover:bg-primary hover:text-primary-foreground',
};

const alignClasses = {
    left: 'text-left items-start',
    center: 'text-center items-center',
    right: 'text-right items-end',
};

/**
 * CTABlock - Call to action component
 * Supports multiple style variants and alignment
 */
export const CTABlock: React.FC<CTABlockProps> = ({
    title,
    description,
    buttonText = 'Get Started',
    buttonLink = '#',
    variant = 'primary',
    align = 'center',
}) => {
    // Security: Validate link URL
    const safeLink = /^(https?:\/\/|\/|#|mailto:|tel:)/.test(buttonLink) ? buttonLink : '#';

    return (
        <div className={`flex flex-col py-12 ${alignClasses[align]}`}>
            <h3 className="text-2xl md:text-3xl font-bold mb-4">
                {title}
            </h3>

            {description && (
                <p className="text-lg text-muted-foreground mb-8 max-w-2xl">
                    {description}
                </p>
            )}

            <a
                href={safeLink}
                className={`
                    inline-flex items-center justify-center
                    px-8 py-3 text-base font-semibold
                    rounded-lg transition-colors
                    focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2
                    ${variantClasses[variant]}
                `}
            >
                {buttonText}
            </a>
        </div>
    );
};
