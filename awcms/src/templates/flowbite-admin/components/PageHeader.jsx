import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight, Home } from 'lucide-react';

const PageHeader = ({ title, description, breadcrumbs = [], actions }) => {
    return (
        <div className="mb-4 col-span-full xl:mb-2">
            <nav className="flex mb-5" aria-label="Breadcrumb">
                <ol className="inline-flex items-center space-x-1 text-sm font-medium md:space-x-2">
                    <li className="inline-flex items-center">
                        <Link to="/cmspanel" className="inline-flex items-center text-gray-700 hover:text-primary-600 dark:text-gray-300 dark:hover:text-white">
                            <Home className="w-4 h-4 mr-2.5" />
                            Home
                        </Link>
                    </li>
                    {breadcrumbs.map((crumb, index) => (
                        <li key={index}>
                            <div className="flex items-center">
                                <ChevronRight className="w-5 h-5 text-gray-400" />
                                {crumb.href ? (
                                    <Link to={crumb.href} className="ml-1 text-gray-700 hover:text-primary-600 md:ml-2 dark:text-gray-300 dark:hover:text-white">
                                        {crumb.label}
                                    </Link>
                                ) : (
                                    <span className="ml-1 text-gray-500 md:ml-2 dark:text-gray-400">{crumb.label}</span>
                                )}
                            </div>
                        </li>
                    ))}
                </ol>
            </nav>
            <div className="flex justify-between items-center sm:flex-row flex-col sm:space-y-0 space-y-4">
                <div>
                    <h1 className="text-xl font-semibold text-gray-900 sm:text-2xl dark:text-white">{title}</h1>
                    {description && <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">{description}</p>}
                </div>
                {actions && (
                    <div className="flex items-center space-x-2">
                        {actions}
                    </div>
                )}
            </div>
        </div>
    );
};
export default PageHeader;
