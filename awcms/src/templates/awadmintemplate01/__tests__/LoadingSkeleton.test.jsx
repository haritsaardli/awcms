import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import LoadingSkeleton from '../LoadingSkeleton';

describe('LoadingSkeleton', () => {
    it('renders page skeleton by default', () => {
        render(<LoadingSkeleton type="page" />);

        const container = screen.getByRole('generic', { busy: true });
        expect(container).toHaveAttribute('aria-busy', 'true');
        expect(container).toHaveAttribute('aria-label', 'Loading page');
    });

    it('renders content skeleton', () => {
        render(<LoadingSkeleton type="content" />);

        const container = screen.getByRole('generic', { busy: true });
        expect(container).toHaveAttribute('aria-label', 'Loading content');
    });

    it('renders table skeleton with custom rows', () => {
        render(<LoadingSkeleton type="table" rows={3} />);

        const container = screen.getByRole('generic', { busy: true });
        expect(container).toHaveAttribute('aria-label', 'Loading table');
    });

    it('renders form skeleton', () => {
        render(<LoadingSkeleton type="form" />);

        const container = screen.getByRole('generic', { busy: true });
        expect(container).toHaveAttribute('aria-label', 'Loading form');
    });

    it('renders card skeleton with custom count', () => {
        render(<LoadingSkeleton type="card" cards={4} />);

        const container = screen.getByRole('generic', { busy: true });
        expect(container).toHaveAttribute('aria-label', 'Loading cards');
    });

    it('renders default skeleton for unknown type', () => {
        render(<LoadingSkeleton />);

        const container = screen.getByRole('generic', { busy: true });
        expect(container).toBeInTheDocument();
    });
});
