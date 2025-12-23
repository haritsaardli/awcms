import React from 'react';
import { getComponent } from './registry';

interface PuckItem {
    type: string;
    props: any;
}

interface PuckData {
    content?: PuckItem[];
    zones?: Record<string, PuckItem[]>;
    root?: { props: any };
}

interface Props {
    data: PuckData;
}

export const PuckRenderer: React.FC<Props> = ({ data }) => {
    // Support standard Puck 'content' array
    const items = data?.content || [];

    if (!items.length) {
        return null;
    }

    return (
        <div className="puck-renderer-root">
            {items.map((item, index) => {
                const entry = getComponent(item.type);

                if (!entry) {
                    // In production, we might want to skip silently or log to telemetry
                    if (import.meta.env.DEV) {
                        console.warn(`[PuckRenderer] Unknown component type: ${item.type}`);
                        return <div key={index} className="bg-red-50 text-red-500 p-4 border border-red-200">Unknown Component: {item.type}</div>;
                    }
                    return null;
                }

                // Runtime Prop Validation
                const validation = entry.schema.safeParse(item.props);
                if (!validation.success) {
                    console.error(`[PuckRenderer] Prop validation failed for ${item.type}:`, validation.error);
                    return null;
                }

                const Component = entry.component;
                return <Component key={`${item.type}-${index}`} {...validation.data} />;
            })}
        </div>
    );
};
