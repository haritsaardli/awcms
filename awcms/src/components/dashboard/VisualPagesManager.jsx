import React, { useState } from 'react';
import PagesManager from './PagesManager';
import ThemeLayoutManager from './ThemeLayoutManager';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Layers, Palette } from 'lucide-react';

/**
 * VisualPagesManager
 * Manages both regular visual pages and system theme layouts.
 */
const VisualPagesManager = () => {
    return (
        <div className="space-y-6">
            <div className="flex flex-col gap-2">
                <h1 className="text-2xl font-bold tracking-tight">Visual Builder</h1>
                <p className="text-muted-foreground">Manage your visual pages and system theme templates.</p>
            </div>

            <Tabs defaultValue="pages" className="w-full">
                <div className="bg-slate-100 p-1 rounded-lg inline-flex mb-6">
                    <TabsList className="bg-transparent">
                        <TabsTrigger value="pages" className="flex items-center gap-2 px-4">
                            <Layers className="w-4 h-4" /> Content Pages
                        </TabsTrigger>
                        <TabsTrigger value="layouts" className="flex items-center gap-2 px-4">
                            <Palette className="w-4 h-4" /> Theme Layouts
                        </TabsTrigger>
                    </TabsList>
                </div>

                <TabsContent value="pages" className="mt-0">
                    {/* Render regular pages (page_type = regular) */}
                    <PagesManager onlyVisual={true} defaultFilters={{ page_type: 'regular' }} />
                </TabsContent>

                <TabsContent value="layouts" className="mt-0">
                    <ThemeLayoutManager />
                </TabsContent>
            </Tabs>
        </div>
    );
};

export default VisualPagesManager;
