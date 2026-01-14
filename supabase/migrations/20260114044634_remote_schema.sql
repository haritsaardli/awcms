
  create table "public"."funfacts" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "updated_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "deleted_at" timestamp with time zone,
    "tenant_id" uuid not null,
    "created_by" uuid,
    "updated_by" uuid,
    "title" text not null,
    "count" text,
    "icon" text,
    "order" integer default 0,
    "status" text default 'published'::text
      );


alter table "public"."funfacts" enable row level security;


  create table "public"."partners" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "updated_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "deleted_at" timestamp with time zone,
    "tenant_id" uuid not null,
    "created_by" uuid,
    "updated_by" uuid,
    "name" text not null,
    "logo" text,
    "link" text,
    "order" integer default 0,
    "status" text default 'published'::text
      );


alter table "public"."partners" enable row level security;


  create table "public"."services" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "updated_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "deleted_at" timestamp with time zone,
    "tenant_id" uuid not null,
    "created_by" uuid,
    "updated_by" uuid,
    "title" text not null,
    "description" text,
    "icon" text,
    "image" text,
    "link" text,
    "order" integer default 0,
    "status" text default 'published'::text
      );


alter table "public"."services" enable row level security;


  create table "public"."teams" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "updated_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "deleted_at" timestamp with time zone,
    "tenant_id" uuid not null,
    "created_by" uuid,
    "updated_by" uuid,
    "name" text not null,
    "role" text,
    "image" text,
    "social_links" jsonb default '[]'::jsonb,
    "order" integer default 0,
    "status" text default 'published'::text
      );


alter table "public"."teams" enable row level security;

CREATE UNIQUE INDEX funfacts_pkey ON public.funfacts USING btree (id);

CREATE UNIQUE INDEX partners_pkey ON public.partners USING btree (id);

CREATE UNIQUE INDEX services_pkey ON public.services USING btree (id);

CREATE UNIQUE INDEX teams_pkey ON public.teams USING btree (id);

alter table "public"."funfacts" add constraint "funfacts_pkey" PRIMARY KEY using index "funfacts_pkey";

alter table "public"."partners" add constraint "partners_pkey" PRIMARY KEY using index "partners_pkey";

alter table "public"."services" add constraint "services_pkey" PRIMARY KEY using index "services_pkey";

alter table "public"."teams" add constraint "teams_pkey" PRIMARY KEY using index "teams_pkey";

alter table "public"."funfacts" add constraint "funfacts_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "public"."funfacts" validate constraint "funfacts_created_by_fkey";

alter table "public"."funfacts" add constraint "funfacts_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'published'::text, 'archived'::text]))) not valid;

alter table "public"."funfacts" validate constraint "funfacts_status_check";

alter table "public"."funfacts" add constraint "funfacts_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."funfacts" validate constraint "funfacts_tenant_id_fkey";

alter table "public"."funfacts" add constraint "funfacts_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "public"."funfacts" validate constraint "funfacts_updated_by_fkey";

alter table "public"."partners" add constraint "partners_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "public"."partners" validate constraint "partners_created_by_fkey";

alter table "public"."partners" add constraint "partners_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'published'::text, 'archived'::text]))) not valid;

alter table "public"."partners" validate constraint "partners_status_check";

alter table "public"."partners" add constraint "partners_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."partners" validate constraint "partners_tenant_id_fkey";

alter table "public"."partners" add constraint "partners_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "public"."partners" validate constraint "partners_updated_by_fkey";

alter table "public"."services" add constraint "services_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "public"."services" validate constraint "services_created_by_fkey";

alter table "public"."services" add constraint "services_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'published'::text, 'archived'::text]))) not valid;

alter table "public"."services" validate constraint "services_status_check";

alter table "public"."services" add constraint "services_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."services" validate constraint "services_tenant_id_fkey";

alter table "public"."services" add constraint "services_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "public"."services" validate constraint "services_updated_by_fkey";

alter table "public"."teams" add constraint "teams_created_by_fkey" FOREIGN KEY (created_by) REFERENCES auth.users(id) not valid;

alter table "public"."teams" validate constraint "teams_created_by_fkey";

alter table "public"."teams" add constraint "teams_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'published'::text, 'archived'::text]))) not valid;

alter table "public"."teams" validate constraint "teams_status_check";

alter table "public"."teams" add constraint "teams_tenant_id_fkey" FOREIGN KEY (tenant_id) REFERENCES public.tenants(id) not valid;

alter table "public"."teams" validate constraint "teams_tenant_id_fkey";

alter table "public"."teams" add constraint "teams_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;

alter table "public"."teams" validate constraint "teams_updated_by_fkey";

grant delete on table "public"."funfacts" to "anon";

grant insert on table "public"."funfacts" to "anon";

grant references on table "public"."funfacts" to "anon";

grant select on table "public"."funfacts" to "anon";

grant trigger on table "public"."funfacts" to "anon";

grant truncate on table "public"."funfacts" to "anon";

grant update on table "public"."funfacts" to "anon";

grant delete on table "public"."funfacts" to "authenticated";

grant insert on table "public"."funfacts" to "authenticated";

grant references on table "public"."funfacts" to "authenticated";

grant select on table "public"."funfacts" to "authenticated";

grant trigger on table "public"."funfacts" to "authenticated";

grant truncate on table "public"."funfacts" to "authenticated";

grant update on table "public"."funfacts" to "authenticated";

grant delete on table "public"."funfacts" to "service_role";

grant insert on table "public"."funfacts" to "service_role";

grant references on table "public"."funfacts" to "service_role";

grant select on table "public"."funfacts" to "service_role";

grant trigger on table "public"."funfacts" to "service_role";

grant truncate on table "public"."funfacts" to "service_role";

grant update on table "public"."funfacts" to "service_role";

grant delete on table "public"."partners" to "anon";

grant insert on table "public"."partners" to "anon";

grant references on table "public"."partners" to "anon";

grant select on table "public"."partners" to "anon";

grant trigger on table "public"."partners" to "anon";

grant truncate on table "public"."partners" to "anon";

grant update on table "public"."partners" to "anon";

grant delete on table "public"."partners" to "authenticated";

grant insert on table "public"."partners" to "authenticated";

grant references on table "public"."partners" to "authenticated";

grant select on table "public"."partners" to "authenticated";

grant trigger on table "public"."partners" to "authenticated";

grant truncate on table "public"."partners" to "authenticated";

grant update on table "public"."partners" to "authenticated";

grant delete on table "public"."partners" to "service_role";

grant insert on table "public"."partners" to "service_role";

grant references on table "public"."partners" to "service_role";

grant select on table "public"."partners" to "service_role";

grant trigger on table "public"."partners" to "service_role";

grant truncate on table "public"."partners" to "service_role";

grant update on table "public"."partners" to "service_role";

grant delete on table "public"."services" to "anon";

grant insert on table "public"."services" to "anon";

grant references on table "public"."services" to "anon";

grant select on table "public"."services" to "anon";

grant trigger on table "public"."services" to "anon";

grant truncate on table "public"."services" to "anon";

grant update on table "public"."services" to "anon";

grant delete on table "public"."services" to "authenticated";

grant insert on table "public"."services" to "authenticated";

grant references on table "public"."services" to "authenticated";

grant select on table "public"."services" to "authenticated";

grant trigger on table "public"."services" to "authenticated";

grant truncate on table "public"."services" to "authenticated";

grant update on table "public"."services" to "authenticated";

grant delete on table "public"."services" to "service_role";

grant insert on table "public"."services" to "service_role";

grant references on table "public"."services" to "service_role";

grant select on table "public"."services" to "service_role";

grant trigger on table "public"."services" to "service_role";

grant truncate on table "public"."services" to "service_role";

grant update on table "public"."services" to "service_role";

grant delete on table "public"."teams" to "anon";

grant insert on table "public"."teams" to "anon";

grant references on table "public"."teams" to "anon";

grant select on table "public"."teams" to "anon";

grant trigger on table "public"."teams" to "anon";

grant truncate on table "public"."teams" to "anon";

grant update on table "public"."teams" to "anon";

grant delete on table "public"."teams" to "authenticated";

grant insert on table "public"."teams" to "authenticated";

grant references on table "public"."teams" to "authenticated";

grant select on table "public"."teams" to "authenticated";

grant trigger on table "public"."teams" to "authenticated";

grant truncate on table "public"."teams" to "authenticated";

grant update on table "public"."teams" to "authenticated";

grant delete on table "public"."teams" to "service_role";

grant insert on table "public"."teams" to "service_role";

grant references on table "public"."teams" to "service_role";

grant select on table "public"."teams" to "service_role";

grant trigger on table "public"."teams" to "service_role";

grant truncate on table "public"."teams" to "service_role";

grant update on table "public"."teams" to "service_role";


  create policy "Public Read Published Funfacts"
  on "public"."funfacts"
  as permissive
  for select
  to public
using ((status = 'published'::text));



  create policy "Tenant Delete Funfacts"
  on "public"."funfacts"
  as permissive
  for delete
  to public
using ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



  create policy "Tenant Insert Funfacts"
  on "public"."funfacts"
  as permissive
  for insert
  to public
with check ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



  create policy "Tenant Select Funfacts"
  on "public"."funfacts"
  as permissive
  for select
  to public
using ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



  create policy "Tenant Update Funfacts"
  on "public"."funfacts"
  as permissive
  for update
  to public
using ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



  create policy "Public Read Published Partners"
  on "public"."partners"
  as permissive
  for select
  to public
using ((status = 'published'::text));



  create policy "Tenant Delete Partners"
  on "public"."partners"
  as permissive
  for delete
  to public
using ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



  create policy "Tenant Insert Partners"
  on "public"."partners"
  as permissive
  for insert
  to public
with check ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



  create policy "Tenant Select Partners"
  on "public"."partners"
  as permissive
  for select
  to public
using ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



  create policy "Tenant Update Partners"
  on "public"."partners"
  as permissive
  for update
  to public
using ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



  create policy "Public Read Published Services"
  on "public"."services"
  as permissive
  for select
  to public
using ((status = 'published'::text));



  create policy "Tenant Delete Services"
  on "public"."services"
  as permissive
  for delete
  to public
using ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



  create policy "Tenant Insert Services"
  on "public"."services"
  as permissive
  for insert
  to public
with check ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



  create policy "Tenant Select Services"
  on "public"."services"
  as permissive
  for select
  to public
using ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



  create policy "Tenant Update Services"
  on "public"."services"
  as permissive
  for update
  to public
using ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



  create policy "Public Read Published Teams"
  on "public"."teams"
  as permissive
  for select
  to public
using ((status = 'published'::text));



  create policy "Tenant Delete Teams"
  on "public"."teams"
  as permissive
  for delete
  to public
using ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



  create policy "Tenant Insert Teams"
  on "public"."teams"
  as permissive
  for insert
  to public
with check ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



  create policy "Tenant Select Teams"
  on "public"."teams"
  as permissive
  for select
  to public
using ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



  create policy "Tenant Update Teams"
  on "public"."teams"
  as permissive
  for update
  to public
using ((tenant_id = ( SELECT (current_setting('app.current_tenant_id'::text, true))::uuid AS current_setting)));



