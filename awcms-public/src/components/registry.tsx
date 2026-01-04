import React from 'react';
import type { ComponentType } from 'react';
import { z } from 'zod';
import { Button } from './ui/Button';

// --- Schemas ---

export const HeroSchema = z.object({
    title: z.string().min(1),
    subtitle: z.string().optional(),
    backgroundImage: z.string().optional(),
    ctaText: z.string().optional(),
    ctaLink: z.string().optional(),
});

export const SectionSchema = z.object({
    title: z.string().optional(),
    variant: z.enum(['default', 'secondary', 'dark']).default('default'),
});

export const RichTextSchema = z.object({
    content: z.any(), // JSON content from TipTap
});

export const CoreTextSchema = z.object({
    content: z.string().optional(),
    isHtml: z.boolean().optional(),
});

export const CoreImageSchema = z.object({
    url: z.string().min(1),
    alt: z.string().optional(),
});

export const CoreButtonSchema = z.object({
    text: z.string().default('Click Me'),
    url: z.string().default('#'),
});

export const CoreMenuSchema = z.object({
    menuId: z.string().optional(),
});

// --- Types ---

type ComponentRegistryItem<T = any> = {
    component: ComponentType<T>;
    schema: z.ZodType<T>;
};

// --- Components ---

const Hero = (props: z.infer<typeof HeroSchema>) => (
    <section className="relative bg-slate-900 text-white py-24 px-4 text-center overflow-hidden">
        {props.backgroundImage && (
            <div
                className="absolute inset-0 w-full h-full bg-cover bg-center opacity-30"
                style={{ backgroundImage: `url(${props.backgroundImage})` }}
            />
        )}
        <div className="relative z-10 max-w-4xl mx-auto flex flex-col items-center">
            <h1 className="text-4xl md:text-6xl font-heading font-bold mb-6 tracking-tight leading-tight">
                {props.title}
            </h1>
            {props.subtitle && (
                <p className="text-xl md:text-2xl mb-8 text-slate-200 max-w-2xl text-balance">
                    {props.subtitle}
                </p>
            )}
            {props.ctaText && props.ctaLink && (
                <Button href={props.ctaLink} size="lg" variant="primary">
                    {props.ctaText}
                </Button>
            )}
        </div>
    </section>
);

const Section = (props: z.infer<typeof SectionSchema>) => {
    const bg = {
        default: 'bg-background text-foreground',
        secondary: 'bg-secondary text-secondary-foreground',
        dark: 'bg-slate-900 text-white',
    };
    return (
        <div className={`py-16 px-4 ${bg[props.variant]}`}>
            <div className="container">
                {props.title && <h2 className="text-3xl font-bold mb-8 text-center">{props.title}</h2>}
                {/* Slot for children if we were using nested zones, but simplistic for now */}
                <div className="text-center text-muted-foreground p-8 border-2 border-dashed rounded-lg">
                    Section Content Placeholder
                </div>
            </div>
        </div>
    );
};

// RichText is handled separately via TipTapRenderer usually, but if embedded in Puck:
const RichTextBlock = (props: z.infer<typeof RichTextSchema>) => (
    <div className="prose prose-lg max-w-none mx-auto bg-white p-6 rounded-lg shadow-sm my-8">
        <pre className="text-xs bg-gray-100 p-2 overflow-auto text-muted-foreground">
            {JSON.stringify(props.content, null, 2)}
        </pre>
    </div>
);

const CoreText = ({ content, isHtml }: z.infer<typeof CoreTextSchema>) => {
    if (isHtml) {
        return <div className="prose max-w-none" dangerouslySetInnerHTML={{ __html: content || '' }} />;
    }
    return <div className="whitespace-pre-wrap">{content}</div>;
};

const CoreImage = ({ url, alt }: z.infer<typeof CoreImageSchema>) => (
    <img src={url} alt={alt || ''} className="max-w-full h-auto rounded-lg my-4" />
);

const CoreButton = ({ text, url }: z.infer<typeof CoreButtonSchema>) => (
    <Button href={url} variant="primary" className="my-2">{text}</Button>
);

const CoreMenu = ({ menuId }: z.infer<typeof CoreMenuSchema>) => {
    // Client-side fetch or static placeholder
    const [items, setItems] = React.useState<any[]>([]);

    React.useEffect(() => {
        if (!menuId) return;
        // Fetch logic would go here. For now, check localStorage or just show placeholder if no standard API yet.
        // We'll return a placeholder to avoid breaking if API logic isn't ready.
        console.log('CoreMenu: Fetching menu', menuId);
    }, [menuId]);

    return (
        <nav className="flex gap-4 p-4">
            {items.length > 0 ? items.map((i, idx) => (
                <a key={idx} href={i.url} className="text-slate-700 hover:text-blue-600">{i.label}</a>
            )) : (
                <span className="text-muted-foreground text-sm border border-dashed px-2">Menu {menuId}</span>
            )}
        </nav>
    );
};

// --- Registry ---

export const COMPONENT_REGISTRY: Record<string, ComponentRegistryItem> = {
    Hero: { component: Hero, schema: HeroSchema },
    Section: { component: Section, schema: SectionSchema },
    RichText: { component: RichTextBlock, schema: RichTextSchema },
    'core/text': { component: CoreText, schema: CoreTextSchema },
    'core/image': { component: CoreImage, schema: CoreImageSchema },
    'core/button': { component: CoreButton, schema: CoreButtonSchema },
    'core/menu': { component: CoreMenu, schema: CoreMenuSchema },
};

// Import awtemplate01 registry and merge
let mergedRegistry = { ...COMPONENT_REGISTRY };

// Dynamic import for awtemplate01 (lazy loading)
const initAwtemplate01 = async () => {
    try {
        const { awtemplate01Registry } = await import('../templates/awtemplate01/registry');
        mergedRegistry = { ...COMPONENT_REGISTRY, ...awtemplate01Registry };
    } catch (e) {
        console.warn('[Registry] awtemplate01 not available:', e);
    }
};

// Initialize on module load
initAwtemplate01();

export const getComponent = (type: string) => {
    return mergedRegistry[type] || COMPONENT_REGISTRY[type];
};
