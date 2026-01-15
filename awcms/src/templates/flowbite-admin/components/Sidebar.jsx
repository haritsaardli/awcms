import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import {
    LayoutDashboard,
    Settings,
    FileText,
    Users,
    ShoppingBag,
    Globe,
    ChevronDown,
    ChevronUp
} from 'lucide-react';
import { cn } from '@/lib/utils'; // Assuming this utility exists, otherwise standard className string interpolation

const SidebarItem = ({ href, icon: Icon, label, active }) => (
    <li>
        <Link
            to={href}
            className={cn(
                "flex items-center p-2 text-base text-gray-900 rounded-lg hover:bg-gray-100 group dark:text-gray-200 dark:hover:bg-gray-700",
                active && "bg-gray-100 dark:bg-gray-700"
            )}
        >
            <Icon className="w-6 h-6 text-gray-500 transition duration-75 group-hover:text-gray-900 dark:text-gray-400 dark:group-hover:text-white" />
            <span className="ml-3">{label}</span>
        </Link>
    </li>
);

const SidebarDropdown = ({ icon: Icon, label, children, id, active }) => {
    const [isOpen, setIsOpen] = useState(active);

    return (
        <li>
            <button
                type="button"
                className="flex items-center w-full p-2 text-base text-gray-900 transition duration-75 rounded-lg group hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700"
                onClick={() => setIsOpen(!isOpen)}
                aria-controls={`dropdown-${id}`}
                aria-expanded={isOpen}
            >
                <Icon className="flex-shrink-0 w-6 h-6 text-gray-500 transition duration-75 group-hover:text-gray-900 dark:text-gray-400 dark:group-hover:text-white" />
                <span className="flex-1 ml-3 text-left whitespace-nowrap">{label}</span>
                {isOpen ? (
                    <ChevronUp className="w-6 h-6" />
                ) : (
                    <ChevronDown className="w-6 h-6" />
                )}
            </button>
            <ul id={`dropdown-${id}`} className={cn("py-2 space-y-2", !isOpen && "hidden")}>
                {children}
            </ul>
        </li>
    );
};

const Sidebar = ({ isOpen, isMobile }) => {
    const location = useLocation();
    const path = location.pathname;

    // Helper to check active state
    const isActive = (p) => path === p || path.startsWith(`${p}/`);

    return (
        <aside
            id="sidebar"
            className={cn(
                "fixed top-0 left-0 z-20 flex flex-col flex-shrink-0 w-64 h-full pt-16 font-normal duration-75 lg:flex transition-width bg-white border-r border-gray-200 dark:bg-gray-800 dark:border-gray-700",
                isMobile && !isOpen ? "hidden" : "flex"
            )}
            aria-label="Sidebar"
        >
            <div className="relative flex flex-col flex-1 min-h-0 pt-0 bg-white border-r border-gray-200 dark:bg-gray-800 dark:border-gray-700">
                <div className="flex flex-col flex-1 pt-5 pb-28 overflow-y-auto scrollbar scrollbar-w-2 scrollbar-thumb-rounded-[0.1667rem] scrollbar-thumb-slate-200 scrollbar-track-gray-400 dark:scrollbar-thumb-slate-900 dark:scrollbar-track-gray-800">
                    <div className="flex-1 px-3 space-y-1 bg-white divide-y divide-gray-200 dark:bg-gray-800 dark:divide-gray-700">
                        <ul className="pb-2 space-y-2">
                            <SidebarItem href="/cmspanel" icon={LayoutDashboard} label="Dashboard" active={path === '/cmspanel'} />

                            <SidebarDropdown icon={FileText} label="Content" id="content">
                                <li>
                                    <Link to="/cmspanel/articles" className="flex items-center p-2 text-base text-gray-900 transition duration-75 rounded-lg pl-11 group hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700">Articles</Link>
                                </li>
                                <li>
                                    <Link to="/cmspanel/pages" className="flex items-center p-2 text-base text-gray-900 transition duration-75 rounded-lg pl-11 group hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700">Pages</Link>
                                </li>
                                <li>
                                    <Link to="/cmspanel/visual-pages" className="flex items-center p-2 text-base text-gray-900 transition duration-75 rounded-lg pl-11 group hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700">Visual Pages</Link>
                                </li>
                            </SidebarDropdown>

                            <SidebarDropdown icon={ShoppingBag} label="E-Commerce" id="ecommerce">
                                <li>
                                    <Link to="/cmspanel/products" className="flex items-center p-2 text-base text-gray-900 transition duration-75 rounded-lg pl-11 group hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700">Products</Link>
                                </li>
                                <li>
                                    <Link to="/cmspanel/orders" className="flex items-center p-2 text-base text-gray-900 transition duration-75 rounded-lg pl-11 group hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700">Orders</Link>
                                </li>
                            </SidebarDropdown>

                            <SidebarDropdown icon={Users} label="Users & Roles" id="users">
                                <li>
                                    <Link to="/cmspanel/users" className="flex items-center p-2 text-base text-gray-900 transition duration-75 rounded-lg pl-11 group hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700">Users</Link>
                                </li>
                                <li>
                                    <Link to="/cmspanel/roles" className="flex items-center p-2 text-base text-gray-900 transition duration-75 rounded-lg pl-11 group hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700">Roles</Link>
                                </li>
                                <li>
                                    <Link to="/cmspanel/permissions" className="flex items-center p-2 text-base text-gray-900 transition duration-75 rounded-lg pl-11 group hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700">Permissions</Link>
                                </li>
                            </SidebarDropdown>

                            <SidebarItem href="/cmspanel/settings/general" icon={Settings} label="Settings" active={isActive('/cmspanel/settings')} />
                        </ul>

                        {/* Additional Links moved to separate section for cleaner look if needed, generally adhering to existing structure */}
                        <div className="pt-2 space-y-2">
                            <a href="https://flowbite.com/docs/getting-started/introduction/" target="_blank" rel="noreferrer" className="flex items-center p-2 text-base text-gray-900 transition duration-75 rounded-lg hover:bg-gray-100 group dark:text-gray-200 dark:hover:bg-gray-700">
                                <Globe className="flex-shrink-0 w-6 h-6 text-gray-500 transition duration-75 group-hover:text-gray-900 dark:text-gray-400 dark:group-hover:text-white" />
                                <span className="ml-3">Flowbite Docs</span>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </aside>
    );
};

export default Sidebar;
