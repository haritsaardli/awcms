import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || '';

if (!supabaseUrl || !supabaseAnonKey) {
    console.error('Missing Supabase environment variables');
}

export const supabase = (supabaseUrl && supabaseAnonKey)
    ? createClient(supabaseUrl, supabaseAnonKey)
    : {} as any; // Fail gracefully or allow partial usage (middleware will catch error)

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
