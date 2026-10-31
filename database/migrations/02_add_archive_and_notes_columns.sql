-- =============================================================================
-- Migration: 02_add_archive_and_notes_columns.sql
-- Mô tả: Thêm các cột còn thiếu theo schema: archive_at, archive_notice cho courses,
--        is_active cho lessons, user_note cho lesson_progress
-- =============================================================================

BEGIN;

ALTER TABLE courses ADD COLUMN IF NOT EXISTS archive_at timestamptz;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS archive_notice text;
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true;
ALTER TABLE lesson_progress ADD COLUMN IF NOT EXISTS user_note text;

COMMIT;
