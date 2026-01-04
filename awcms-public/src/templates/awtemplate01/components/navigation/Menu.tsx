import React, { useState, useEffect } from 'react';
import type { z } from 'zod';
import type { MenuSchema } from '../../registry';

type MenuProps = z.infer<typeof MenuSchema>;

interface MenuItem {
    id: string;
    label: string;
    url: string;
    target?: string;
    children?: MenuItem[];
}

/**
 * Menu - Dynamic navigation menu
 * Fetches menu items from DB via menuId
 */
export const Menu: React.FC<MenuProps> = ({
    menuId,
    variant = 'horizontal',
}) => {
    const [items, setItems] = useState<MenuItem[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        if (!menuId) {
            setLoading(false);
            return;
        }

        // Client-side fetch for menu items
        // In production, this would call Supabase or an API endpoint
        const fetchMenu = async () => {
            try {
                // Placeholder: In real implementation, fetch from API
                // const response = await fetch(`/api/menus/${menuId}`);
                // const data = await response.json();
                // setItems(data.items || []);

                // Demo items for now
                setItems([
                    { id: '1', label: 'Home', url: '/' },
                    { id: '2', label: 'About', url: '/about' },
                    { id: '3', label: 'Services', url: '/services' },
                    { id: '4', label: 'Contact', url: '/contact' },
                ]);
            } catch (error) {
                console.error('Failed to fetch menu:', error);
            } finally {
                setLoading(false);
            }
        };

        fetchMenu();
    }, [menuId]);

    if (loading) {
        return (
            <nav className="animate-pulse">
                <div className="flex gap-4">
                    {[1, 2, 3, 4].map(i => (
                        <div key={i} className="h-4 w-16 bg-muted rounded" />
                    ))}
                </div>
            </nav>
        );
    }

    if (!items.length) {
        return null;
    }

    const isHorizontal = variant === 'horizontal';

    return (
        <nav className={`awt01-menu ${isHorizontal ? 'flex-row' : 'flex-col'}`}>
            <ul className={`flex ${isHorizontal ? 'flex-row gap-6' : 'flex-col gap-2'}`}>
                {items.map(item => (
                    <li key={item.id}>
                        <a
                            href={item.url}
                            target={item.target}
                            rel={item.target === '_blank' ? 'noopener noreferrer' : undefined}
                            className="
                                text-foreground/80 hover:text-foreground
                                transition-colors font-medium
                                py-2 inline-block
                            "
                        >
                            {item.label}
                        </a>
                    </li>
                ))}
            </ul>
        </nav>
    );
};
