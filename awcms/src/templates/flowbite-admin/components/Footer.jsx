import React from 'react';

const Footer = () => {
    return (
        <footer className="p-4 my-6 bg-card rounded-lg shadow md:flex md:items-center md:justify-between md:p-6">
            <ul className="flex flex-wrap items-center mb-6 space-y-1 md:mb-0">
                <li>
                    <a href="/" className="mr-4 text-sm font-normal text-muted-foreground hover:underline md:mr-6">Terms and conditions</a>
                </li>
                <li>
                    <a href="/" className="mr-4 text-sm font-normal text-muted-foreground hover:underline md:mr-6">Privacy Policy</a>
                </li>
                <li>
                    <a href="/" className="mr-4 text-sm font-normal text-muted-foreground hover:underline md:mr-6">Licensing</a>
                </li>
                <li>
                    <a href="/" className="mr-4 text-sm font-normal text-muted-foreground hover:underline md:mr-6">Cookie Policy</a>
                </li>
                <li>
                    <a href="/" className="text-sm font-normal text-muted-foreground hover:underline">Contact</a>
                </li>
            </ul>
            <p className="text-sm text-center text-muted-foreground">
                &copy; 2024-2025 <a href="https://ahliweb.com" className="hover:underline" target="_blank" rel="noreferrer">AhliWeb.com</a> & AWCMS. All rights reserved.
            </p>
        </footer>
    )
}
export default Footer;
