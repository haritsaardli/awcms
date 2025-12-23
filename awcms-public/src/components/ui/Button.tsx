import React from 'react';
import { cn } from '../utils/cn'; // Need to create this utility or inline it

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'destructive';
    size?: 'sm' | 'md' | 'lg';
    href?: string;
}

export const Button: React.FC<ButtonProps> = ({
    className, variant = 'primary', size = 'md', href, children, ...props
}) => {
    const baseStyles = "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50";

    const variants = {
        primary: "bg-primary text-primary-foreground shadow hover:bg-primary/90",
        secondary: "bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80",
        outline: "border border-input bg-transparent shadow-sm hover:bg-accent hover:text-accent-foreground",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        destructive: "bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90",
    };

    const sizes = {
        sm: "h-8 px-3 text-xs",
        md: "h-9 px-4 py-2",
        lg: "h-10 px-8",
    };

    const combinedClasses = cn(baseStyles, variants[variant], sizes[size], className);

    if (href) {
        return (
            <a href={href} className={combinedClasses}>
                {children}
            </a>
        );
    }

    return (
        <button className={combinedClasses} {...props}>
            {children}
        </button>
    );
};
