-- =============================================================================
-- Migration: 03_add_user_profile_columns.sql
-- Mô tả: Thêm các cột phục vụ thông tin cá nhân (Profile): avatar_url, phone, birth_date
-- =============================================================================

BEGIN;

ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url varchar(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone varchar(20);
ALTER TABLE users ADD COLUMN IF NOT EXISTS birth_date date;

COMMIT;
