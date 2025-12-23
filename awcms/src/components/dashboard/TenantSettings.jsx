import React, { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { supabase } from '@/lib/customSupabaseClient';
import { useTenant } from '@/contexts/TenantContext';
import { usePermissions } from '@/contexts/PermissionContext';
import { useToast } from '@/components/ui/use-toast';

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Separator } from '@/components/ui/separator';
import { ImageUpload } from '@/components/ui/ImageUpload';
import { Loader2, Save } from 'lucide-react';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';

export default function TenantSettings() {
    const { currentTenant: tenant, loading: tenantLoading } = useTenant();
    const { checkAccess } = usePermissions();
    const { toast } = useToast();
    const [saving, setSaving] = useState(false);

    // Permission Check
    const canManageSettings = checkAccess('update', 'setting');
    // Ideally we'd have a specific permission 'manage_tenant_settings', but 'update_settings' is a fair proxy for now.

    const form = useForm({
        defaultValues: {
            brandColor: '#000000',
            fontFamily: 'Inter',
            logoUrl: '',
            siteName: ''
        }
    });

    useEffect(() => {
        if (tenant) {
            form.reset({
                brandColor: tenant.config?.theme?.brandColor || '#000000',
                fontFamily: tenant.config?.theme?.fontFamily || 'Inter',
                logoUrl: tenant.config?.theme?.logoUrl || '',
                siteName: tenant.config?.settings?.siteName || tenant.name || ''
            });
        }
    }, [tenant, form]);

    const onSubmit = async (values) => {
        setSaving(true);
        try {
            const newConfig = {
                ...tenant.config,
                theme: {
                    brandColor: values.brandColor,
                    fontFamily: values.fontFamily,
                    logoUrl: values.logoUrl
                },
                settings: {
                    ...tenant.config?.settings,
                    siteName: values.siteName
                }
            };

            const { error } = await supabase
                .from('tenants')
                .update({
                    config: newConfig,
                    updated_at: new Date().toISOString()
                })
                .eq('id', tenant.id);

            if (error) throw error;

            toast({ title: 'Settings Saved', description: 'Your tenant settings have been updated.' });

            // Note: refreshTenant not available in current TenantContext
            // Full refresh would require page reload or context enhancement

        } catch (err) {
            console.error('Error saving settings:', err);
            toast({ variant: 'destructive', title: 'Error', description: err.message });
        } finally {
            setSaving(false);
        }
    };

    if (tenantLoading) return <div className="p-8 flex justify-center"><Loader2 className="animate-spin text-slate-400" /></div>;
    if (!tenant) return <div className="p-8 text-center"><h2 className="text-xl font-bold text-slate-800">Tenant Not Found</h2><p className="text-slate-500">Unable to load tenant settings.</p></div>;

    if (!canManageSettings) {
        return (
            <div className="p-8 text-center">
                <h2 className="text-xl font-bold text-slate-800">Access Denied</h2>
                <p className="text-slate-500">You do not have permission to manage tenant settings.</p>
            </div>
        );
    }

    return (
        <div className="max-w-4xl mx-auto space-y-6 pb-12">
            <div>
                <h1 className="text-3xl font-bold tracking-tight text-slate-900">Tenant Settings</h1>
                <p className="text-slate-500">Manage your organization's branding and preferences.</p>
            </div>

            <Form {...form}>
                <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">

                    {/* Branding Section */}
                    <Card>
                        <CardHeader>
                            <CardTitle>Branding</CardTitle>
                            <CardDescription>Customize how your portal looks.</CardDescription>
                        </CardHeader>
                        <CardContent className="space-y-4">

                            <FormField
                                control={form.control}
                                name="siteName"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Site Name</FormLabel>
                                        <FormControl>
                                            <Input placeholder="Acme Corp" {...field} />
                                        </FormControl>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                <FormField
                                    control={form.control}
                                    name="brandColor"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Brand Color</FormLabel>
                                            <div className="flex gap-3 items-center">
                                                <div className="relative">
                                                    <div
                                                        className="w-12 h-12 rounded-lg border-2 border-slate-200 shadow-sm cursor-pointer transition-transform hover:scale-105"
                                                        style={{ backgroundColor: field.value }}
                                                        onClick={() => document.getElementById('color-picker').click()}
                                                    />
                                                    <input
                                                        id="color-picker"
                                                        type="color"
                                                        className="invisible absolute top-0 left-0 w-full h-full"
                                                        value={field.value}
                                                        onChange={(e) => field.onChange(e.target.value)}
                                                    />
                                                </div>
                                                <div className="flex-1">
                                                    <FormControl>
                                                        <Input
                                                            placeholder="#000000"
                                                            {...field}
                                                            className="font-mono uppercase"
                                                            onChange={(e) => {
                                                                const val = e.target.value;
                                                                // Allow manual typing if valid hex (or partial)
                                                                field.onChange(val);
                                                            }}
                                                        />
                                                    </FormControl>
                                                    <FormDescription className="text-xs mt-1">
                                                        Primary color for buttons and accents.
                                                    </FormDescription>
                                                </div>
                                            </div>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />

                                <FormField
                                    control={form.control}
                                    name="fontFamily"
                                    render={({ field }) => (
                                        <FormItem>
                                            <FormLabel>Font Family</FormLabel>
                                            <Select onValueChange={field.onChange} defaultValue={field.value}>
                                                <FormControl>
                                                    <SelectTrigger>
                                                        <SelectValue placeholder="Select a font" />
                                                    </SelectTrigger>
                                                </FormControl>
                                                <SelectContent>
                                                    <SelectItem value="Inter" style={{ fontFamily: 'Inter, sans-serif' }}>Inter (Default)</SelectItem>
                                                    <SelectItem value="Roboto" style={{ fontFamily: 'Roboto, sans-serif' }}>Roboto</SelectItem>
                                                    <SelectItem value="Open Sans" style={{ fontFamily: '"Open Sans", sans-serif' }}>Open Sans</SelectItem>
                                                    <SelectItem value="Lato" style={{ fontFamily: 'Lato, sans-serif' }}>Lato</SelectItem>
                                                    <SelectItem value="Montserrat" style={{ fontFamily: 'Montserrat, sans-serif' }}>Montserrat</SelectItem>
                                                    <SelectItem value="Poppins" style={{ fontFamily: 'Poppins, sans-serif' }}>Poppins</SelectItem>
                                                    <SelectItem value="Playfair Display" style={{ fontFamily: '"Playfair Display", serif' }}>Playfair Display</SelectItem>
                                                    <SelectItem value="Merriweather" style={{ fontFamily: 'Merriweather, serif' }}>Merriweather</SelectItem>
                                                    <SelectItem value="system-ui" style={{ fontFamily: 'system-ui, sans-serif' }}>System Default</SelectItem>
                                                </SelectContent>
                                            </Select>
                                            <FormDescription>
                                                Select the primary font for your portal.
                                                <span
                                                    className="block mt-2 text-lg text-slate-800 border p-2 rounded bg-slate-50"
                                                    style={{ fontFamily: field.value === 'system-ui' ? 'system-ui' : `${field.value}, sans-serif` }}
                                                >
                                                    The quick brown fox jumps over the lazy dog.
                                                </span>
                                            </FormDescription>
                                            <FormMessage />
                                        </FormItem>
                                    )}
                                />
                            </div>

                            <FormField
                                control={form.control}
                                name="logoUrl"
                                render={({ field }) => (
                                    <FormItem>
                                        <FormLabel>Logo</FormLabel>
                                        <FormControl>
                                            <ImageUpload
                                                value={field.value}
                                                onChange={field.onChange}
                                                className="w-full max-w-sm"
                                            />
                                        </FormControl>
                                        <FormDescription>Recommended: PNG or SVG, transparent background.</FormDescription>
                                        <FormMessage />
                                    </FormItem>
                                )}
                            />

                        </CardContent>
                    </Card>

                    <div className="flex justify-end">
                        <Button type="submit" disabled={saving} className="bg-blue-600 hover:bg-blue-700">
                            {saving && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
                            <Save className="w-4 h-4 mr-2" />
                            Save Changes
                        </Button>
                    </div>

                </form>
            </Form>
        </div>
    );
}
