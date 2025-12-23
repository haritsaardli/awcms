import React, { createContext, useContext, useEffect, useState } from 'react';
import { hooks } from '@/lib/hooks';
import { supabase } from '@/lib/customSupabaseClient';
import { getExtensionComponent } from '@/lib/extensionRegistry';

const PluginContext = createContext(null);

export const usePlugins = () => {
    const context = useContext(PluginContext);
    if (!context) {
        throw new Error('usePlugins must be used within a PluginProvider');
    }
    return context;
};

/**
 * Component to render content injected via actions
 * Usage: <PluginAction name="dashboard_top" args={[user]} />
 */
export const PluginAction = ({ name, args = [], fallback = null }) => {
    // Actions are usually void, but for UI rendering we can use a "render_action" pattern
    // where plugins register a component to be rendered.
    // However, the standard 'doAction' is for logic. 
    // For UI injection, we often use a filter that returns an array of components.

    // Alternative: We can define a convention where 'applyFilters' is used for UI lists.
    // Example: const widgets = applyFilters('dashboard_widgets', []);

    // But specific 'slot' rendering is common.
    // Let's implement a 'Slot' helper that uses filters to gather content.

    const { applyFilters } = usePlugins();

    // Plugins can hook into 'name' and append their component to the array
    const components = applyFilters(name, []);

    if (!Array.isArray(components) || components.length === 0) {
        return fallback;
    }

    return (
        <>
            {components.map((Comp, index) => (
                <React.Fragment key={index}>
                    {React.isValidElement(Comp) ? Comp : <Comp {...(args[0] || {})} />}
                </React.Fragment>
            ))}
        </>
    );
};

export const PluginProvider = ({ children }) => {
    const [isLoading, setIsLoading] = useState(true);
    const [activeExtensions, setActiveExtensions] = useState([]);

    // Expose hook methods
    const { addAction, doAction, addFilter, applyFilters, removeAction, removeFilter } = hooks;

    useEffect(() => {
        const loadExtensions = async () => {
            setIsLoading(true);
            try {
                // 1. Fetch active extensions
                const { data: extensions, error } = await supabase
                    .from('extensions')
                    .select('*')
                    .eq('is_active', true)
                    .is('deleted_at', null);

                if (error) throw error;

                setActiveExtensions(extensions || []);

                // 2. Register Loops
                // For each extension, we look up its entry point in the static registry
                // and call its 'register' function if it exists.
                // Note: Since code is bundled, we still rely on extensionRegistry.js to map 
                // DB keys to actual code.

                if (extensions) {
                    for (const ext of extensions) {
                        try {
                            const extensionModule = getExtensionComponent(ext.component_key);

                            // If the module exports a 'register' function, run it.
                            // We need to handle how getExtensionComponent returns. 
                            // Currently it returns a Component. 
                            // We might need to adjust genericRegistry to export the module or an object.

                            // Let's assume for strict "WordPress Style", we need a 'register' function.
                            // But getExtensionComponent currently just returns the Main Component (for UI).
                            // We might need a separate 'getExtensionEntry' or check if the Component has a static 'register' method.

                            if (extensionModule && typeof extensionModule.register === 'function') {
                                extensionModule.register({ addAction, addFilter, supabase });
                            }

                            // Also check if there's a standalone register function exported alongside if we change registry import
                        } catch (err) {
                            console.error(`Failed to register extension ${ext.name}:`, err);
                        }
                    }
                }

                // 3. Trigger 'plugins_loaded' action
                doAction('plugins_loaded');

            } catch (err) {
                console.error("Error loading extensions:", err);
            } finally {
                setIsLoading(false);
            }
        };

        loadExtensions();
    }, []);

    const value = {
        isLoading,
        activeExtensions,
        addAction,
        doAction,
        addFilter,
        applyFilters,
        removeAction,
        removeFilter
    };

    return (
        <PluginContext.Provider value={value}>
            {children}
        </PluginContext.Provider>
    );
};
