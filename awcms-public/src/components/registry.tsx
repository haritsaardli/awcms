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

// --- Registry ---

export const COMPONENT_REGISTRY: Record<string, ComponentRegistryItem> = {
    Hero: { component: Hero, schema: HeroSchema },
    Section: { component: Section, schema: SectionSchema },
    RichText: { component: RichTextBlock, schema: RichTextSchema },
};

export const getComponent = (type: string) => {
    return COMPONENT_REGISTRY[type];
};
