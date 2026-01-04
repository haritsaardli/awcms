/**
 * awtemplate01 Configuration
 * Template manifest and metadata
 */

export interface TemplateConfig {
    id: string;
    name: string;
    description: string;
    version: string;
    author: string;
    features: string[];
    parts: {
        header?: string;
        footer?: string;
        sidebar?: string;
    };
    tokens: Record<string, string>;
}

export const awtemplate01Config: TemplateConfig = {
    id: 'awtemplate01',
    name: 'AW Template 01',
    description: 'Default AWCMS template with TipTap editor, Puck visual builder, and Theme editor support',
    version: '1.0.0',
    author: 'Ahliweb',
    features: ['tiptap', 'puck', 'theme-editor', 'responsive', 'accessible'],
    parts: {
        header: 'awtemplate01-header',
        footer: 'awtemplate01-footer',
    },
    tokens: {
        '--awtemplate01-header-height': '64px',
        '--awtemplate01-footer-height': 'auto',
        '--awtemplate01-container-max-width': '1280px',
        '--awtemplate01-section-padding-y': '4rem',
        '--awtemplate01-section-padding-x': '1.5rem',
    },
};
