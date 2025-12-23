-- Migration: Fix Tags Multi-Tenancy and Update Sync Function
-- Description: Scopes tag uniqueness to tenant_id and updates sync_resource_tags to require tenant_id.

-- 1. Drop the global unique constraint on slug
ALTER TABLE public.tags DROP CONSTRAINT IF EXISTS tags_slug_key;

-- 2. Create the scoped unique index (tenant_id, slug)
-- Note: Logic ensures we don't fail if it already exists
CREATE UNIQUE INDEX IF NOT EXISTS idx_tags_tenant_slug ON public.tags (tenant_id, slug);

-- 3. Drop default value on Sync Function to ensure we replace it cleanly (or handle overload)
-- We explicitly drop the OLD signature to avoid ambiguity
DROP FUNCTION IF EXISTS public.sync_resource_tags(uuid, text, text[]);

-- 4. Create new Secure Function with tenant_id param
CREATE OR REPLACE FUNCTION public.sync_resource_tags(p_resource_id uuid, p_resource_type text, p_tags text[], p_tenant_id uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    v_tag_id uuid;
    v_tag_name text;
    v_tag_ids uuid[] := ARRAY[]::uuid[];
    v_slug text;
BEGIN
    -- Strict Tenant Check
    IF p_tenant_id IS NULL THEN
        RAISE EXCEPTION 'Tenant ID is required for tag synchronization';
    END IF;

    IF p_tags IS NOT NULL THEN
        FOREACH v_tag_name IN ARRAY p_tags
        LOOP
            IF length(trim(v_tag_name)) > 0 THEN
                v_tag_name := trim(v_tag_name);
                v_slug := lower(regexp_replace(v_tag_name, '[^a-zA-Z0-9]+', '-', 'g'));
                v_slug := regexp_replace(v_slug, '^-+|-+$', '', 'g');
                
                -- Insert with tenant_id, conflict on (tenant_id, slug)
                INSERT INTO tags (name, slug, tenant_id, created_at, updated_at)
                VALUES (v_tag_name, v_slug, p_tenant_id, NOW(), NOW())
                ON CONFLICT (tenant_id, slug) DO UPDATE SET updated_at = NOW()
                RETURNING id INTO v_tag_id;
                
                -- Fallback lookup if simple update/insert didn't return (shouldn't happen with RETURNING but strict safety)
                IF v_tag_id IS NULL THEN
                    SELECT id INTO v_tag_id FROM tags WHERE slug = v_slug AND tenant_id = p_tenant_id;
                END IF;

                IF v_tag_id IS NOT NULL THEN
                    v_tag_ids := array_append(v_tag_ids, v_tag_id);
                END IF;
            END IF;
        END LOOP;
    END IF;

    -- Update Junction Tables
    -- Note: Junction tables use resource_id which is already tenant-scoped via RLS on the resource table.
    -- However, we only link tags that belong to the tenant (enforced by v_tag_id logic above)
    
    IF p_resource_type = 'articles' THEN
        DELETE FROM article_tags WHERE article_id = p_resource_id AND (cardinality(v_tag_ids) = 0 OR tag_id != ALL(v_tag_ids));
        IF cardinality(v_tag_ids) > 0 THEN
            INSERT INTO article_tags (article_id, tag_id)
            SELECT p_resource_id, unnest(v_tag_ids)
            ON CONFLICT (article_id, tag_id) DO NOTHING;
        END IF;
    ELSIF p_resource_type = 'pages' THEN
        DELETE FROM page_tags WHERE page_id = p_resource_id AND (cardinality(v_tag_ids) = 0 OR tag_id != ALL(v_tag_ids));
        IF cardinality(v_tag_ids) > 0 THEN
            INSERT INTO page_tags (page_id, tag_id)
            SELECT p_resource_id, unnest(v_tag_ids)
            ON CONFLICT (page_id, tag_id) DO NOTHING;
        END IF;
    ELSIF p_resource_type = 'video_gallery' THEN
        DELETE FROM video_gallery_tags WHERE video_gallery_id = p_resource_id AND (cardinality(v_tag_ids) = 0 OR tag_id != ALL(v_tag_ids));
        IF cardinality(v_tag_ids) > 0 THEN
             INSERT INTO video_gallery_tags (video_gallery_id, tag_id)
             SELECT p_resource_id, unnest(v_tag_ids)
             ON CONFLICT (video_gallery_id, tag_id) DO NOTHING;
        END IF;
    ELSIF p_resource_type = 'contacts' THEN
        DELETE FROM contact_tags WHERE contact_id = p_resource_id AND (cardinality(v_tag_ids) = 0 OR tag_id != ALL(v_tag_ids));
        IF cardinality(v_tag_ids) > 0 THEN
             INSERT INTO contact_tags (contact_id, tag_id)
             SELECT p_resource_id, unnest(v_tag_ids)
             ON CONFLICT (contact_id, tag_id) DO NOTHING;
        END IF;
    ELSIF p_resource_type = 'contact_messages' THEN
        DELETE FROM contact_message_tags WHERE message_id = p_resource_id AND (cardinality(v_tag_ids) = 0 OR tag_id != ALL(v_tag_ids));
        IF cardinality(v_tag_ids) > 0 THEN
             INSERT INTO contact_message_tags (message_id, tag_id)
             SELECT p_resource_id, unnest(v_tag_ids)
             ON CONFLICT (message_id, tag_id) DO NOTHING;
        END IF;
    ELSIF p_resource_type = 'product_types' THEN
        DELETE FROM product_type_tags WHERE product_type_id = p_resource_id AND (cardinality(v_tag_ids) = 0 OR tag_id != ALL(v_tag_ids));
        IF cardinality(v_tag_ids) > 0 THEN
             INSERT INTO product_type_tags (product_type_id, tag_id)
             SELECT p_resource_id, unnest(v_tag_ids)
             ON CONFLICT (product_type_id, tag_id) DO NOTHING;
        END IF;
    END IF;
END;
$function$;
