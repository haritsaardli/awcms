-- Verification Script: Phase 2 Content Isolation
-- Tests RLS for Pages and Files

BEGIN;

-- 1. Setup Context
-- Create two test tenants
INSERT INTO public.tenants (id, name, slug, status) VALUES 
('11111111-1111-1111-1111-111111111111', 'Tenant A', 'tenant-a', 'active'),
('22222222-2222-2222-2222-222222222222', 'Tenant B', 'tenant-b', 'active')
ON CONFLICT DO NOTHING;

-- Create two test users
INSERT INTO auth.users (id, email) VALUES
('aaaa1111-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'user@tenant-a.com'),
('bbbb2222-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'user@tenant-b.com')
ON CONFLICT DO NOTHING;

-- Assign users to tenants
INSERT INTO public.users (id, email, tenant_id) VALUES
('aaaa1111-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'user@tenant-a.com', '11111111-1111-1111-1111-111111111111'),
('bbbb2222-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'user@tenant-b.com', '22222222-2222-2222-2222-222222222222')
ON CONFLICT (id) DO UPDATE SET tenant_id = EXCLUDED.tenant_id;

-- 2. Insert Data as Tenant A
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claim.sub = 'aaaa1111-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

-- Insert Page for A
INSERT INTO public.pages (title, slug, content, tenant_id) 
VALUES ('Page A', 'page-a', 'Content A', '11111111-1111-1111-1111-111111111111');

-- Insert File for A
INSERT INTO public.files (name, file_path, file_size, file_type, bucket_name, uploaded_by, tenant_id)
VALUES ('File A.jpg', '11111111-1111-1111-1111-111111111111/file-a.jpg', 100, 'image/jpeg', 'cms-uploads', 'aaaa1111-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111');

-- 3. Verify Visibility as Tenant A
SELECT 'Tenant A sees Pages count: ' || count(*) FROM public.pages;
SELECT 'Tenant A sees Files count: ' || count(*) FROM public.files;

-- 4. Switch to Tenant B
SET LOCAL request.jwt.claim.sub = 'bbbb2222-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

-- Verify Visibility as Tenant B (Should be 0 for previous inserts)
SELECT 'Tenant B sees Pages count (should be 0): ' || count(*) FROM public.pages WHERE title = 'Page A';
SELECT 'Tenant B sees Files count (should be 0): ' || count(*) FROM public.files WHERE name = 'File A.jpg';

-- 5. Insert Data as Tenant B
INSERT INTO public.pages (title, slug, content, tenant_id) 
VALUES ('Page B', 'page-b', 'Content B', '22222222-2222-2222-2222-222222222222');

-- 6. Switch back to Tenant A
SET LOCAL request.jwt.claim.sub = 'aaaa1111-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
SELECT 'Tenant A sees Page B (should be 0): ' || count(*) FROM public.pages WHERE title = 'Page B';

ROLLBACK;
