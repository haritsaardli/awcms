import { createClient } from '@supabase/supabase-js';

// Global instance removed to prevent startup crashes on Cloudflare
// where import.meta.env might not be fully populated at module-level.
// Use creatingClientFromEnv with runtime variables instead.
export const supabase = null;

// Helper to create client from Runtime Env (Cloudflare) or Build Env (Import Meta)
export const createClientFromEnv = (env: any = {}, headers: Record<string, string> = {}) => {
    // Try Runtime Env first, then fallback to Build Env
    const url = env.VITE_SUPABASE_URL || import.meta.env.VITE_SUPABASE_URL || '';
    const key = env.VITE_SUPABASE_ANON_KEY || import.meta.env.VITE_SUPABASE_ANON_KEY || '';

    if (!url || !key) {
        console.error('[Supabase] Missing URL or Key. Check Cloudflare Variables.');
        // Return null to indicate failure
        return null;
    }

    return createClient(url, key, {
        global: {
            headers: headers
        }
    });
};

export const createScopedClient = (headers: Record<string, string> = {}, env: any = {}) => {
    return createClientFromEnv(env, headers);
};
