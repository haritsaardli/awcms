import React from 'react';
import type { z } from 'zod';
import type { HeroBlockSchema } from '../../registry';

type HeroBlockProps = z.infer<typeof HeroBlockSchema>;

const heightClasses = {
    small: 'min-h-[300px]',
    medium: 'min-h-[450px]',
    large: 'min-h-[600px]',
    full: 'min-h-screen',
};

const alignmentClasses = {
    left: 'items-start text-left',
    center: 'items-center text-center',
    right: 'items-end text-right',
};

/**
 * HeroBlock - Full-width hero section
 * Supports background images, overlay, and CTA
 */
export const HeroBlock: React.FC<HeroBlockProps> = ({
    title,
    subtitle,
    backgroundImage,
    buttonText,
    buttonLink,
    alignment = 'center',
    overlay = true,
    height = 'large',
}) => {
    // Security: Validate background image URL
    const safeBackgroundImage = backgroundImage && /^(https?:\/\/|\/|data:image\/)/.test(backgroundImage)
        ? backgroundImage
        : undefined;

    return (
        <section
            className={`
                relative flex flex-col justify-center px-6
                ${heightClasses[height]}
                ${alignmentClasses[alignment]}
                ${safeBackgroundImage ? 'text-white' : 'bg-gradient-to-br from-primary/10 to-secondary/10'}
            `}
        >
            {/* Background Image */}
            {safeBackgroundImage && (
                <div
                    className="absolute inset-0 bg-cover bg-center bg-no-repeat"
                    style={{ backgroundImage: `url(${safeBackgroundImage})` }}
                    aria-hidden="true"
                />
            )}

            {/* Overlay */}
            {overlay && safeBackgroundImage && (
                <div className="absolute inset-0 bg-black/50" aria-hidden="true" />
            )}

            {/* Content */}
            <div className={`relative z-10 max-w-4xl mx-auto w-full ${alignment === 'center' ? 'flex flex-col items-center' : ''}`}>
                <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold mb-6 tracking-tight leading-tight">
                    {title}
                </h1>

                {subtitle && (
                    <p className="text-xl md:text-2xl mb-8 opacity-90 max-w-2xl">
                        {subtitle}
                    </p>
                )}

                {buttonText && buttonLink && (
                    <a
                        href={buttonLink}
                        className="
                            inline-flex items-center justify-center
                            px-8 py-4 text-lg font-semibold
                            bg-primary text-primary-foreground
                            rounded-lg shadow-lg
                            hover:bg-primary/90 transition-colors
                            focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2
                        "
                    >
                        {buttonText}
                    </a>
                )}
            </div>
        </section>
    );
};
