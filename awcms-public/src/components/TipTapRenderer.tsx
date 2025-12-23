import React, { Fragment } from 'react';

interface TipTapNode {
    type: string;
    attrs?: Record<string, any>;
    content?: TipTapNode[];
    marks?: { type: string; attrs?: any }[];
    text?: string;
}

interface Props {
    doc: TipTapNode;
}

const renderMarks = (text: string, marks?: { type: string; attrs?: any }[]) => {
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
                return <code className="bg-gray-100 px-1 rounded text-sm text-red-500 font-mono">{acc}</code>;
            case 'link':
                return (
                    <a
                        href={mark.attrs?.href}
                        target={mark.attrs?.target}
                        rel={mark.attrs?.target === '_blank' ? 'noopener noreferrer' : undefined}
                        className="text-blue-600 hover:underline"
                    >
                        {acc}
                    </a>
                );
            default:
                return acc;
        }
    }, text);
};

const RenderNode: React.FC<{ node: TipTapNode }> = ({ node }) => {
    if (node.type === 'text') {
        return <Fragment>{renderMarks(node.text || '', node.marks)}</Fragment>;
    }

    const children = node.content?.map((child, i) => <RenderNode key={i} node={child} />);

    switch (node.type) {
        case 'doc':
            return <div className="tiptap-doc">{children}</div>;
        case 'paragraph':
            return <p className="mb-4 leading-relaxed text-gray-700">{children}</p>;
        case 'heading': {
            const level = node.attrs?.level || 1;
            const classes = {
                1: 'text-4xl font-bold mb-6 mt-8 text-gray-900',
                2: 'text-3xl font-bold mb-5 mt-8 text-gray-900',
                3: 'text-2xl font-bold mb-4 mt-6 text-gray-900',
                4: 'text-xl font-bold mb-4 mt-6 text-gray-900',
                5: 'text-lg font-bold mb-3 mt-4 text-gray-900',
                6: 'text-base font-bold mb-3 mt-4 text-gray-900',
            };
            const Tag = `h${level}` as React.ElementType;
            return <Tag className={classes[level as keyof typeof classes]}>{children}</Tag>;
        }
        case 'bulletList':
            return <ul className="list-disc list-outside ml-6 mb-4 space-y-1">{children}</ul>;
        case 'orderedList':
            return <ol className="list-decimal list-outside ml-6 mb-4 space-y-1">{children}</ol>;
        case 'listItem':
            return <li>{children}</li>;
        case 'blockquote':
            return <blockquote className="border-l-4 border-blue-500 pl-4 py-1 italic my-4 bg-gray-50">{children}</blockquote>;
        case 'codeBlock':
            return (
                <pre className="bg-gray-900 text-gray-100 p-4 rounded-lg overflow-x-auto my-6 font-mono text-sm">
                    <code>{children}</code>
                </pre>
            );
        case 'horizontalRule':
            return <hr className="my-8 border-gray-200" />;
        case 'image':
            return (
                <figure className="my-8">
                    <img
                        src={node.attrs?.src}
                        alt={node.attrs?.alt}
                        title={node.attrs?.title}
                        className="rounded-lg shadow-md max-w-full h-auto"
                        loading="lazy"
                    />
                    {node.attrs?.title && <figcaption className="text-center text-sm text-gray-500 mt-2">{node.attrs.title}</figcaption>}
                </figure>
            );
        default:
            console.warn(`[TipTapRenderer] Unsupported node type: ${node.type}`);
            return null;
    }
};

export const TipTapRenderer: React.FC<Props> = ({ doc }) => {
    if (!doc || !doc.content) return null;
    return <RenderNode node={doc} />;
};
