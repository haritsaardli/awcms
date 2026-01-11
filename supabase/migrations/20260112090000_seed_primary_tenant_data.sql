-- Migration: Seed Primary Tenant Data
-- Date: 2026-01-12
-- Description: Deletes existing data for 'primary' tenant and seeds new records for 'cms@ahliweb.com' and 'marketing@ahliweb.com'.

DO $$
DECLARE
    v_tenant_id UUID;
    v_cms_user_id UUID;
    v_marketing_user_id UUID;
    v_category_id UUID;
    v_tag_id UUID;
    i INT;
BEGIN
    -- 1. Get Tenant ID
    SELECT id INTO v_tenant_id FROM tenants WHERE slug = 'primary';
    
    -- 2. Get User IDs
    SELECT id INTO v_cms_user_id FROM auth.users WHERE email = 'cms@ahliweb.com';
    SELECT id INTO v_marketing_user_id FROM auth.users WHERE email = 'marketing@ahliweb.com';

    -- Only proceed if tenant exists
    IF v_tenant_id IS NOT NULL THEN
        RAISE NOTICE 'Seeding data for Tenant: %', v_tenant_id;

        -- 3. DELETE EXISTING DATA for this tenant (Content Modules)
        -- We delete dependent tables first if necessary, but most have standard FKs with ON DELETE SET NULL or CASCADE implicitly managed, 
        -- or we just delete the main records.
        -- Note: Many-to-many junction tables (article_tags, etc.) usually cascade on delete of main entity.
        
        DELETE FROM articles WHERE tenant_id = v_tenant_id;
        DELETE FROM pages WHERE tenant_id = v_tenant_id;
        DELETE FROM announcements WHERE tenant_id = v_tenant_id;
        DELETE FROM photo_gallery WHERE tenant_id = v_tenant_id;
        DELETE FROM testimonies WHERE tenant_id = v_tenant_id;
        DELETE FROM products WHERE tenant_id = v_tenant_id;
        DELETE FROM promotions WHERE tenant_id = v_tenant_id;
        DELETE FROM portfolio WHERE tenant_id = v_tenant_id;
        DELETE FROM contacts WHERE tenant_id = v_tenant_id;
        DELETE FROM orders WHERE tenant_id = v_tenant_id;
        
        -- Delete taxonomies for this tenant
        DELETE FROM categories WHERE tenant_id = v_tenant_id;
        DELETE FROM tags WHERE tenant_id = v_tenant_id;

        -- 4. SEED DATA FOR CMS USER (3 records)
        IF v_cms_user_id IS NOT NULL THEN
            RAISE NOTICE 'Creating records for CMS User: %', v_cms_user_id;
            
            FOR i IN 1..3 LOOP
                 -- Create Category
                INSERT INTO categories (name, slug, type, tenant_id, created_by)
                VALUES ('CMS Category ' || i, 'cms-category-' || i, 'article', v_tenant_id, v_cms_user_id)
                RETURNING id INTO v_category_id;
                
                -- Create Tag
                INSERT INTO tags (name, slug, tenant_id, created_by)
                VALUES ('CMS Tag ' || i, 'cms-tag-' || i, v_tenant_id, v_cms_user_id)
                RETURNING id INTO v_tag_id;

                -- Articles
                INSERT INTO articles (title, slug, content, status, tenant_id, created_by, category_id, tags)
                VALUES ('CMS Article ' || i, 'cms-article-' || i, 'Content for article ' || i, 'published', v_tenant_id, v_cms_user_id, v_category_id, ARRAY['CMS Tag ' || i]);

                -- Pages
                INSERT INTO pages (title, slug, content, status, tenant_id, created_by, category_id, tags)
                VALUES ('CMS Page ' || i, 'cms-page-' || i, 'Content for page ' || i, 'published', v_tenant_id, v_cms_user_id, v_category_id, ARRAY['CMS Tag ' || i]);
                
                -- Announcements
                INSERT INTO announcements (title, content, status, tenant_id, created_by, category_id, tags)
                VALUES ('CMS Announcement ' || i, 'Content for announcement ' || i, 'published', v_tenant_id, v_cms_user_id, v_category_id, ARRAY['CMS Tag ' || i]);
                
                -- Photo Gallery
                INSERT INTO photo_gallery (title, description, status, tenant_id, created_by, category_id, tags)
                VALUES ('CMS Gallery ' || i, 'Description for gallery ' || i, 'published', v_tenant_id, v_cms_user_id, v_category_id, ARRAY['CMS Tag ' || i]);
                
                -- Testimonies
                INSERT INTO testimonies (title, content, author_name, status, slug, tenant_id, created_by, category_id, tags)
                VALUES ('CMS Testimony ' || i, 'Content for testimony ' || i, 'Author ' || i, 'published', 'cms-testimony-' || i, v_tenant_id, v_cms_user_id, v_category_id, ARRAY['CMS Tag ' || i]);
                
                -- Products
                INSERT INTO products (name, slug, description, price, status, tenant_id, created_by, category_id, tags)
                VALUES ('CMS Product ' || i, 'cms-product-' || i, 'Description for product ' || i, 100 * i, 'published', v_tenant_id, v_cms_user_id, v_category_id, ARRAY['CMS Tag ' || i]);
                
                -- Promotions
                INSERT INTO promotions (title, description, discount_percentage, status, tenant_id, created_by, category_id, tags)
                VALUES ('CMS Promotion ' || i, 'Description for promotion ' || i, 10, 'published', v_tenant_id, v_cms_user_id, v_category_id, ARRAY['CMS Tag ' || i]);

                -- Portfolio
                INSERT INTO portfolio (title, slug, description, status, tenant_id, created_by, category_id)
                VALUES ('CMS Portfolio ' || i, 'cms-portfolio-' || i, 'Description for portfolio ' || i, 'published', v_tenant_id, v_cms_user_id, v_category_id);

                -- Contacts
                INSERT INTO contacts (name, email, description, tenant_id, created_by, tags)
                VALUES ('CMS Contact ' || i, 'cms' || i || '@example.com', 'Description for contact ' || i, v_tenant_id, v_cms_user_id, ARRAY['CMS Tag ' || i]);

            END LOOP;
        ELSE
            RAISE NOTICE 'User cms@ahliweb.com not found. Skipping.';
        END IF;

        -- 5. SEED DATA FOR MARKETING USER (4 records)
        IF v_marketing_user_id IS NOT NULL THEN
            RAISE NOTICE 'Creating records for Marketing User: %', v_marketing_user_id;

             FOR i IN 1..4 LOOP
                 -- Create Category
                INSERT INTO categories (name, slug, type, tenant_id, created_by)
                VALUES ('Marketing Category ' || i, 'marketing-category-' || i, 'article', v_tenant_id, v_marketing_user_id)
                RETURNING id INTO v_category_id;
                
                -- Create Tag
                INSERT INTO tags (name, slug, tenant_id, created_by)
                VALUES ('Marketing Tag ' || i, 'marketing-tag-' || i, v_tenant_id, v_marketing_user_id)
                RETURNING id INTO v_tag_id;

                -- Articles
                INSERT INTO articles (title, slug, content, status, tenant_id, created_by, category_id, tags)
                VALUES ('Marketing Article ' || i, 'marketing-article-' || i, 'Content for article ' || i, 'published', v_tenant_id, v_marketing_user_id, v_category_id, ARRAY['Marketing Tag ' || i]);

                -- Pages
                INSERT INTO pages (title, slug, content, status, tenant_id, created_by, category_id, tags)
                VALUES ('Marketing Page ' || i, 'marketing-page-' || i, 'Content for page ' || i, 'published', v_tenant_id, v_marketing_user_id, v_category_id, ARRAY['Marketing Tag ' || i]);
                
                -- Announcements
                INSERT INTO announcements (title, content, status, tenant_id, created_by, category_id, tags)
                VALUES ('Marketing Announcement ' || i, 'Content for announcement ' || i, 'published', v_tenant_id, v_marketing_user_id, v_category_id, ARRAY['Marketing Tag ' || i]);
                
                -- Photo Gallery
                INSERT INTO photo_gallery (title, description, status, tenant_id, created_by, category_id, tags)
                VALUES ('Marketing Gallery ' || i, 'Description for gallery ' || i, 'published', v_tenant_id, v_marketing_user_id, v_category_id, ARRAY['Marketing Tag ' || i]);
                
                -- Testimonies
                INSERT INTO testimonies (title, content, author_name, status, slug, tenant_id, created_by, category_id, tags)
                VALUES ('Marketing Testimony ' || i, 'Content for testimony ' || i, 'Author ' || i, 'published', 'marketing-testimony-' || i, v_tenant_id, v_marketing_user_id, v_category_id, ARRAY['Marketing Tag ' || i]);
                
                -- Products
                INSERT INTO products (name, slug, description, price, status, tenant_id, created_by, category_id, tags)
                VALUES ('Marketing Product ' || i, 'marketing-product-' || i, 'Description for product ' || i, 100 * i, 'published', v_tenant_id, v_marketing_user_id, v_category_id, ARRAY['Marketing Tag ' || i]);
                
                -- Promotions
                INSERT INTO promotions (title, description, discount_percentage, status, tenant_id, created_by, category_id, tags)
                VALUES ('Marketing Promotion ' || i, 'Description for promotion ' || i, 10, 'published', v_tenant_id, v_marketing_user_id, v_category_id, ARRAY['Marketing Tag ' || i]);
                
                -- Portfolio
                INSERT INTO portfolio (title, slug, description, status, tenant_id, created_by, category_id)
                VALUES ('Marketing Portfolio ' || i, 'marketing-portfolio-' || i, 'Description for portfolio ' || i, 'published', v_tenant_id, v_marketing_user_id, v_category_id);

                -- Contacts
                INSERT INTO contacts (name, email, description, tenant_id, created_by, tags)
                VALUES ('Marketing Contact ' || i, 'marketing' || i || '@example.com', 'Description for contact ' || i, v_tenant_id, v_marketing_user_id, ARRAY['Marketing Tag ' || i]);

            END LOOP;
        ELSE
            RAISE NOTICE 'User marketing@ahliweb.com not found. Skipping.';
        END IF;

    ELSE
        RAISE NOTICE 'Tenant "primary" not found. Skipping seed.';
    END IF;
END $$;
