import React, { Fragment } from 'react';
import type { z } from 'zod';
import type { RichTextBlockSchema } from '../../registry';

type RichTextBlockProps = z.infer<typeof RichTextBlockSchema>;

interface TipTapNode {
    type: string;
    attrs?: Record<string, unknown>;
    content?: TipTapNode[];
    marks?: { type: string; attrs?: Record<string, unknown> }[];
    text?: string;
}

/**
 * Render text with marks (bold, italic, etc.)
 * Security: Node-by-node rendering, no dangerouslySetInnerHTML
 */
const renderMarks = (text: string, marks?: { type: string; attrs?: Record<string, unknown> }[]) => {
    if (!marks || !marks.length) return text;

    return marks.reduce((acc: React.ReactNode, mark) => {
        switch (mark.type) {
            case 'bold':
                return <strong>{acc}</strong>;
            case 'italic':
                return <em>{acc}</em>;
            case 'underline':
                return <u>{acc}</u>;
            case 'strike':
                return <del>{acc}</del>;
            case 'code':
                return <code className="bg-muted px-1.5 py-0.5 rounded text-sm font-mono">{acc}</code>;
            case 'link': {
                const href = String(mark.attrs?.href || '#');
                const target = mark.attrs?.target as string | undefined;
                // Security: Validate URL protocol
                const safeHref = /^(https?:\/\/|\/|#)/.test(href) ? href : '#';
                return (
                    <a
                        href={safeHref}
                        target={target}
                        rel={target === '_blank' ? 'noopener noreferrer' : undefined}
                        className="text-primary underline hover:no-underline"
                    >
                        {acc}
                    </a>
                );
            }
            default:
                return acc;
        }
    }, text);
};

/**
 * Render a single TipTap node
 */
const RenderNode: React.FC<{ node: TipTapNode }> = ({ node }) => {
    if (node.type === 'text') {
        return <Fragment>{renderMarks(node.text || '', node.marks)}</Fragment>;
    }

    const children = node.content?.map((child, i) => <RenderNode key={i} node={child} />);

    switch (node.type) {
        case 'doc':
            return <div className="tiptap-content">{children}</div>;
        case 'paragraph':
            return <p className="mb-4 leading-relaxed">{children}</p>;
        case 'heading': {
            const level = (node.attrs?.level as number) || 1;
            const headingClasses: Record<number, string> = {
                1: 'text-4xl font-bold mb-6 mt-8',
                2: 'text-3xl font-bold mb-5 mt-8',
                3: 'text-2xl font-bold mb-4 mt-6',
                4: 'text-xl font-bold mb-4 mt-6',
                5: 'text-lg font-bold mb-3 mt-4',
                6: 'text-base font-bold mb-3 mt-4',
            };
            const className = headingClasses[level] || '';
            switch (level) {
                case 1: return <h1 className={className}>{children}</h1>;
                case 2: return <h2 className={className}>{children}</h2>;
                case 3: return <h3 className={className}>{children}</h3>;
                case 4: return <h4 className={className}>{children}</h4>;
                case 5: return <h5 className={className}>{children}</h5>;
                case 6: return <h6 className={className}>{children}</h6>;
                default: return <p className={className}>{children}</p>;
            }
        }
        case 'bulletList':
            return <ul className="list-disc list-outside ml-6 mb-4 space-y-2">{children}</ul>;
        case 'orderedList':
            return <ol className="list-decimal list-outside ml-6 mb-4 space-y-2">{children}</ol>;
        case 'listItem':
            return <li>{children}</li>;
        case 'blockquote':
            return (
                <blockquote className="border-l-4 border-primary pl-4 py-2 italic my-6 bg-muted/50 rounded-r">
                    {children}
                </blockquote>
            );
        case 'codeBlock':
            return (
                <pre className="bg-slate-900 text-slate-100 p-4 rounded-lg overflow-x-auto my-6 font-mono text-sm">
                    <code>{children}</code>
                </pre>
            );
        case 'horizontalRule':
            return <hr className="my-8 border-border" />;
        case 'image': {
            const src = String(node.attrs?.src || '');
            const alt = String(node.attrs?.alt || '');
            const title = node.attrs?.title as string | undefined;
            // Security: Validate image source
            const safeSrc = /^(https?:\/\/|\/|data:image\/)/.test(src) ? src : '';
            if (!safeSrc) return null;
            return (
                <figure className="my-8">
                    <img
                        src={safeSrc}
                        alt={alt}
                        title={title}
                        className="rounded-lg shadow-md max-w-full h-auto"
                        loading="lazy"
                    />
                    {title && <figcaption className="text-center text-sm text-muted-foreground mt-2">{title}</figcaption>}
                </figure>
            );
        }
        default:
            // Unknown node types are silently ignored for security
            return null;
    }
};

const alignClasses = {
    left: 'text-left',
    center: 'text-center',
    right: 'text-right',
};

/**
 * RichTextBlock - Safe TipTap content renderer
 * Security: No dangerouslySetInnerHTML, node-by-node rendering
 */
export const RichTextBlock: React.FC<RichTextBlockProps> = ({
    content,
    align = 'left',
}) => {
    if (!content || typeof content !== 'object') {
        return null;
    }

    return (
        <div className={`prose prose-lg max-w-none ${alignClasses[align]}`}>
            <RenderNode node={content as TipTapNode} />
        </div>
    );
};
