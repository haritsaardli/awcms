/**
 * Sidebar configuration and fetching utilities.
 * Manages dynamic sidebar menus and navigation from Supabase.
 */
import type { SupabaseClient } from "@supabase/supabase-js";

export interface SidebarItem {
  id: string;
  title: string;
  href: string;
  icon?: string;
  badge?: string;
  badge_color?: string;
  permission?: string;
  is_active: boolean;
  is_collapsed?: boolean;
  children?: SidebarItem[];
}

export interface SidebarGroup {
  id: string;
  title: string;
  icon?: string;
  is_collapsed?: boolean;
  items: SidebarItem[];
  sort_order: number;
}

export interface SidebarConfig {
  groups: SidebarGroup[];
  collapsible: boolean;
  show_icons: boolean;
  compact_mode: boolean;
}

/**
 * Fetch sidebar configuration for public portal
 */
export async function getSidebarConfig(
  supabase: SupabaseClient,
  location: string = "public_sidebar",
  tenantId?: string | null,
): Promise<SidebarConfig | null> {
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
    if (error.code === "PGRST116") return null;
    console.error("[Sidebar] Error fetching sidebar:", error.message);
    return null;
  }

  // Parse items into groups
  let items: SidebarItem[] = [];
  if (data.items) {
    try {
      items =
        typeof data.items === "string" ? JSON.parse(data.items) : data.items;
    } catch {
      items = [];
    }
  }

  // Group items by parent or create default group
  const groups = groupSidebarItems(items);

  return {
    groups,
    collapsible: data.settings?.collapsible ?? true,
    show_icons: data.settings?.show_icons ?? true,
    compact_mode: data.settings?.compact_mode ?? false,
  };
}

/**
 * Group flat items into sidebar groups
 */
function groupSidebarItems(items: SidebarItem[]): SidebarGroup[] {
  const groups: SidebarGroup[] = [];
  const ungroupedItems: SidebarItem[] = [];

  // First pass: find groups (items with children)
  for (const item of items) {
    if (item.children && item.children.length > 0) {
      groups.push({
        id: item.id,
        title: item.title,
        icon: item.icon,
        is_collapsed: item.is_collapsed,
        items: item.children.filter((c) => c.is_active !== false),
        sort_order: groups.length,
      });
    } else if (item.is_active !== false) {
      ungroupedItems.push(item);
    }
  }

  // Add ungrouped items as a default group if any
  if (ungroupedItems.length > 0) {
    groups.unshift({
      id: "default",
      title: "",
      items: ungroupedItems,
      sort_order: 0,
    });
  }

  return groups.sort((a, b) => a.sort_order - b.sort_order);
}

/**
 * Filter sidebar items by user permissions
 */
export function filterByPermissions(
  groups: SidebarGroup[],
  userPermissions: string[],
): SidebarGroup[] {
  return groups
    .map((group) => ({
      ...group,
      items: group.items.filter((item) => {
        if (!item.permission) return true;
        return userPermissions.includes(item.permission);
      }),
    }))
    .filter((group) => group.items.length > 0);
}

/**
 * Check if current path matches sidebar item
 */
export function isActivePath(itemHref: string, currentPath: string): boolean {
  if (itemHref === "/") {
    return currentPath === "/";
  }
  return currentPath.startsWith(itemHref);
}

/**
 * Get breadcrumb trail from sidebar
 */
export function getBreadcrumbFromSidebar(
  groups: SidebarGroup[],
  currentPath: string,
): { title: string; href: string }[] {
  const breadcrumb: { title: string; href: string }[] = [];

  for (const group of groups) {
    for (const item of group.items) {
      if (isActivePath(item.href, currentPath)) {
        if (group.title) {
          breadcrumb.push({
            title: group.title,
            href: group.items[0]?.href || "#",
          });
        }
        breadcrumb.push({ title: item.title, href: item.href });

        // Check children
        if (item.children) {
          for (const child of item.children) {
            if (isActivePath(child.href, currentPath)) {
              breadcrumb.push({ title: child.title, href: child.href });
              break;
            }
          }
        }
        return breadcrumb;
      }
    }
  }

  return breadcrumb;
}
