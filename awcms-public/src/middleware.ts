import { defineMiddleware } from "astro/middleware";
import { supabase } from "./lib/supabase";

export const onRequest = defineMiddleware(async (context, next) => {
    const { request, locals } = context;

    // 1. Resolve Host
    let host = request.headers.get("x-forwarded-host") || request.headers.get("host") || "";
    if (host.includes(":")) {
        host = host.split(":")[0];
    }

    // Dev override (add this to .env if needed)
    if (import.meta.env.DEV && import.meta.env.VITE_DEV_TENANT_HOST) {
        host = import.meta.env.VITE_DEV_TENANT_HOST;
    }

    // 2. Resolve Tenant ID via RPC
    // Using single-flight query to custom safe function
    const { data: tenantId, error } = await supabase
        .rpc('get_tenant_id_by_host', { lookup_host: host })
        .single();

    if (error || !tenantId) {
        console.warn(`Tenant resolution failed for host: ${host}`);
        // If no tenant found, return 404 or redirect to platform landing
        // For now, strict 404
        return new Response(`Tenant Not Found for host: ${host}`, { status: 404 });
    }

    // 3. Set Context
    locals.tenant_id = tenantId as string;
    locals.host = host;

    return next();
});
