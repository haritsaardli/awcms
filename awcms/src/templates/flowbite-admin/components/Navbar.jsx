import React from 'react';
import { useDarkMode } from '@/contexts/DarkModeContext';
import { Menu, Search, Bell, Moon, Sun, User, Github } from 'lucide-react';
import { Link } from 'react-router-dom';

const Navbar = ({ toggleSidebar }) => {
    const { isDark, setMode } = useDarkMode();

    const toggleTheme = () => {
        setMode(isDark ? 'light' : 'dark');
    };

    return (
        <nav className="fixed z-30 w-full bg-white border-b border-gray-200 dark:bg-gray-800 dark:border-gray-700">
            <div className="px-3 py-3 lg:px-5 lg:pl-3">
                <div className="flex items-center justify-between">
                    <div className="flex items-center justify-start">
                        <button
                            onClick={toggleSidebar}
                            className="p-2 text-gray-600 rounded cursor-pointer lg:hidden hover:text-gray-900 hover:bg-gray-100 focus:bg-gray-100 dark:focus:bg-gray-700 focus:ring-2 focus:ring-gray-100 dark:focus:ring-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white"
                        >
                            <Menu className="w-6 h-6" />
                        </button>
                        <Link to="/" className="flex ml-2 md:mr-24">
                            <span className="self-center text-xl font-semibold sm:text-2xl whitespace-nowrap dark:text-white">
                                AWCMS
                            </span>
                        </Link>

                        <form className="hidden lg:block lg:pl-3.5">
                            <label htmlFor="topbar-search" className="sr-only">Search</label>
                            <div className="relative mt-1 lg:w-96">
                                <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
                                    <Search className="w-5 h-5 text-gray-500 dark:text-gray-400" />
                                </div>
                                <input
                                    type="text"
                                    name="search"
                                    id="topbar-search"
                                    className="bg-gray-50 border border-gray-300 text-gray-900 sm:text-sm rounded-lg focus:ring-primary-500 focus:border-primary-500 block w-full pl-10 p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-primary-500 dark:focus:border-primary-500"
                                    placeholder="Search"
                                />
                            </div>
                        </form>
                    </div>
                    <div className="flex items-center">
                        {/* Github Button */}
                        <a href="https://github.com/ahliweb/awcms" target="_blank" rel="noreferrer" className="hidden sm:inline-block p-2 text-gray-500 rounded-lg hover:text-gray-900 hover:bg-gray-100 dark:text-gray-400 dark:hover:text-white dark:hover:bg-gray-700 mr-2">
                            <Github className="w-6 h-6" />
                        </a>

                        {/* Notifications (Placeholder) */}
                        <button type="button" className="p-2 text-gray-500 rounded-lg hover:text-gray-900 hover:bg-gray-100 dark:text-gray-400 dark:hover:text-white dark:hover:bg-gray-700">
                            <span className="sr-only">View notifications</span>
                            <Bell className="w-6 h-6" />
                        </button>

                        {/* Theme Toggle */}
                        <button
                            onClick={toggleTheme}
                            className="p-2 text-gray-500 rounded-lg hover:text-gray-900 hover:bg-gray-100 dark:text-gray-400 dark:hover:text-white dark:hover:bg-gray-700"
                        >
                            {isDark ? <Sun className="w-6 h-6" /> : <Moon className="w-6 h-6" />}
                        </button>

                        {/* User Profile (Simplified) */}
                        <button type="button" className="flex mx-3 text-sm bg-gray-800 rounded-full md:mr-0 focus:ring-4 focus:ring-gray-300 dark:focus:ring-gray-600">
                            <span className="sr-only">Open user menu</span>
                            <div className="w-8 h-8 rounded-full flex items-center justify-center bg-gray-300 dark:bg-gray-600">
                                <User className="w-5 h-5 text-gray-600 dark:text-gray-300" />
                            </div>
                        </button>
                    </div>
                </div>
            </div>
        </nav>
    );
};
export default Navbar;
