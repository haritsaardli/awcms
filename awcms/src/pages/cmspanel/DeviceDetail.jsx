/**
 * DeviceDetail Page
 * View ESP32 device details and sensor data
 */

import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
    ArrowLeft,
    Wifi,
    WifiOff,
    RefreshCw,
    Settings,
    Camera,
    Thermometer,
    Droplets,
    Wind,
} from 'lucide-react';
import { supabase } from '@/lib/customSupabaseClient';
import { useSensorData } from '@/hooks/useSensorData';
import { usePermissions } from '@/contexts/PermissionContext';
import SensorChart from '@/components/esp32/SensorChart';
import { Skeleton } from '@/components/ui/skeleton';
import { formatDistanceToNow } from 'date-fns';

function DeviceDetail() {
    const { id } = useParams();
    const navigate = useNavigate();
    const { tenantId } = usePermissions();
    const [device, setDevice] = useState(null);
    const [loading, setLoading] = useState(true);

    const { chartData, latestReading, loading: sensorLoading } = useSensorData(
        device?.device_id,
        { limit: 100 }
    );

    // Fetch device
    useEffect(() => {
        const fetchDevice = async () => {
            if (!id || !tenantId) return;

            const { data, error } = await supabase
                .from('devices')
                .select('*')
                .eq('id', id)
                .eq('tenant_id', tenantId)
                .single();

            if (error) {
                console.error('Failed to fetch device:', error);
                navigate('/admin/devices');
                return;
            }

            setDevice(data);
            setLoading(false);
        };

        fetchDevice();

        // Realtime subscription for device status
        const channel = supabase
            .channel(`device-${id}`)
            .on(
                'postgres_changes',
                {
                    event: 'UPDATE',
                    schema: 'public',
                    table: 'devices',
                    filter: `id=eq.${id}`,
                },
                (payload) => {
                    setDevice(payload.new);
                }
            )
            .subscribe();

        return () => {
            supabase.removeChannel(channel);
        };
    }, [id, tenantId, navigate]);

    if (loading) {
        return (
            <div className="space-y-6">
                <Skeleton className="h-8 w-64" />
                <div className="grid gap-4 md:grid-cols-4">
                    {[1, 2, 3, 4].map((i) => (
                        <Skeleton key={i} className="h-24" />
                    ))}
                </div>
                <Skeleton className="h-80" />
            </div>
        );
    }

    if (!device) {
        return null;
    }

    const isOnline = device.is_online;
    const lastSeen = device.last_seen
        ? formatDistanceToNow(new Date(device.last_seen), { addSuffix: true })
        : 'Never';

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                    <Button variant="ghost" size="icon" onClick={() => navigate('/admin/devices')}>
                        <ArrowLeft className="h-4 w-4" />
                    </Button>
                    <div>
                        <h1 className="text-2xl font-bold flex items-center gap-3">
                            {device.device_name || device.device_id}
                            <Badge variant={isOnline ? 'default' : 'secondary'}>
                                {isOnline ? (
                                    <><Wifi className="mr-1 h-3 w-3" /> Online</>
                                ) : (
                                    <><WifiOff className="mr-1 h-3 w-3" /> Offline</>
                                )}
                            </Badge>
                        </h1>
                        <p className="text-muted-foreground">
                            {device.device_id} • Last seen {lastSeen}
                        </p>
                    </div>
                </div>

                <div className="flex gap-2">
                    <Button variant="outline" onClick={() => { }}>
                        <RefreshCw className="mr-2 h-4 w-4" />
                        Refresh
                    </Button>
                    <Button variant="outline" onClick={() => navigate(`/admin/devices/${id}/settings`)}>
                        <Settings className="mr-2 h-4 w-4" />
                        Settings
                    </Button>
                </div>
            </div>

            {/* Stats Cards */}
            <div className="grid gap-4 md:grid-cols-4">
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-red-500/10 rounded-full">
                                <Wind className="h-5 w-5 text-red-500" />
                            </div>
                            <div>
                                <p className="text-2xl font-bold">
                                    {latestReading?.gas_ppm?.toFixed(1) || '--'}
                                </p>
                                <p className="text-sm text-muted-foreground">Gas PPM</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-orange-500/10 rounded-full">
                                <Thermometer className="h-5 w-5 text-orange-500" />
                            </div>
                            <div>
                                <p className="text-2xl font-bold">
                                    {latestReading?.temperature?.toFixed(1) || '--'}°C
                                </p>
                                <p className="text-sm text-muted-foreground">Temperature</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-blue-500/10 rounded-full">
                                <Droplets className="h-5 w-5 text-blue-500" />
                            </div>
                            <div>
                                <p className="text-2xl font-bold">
                                    {latestReading?.humidity?.toFixed(1) || '--'}%
                                </p>
                                <p className="text-sm text-muted-foreground">Humidity</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-purple-500/10 rounded-full">
                                <Camera className="h-5 w-5 text-purple-500" />
                            </div>
                            <div>
                                <p className="text-2xl font-bold">
                                    {device.config?.camera_enabled ? 'Active' : 'N/A'}
                                </p>
                                <p className="text-sm text-muted-foreground">Camera</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Charts */}
            <Tabs defaultValue="all" className="w-full">
                <TabsList>
                    <TabsTrigger value="all">All Sensors</TabsTrigger>
                    <TabsTrigger value="gas">Gas</TabsTrigger>
                    <TabsTrigger value="temperature">Temperature</TabsTrigger>
                    <TabsTrigger value="humidity">Humidity</TabsTrigger>
                </TabsList>

                <TabsContent value="all" className="mt-4">
                    <SensorChart data={chartData} title="All Sensors" type="all" />
                </TabsContent>

                <TabsContent value="gas" className="mt-4">
                    <SensorChart data={chartData} title="Gas Level" type="gas" />
                </TabsContent>

                <TabsContent value="temperature" className="mt-4">
                    <SensorChart data={chartData} title="Temperature" type="temperature" />
                </TabsContent>

                <TabsContent value="humidity" className="mt-4">
                    <SensorChart data={chartData} title="Humidity" type="humidity" />
                </TabsContent>
            </Tabs>

            {/* Device Info */}
            <Card>
                <CardHeader>
                    <CardTitle>Device Information</CardTitle>
                </CardHeader>
                <CardContent>
                    <div className="grid gap-4 md:grid-cols-2">
                        <div>
                            <p className="text-sm text-muted-foreground">Device ID</p>
                            <p className="font-mono">{device.device_id}</p>
                        </div>
                        <div>
                            <p className="text-sm text-muted-foreground">IP Address</p>
                            <p className="font-mono">{device.ip_address || 'Unknown'}</p>
                        </div>
                        <div>
                            <p className="text-sm text-muted-foreground">MAC Address</p>
                            <p className="font-mono">{device.mac_address || 'Unknown'}</p>
                        </div>
                        <div>
                            <p className="text-sm text-muted-foreground">Firmware</p>
                            <p>v{device.firmware_version || '1.0.0'}</p>
                        </div>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
}

export default DeviceDetail;
