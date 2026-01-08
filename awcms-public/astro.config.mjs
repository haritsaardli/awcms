import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';
import cloudflare from '@astrojs/cloudflare';

// https://astro.build/config
export default defineConfig({
    output: 'server',
    trailingSlash: 'always',
    adapter: cloudflare({
        imageService: 'cloudflare',
    }),
    integrations: [
        react(),
        tailwind({
            // We will handle base styles via our own CSS or Main Layout
            applyBaseStyles: false,
        }),
    ],
});
