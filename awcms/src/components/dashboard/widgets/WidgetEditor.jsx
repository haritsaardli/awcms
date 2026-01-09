import React, { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
import { CORE_WIDGETS } from '@/lib/widgetRegistry';

const WidgetEditor = ({ type, config, onChange, onSave, onCancel }) => {
    // Clone config to local state
    const [localConfig, setLocalConfig] = useState(config || {});

    // Helper to update local config
    const updateField = (key, value) => {
        setLocalConfig(prev => ({ ...prev, [key]: value }));
    };

    // Notify parent on change if needed (for live preview?)
    useEffect(() => {
        onChange && onChange(localConfig);
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [localConfig]);

    // Render form based on type
    const renderFields = () => {
        switch (type) {
            case 'core/text':
                return (
                    <div className="space-y-4">
                        <div className="grid gap-2">
                            <Label>Content (HTML supported)</Label>
                            <Textarea
                                value={localConfig.content || ''}
                                onChange={e => updateField('content', e.target.value)}
                                rows={8}
                            />
                        </div>
                        <div className="flex items-center space-x-2">
                            <Switch
                                id="isHtml"
                                checked={localConfig.isHtml || false}
                                onCheckedChange={checked => updateField('isHtml', checked)}
                            />
                            <Label htmlFor="isHtml">Render as raw HTML</Label>
                        </div>
                    </div>
                );
            case 'core/image':
                return (
                    <div className="space-y-4">
                        <div className="grid gap-2">
                            <Label>Image URL</Label>
                            <Input
                                value={localConfig.url || ''}
                                onChange={e => updateField('url', e.target.value)}
                            />
                        </div>
                        <div className="grid gap-2">
                            <Label>Alt Text</Label>
                            <Input
                                value={localConfig.alt || ''}
                                onChange={e => updateField('alt', e.target.value)}
                            />
                        </div>
                    </div>
                );
            case 'core/button':
                return (
                    <div className="space-y-4">
                        <div className="grid gap-2">
                            <Label>Button Text</Label>
                            <Input
                                value={localConfig.text || ''}
                                onChange={e => updateField('text', e.target.value)}
                            />
                        </div>
                        <div className="grid gap-2">
                            <Label>URL</Label>
                            <Input
                                value={localConfig.url || '#'}
                                onChange={e => updateField('url', e.target.value)}
                            />
                        </div>
                    </div>
                );
            case 'core/menu':
                return (
                    <div className="space-y-4">
                        <div className="grid gap-2">
                            <Label>Menu ID (UUID)</Label>
                            <Input
                                value={localConfig.menuId || ''}
                                onChange={e => updateField('menuId', e.target.value)}
                                placeholder="Paste format-uuid here"
                            />
                            <p className="text-xs text-muted-foreground">Select a menu from Menus manager (TBD: Dropdown)</p>
                        </div>
                    </div>
                );
            default:
                return (
                    <div className="space-y-4">
                        <div className="p-4 bg-yellow-50 text-yellow-800 rounded text-sm">
                            Generic Editor (JSON)
                        </div>
                        <div className="grid gap-2">
                            <Label>Config JSON</Label>
                            <Textarea
                                value={JSON.stringify(localConfig, null, 2)}
                                onChange={e => {
                                    try {
                                        setLocalConfig(JSON.parse(e.target.value));
                                    } catch (err) {
                                        // ignore parse error while typing
                                    }
                                }}
                                rows={10}
                                className="font-mono text-xs"
                            />
                        </div>
                    </div>
                );
        }
    };

    return (
        <div className="space-y-6">
            <div className="border-b pb-4 mb-4">
                <h3 className="font-medium text-lg">
                    Edit {CORE_WIDGETS.find(w => w.type === type)?.name || type}
                </h3>
            </div>

            {renderFields()}

            <div className="flex justify-end gap-2 pt-4 border-t mt-4">
                <Button variant="outline" onClick={onCancel}>Cancel</Button>
                <Button onClick={() => onSave(localConfig)}>Save Widget</Button>
            </div>
        </div>
    );
};

export default WidgetEditor;
