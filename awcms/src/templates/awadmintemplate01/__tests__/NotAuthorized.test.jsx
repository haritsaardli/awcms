import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import NotAuthorized from '../NotAuthorized';

// Wrapper for components that use react-router
const renderWithRouter = (ui) => {
    return render(
        <MemoryRouter>
            {ui}
        </MemoryRouter>
    );
};

describe('NotAuthorized', () => {
    it('renders with default props', () => {
        renderWithRouter(<NotAuthorized />);

        expect(screen.getByText('Access Denied')).toBeInTheDocument();
        expect(screen.getByText('You do not have permission to view this page.')).toBeInTheDocument();
    });

    it('renders custom title and description', () => {
        renderWithRouter(
            <NotAuthorized
                title="Forbidden"
                description="You cannot access this resource."
            />
        );

        expect(screen.getByText('Forbidden')).toBeInTheDocument();
        expect(screen.getByText('You cannot access this resource.')).toBeInTheDocument();
    });

    it('displays required permission when provided', () => {
        renderWithRouter(
            <NotAuthorized permission="tenant.articles.delete" />
        );

        expect(screen.getByText(/Required: tenant.articles.delete/)).toBeInTheDocument();
    });

    it('shows back button by default', () => {
        renderWithRouter(<NotAuthorized />);

        expect(screen.getByRole('link', { name: /Back to Dashboard/i })).toBeInTheDocument();
    });

    it('hides back button when showBackButton is false', () => {
        renderWithRouter(<NotAuthorized showBackButton={false} />);

        expect(screen.queryByRole('link', { name: /Back to Dashboard/i })).not.toBeInTheDocument();
    });

    it('has proper accessibility attributes', () => {
        renderWithRouter(<NotAuthorized />);

        const alert = screen.getByRole('alert');
        expect(alert).toHaveAttribute('aria-live', 'assertive');
    });
});
