
import React from 'react';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Menu, LogOut, User } from 'lucide-react';
import { useAuth } from '@/contexts/SupabaseAuthContext';
import { usePermissions } from '@/contexts/PermissionContext';
import { useTenant } from '@/contexts/TenantContext';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import LanguageSelector from '@/components/ui/LanguageSelector';
import { NotificationDropdown } from '@/components/dashboard/notifications/NotificationDropdown';
import { TenantBadge } from '@/templates/flowbite-admin';
import { DarkModeToggle } from '@/components/ui/DarkModeToggle';

function Header({ toggleSidebar, onNavigate }) {
  const { user, signOut } = useAuth();
  const { t } = useTranslation();
  const { isPlatformAdmin } = usePermissions();
  const { currentTenant } = useTenant();

  const getInitials = (email) => {
    return email ? email.substring(0, 2).toUpperCase() : 'U';
  };

  return (
    <header className="bg-background border-b border-border shadow-sm z-30">
      <div className="flex items-center justify-between px-6 py-4">
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="icon"
            onClick={toggleSidebar}
            className="lg:hidden text-muted-foreground hover:text-foreground"
          >
            <Menu className="w-6 h-6" />
          </Button>
          <div className="hidden md:block">
            {/* Title removed: Handled by individual pages via PageHeader */}
          </div>
          {/* Tenant Context Badge for Platform Admins */}
          {isPlatformAdmin && (
            <div className="hidden lg:block ml-4">
              <TenantBadge tenant={currentTenant} />
            </div>
          )}
        </div>

        <div className="flex items-center gap-2 md:gap-4">
          {/* Dark Mode Toggle */}
          <DarkModeToggle />

          <LanguageSelector />

          {/* Notification Dropdown */}
          <NotificationDropdown />

          <div className="h-8 w-px bg-border mx-1 hidden md:block"></div>

          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" className="flex items-center gap-3 pl-2 pr-4 py-2 h-auto hover:bg-muted rounded-full border border-transparent hover:border-border transition-all">
                <Avatar className="w-9 h-9 border border-border">
                  {(user?.user_metadata?.avatar_url) && (
                    <AvatarImage
                      src={user.user_metadata.avatar_url}
                      alt="Profile"
                      className="object-cover"
                    />
                  )}
                  <AvatarFallback className="bg-primary text-primary-foreground font-semibold">
                    {getInitials(user?.email)}
                  </AvatarFallback>
                </Avatar>
                <div className="hidden md:flex flex-col items-start text-sm">
                  <span className="font-semibold text-foreground">{user?.email?.split('@')[0]}</span>
                  <span className="text-xs text-muted-foreground">Administrator</span>
                </div>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56 bg-card border-border text-foreground shadow-lg">
              <DropdownMenuLabel className="text-foreground">{t('menu.profile')}</DropdownMenuLabel>
              <DropdownMenuSeparator className="bg-border" />
              <DropdownMenuItem asChild className="focus:bg-muted cursor-pointer">
                <Link to="/cmspanel/profile" className="flex items-center w-full">
                  <User className="w-4 h-4 mr-2 text-muted-foreground" />
                  {t('menu.profile')}
                </Link>
              </DropdownMenuItem>
              <DropdownMenuSeparator className="bg-border" />
              <DropdownMenuItem onClick={signOut} className="text-destructive focus:bg-destructive/10 focus:text-destructive cursor-pointer">
                <LogOut className="w-4 h-4 mr-2" />
                {t('auth.logout')}
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </header>
  );
}

export default Header;
