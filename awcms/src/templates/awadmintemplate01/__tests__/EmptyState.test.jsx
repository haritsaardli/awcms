import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import EmptyState from '../EmptyState';
import { Inbox, Plus } from 'lucide-react';

describe('EmptyState', () => {
    it('renders with default props', () => {
        render(<EmptyState />);

        expect(screen.getByText('No data found')).toBeInTheDocument();
        expect(screen.getByText('There are no items to display.')).toBeInTheDocument();
    });

    it('renders custom title and description', () => {
        render(
            <EmptyState
                title="No Articles"
                description="Create your first article to get started."
            />
        );

        expect(screen.getByText('No Articles')).toBeInTheDocument();
        expect(screen.getByText('Create your first article to get started.')).toBeInTheDocument();
    });

    it('renders custom icon', () => {
        render(<EmptyState icon={Inbox} title="Empty Inbox" />);

        expect(screen.getByText('Empty Inbox')).toBeInTheDocument();
    });

    it('renders action button when provided', () => {
        const mockAction = {
            label: 'Create New',
            onClick: () => { },
            icon: Plus,
        };

        render(
            <EmptyState
                title="No Items"
                action={mockAction}
            />
        );

        expect(screen.getByRole('button', { name: /Create New/i })).toBeInTheDocument();
    });

    it('has proper accessibility attributes', () => {
        render(<EmptyState />);

        const container = screen.getByRole('status');
        expect(container).toHaveAttribute('aria-live', 'polite');
    });
});
