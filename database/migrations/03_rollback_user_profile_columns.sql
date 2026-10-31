-- =============================================================================
-- Migration Rollback: 03_rollback_user_profile_columns.sql
-- Mô tả: Hoàn tác các cột hồ sơ cá nhân: avatar_url, phone, birth_date
-- =============================================================================

BEGIN;

ALTER TABLE users DROP COLUMN IF EXISTS avatar_url;
ALTER TABLE users DROP COLUMN IF EXISTS phone;
ALTER TABLE users DROP COLUMN IF EXISTS birth_date;

COMMIT;
