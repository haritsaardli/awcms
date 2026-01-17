import React from 'react';
import { useDarkMode } from '@/contexts/DarkModeContext';
import { Menu, Bell, Moon, Sun, User, Github } from 'lucide-react';
import { Link } from 'react-router-dom';

const Navbar = ({ toggleSidebar }) => {
    const { isDark, setMode } = useDarkMode();

    const toggleTheme = () => {
        setMode(isDark ? 'light' : 'dark');
    };

    return (
        <nav className="fixed z-30 w-full bg-background border-b border-border">
            <div className="px-3 py-3 lg:px-5 lg:pl-3">
                <div className="flex items-center justify-between">
                    <div className="flex items-center justify-start">
                        <button
                            onClick={toggleSidebar}
                            className="p-2 text-muted-foreground rounded cursor-pointer lg:hidden hover:text-foreground hover:bg-accent focus:bg-accent focus:ring-2 focus:ring-border"
                        >
                            <Menu className="w-6 h-6" />
                        </button>
                        <Link to="/" className="flex ml-2 md:mr-24">
                            <span className="self-center text-xl font-semibold sm:text-2xl whitespace-nowrap text-foreground">
                                AWCMS
                            </span>
                        </Link>


                    </div>
                    <div className="flex items-center">
                        {/* Github Button */}
                        <a href="https://github.com/ahliweb/awcms" target="_blank" rel="noreferrer" className="hidden sm:inline-block p-2 text-muted-foreground rounded-lg hover:text-foreground hover:bg-accent mr-2">
                            <Github className="w-6 h-6" />
                        </a>

                        {/* Notifications (Placeholder) */}
                        <button type="button" className="p-2 text-muted-foreground rounded-lg hover:text-foreground hover:bg-accent">
                            <span className="sr-only">View notifications</span>
                            <Bell className="w-6 h-6" />
                        </button>

                        {/* Theme Toggle */}
                        <button
                            onClick={toggleTheme}
                            className="p-2 text-muted-foreground rounded-lg hover:text-foreground hover:bg-accent"
                        >
                            {isDark ? <Sun className="w-6 h-6" /> : <Moon className="w-6 h-6" />}
                        </button>

                        {/* User Profile (Simplified) */}
                        <button type="button" className="flex mx-3 text-sm bg-muted rounded-full md:mr-0 focus:ring-4 focus:ring-accent">
                            <span className="sr-only">Open user menu</span>
                            <div className="w-8 h-8 rounded-full flex items-center justify-center bg-muted">
                                <User className="w-5 h-5 text-muted-foreground" />
                            </div>
                        </button>
                    </div>
                </div>
            </div>
        </nav>
    );
};
export default Navbar;
