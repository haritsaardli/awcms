-- Migration: 20260104000001_seed_awtemplate01.sql
-- Description: Seeds the awtemplate01 default template and assigns it to primary tenant.

DO $$
DECLARE
    v_tenant_id UUID;
    v_template_id UUID;
BEGIN
    -- Find primary tenant by domain
    SELECT id INTO v_tenant_id FROM public.tenants WHERE domain = 'primary.ahliweb.com' LIMIT 1;
    
    -- Fallback to first tenant if primary not found (for dev environments)
    IF v_tenant_id IS NULL THEN
        SELECT id INTO v_tenant_id FROM public.tenants ORDER BY created_at ASC LIMIT 1;
    END IF;

    IF v_tenant_id IS NOT NULL THEN
        -- 1. Insert 'AW Template 01' (Home)
        -- Using ON CONFLICT (slug) assuming slug uniqueness. 
        -- If slug is unique per tenant, this might need adjustment, but usually slug is unique globally or has a constraint.
        INSERT INTO public.templates (name, slug, description, type, is_active, data, tenant_id)
        VALUES (
            'AW Template 01',
            'awtemplate01', -- The requested slug/name
            'Default public template using awtemplate01 system',
            'page',
            true,
            '{
                "root": {},
                "content": [
                    {
                        "type": "Hero",
                        "props": {
                            "title": "Welcome to awtemplate01",
                            "subtitle": "A modern, secure, and performant template system.",
                            "buttonText": "Get Started",
                            "buttonLink": "#",
                            "height": "large",
                            "overlay": true,
                            "alignment": "center"
                        }
                    },
                    {
                        "type": "Section",
                        "props": {
                            "variant": "default",
                            "paddingY": "lg"
                        },
                        "content": [
                            {
                                "type": "Grid",
                                "props": {
                                    "columns": 3,
                                    "gap": "md",
                                    "responsive": true
                                },
                                "content": [
                                    {
                                        "type": "CTABlock",
                                        "props": {
                                            "title": "Visual Editing",
                                            "description": "Built with Puck for easy visual content management.",
                                            "buttonText": "Docs",
                                            "variant": "outline",
                                            "align": "center"
                                        }
                                    },
                                    {
                                        "type": "CTABlock",
                                        "props": {
                                            "title": "Rich Text",
                                            "description": "Secure TipTap editing with advanced formatting.",
                                            "buttonText": "Editing",
                                            "variant": "outline",
                                            "align": "center"
                                        }
                                    },
                                    {
                                        "type": "CTABlock",
                                        "props": {
                                            "title": "Themeable",
                                            "description": "Fully customizable via CSS variables and Theme Editor.",
                                            "buttonText": "Themes",
                                            "variant": "outline",
                                            "align": "center"
                                        }
                                    }
                                ]
                            },
                            {
                                "type": "Section",
                                "props": {
                                    "variant": "secondary",
                                    "paddingY": "md"
                                },
                                "content": [
                                    {
                                        "type": "RichText",
                                        "props": {
                                            "content": {
                                                "type": "doc",
                                                "content": [
                                                    {
                                                        "type": "heading",
                                                        "attrs": { "level": 2 },
                                                        "content": [{ "type": "text", "text": "Built for Performance" }]
                                                    },
                                                    {
                                                        "type": "paragraph",
                                                        "content": [{ "type": "text", "text": "This template is optimized for speed and SEO, using Astro SSR and React Islands." }]
                                                    }
                                                ]
                                            },
                                            "align": "center"
                                        }
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }'::jsonb,
            v_tenant_id
        )
        ON CONFLICT (slug) 
        DO UPDATE SET data = EXCLUDED.data, tenant_id = EXCLUDED.tenant_id
        RETURNING id INTO v_template_id;

        -- 2. Assign to 'home'
        -- Constraint might be missing, so use DELETE/INSERT
        DELETE FROM public.template_assignments WHERE tenant_id = v_tenant_id AND route_type = 'home';
        
        INSERT INTO public.template_assignments (tenant_id, route_type, template_id)
        VALUES (v_tenant_id, 'home', v_template_id);

        -- 3. Also assign to 'single' (fallback)
        DELETE FROM public.template_assignments WHERE tenant_id = v_tenant_id AND route_type = 'single';
        
        INSERT INTO public.template_assignments (tenant_id, route_type, template_id)
        VALUES (v_tenant_id, 'single', v_template_id);
        
        RAISE NOTICE 'Seeded awtemplate01 and assigned to tenant %', v_tenant_id;
    END IF;
END $$;
