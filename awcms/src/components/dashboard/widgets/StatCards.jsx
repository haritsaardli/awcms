
import React from 'react';
import { FileText, Layers, ShoppingBag, Users, HardDrive } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';

export function StatCards({ data, loading }) {
  const stats = [
    {
      title: "Total Articles",
      value: data?.articles,
      icon: FileText,
      color: "text-blue-600",
      bg: "bg-blue-100"
    },
    {
      title: "Total Pages",
      value: data?.pages,
      icon: Layers,
      color: "text-purple-600",
      bg: "bg-purple-100"
    },
    {
      title: "Total Products",
      value: data?.products,
      icon: ShoppingBag,
      color: "text-orange-600",
      bg: "bg-orange-100"
    },
    {
      title: "Active Users",
      value: data?.users,
      icon: Users,
      color: "text-green-600",
      bg: "bg-green-100"
    },
    {
      title: "Total Orders",
      value: data?.orders,
      icon: ShoppingBag,
      color: "text-emerald-600",
      bg: "bg-emerald-100"
    },
    {
      title: "Storage Used",
      value: data?.storage,
      icon: HardDrive,
      color: "text-slate-600",
      bg: "bg-slate-100"
    }
  ];

  if (loading) {
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
        {[1, 2, 3, 4, 5, 6].map((i) => (
          <Card key={i}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <Skeleton className="h-4 w-20" />
              <Skeleton className="h-4 w-4 rounded-full" />
            </CardHeader>
            <CardContent>
              <Skeleton className="h-8 w-12" />
            </CardContent>
          </Card>
        ))}
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
      {stats.map((stat, index) => {
        const Icon = stat.icon;
        return (
          <Card key={index} className="border-slate-200 shadow-sm hover:shadow-md transition-shadow">
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium text-slate-500">
                {stat.title}
              </CardTitle>
              <div className={`p-2 rounded-full ${stat.bg}`}>
                <Icon className={`h-4 w-4 ${stat.color}`} />
              </div>
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-slate-900">{stat.value}</div>
            </CardContent>
          </Card>
        );
      })}
    </div>
  );
}
