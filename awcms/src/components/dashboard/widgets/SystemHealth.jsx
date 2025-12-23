
import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { CheckCircle2, AlertTriangle, XCircle } from 'lucide-react';

const StatusItem = ({ label, status }) => {
  let Icon = CheckCircle2;
  let color = "text-green-500";
  
  if (status === 'warning') {
    Icon = AlertTriangle;
    color = "text-yellow-500";
  } else if (status === 'error' || status === 'down') {
    Icon = XCircle;
    color = "text-red-500";
  }

  return (
    <div className="flex items-center justify-between p-3 bg-slate-50 rounded-lg">
      <span className="text-sm font-medium text-slate-700">{label}</span>
      <div className="flex items-center gap-2">
        <span className={`text-xs uppercase font-bold ${color}`}>{status}</span>
        <Icon className={`w-4 h-4 ${color}`} />
      </div>
    </div>
  );
};

export function SystemHealth({ health }) {
  return (
    <Card className="col-span-1 border-slate-200 shadow-sm h-full">
      <CardHeader>
        <CardTitle>System Health</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <StatusItem label="Database Connection" status={health?.database || 'unknown'} />
        <StatusItem label="Storage Service" status={health?.storage || 'unknown'} />
        <StatusItem label="API Status" status={health?.api || 'unknown'} />
      </CardContent>
    </Card>
  );
}
