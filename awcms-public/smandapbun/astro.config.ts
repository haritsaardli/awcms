import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';
import react from '@astrojs/react';
import sitemap from '@astrojs/sitemap';
import icon from 'astro-icon';

export default defineConfig({
  site: 'https://sman2pangkalanbun.sch.id',
  output: 'static',
  integrations: [
    tailwind(),
    react(),
    sitemap(),
    icon({
      include: {
        tabler: ['*'],
      },
    }),
  ],
  i18n: {
    defaultLocale: 'id',
    locales: ['id', 'en'],
    routing: {
      prefixDefaultLocale: false,
    },
  },
});
