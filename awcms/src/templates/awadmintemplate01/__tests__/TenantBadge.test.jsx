import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import TenantBadge from '../TenantBadge';

describe('TenantBadge', () => {
    it('renders tenant name when tenant is provided', () => {
        const tenant = {
            id: '123',
            name: 'Acme Corp',
        };

        render(<TenantBadge tenant={tenant} />);

        expect(screen.getByText('Acme Corp')).toBeInTheDocument();
    });

    it('renders "All Tenants" when isAllTenants is true', () => {
        render(<TenantBadge isAllTenants={true} />);

        expect(screen.getByText(/All Tenants/i)).toBeInTheDocument();
        expect(screen.getByText(/Platform View/i)).toBeInTheDocument();
    });

    it('renders "All Tenants" when tenant is null', () => {
        render(<TenantBadge tenant={null} />);

        expect(screen.getByText(/All Tenants/i)).toBeInTheDocument();
    });

    it('renders tenant logo when available', () => {
        const tenant = {
            id: '123',
            name: 'Acme Corp',
            logo_url: 'https://example.com/logo.png',
        };

        const { container } = render(<TenantBadge tenant={tenant} />);

        // Logo is aria-hidden so we query directly
        const logo = container.querySelector('img');
        expect(logo).toBeInTheDocument();
        expect(logo).toHaveAttribute('src', 'https://example.com/logo.png');
    });

    it('has proper accessibility attributes', () => {
        const tenant = { id: '123', name: 'Test Tenant' };
        render(<TenantBadge tenant={tenant} />);

        const badge = screen.getByRole('status');
        expect(badge).toHaveAttribute('aria-label', 'Current tenant: Test Tenant');
    });

    it('has proper accessibility for platform view', () => {
        render(<TenantBadge isAllTenants={true} />);

        const badge = screen.getByRole('status');
        expect(badge).toHaveAttribute('aria-label', 'Viewing all tenants');
    });
});
