/**
 * Custom hook for media library operations
 * Provides upload, sync, and stats functionality for the FilesManager
 */
import { useState, useEffect, useCallback } from 'react';
import { supabase } from '@/lib/customSupabaseClient';
import { useToast } from '@/components/ui/use-toast';
import { useTenant } from '@/contexts/TenantContext'; // Import TenantContext
import { usePermissions } from '@/contexts/PermissionContext';

export function useMedia() {
    const { toast } = useToast();
    const { currentTenant } = useTenant(); // Get Current Tenant
    const tenantId = currentTenant?.id;

    const [uploading, setUploading] = useState(false);
    const [syncing, setSyncing] = useState(false);
    const [stats, setStats] = useState({
        total_files: 0,
        total_size: 0,
        image_count: 0,
        doc_count: 0,
        video_count: 0,
        other_count: 0
    });
    const [statsLoading, setStatsLoading] = useState(true);

    // Fetch file stats
    const fetchStats = useCallback(async () => {
        setStatsLoading(true);
        try {
            // Stats should implicitly filter by RLS, but we can rely on that.
            const { data, error } = await supabase
                .from('files')
                .select('file_size, file_type')
                .is('deleted_at', null);

            if (error) throw error;

            const statsData = {
                total_files: data.length,
                total_size: data.reduce((acc, f) => acc + (f.file_size || 0), 0),
                image_count: data.filter(f => f.file_type?.startsWith('image/')).length,
                doc_count: data.filter(f =>
                    f.file_type?.includes('pdf') ||
                    f.file_type?.includes('document') ||
                    f.file_type?.includes('text')
                ).length,
                video_count: data.filter(f => f.file_type?.startsWith('video/')).length,
                other_count: 0
            };
            statsData.other_count = statsData.total_files - statsData.image_count - statsData.doc_count - statsData.video_count;

            setStats(statsData);
        } catch (err) {
            console.error('Error fetching stats:', err);
        } finally {
            setStatsLoading(false);
        }
    }, []);

    // Initial fetch
    useEffect(() => {
        fetchStats();
    }, [fetchStats]);

    // Upload a single file
    const uploadFile = useCallback(async (file, folder = '') => {
        setUploading(true);
        try {
            const fileExt = file.name.split('.').pop();
            const fileName = `${Date.now()}-${Math.random().toString(36).substring(7)}.${fileExt}`;

            // Construct path with tenant isolation
            // If tenantId is present, prefix with it. Default to 'public' or root if none (legacy)
            const tenantPrefix = tenantId ? `${tenantId}/` : '';
            const filePath = `${tenantPrefix}${folder ? folder + '/' : ''}${fileName}`;

            // 1. Upload to Storage
            const { error: uploadError } = await supabase.storage
                .from('cms-uploads')
                .upload(filePath, file);

            if (uploadError) throw uploadError;

            // 2. Get Public URL
            const { data: { publicUrl } } = supabase.storage
                .from('cms-uploads')
                .getPublicUrl(filePath);

            // 3. Save to DB
            const { data: userData } = await supabase.auth.getUser();
            const { error: dbError } = await supabase.from('files').insert({
                name: file.name,
                file_path: publicUrl,
                file_size: file.size,
                file_type: file.type,
                bucket_name: 'cms-uploads',
                uploaded_by: userData.user?.id,
                tenant_id: tenantId // Explicitly add tenant_id
            });

            if (dbError) throw dbError;

            // Refresh stats after upload
            await fetchStats();

            return { success: true, url: publicUrl };
        } catch (err) {
            console.error('Upload error:', err);
            throw err;
        } finally {
            setUploading(false);
        }
    }, [fetchStats, tenantId]);

    // Sync files from storage bucket to database
    // Updated to support tenant folders
    const syncFiles = useCallback(async () => {
        setSyncing(true);
        try {
            // List files in storage bucket (scoped to tenant folder)
            const searchFolder = tenantId ? `${tenantId}` : '';
            const { data: storageFiles, error: listError } = await supabase.storage
                .from('cms-uploads')
                .list(searchFolder, { limit: 1000, offset: 0 });

            if (listError) throw listError;

            // Get existing files in DB
            const { data: dbFiles, error: dbError } = await supabase
                .from('files')
                .select('file_path')
                .is('deleted_at', null);

            if (dbError) throw dbError;

            // Normalize check derived from filename
            const existingFilenames = new Set(dbFiles.map(f => {
                // Public URL: .../cms-uploads/tenant-id/filename.ext
                // We want just 'filename.ext' for comparison if we are searching inside 'tenant-id/'
                return f.file_path.split('/').pop();
            }));

            const newFiles = storageFiles.filter(sf =>
                !sf.id?.includes('/') && // Skip folders (though list shouldn't return subfolders in non-recursive mode usually)
                sf.name &&
                sf.name !== '.emptyFolderPlaceholder' &&
                !existingFilenames.has(sf.name)
            );

            if (newFiles.length === 0) {
                toast({ title: 'Sync Complete', description: 'No new files found in storage.' });
                return true;
            }

            // Insert missing files to DB
            const { data: userData } = await supabase.auth.getUser();
            let syncedCount = 0;

            for (const sf of newFiles) {
                // Reconstruct full path for Public URL generation
                const fullPath = searchFolder ? `${searchFolder}/${sf.name}` : sf.name;

                const { data: { publicUrl } } = supabase.storage
                    .from('cms-uploads')
                    .getPublicUrl(fullPath);

                const { error: insertError } = await supabase.from('files').insert({
                    name: sf.name,
                    file_path: publicUrl,
                    file_size: sf.metadata?.size || 0,
                    file_type: sf.metadata?.mimetype || 'application/octet-stream',
                    bucket_name: 'cms-uploads',
                    uploaded_by: userData.user?.id,
                    tenant_id: tenantId
                });

                if (!insertError) syncedCount++;
            }

            toast({
                title: 'Sync Complete',
                description: `${syncedCount} new files synced from storage.`
            });

            // Refresh stats after sync
            await fetchStats();

            return true;
        } catch (err) {
            console.error('Sync error:', err);
            toast({
                variant: 'destructive',
                title: 'Sync Failed',
                description: err.message
            });
            return false;
        } finally {
            setSyncing(false);
        }
    }, [toast, fetchStats, tenantId]);

    return {
        uploadFile,
        uploading,
        syncFiles,
        syncing,
        stats,
        statsLoading,
        refreshStats: fetchStats
    };
}

export default useMedia;
