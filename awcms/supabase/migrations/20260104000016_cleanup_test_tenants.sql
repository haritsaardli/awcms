-- Migration: 20260104000016_cleanup_test_tenants.sql
-- Description: Delete all tenants except the primary one to clean up test data.

DELETE FROM tenants 
WHERE slug != 'primary';
