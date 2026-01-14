drop policy "articles_delete_unified" on "public"."articles";

drop policy "articles_insert_unified" on "public"."articles";

drop policy "articles_select_unified" on "public"."articles";

drop policy "articles_update_unified" on "public"."articles";

drop policy "Public Read Published Funfacts" on "public"."funfacts";

drop policy "Tenant Delete Funfacts" on "public"."funfacts";

drop policy "Tenant Insert Funfacts" on "public"."funfacts";

drop policy "Tenant Select Funfacts" on "public"."funfacts";

drop policy "Tenant Update Funfacts" on "public"."funfacts";

drop policy "Public Read Published Partners" on "public"."partners";

drop policy "Tenant Delete Partners" on "public"."partners";

drop policy "Tenant Insert Partners" on "public"."partners";

drop policy "Tenant Select Partners" on "public"."partners";

drop policy "Tenant Update Partners" on "public"."partners";

drop policy "portfolio_delete_unified" on "public"."portfolio";

drop policy "portfolio_insert_unified" on "public"."portfolio";

drop policy "portfolio_select_unified" on "public"."portfolio";

drop policy "portfolio_update_unified" on "public"."portfolio";

drop policy "Public Read Published Services" on "public"."services";

drop policy "Tenant Delete Services" on "public"."services";

drop policy "Tenant Insert Services" on "public"."services";

drop policy "Tenant Select Services" on "public"."services";

drop policy "Tenant Update Services" on "public"."services";

drop policy "Public Read Published Teams" on "public"."teams";

drop policy "Tenant Delete Teams" on "public"."teams";

drop policy "Tenant Insert Teams" on "public"."teams";

drop policy "Tenant Select Teams" on "public"."teams";

drop policy "Tenant Update Teams" on "public"."teams";

drop policy "testimonies_delete_unified" on "public"."testimonies";

drop policy "testimonies_insert_unified" on "public"."testimonies";

drop policy "testimonies_select_unified" on "public"."testimonies";

drop policy "testimonies_update_unified" on "public"."testimonies";

alter table "public"."funfacts" drop column "order";

alter table "public"."funfacts" add column "display_order" integer default 0;

alter table "public"."partners" drop column "order";

alter table "public"."partners" add column "display_order" integer default 0;

alter table "public"."services" drop column "order";

alter table "public"."services" add column "display_order" integer default 0;

alter table "public"."teams" drop column "order";

alter table "public"."teams" add column "display_order" integer default 0;

CREATE INDEX idx_funfacts_created_by ON public.funfacts USING btree (created_by);

CREATE INDEX idx_funfacts_display_order ON public.funfacts USING btree (display_order);

CREATE INDEX idx_funfacts_tenant_id ON public.funfacts USING btree (tenant_id);

CREATE INDEX idx_funfacts_updated_by ON public.funfacts USING btree (updated_by);

CREATE INDEX idx_partners_created_by ON public.partners USING btree (created_by);

CREATE INDEX idx_partners_display_order ON public.partners USING btree (display_order);

CREATE INDEX idx_partners_tenant_id ON public.partners USING btree (tenant_id);

CREATE INDEX idx_partners_updated_by ON public.partners USING btree (updated_by);

CREATE INDEX idx_services_created_by ON public.services USING btree (created_by);

CREATE INDEX idx_services_display_order ON public.services USING btree (display_order);

CREATE INDEX idx_services_tenant_id ON public.services USING btree (tenant_id);

CREATE INDEX idx_services_updated_by ON public.services USING btree (updated_by);

CREATE INDEX idx_teams_created_by ON public.teams USING btree (created_by);

CREATE INDEX idx_teams_display_order ON public.teams USING btree (display_order);

CREATE INDEX idx_teams_tenant_id ON public.teams USING btree (tenant_id);

CREATE INDEX idx_teams_updated_by ON public.teams USING btree (updated_by);


  create policy "articles_delete_unified"
  on "public"."articles"
  as permissive
  for delete
  to public
using ((((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) AND ( SELECT public.is_admin_or_above() AS is_admin_or_above)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "articles_insert_unified"
  on "public"."articles"
  as permissive
  for insert
  to public
with check ((((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) AND ( SELECT public.is_admin_or_above() AS is_admin_or_above)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "articles_select_unified"
  on "public"."articles"
  as permissive
  for select
  to public
using (((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "articles_update_unified"
  on "public"."articles"
  as permissive
  for update
  to public
using ((((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) AND ( SELECT public.is_admin_or_above() AS is_admin_or_above)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "Public Read Published Funfacts"
  on "public"."funfacts"
  as permissive
  for select
  to anon
using ((status = 'published'::text));



  create policy "Tenant Delete Funfacts"
  on "public"."funfacts"
  as permissive
  for delete
  to authenticated
using ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "Tenant Insert Funfacts"
  on "public"."funfacts"
  as permissive
  for insert
  to authenticated
with check ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "Tenant Select Funfacts"
  on "public"."funfacts"
  as permissive
  for select
  to authenticated
using ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "Tenant Update Funfacts"
  on "public"."funfacts"
  as permissive
  for update
  to authenticated
using ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "Public Read Published Partners"
  on "public"."partners"
  as permissive
  for select
  to anon
using ((status = 'published'::text));



  create policy "Tenant Delete Partners"
  on "public"."partners"
  as permissive
  for delete
  to authenticated
using ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "Tenant Insert Partners"
  on "public"."partners"
  as permissive
  for insert
  to authenticated
with check ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "Tenant Select Partners"
  on "public"."partners"
  as permissive
  for select
  to authenticated
using ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "Tenant Update Partners"
  on "public"."partners"
  as permissive
  for update
  to authenticated
using ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "portfolio_delete_unified"
  on "public"."portfolio"
  as permissive
  for delete
  to public
using ((((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) AND ( SELECT public.is_admin_or_above() AS is_admin_or_above)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "portfolio_insert_unified"
  on "public"."portfolio"
  as permissive
  for insert
  to public
with check ((((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) AND ( SELECT public.is_admin_or_above() AS is_admin_or_above)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "portfolio_select_unified"
  on "public"."portfolio"
  as permissive
  for select
  to public
using (((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "portfolio_update_unified"
  on "public"."portfolio"
  as permissive
  for update
  to public
using ((((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) AND ( SELECT public.is_admin_or_above() AS is_admin_or_above)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "Public Read Published Services"
  on "public"."services"
  as permissive
  for select
  to anon
using ((status = 'published'::text));



  create policy "Tenant Delete Services"
  on "public"."services"
  as permissive
  for delete
  to authenticated
using ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "Tenant Insert Services"
  on "public"."services"
  as permissive
  for insert
  to authenticated
with check ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "Tenant Select Services"
  on "public"."services"
  as permissive
  for select
  to authenticated
using ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "Tenant Update Services"
  on "public"."services"
  as permissive
  for update
  to authenticated
using ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "Public Read Published Teams"
  on "public"."teams"
  as permissive
  for select
  to anon
using ((status = 'published'::text));



  create policy "Tenant Delete Teams"
  on "public"."teams"
  as permissive
  for delete
  to authenticated
using ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "Tenant Insert Teams"
  on "public"."teams"
  as permissive
  for insert
  to authenticated
with check ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "Tenant Select Teams"
  on "public"."teams"
  as permissive
  for select
  to authenticated
using ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "Tenant Update Teams"
  on "public"."teams"
  as permissive
  for update
  to authenticated
using ((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)));



  create policy "testimonies_delete_unified"
  on "public"."testimonies"
  as permissive
  for delete
  to public
using ((((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) AND ( SELECT public.is_admin_or_above() AS is_admin_or_above)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "testimonies_insert_unified"
  on "public"."testimonies"
  as permissive
  for insert
  to public
with check ((((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) AND ( SELECT public.is_admin_or_above() AS is_admin_or_above)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "testimonies_select_unified"
  on "public"."testimonies"
  as permissive
  for select
  to public
using (((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "testimonies_update_unified"
  on "public"."testimonies"
  as permissive
  for update
  to public
using ((((tenant_id = ( SELECT public.current_tenant_id() AS current_tenant_id)) AND ( SELECT public.is_admin_or_above() AS is_admin_or_above)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



