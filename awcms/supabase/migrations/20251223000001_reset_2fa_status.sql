-- Migration: Reset 2FA Status for All Users
-- Reason: To resolve potential lockout/sync issues during system overhaul.

BEGIN;

-- 1. Disable 2FA for all users
UPDATE two_factor_auth
SET enabled = false,
    updated_at = NOW();

-- 2. Log the administrative action (Optional but recommended)
-- Assuming we have an audit log table or just rely on the updated_at timestamp.
-- We can add a note if there's an audit table. For now, the update is sufficient.

COMMIT;
