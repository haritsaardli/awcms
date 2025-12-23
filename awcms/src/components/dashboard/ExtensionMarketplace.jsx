
import React, { useState } from 'react';
import { Download, Star, ShieldCheck, AlertCircle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { useToast } from '@/components/ui/use-toast';
import { supabase } from '@/lib/customSupabaseClient';
import { useAuth } from '@/contexts/SupabaseAuthContext';

// Mock Data for Marketplace
const MARKETPLACE_EXTENSIONS = [
  {
    id: 'ext-analytics',
    name: 'Advanced Analytics',
    slug: 'advanced-analytics',
    description: 'Detailed dashboard analytics with charts, user journey tracking, and export capabilities.',
    version: '2.1.0',
    author: 'CMS Team',
    icon: '📊',
    rating: 4.8,
    downloads: '1.2k',
    verified: true
  },
  {
    id: 'ext-newsletter',
    name: 'Newsletter Manager',
    slug: 'newsletter-manager',
    description: 'Create, schedule, and send newsletters directly from your CMS. Includes templates.',
    version: '1.0.5',
    author: 'EmailPro',
    icon: '📧',
    rating: 4.5,
    downloads: '850',
    verified: true
  },
  {
    id: 'ext-backup',
    name: 'Auto Backup',
    slug: 'auto-backup',
    description: 'Automated daily backups of your content to secure storage. Restore with one click.',
    version: '1.2.0',
    author: 'SysAdmin',
    icon: '💾',
    rating: 4.9,
    downloads: '2k',
    verified: true
  },
  {
    id: 'ext-seo-pro',
    name: 'SEO Pro',
    slug: 'seo-pro',
    description: 'Advanced SEO tools, meta tag generator, sitemap management, and keyword analysis.',
    version: '3.0.1',
    author: 'SEO Master',
    icon: '🔍',
    rating: 4.7,
    downloads: '3.5k',
    verified: true
  }
];

function ExtensionMarketplace({ onInstall }) {
  const { toast } = useToast();
  const { user } = useAuth();
  const [installing, setInstalling] = useState(null);

  const handleInstall = async (ext) => {
    setInstalling(ext.id);
    
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 1500));

    try {
      const payload = {
        name: ext.name,
        slug: ext.slug,
        description: ext.description,
        version: ext.version,
        author: ext.author,
        icon: ext.icon,
        is_active: true,
        created_by: user.id,
        config: { installed_from: 'marketplace', original_id: ext.id }
      };

      const { error } = await supabase
        .from('extensions')
        .insert([payload]);

      if (error) {
          if (error.code === '23505') { // Unique violation
             throw new Error("This extension is already installed.");
          }
          throw error;
      }

      toast({
        title: "Installation Complete",
        description: `${ext.name} has been successfully installed and activated.`
      });
      
      if (onInstall) onInstall();

    } catch (error) {
      toast({
        variant: "destructive",
        title: "Installation Failed",
        description: error.message
      });
    } finally {
      setInstalling(null);
    }
  };

  return (
    <div className="space-y-6">
        <div className="bg-gradient-to-r from-blue-600 to-indigo-700 rounded-xl p-8 text-white shadow-lg mb-8">
            <h2 className="text-3xl font-bold mb-2">Extension Marketplace</h2>
            <p className="text-blue-100 max-w-2xl">
                Discover and install plugins to supercharge your CMS. From analytics to SEO, 
                find the tools you need to grow.
            </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
            {MARKETPLACE_EXTENSIONS.map((ext) => (
                <div key={ext.id} className="bg-white rounded-xl border border-slate-200 shadow-sm hover:shadow-md transition-shadow flex flex-col">
                    <div className="p-6 flex-1">
                        <div className="flex justify-between items-start mb-4">
                            <div className="w-12 h-12 bg-slate-50 border border-slate-100 rounded-xl flex items-center justify-center text-2xl shadow-sm">
                                {ext.icon}
                            </div>
                            {ext.verified && (
                                <Badge variant="secondary" className="bg-blue-50 text-blue-600 border-blue-100 flex gap-1">
                                    <ShieldCheck className="w-3 h-3" /> Verified
                                </Badge>
                            )}
                        </div>

                        <h3 className="text-lg font-bold text-slate-900 mb-2">{ext.name}</h3>
                        <p className="text-slate-500 text-sm mb-4 leading-relaxed">
                            {ext.description}
                        </p>

                        <div className="flex items-center gap-4 text-xs text-slate-400 font-medium">
                            <div className="flex items-center gap-1 text-amber-500">
                                <Star className="w-3 h-3 fill-current" />
                                <span>{ext.rating}</span>
                            </div>
                            <span>{ext.downloads} installs</span>
                            <span>v{ext.version}</span>
                        </div>
                    </div>

                    <div className="p-4 bg-slate-50/50 border-t border-slate-100 rounded-b-xl">
                        <Button 
                            className="w-full bg-slate-900 hover:bg-slate-800"
                            onClick={() => handleInstall(ext)}
                            disabled={!!installing}
                        >
                            {installing === ext.id ? (
                                'Installing...'
                            ) : (
                                <>
                                    <Download className="w-4 h-4 mr-2" />
                                    Install Extension
                                </>
                            )}
                        </Button>
                    </div>
                </div>
            ))}
        </div>
    </div>
  );
}

export default ExtensionMarketplace;
