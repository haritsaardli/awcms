
/**
 * Tier Feature Mapping
 * Defines which features are available for each subscription tier.
 */

export const TIER_FEATURES = {
    free: [
        'home', 'articles', 'pages', 'visual_builder', 'media',
        'categories', 'tags', 'files', 'portfolio', 'testimonials',
        'announcements', 'promotions', 'inbox', 'menus', 'products',
        'product_types', 'orders', 'contacts', 'messages', 'contact_messages', 'users', 'profile'
    ],
    pro: [
        // Includes all Free features
        'ALL_FREE',
        'themes', 'roles', 'permissions', 'seo_manager', 'languages',
        'notifications', 'audit_logs', 'settings_branding', 'backup'
    ],
    enterprise: [
        // Includes all Pro features
        'ALL_PRO',
        'sso', 'extensions', 'sidebar_manager', 'tenants'
    ]
};

const resolveFeatures = (tier) => {
    const tierKey = tier?.toLowerCase() || 'free';

    // Helper to get features recursively (simple implementation)
    const getFeatures = (t) => {
        const list = TIER_FEATURES[t] || [];
        let resolved = [];
        list.forEach(f => {
            if (f === 'ALL_FREE') resolved = [...resolved, ...getFeatures('free')];
            else if (f === 'ALL_PRO') resolved = [...resolved, ...getFeatures('pro')];
            else resolved.push(f);
        });
        return resolved;
    };

    return getFeatures(tierKey);
};

export const checkTierAccess = (tier, featureKey) => {
    // Platform Admins (usually on 'enterprise' or implicit super access) might bypass, 
    // but here we check strictly by tier config.
    // If featureKey is undefined or empty, we assume it's visible (general pages).
    if (!featureKey) return true;

    const allowedFeatures = resolveFeatures(tier);
    // Extensions are special: usually handled by 'extensions' key
    if (featureKey.startsWith('ext-')) return allowedFeatures.includes('extensions');

    return allowedFeatures.includes(featureKey);
};
