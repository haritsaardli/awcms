-- Create a Visual Builder Homepage
INSERT INTO pages (
    title,
    slug,
    page_type,
    status,
    is_public,
    editor_type,
    content_published,
    created_at,
    updated_at
) VALUES (
    'Home',
    'home',
    'homepage',
    'published',
    true,
    'visual',
    '{
        "content": [
            {
                "type": "Hero",
                "props": {
                    "title": "Build With AWCMS",
                    "subtitle": "Experience the power of a modern, flexible, and secure content management system.",
                    "buttonText": "Get Started",
                    "buttonLink": "/contact",
                    "height": "large",
                    "overlay": true,
                    "alignment": "center",
                    "backgroundImage": "https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&q=80&w=2069"
                }
            },
            {
                "type": "Spacer",
                "props": { "height": 60 }
            },
            {
                "type": "Grid",
                "props": {
                    "columns": 3,
                    "gap": 24,
                    "id": "features-grid"
                }
            },
            {
                "type": "Spacer",
                "props": { "height": 60 }
            },
            {
                "type": "Promotion",
                "props": {
                    "variant": "banner",
                    "promotionId": "" 
                }
            },
            {
                "type": "Spacer",
                "props": { "height": 60 }
            },
            {
                "type": "Testimonial",
                "props": {
                    "quote": "AWCMS incredibly simplified our workflow. The visual builder is a game changer!",
                    "name": "Alex Johnson",
                    "role": "Product Manager",
                    "rating": 5,
                    "variant": "card",
                    "avatar": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200"
                }
            }
        ],
        "zones": {
            "features-grid:column-0": [
                {
                    "type": "Feature",
                    "props": {
                        "title": "Visual Editing",
                        "description": "Drag and drop components to build stunning pages in minutes.",
                        "icon": "zap",
                        "iconColor": "#3b82f6"
                    }
                }
            ],
            "features-grid:column-1": [
                {
                    "type": "Feature",
                    "props": {
                        "title": "Secure Core",
                        "description": "Built on top of Supabase with robust Row Level Security.",
                        "icon": "shield",
                        "iconColor": "#10b981"
                    }
                }
            ],
            "features-grid:column-2": [
                {
                    "type": "Feature",
                    "props": {
                        "title": "Extensible",
                        "description": "Add new functionality with our powerful plugin system.",
                        "icon": "puzzle",
                        "iconColor": "#8b5cf6"
                    }
                }
            ]
        },
        "root": {
            "props": { "title": "Home" }
        }
    }'::jsonb,
    NOW(),
    NOW()
)
ON CONFLICT (page_type) WHERE (page_type = 'homepage' AND deleted_at IS NULL AND status = 'published') 
DO UPDATE SET 
    content_published = EXCLUDED.content_published,
    editor_type = 'visual',
    updated_at = NOW();
