import React from 'react';
import type { z } from 'zod';
import type { MediaBlockSchema } from '../../registry';

type MediaBlockProps = z.infer<typeof MediaBlockSchema>;

const aspectRatioClasses = {
    auto: '',
    '16:9': 'aspect-video',
    '4:3': 'aspect-[4/3]',
    '1:1': 'aspect-square',
    '3:2': 'aspect-[3/2]',
};

// Allowed video embed domains (security allowlist)
const ALLOWED_VIDEO_DOMAINS = [
    'youtube.com',
    'www.youtube.com',
    'youtu.be',
    'vimeo.com',
    'player.vimeo.com',
];

const isAllowedVideoUrl = (url: string): boolean => {
    try {
        const parsed = new URL(url);
        return ALLOWED_VIDEO_DOMAINS.some(domain => parsed.hostname === domain || parsed.hostname.endsWith(`.${domain}`));
    } catch {
        return false;
    }
};

/**
 * MediaBlock - Image/Video component with lazy loading
 * Security: URL validation and embed domain allowlist
 */
export const MediaBlock: React.FC<MediaBlockProps> = ({
    type = 'image',
    src,
    alt,
    caption,
    aspectRatio = 'auto',
    rounded = true,
}) => {
    // Security: Validate src
    const isValidImageSrc = /^(https?:\/\/|\/|data:image\/)/.test(src);
    const isValidVideoSrc = type === 'video' && isAllowedVideoUrl(src);

    if (type === 'image' && !isValidImageSrc) {
        return null;
    }

    if (type === 'video' && !isValidVideoSrc) {
        return (
            <div className="bg-muted rounded-lg p-8 text-center text-muted-foreground">
                <p>Video source not allowed</p>
            </div>
        );
    }

    return (
        <figure className="my-6">
            <div className={`overflow-hidden ${rounded ? 'rounded-lg' : ''} ${aspectRatioClasses[aspectRatio]}`}>
                {type === 'image' ? (
                    <img
                        src={src}
                        alt={alt || ''}
                        className="w-full h-full object-cover"
                        loading="lazy"
                    />
                ) : (
                    <iframe
                        src={src}
                        title={alt || 'Video'}
                        className="w-full h-full"
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                        allowFullScreen
                    />
                )}
            </div>
            {caption && (
                <figcaption className="text-center text-sm text-muted-foreground mt-3">
                    {caption}
                </figcaption>
            )}
        </figure>
    );
};
