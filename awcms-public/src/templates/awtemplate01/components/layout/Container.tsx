import React from 'react';
import type { z } from 'zod';
import type { ContainerSchema } from '../../registry';

type ContainerProps = z.infer<typeof ContainerSchema> & {
    children?: React.ReactNode;
};

const maxWidthClasses = {
    sm: 'max-w-screen-sm',
    md: 'max-w-screen-md',
    lg: 'max-w-screen-lg',
    xl: 'max-w-screen-xl',
    '2xl': 'max-w-screen-2xl',
    full: 'max-w-full',
};

const paddingClasses = {
    none: 'px-0',
    sm: 'px-4',
    md: 'px-6',
    lg: 'px-8',
};

/**
 * Container - Responsive max-width wrapper
 * Uses theme tokens for consistent spacing
 */
export const Container: React.FC<ContainerProps> = ({
    maxWidth = 'xl',
    padding = 'md',
    children,
}) => {
    return (
        <div
            className={`
                mx-auto w-full
                ${maxWidthClasses[maxWidth]}
                ${paddingClasses[padding]}
            `}
        >
            {children}
        </div>
    );
};
