import React from 'react';
import { useTranslation } from 'react-i18next';
import { LayoutTemplate } from 'lucide-react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import TemplatesList from './templates/TemplatesList';
import TemplatePartsList from './templates/TemplatePartsList';
import TemplateAssignments from './templates/TemplateAssignments';
import TemplateLanguageManager from './templates/TemplateLanguageManager';
import { usePermissions } from '@/contexts/PermissionContext';

const TemplatesManager = () => {
    const { t } = useTranslation();
    const { hasPermission } = usePermissions();

    return (
        <div className="p-6 max-w-7xl mx-auto space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold text-slate-900">Templates</h1>
                    <p className="text-slate-500 mt-1">Manage page templates, parts, and assignments.</p>
                </div>
            </div>

            <Tabs defaultValue="pages" className="w-full">
                <TabsList className="grid w-full grid-cols-4 lg:w-[600px]">
                    <TabsTrigger value="pages">Page Templates</TabsTrigger>
                    <TabsTrigger value="parts">Template Parts</TabsTrigger>
                    <TabsTrigger value="assignments">Assignments</TabsTrigger>
                    <TabsTrigger value="languages">Languages</TabsTrigger>
                </TabsList>

                <TabsContent value="pages" className="mt-6">
                    <TemplatesList />
                </TabsContent>

                <TabsContent value="parts" className="mt-6">
                    <TemplatePartsList />
                </TabsContent>

                <TabsContent value="assignments" className="mt-6">
                    <TemplateAssignments />
                </TabsContent>

                <TabsContent value="languages" className="mt-6">
                    <TemplateLanguageManager />
                </TabsContent>
            </Tabs>
        </div>
    );
};

export default TemplatesManager;
