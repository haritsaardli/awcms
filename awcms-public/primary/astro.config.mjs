import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import cloudflare from '@astrojs/cloudflare';
import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
    output: 'server',
    trailingSlash: 'always',
    adapter: cloudflare({
        imageService: 'cloudflare',
    }),
    integrations: [
        react(),
    ],
    vite: {
        plugins: [tailwindcss()],
        ssr: {
            // Silence Vite node built-in externalization warnings during SSR build.
            external: [
                'node:crypto',
                'node:crypto?commonjs-external',
                'node:fs/promises',
                'node:path',
                'node:url',
            ],
        },
    },
});
