/**
 * Menu fetching utilities for dynamic navigation from Supabase.
 * Syncs with MenusManager in admin panel for unified menu management.
 */
import type { SupabaseClient } from "@supabase/supabase-js";

export interface MenuItem {
  id: string;
  title: string;
  url: string;
  target?: string;
  icon?: string;
  badge?: string;
  badge_color?: string;
  children?: MenuItem[];
  is_active: boolean;
  sort_order: number;
}

export interface MenuData {
  id: string;
  name: string;
  slug: string;
  location: string;
  items: MenuItem[];
  is_active: boolean;
}

/**
 * Fetch menu by location (header, footer, sidebar, etc.)
 */
export async function getMenuByLocation(
  supabase: SupabaseClient,
  location: string,
  tenantId?: string | null,
): Promise<MenuData | null> {
  let query = supabase
    .from("menus")
    .select("*")
    .eq("location", location)
    .eq("is_active", true)
    .is("deleted_at", null);

  if (tenantId) {
    query = query.eq("tenant_id", tenantId);
  }

  const { data, error } = await query.single();

  if (error) {
    console.error(
      `[Menu] Error fetching menu for location "${location}":`,
      error.message,
    );
    return null;
  }

  if (!data) {
    return null;
  }

  // Parse items from JSON if stored as string
  let items: MenuItem[] = [];
  if (data.items) {
    try {
      items =
        typeof data.items === "string" ? JSON.parse(data.items) : data.items;
    } catch (e) {
      console.error(`[Menu] Error parsing menu items for "${location}":`, e);
      items = [];
    }
  }

  // Filter and sort active items
  const activeItems = filterActiveItems(items);

  return {
    id: data.id,
    name: data.name,
    slug: data.slug,
    location: data.location,
    items: activeItems,
    is_active: data.is_active,
  };
}

/**
 * Fetch all menus for a tenant
 */
export async function getAllMenus(
  supabase: SupabaseClient,
  tenantId?: string | null,
): Promise<MenuData[]> {
  let query = supabase
    .from("menus")
    .select("*")
    .eq("is_active", true)
    .is("deleted_at", null)
    .order("location");

  if (tenantId) {
    query = query.eq("tenant_id", tenantId);
  }

  const { data, error } = await query;

  if (error) {
    console.error("[Menu] Error fetching all menus:", error.message);
    return [];
  }

  return (data || []).map((menu) => {
    let items: MenuItem[] = [];
    if (menu.items) {
      try {
        items =
          typeof menu.items === "string" ? JSON.parse(menu.items) : menu.items;
      } catch {
        items = [];
      }
    }

    return {
      id: menu.id,
      name: menu.name,
      slug: menu.slug,
      location: menu.location,
      items: filterActiveItems(items),
      is_active: menu.is_active,
    };
  });
}

/**
 * Get menu items for header navigation
 */
export async function getHeaderMenu(
  supabase: SupabaseClient,
  tenantId?: string | null,
): Promise<MenuItem[]> {
  const menu = await getMenuByLocation(supabase, "header", tenantId);
  return menu?.items || [];
}

/**
 * Get menu items for footer navigation
 */
export async function getFooterMenu(
  supabase: SupabaseClient,
  tenantId?: string | null,
): Promise<MenuItem[]> {
  const menu = await getMenuByLocation(supabase, "footer", tenantId);
  return menu?.items || [];
}

/**
 * Recursively filter and sort active menu items
 */
function filterActiveItems(items: MenuItem[]): MenuItem[] {
  return items
    .filter((item) => item.is_active !== false)
    .sort((a, b) => (a.sort_order || 0) - (b.sort_order || 0))
    .map((item) => ({
      ...item,
      children: item.children ? filterActiveItems(item.children) : undefined,
    }));
}

/**
 * Build flat list of all URLs for sitemap generation
 */
export function extractMenuUrls(items: MenuItem[]): string[] {
  const urls: string[] = [];

  function traverse(items: MenuItem[]) {
    for (const item of items) {
      if (
        item.url &&
        !item.url.startsWith("#") &&
        !item.url.startsWith("http")
      ) {
        urls.push(item.url);
      }
      if (item.children) {
        traverse(item.children);
      }
    }
  }

  traverse(items);
  return urls;
}
